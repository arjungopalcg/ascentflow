import 'package:flutter/material.dart';
import 'tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ASCENT FLOW — THEME EXTENSION
// Dual-theme system: Dark ("Midnight Studio") + Light ("Morning Clarity")
// Resolve via: Theme.of(context).extension<AppColorsExtension>()!
// ─────────────────────────────────────────────────────────────────────────────

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.background,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.primary,
    required this.primaryGlow,
    required this.primaryLighter,
    required this.mint,
    required this.amber,
    required this.danger,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.shadow,
    required this.cardShadow,
    required this.isDark,
  });

  final Color background;
  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color primary;
  final Color primaryGlow;
  final Color primaryLighter;
  final Color mint;
  final Color amber;
  final Color danger;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color shadow;
  final List<BoxShadow> cardShadow;
  final bool isDark;

  // ── Dark Theme Instance ──────────────────────────────────────────────
  static const dark = AppColorsExtension(
    background: AppColors.darkBg,
    surface1: AppColors.darkSurface1,
    surface2: AppColors.darkSurface2,
    surface3: AppColors.darkSurface3,
    primary: AppColors.primaryDark,
    primaryGlow: AppColors.primaryGlowDark,
    primaryLighter: AppColors.primaryLighter,
    mint: AppColors.mint,
    amber: AppColors.amber,
    danger: AppColors.danger,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    border: AppColors.darkBorder,
    shadow: Colors.transparent,
    cardShadow: [],
    isDark: true,
  );

  // ── Light Theme Instance ─────────────────────────────────────────────
  static const light = AppColorsExtension(
    background: AppColors.lightBg,
    surface1: AppColors.lightSurface1,
    surface2: AppColors.lightSurface2,
    surface3: AppColors.lightSurface3,
    primary: AppColors.primaryLight,
    primaryGlow: AppColors.primaryGlowLight,
    primaryLighter: AppColors.primaryLighter,
    mint: AppColors.mintLight,
    amber: AppColors.amberLight,
    danger: AppColors.dangerLight,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    border: AppColors.lightBorder,
    shadow: AppColors.lightShadow,
    cardShadow: [
      BoxShadow(
        color: Color(0x146B4ED9), // rgba(107,78,217,0.08)
        blurRadius: 16,
        offset: Offset(0, 2),
      ),
    ],
    isDark: false,
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? background,
    Color? surface1,
    Color? surface2,
    Color? surface3,
    Color? primary,
    Color? primaryGlow,
    Color? primaryLighter,
    Color? mint,
    Color? amber,
    Color? danger,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? shadow,
    List<BoxShadow>? cardShadow,
    bool? isDark,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface1: surface1 ?? this.surface1,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      primary: primary ?? this.primary,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      primaryLighter: primaryLighter ?? this.primaryLighter,
      mint: mint ?? this.mint,
      amber: amber ?? this.amber,
      danger: danger ?? this.danger,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      cardShadow: cardShadow ?? this.cardShadow,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      primaryLighter: Color.lerp(primaryLighter, other.primaryLighter, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// THEME DATA BUILDERS
// ═══════════════════════════════════════════════════════════════════════════

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.mint,
      surface: AppColors.darkSurface1,
      error: AppColors.danger,
    ),
    extensions: const [AppColorsExtension.dark],
  );
}

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.mintLight,
      surface: AppColors.lightSurface1,
      error: AppColors.dangerLight,
    ),
    extensions: const [AppColorsExtension.light],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// CONVENIENCE EXTENSION ON BuildContext
// ═══════════════════════════════════════════════════════════════════════════

extension AppThemeContext on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;

  bool get isDark => colors.isDark;
}
