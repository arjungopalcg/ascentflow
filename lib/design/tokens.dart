import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ASCENT FLOW — DESIGN TOKENS
// All design constants. Import this file everywhere. Never hardcode values.
// ─────────────────────────────────────────────────────────────────────────────

// ═══════════════════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // "Alpine ascent" — the day as a climb. Cool snowfield and granite,
  // lake-blue for action, and alpenglow reserved for wins.

  // ── Dark Theme — "Night climb" (blue slate, never near-black) ───────
  static const Color darkBg = Color(0xFF16212A);
  static const Color darkSurface1 = Color(0xFF1D2A34);
  static const Color darkSurface2 = Color(0xFF253540);
  static const Color darkSurface3 = Color(0xFF30424E);
  static const Color darkSurface4 = Color(0xFF3B4F5C);

  static const Color darkTextPrimary = Color(0xFFE6EDF1);
  static const Color darkTextSecondary = Color(0xFFA3B3BD);
  static const Color darkTextTertiary = Color(0xFF718592);
  static const Color darkBorder = Color(0xFF2C3C47);

  // ── Light Theme — "Snowfield" ────────────────────────────────────────
  static const Color lightBg = Color(0xFFEDF1F3);
  static const Color lightSurface1 = Color(0xFFFAFCFD);
  static const Color lightSurface2 = Color(0xFFE2E8EB);
  static const Color lightSurface3 = Color(0xFFD3DCE1);

  static const Color lightTextPrimary = Color(0xFF1E2A32);
  static const Color lightTextSecondary = Color(0xFF52626C);
  static const Color lightTextTertiary = Color(0xFF7F8F9A);
  static const Color lightBorder = Color(0xFFD6DEE3);
  static const Color lightShadow = Color(0x141E2A32);

  // ── Lake — primary action ────────────────────────────────────────────
  static const Color primaryDark = Color(0xFF7FB6CF);
  static const Color primaryLight = Color(0xFF1F5F7A);
  // Kept for API compatibility; glows are intentionally switched off.
  static const Color primaryGlowDark = Color(0x00000000);
  static const Color primaryGlowLight = Color(0x00000000);
  static const Color primaryLighter = Color(0xFFD5E6EE);

  // ── Alpenglow — achievements only (XP, streaks, summits) ─────────────
  static const Color summitDark = Color(0xFFF08A97);
  static const Color summitLight = Color(0xFFD45568);

  // ── Semantic ─────────────────────────────────────────────────────────
  static const Color mint = Color(0xFF8DBB8C); // done — moss
  static const Color mintLight = Color(0xFF4F7D52);
  static const Color amber = Color(0xFFE2B062); // attention — larch
  static const Color amberLight = Color(0xFFA06E16);
  static const Color danger = Color(0xFFE58A80); // urgent — rust
  static const Color dangerLight = Color(0xFFB4443C);
}

// ═══════════════════════════════════════════════════════════════════════════
// CATEGORY COLOURS — identity for calendar types, savings goals, goal rings.
// One set for both themes. Validated with the dataviz skill's palette checker
// (lightness band, chroma, colour-blind separation, contrast) against both the
// Snowfield and Night-climb surfaces. Assign in this order; never generate more.
// ═══════════════════════════════════════════════════════════════════════════

class AppCategoryColors {
  AppCategoryColors._();

  static const Color lake = Color(0xFF3A82D0);
  static const Color alpenglow = Color(0xFFDB6840);
  static const Color glacier = Color(0xFF1FA48A);
  static const Color larch = Color(0xFFBB850E);
  static const Color gentian = Color(0xFF7A62D0);
  static const Color rose = Color(0xFFC9558A);

  static const List<Color> ordered = [lake, alpenglow, glacier, larch, gentian, rose];
}

// ═══════════════════════════════════════════════════════════════════════════
// SPACING — 4pt base grid
// ═══════════════════════════════════════════════════════════════════════════

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

// ═══════════════════════════════════════════════════════════════════════════
// RADIUS
// ═══════════════════════════════════════════════════════════════════════════

class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 22;
  static const double pill = 999;

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusPill = BorderRadius.all(Radius.circular(pill));
}

// ═══════════════════════════════════════════════════════════════════════════
// DURATIONS
// ═══════════════════════════════════════════════════════════════════════════

class AppDuration {
  AppDuration._();

  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration xSlow = Duration(milliseconds: 400);
  static const Duration pageLoad = Duration(milliseconds: 500);
  static const Duration celebration = Duration(milliseconds: 600);
  static const Duration chart = Duration(milliseconds: 800);
}

// ═══════════════════════════════════════════════════════════════════════════
// CURVES
// ═══════════════════════════════════════════════════════════════════════════

class AppCurves {
  AppCurves._();

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve easeInCubic = Curves.easeInCubic;
  static const Curve easeOutBack = Curves.easeOutBack;

  // Spring curves for interactive elements
  static const SpringDescription buttonSpring = SpringDescription(
    mass: 1.0,
    stiffness: 400,
    damping: 20,
  );

  static const SpringDescription chipSpring = SpringDescription(
    mass: 1.0,
    stiffness: 380,
    damping: 18,
  );

  static const SpringDescription fabSpring = SpringDescription(
    mass: 1.0,
    stiffness: 420,
    damping: 20,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATION STAGGER
// ═══════════════════════════════════════════════════════════════════════════

class AppStagger {
  AppStagger._();

  static const Duration widgetDelay = Duration(milliseconds: 60);
  static const Duration cardDelay = Duration(milliseconds: 40);
  static const Duration chipDelay = Duration(milliseconds: 50);
  static const Duration highlightDelay = Duration(milliseconds: 80);
  static const Duration heatmapDelay = Duration(milliseconds: 10);
}
