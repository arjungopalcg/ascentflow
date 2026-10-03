import 'dart:ui';
import 'package:flutter/material.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TIER 1 — SOLID CARD
// Default card. Clean bordered surface with controlled shadow.
// ─────────────────────────────────────────────────────────────────────────────

class SolidCard extends StatelessWidget {
  const SolidCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
    this.leftAccentColor,
    this.leftAccentWidth = 3,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? leftAccentColor;
  final double leftAccentWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final card = Container(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: borderColor ?? colors.border,
          width: 1,
        ),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          if (leftAccentColor != null)
            Container(
              width: leftAccentWidth,
              color: leftAccentColor,
            ),
          Expanded(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIER 2 — ELEVATED CARD
// Elevated with glow/shadow. For More menu, featured content.
// ─────────────────────────────────────────────────────────────────────────────

class ElevatedCard extends StatelessWidget {
  const ElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: colors.isDark
              ? colors.primary.withValues(alpha: 0.2)
              : colors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          if (colors.isDark)
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.1),
              blurRadius: 24,
            )
          else
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIER 3 — GLASS CARD
// BackdropFilter blur. Use ONLY for: nav bar, modals, overlays.
// ─────────────────────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.blurSigma,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? blurSigma;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = borderRadius ?? AppRadius.borderRadiusMd;
    final sigma = blurSigma ?? (colors.isDark ? 16.0 : 12.0);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: radius,
              border: Border.all(
                color: colors.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : colors.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
