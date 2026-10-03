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

  // A calm, warm palette — paper and ink with one quiet green accent.
  // Solid surfaces, no glows. Colour is reserved for meaning.

  // ── Dark Theme — "Evening" (warm charcoal, never blue-black) ─────────
  static const Color darkBg = Color(0xFF191816);
  static const Color darkSurface1 = Color(0xFF211F1C);
  static const Color darkSurface2 = Color(0xFF2A2825);
  static const Color darkSurface3 = Color(0xFF35322E);
  static const Color darkSurface4 = Color(0xFF403C37);

  static const Color darkTextPrimary = Color(0xFFEFEBE4);
  static const Color darkTextSecondary = Color(0xFFADA79D);
  static const Color darkTextTertiary = Color(0xFF7A746B);
  static const Color darkBorder = Color(0xFF34312C);

  // ── Light Theme — "Paper" ────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF5F2EC);
  static const Color lightSurface1 = Color(0xFFFFFDF9);
  static const Color lightSurface2 = Color(0xFFEFEBE3);
  static const Color lightSurface3 = Color(0xFFE4DFD5);

  static const Color lightTextPrimary = Color(0xFF26231F);
  static const Color lightTextSecondary = Color(0xFF68625A);
  static const Color lightTextTertiary = Color(0xFF9C958A);
  static const Color lightBorder = Color(0xFFE3DED4);
  static const Color lightShadow = Color(0x0F26231F);

  // ── Accent — forest green ────────────────────────────────────────────
  static const Color primaryDark = Color(0xFF8CC3A7);
  static const Color primaryLight = Color(0xFF2F6B55);
  // Kept for API compatibility; glows are intentionally switched off.
  static const Color primaryGlowDark = Color(0x00000000);
  static const Color primaryGlowLight = Color(0x00000000);
  static const Color primaryLighter = Color(0xFFDCEBE2);

  // ── Semantic colours (muted, earthy) ─────────────────────────────────
  static const Color mint = Color(0xFF8FBF8F); // success — sage
  static const Color mintLight = Color(0xFF4F7F55);
  static const Color amber = Color(0xFFE0B061); // attention — ochre
  static const Color amberLight = Color(0xFF9A6A1C);
  static const Color danger = Color(0xFFE08A7A); // urgent — brick
  static const Color dangerLight = Color(0xFFA9473A);
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
  static const double lg = 20;
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
