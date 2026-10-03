import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PRIMARY PILL BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = PillButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  final String label;

  /// Null disables the button (shown faded, ignores taps).
  final VoidCallback? onTap;
  final PillButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  @override
  State<PillButton> createState() => _PillButtonState();
}

enum PillButtonVariant { primary, secondary, destructive }

class _PillButtonState extends State<PillButton> {
  // Chunky, tactile button: a darker "edge" sits under the face; pressing
  // pushes the face down onto it, like a physical key.
  static const _edge = 4.0;
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  static Color _darken(Color c, double by) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - by).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = widget.onTap != null;
    final (face, edge, border) = switch (widget.variant) {
      PillButtonVariant.primary => (colors.primary, _darken(colors.primary, 0.12), null),
      PillButtonVariant.destructive => (colors.danger, _darken(colors.danger, 0.14), null),
      PillButtonVariant.secondary => (colors.surface1, colors.border, colors.border),
    };
    final radius = AppRadius.borderRadiusMd;

    return Semantics(
      button: true,
      enabled: enabled,
      child: AnimatedOpacity(
        duration: AppDuration.fast,
        opacity: enabled ? 1 : 0.4,
        child: GestureDetector(
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled
              ? (_) {
                  _setPressed(false);
                  HapticFeedback.lightImpact();
                  widget.onTap!();
                }
              : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          child: Padding(
            padding: EdgeInsets.only(top: _pressed ? _edge : 0),
            child: Container(
              decoration: BoxDecoration(color: edge, borderRadius: radius),
              padding: EdgeInsets.only(bottom: _pressed ? 0 : _edge),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 28),
                decoration: BoxDecoration(
                  color: face,
                  borderRadius: radius,
                  border: border == null ? null : Border.all(color: border, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 19, color: _textColor(colors)),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    if (widget.isLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _textColor(colors),
                        ),
                      )
                    else
                      Flexible(
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: AppTypography.heading3.copyWith(
                            color: _textColor(colors),
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _textColor(AppColorsExtension colors) {
    switch (widget.variant) {
      case PillButtonVariant.primary:
      case PillButtonVariant.destructive:
        return colors.isDark ? AppColors.darkBg : Colors.white;
      case PillButtonVariant.secondary:
        return colors.textPrimary;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class AppFab extends StatefulWidget {
  const AppFab({super.key, required this.onTap, this.icon = Icons.add});

  final VoidCallback onTap;
  final IconData icon;

  @override
  State<AppFab> createState() => _AppFabState();
}

class _AppFabState extends State<AppFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderRadiusLg,
            color: colors.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: colors.isDark ? 0.3 : 0.12,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: colors.isDark ? AppColors.darkBg : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
