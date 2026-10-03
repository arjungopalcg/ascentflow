import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';
import 'typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ASCENT FLOW — THEME EXTENSION
// Dual-theme system: Light ("Fresh snow") + Dark ("Night sky")
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
    required this.summit,
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

  /// Alpenglow — reserved for achievements (XP, streaks, summits).
  final Color summit;
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
    summit: AppColors.summitDark,
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
    summit: AppColors.summitLight,
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
        color: AppColors.lightShadow,
        blurRadius: 3,
        offset: Offset(0, 1),
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
    Color? summit,
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
      summit: summit ?? this.summit,
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
      summit: Color.lerp(summit, other.summit, t)!,
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

ThemeData buildDarkTheme() => _buildTheme(AppColorsExtension.dark);

ThemeData buildLightTheme() => _buildTheme(AppColorsExtension.light);

ThemeData _buildTheme(AppColorsExtension c) {
  final brightness = c.isDark ? Brightness.dark : Brightness.light;
  final onPrimary = c.isDark ? AppColors.darkBg : Colors.white;
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
    bodyColor: c.textPrimary,
    displayColor: c.textPrimary,
  );

  return base.copyWith(
    scaffoldBackgroundColor: c.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
    ).copyWith(
      primary: c.primary,
      onPrimary: onPrimary,
      secondary: c.mint,
      surface: c.surface1,
      onSurface: c.textPrimary,
      error: c.danger,
      outline: c.border,
    ),
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.heading1.copyWith(color: c.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: c.surface1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusMd,
        side: BorderSide(color: c.border),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface1,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: c.surface3,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.textPrimary,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.background),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: c.textTertiary),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? onPrimary : c.textTertiary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.primary : c.surface2,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.primary : c.border,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: c.primary,
      foregroundColor: onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primary,
      linearTrackColor: c.surface2,
      circularTrackColor: c.surface2,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.primary,
      selectionColor: c.primary.withValues(alpha: 0.25),
      selectionHandleColor: c.primary,
    ),
    extensions: [c],
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
