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
          width: 2,
        ),
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
// PLAIN SECTION — Content set directly on the page, divided by a hairline.
// Use for read-mostly groups so not everything becomes a card.
// ─────────────────────────────────────────────────────────────────────────────

class PlainSection extends StatelessWidget {
  const PlainSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIER 2 — ELEVATED CARD
// A touch more presence than a surface card. For menus, featured content.
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
        color: colors.surface1,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: colors.border, width: 2),
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
// Historically a blur panel; now a calm solid surface for overlays.
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

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: radius,
        border: Border.all(color: colors.border, width: 1),
      ),
      child: child,
    );
  }
}
