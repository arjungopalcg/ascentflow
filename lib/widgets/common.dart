import 'dart:async';
import 'package:flutter/material.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP CHIP — 5 semantic variants
// ─────────────────────────────────────────────────────────────────────────────

enum ChipVariant { violet, mint, amber, danger, gray }

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.variant = ChipVariant.violet,
    this.onTap,
    this.icon,
  });

  final String label;
  final ChipVariant variant;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chipColors = _resolveColors(colors);

    final chip = Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: chipColors.bg,
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(color: chipColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: chipColors.text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.eyebrow.copyWith(
              color: chipColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }
    return chip;
  }

  _ChipColors _resolveColors(AppColorsExtension c) {
    switch (variant) {
      case ChipVariant.violet:
        return _ChipColors(
          bg: c.isDark
              ? const Color(0x337C5CE4)
              : const Color(0x1A6B4ED9),
          border: c.isDark
              ? const Color(0x4D7C5CE4)
              : const Color(0x336B4ED9),
          text: AppColors.primaryLighter,
        );
      case ChipVariant.mint:
        return _ChipColors(
          bg: c.isDark
              ? const Color(0x2600C9A7)
              : const Color(0x1A00A88B),
          border: c.isDark
              ? const Color(0x4000C9A7)
              : const Color(0x3300A88B),
          text: AppColors.mint,
        );
      case ChipVariant.amber:
        return _ChipColors(
          bg: c.isDark
              ? const Color(0x26F59E0B)
              : const Color(0x1AD97706),
          border: c.isDark
              ? const Color(0x40F59E0B)
              : const Color(0x33D97706),
          text: AppColors.amber,
        );
      case ChipVariant.danger:
        return _ChipColors(
          bg: c.isDark
              ? const Color(0x26EF4444)
              : const Color(0x1ADC2626),
          border: c.isDark
              ? const Color(0x40EF4444)
              : const Color(0x33DC2626),
          text: AppColors.danger,
        );
      case ChipVariant.gray:
        return _ChipColors(
          bg: c.isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
          border: c.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          text: c.textSecondary,
        );
    }
  }
}

class _ChipColors {
  const _ChipColors({
    required this.bg,
    required this.border,
    required this.text,
  });
  final Color bg;
  final Color border;
  final Color text;
}

// ─────────────────────────────────────────────────────────────────────────────
// EYEBROW LABEL — Tracked-caps section header
// ─────────────────────────────────────────────────────────────────────────────

class EyebrowLabel extends StatelessWidget {
  const EyebrowLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      text.toUpperCase(),
      style: AppTypography.eyebrow.copyWith(
        color: color ?? colors.textSecondary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COUNT-UP TEXT — Animated number counter
// ─────────────────────────────────────────────────────────────────────────────

class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 600),
    this.suffix = '',
  });

  final double value;
  final TextStyle style;
  final Duration duration;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: AppCurves.easeOut,
      builder: (context, animatedValue, child) {
        return Text(
          '${animatedValue.toInt()}$suffix',
          style: style,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPEWRITER TEXT — Character-by-character reveal
// ─────────────────────────────────────────────────────────────────────────────

class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.charDelay = const Duration(milliseconds: 20),
    this.onComplete,
  });

  final String text;
  final TextStyle style;
  final Duration charDelay;
  final VoidCallback? onComplete;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.charDelay, (timer) {
      if (_charIndex < widget.text.length) {
        setState(() {
          _charIndex++;
          _displayedText = widget.text.substring(0, _charIndex);
        });
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayedText, style: widget.style);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER LOADER — Skeleton loading placeholder
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ?? AppRadius.borderRadiusXs,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: [
                colors.surface2,
                colors.surface3,
                colors.surface2,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// XP TOAST — Floating "+15 XP" notification
// ─────────────────────────────────────────────────────────────────────────────

class XpToast extends StatefulWidget {
  const XpToast({super.key, required this.xp});

  final int xp;

  @override
  State<XpToast> createState() => _XpToastState();
}

class _XpToastState extends State<XpToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideUp;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _slideUp = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 32.0, end: 0.0)
            .chain(CurveTween(curve: AppCurves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 75,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -24.0)
            .chain(CurveTween(curve: AppCurves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 75,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 15,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideUp.value),
          child: Opacity(
            opacity: _opacity.value,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: AppRadius.borderRadiusPill,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primaryGlow,
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Text(
                '+${widget.xp} XP',
                style: AppTypography.bodyLarge.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
