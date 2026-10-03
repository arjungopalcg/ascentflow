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
  final VoidCallback onTap;
  final PillButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  @override
  State<PillButton> createState() => _PillButtonState();
}

enum PillButtonVariant { primary, secondary, destructive }

class _PillButtonState extends State<PillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
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
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          decoration: _buildDecoration(colors),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 18,
                  color: _textColor(colors),
                ),
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
                Text(
                  widget.label,
                  style: AppTypography.label.copyWith(
                    color: _textColor(colors),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(AppColorsExtension colors) {
    switch (widget.variant) {
      case PillButtonVariant.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              colors.primary.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: AppRadius.borderRadiusPill,
          boxShadow: colors.isDark
              ? [
                  BoxShadow(
                    color: colors.primaryGlow,
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        );
      case PillButtonVariant.secondary:
        return BoxDecoration(
          color: colors.isDark
              ? Colors.transparent
              : colors.primary.withValues(alpha: 0.06),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        );
      case PillButtonVariant.destructive:
        return BoxDecoration(
          color: colors.danger,
          borderRadius: AppRadius.borderRadiusPill,
        );
    }
  }

  Color _textColor(AppColorsExtension colors) {
    switch (widget.variant) {
      case PillButtonVariant.primary:
      case PillButtonVariant.destructive:
        return Colors.white;
      case PillButtonVariant.secondary:
        return colors.primary;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class AppFab extends StatefulWidget {
  const AppFab({
    super.key,
    required this.onTap,
    this.icon = Icons.add,
  });

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
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
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
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: colors.isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, Color(0xFF5B3EC9)],
                  )
                : null,
            color: colors.isDark ? null : colors.primary,
            boxShadow: [
              BoxShadow(
                color: colors.isDark
                    ? colors.primaryGlow
                    : colors.primary.withValues(alpha: 0.25),
                blurRadius: colors.isDark ? 32 : 20,
                offset: Offset(0, colors.isDark ? 8 : 6),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
