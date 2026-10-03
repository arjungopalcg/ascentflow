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

  // "Playful alpine" — bright snow, pine-green action, sky-blue trail,
  // campfire orange for streaks and alpenglow pink for wins.

  // ── Dark Theme — "Night sky" ─────────────────────────────────────────
  static const Color darkBg = Color(0xFF13202A);
  static const Color darkSurface1 = Color(0xFF1B2B37);
  static const Color darkSurface2 = Color(0xFF233746);
  static const Color darkSurface3 = Color(0xFF2E4556);
  static const Color darkSurface4 = Color(0xFF3A5366);

  static const Color darkTextPrimary = Color(0xFFEEF4F8);
  static const Color darkTextSecondary = Color(0xFFA9BAC6);
  static const Color darkTextTertiary = Color(0xFF7A8EA0);
  static const Color darkBorder = Color(0xFF2A3D4B);

  // ── Light Theme — "Fresh snow" ───────────────────────────────────────
  static const Color lightBg = Color(0xFFF6F9FB);
  static const Color lightSurface1 = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFEAF1F5);
  static const Color lightSurface3 = Color(0xFFD9E4EB);

  static const Color lightTextPrimary = Color(0xFF1F2D38);
  static const Color lightTextSecondary = Color(0xFF566876);
  static const Color lightTextTertiary = Color(0xFF8495A2);
  static const Color lightBorder = Color(0xFFDCE5EB);
  static const Color lightShadow = Color(0x141F2D38);

  // ── Pine — primary action ────────────────────────────────────────────
  static const Color primaryDark = Color(0xFF4CC77E);
  static const Color primaryLight = Color(0xFF22A058);
  // Kept for API compatibility; glows are intentionally switched off.
  static const Color primaryGlowDark = Color(0x00000000);
  static const Color primaryGlowLight = Color(0x00000000);
  static const Color primaryLighter = Color(0xFFD6F2E1);

  // ── Sky — the trail and the mountain ─────────────────────────────────
  static const Color sky = Color(0xFF3A9BE0);
  static const Color skyDeep = Color(0xFF1F6FB0);
  static const Color skyNight = Color(0xFF1C4466);

  // ── Alpenglow — achievements only (XP, summits) ──────────────────────
  static const Color summitDark = Color(0xFFFF86A6);
  static const Color summitLight = Color(0xFFE5507A);

  // ── Campfire — streaks ───────────────────────────────────────────────
  static const Color campfire = Color(0xFFFF9433);
  static const Color campfireDeep = Color(0xFFE5651C);

  // ── Semantic ─────────────────────────────────────────────────────────
  static const Color mint = Color(0xFF4CC77E); // done
  static const Color mintLight = Color(0xFF22A058);
  static const Color amber = Color(0xFFFFB347); // attention
  static const Color amberLight = Color(0xFFC77700);
  static const Color danger = Color(0xFFFF7A7A); // urgent
  static const Color dangerLight = Color(0xFFD93F3F);
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

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
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
