import 'dart:async';
import 'package:flutter/material.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP CHIP — 5 semantic variants
// ─────────────────────────────────────────────────────────────────────────────

/// `violet` is the primary (lake) accent; `summit` is alpenglow, for wins.
enum ChipVariant { violet, summit, mint, amber, danger, gray }

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
            style: AppTypography.caption.copyWith(
              color: chipColors.text,
              fontWeight: FontWeight.w600,
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
    // Soft tinted fill, no outline — colour carries meaning, not decoration.
    Color tint(Color base) => base.withValues(alpha: c.isDark ? 0.16 : 0.12);
    switch (variant) {
      case ChipVariant.violet:
        return _ChipColors(bg: tint(c.primary), border: Colors.transparent, text: c.primary);
      case ChipVariant.summit:
        return _ChipColors(bg: tint(c.summit), border: Colors.transparent, text: c.summit);
      case ChipVariant.mint:
        return _ChipColors(bg: tint(c.mint), border: Colors.transparent, text: c.mint);
      case ChipVariant.amber:
        return _ChipColors(bg: tint(c.amber), border: Colors.transparent, text: c.amber);
      case ChipVariant.danger:
        return _ChipColors(bg: tint(c.danger), border: Colors.transparent, text: c.danger);
      case ChipVariant.gray:
        return _ChipColors(bg: c.surface2, border: Colors.transparent, text: c.textSecondary);
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
// SECTION HEADING — Condensed, sentence case
// ─────────────────────────────────────────────────────────────────────────────

class EyebrowLabel extends StatelessWidget {
  const EyebrowLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      sentenceCase(text),
      style: AppTypography.eyebrow.copyWith(
        color: color ?? colors.textPrimary,
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

