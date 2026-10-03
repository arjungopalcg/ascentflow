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

  // ── Dark Theme — "Midnight Studio" ───────────────────────────────────
  static const Color darkBg = Color(0xFF0A0A12);
  static const Color darkSurface1 = Color(0xFF13152A);
  static const Color darkSurface2 = Color(0xFF1C1E35);
  static const Color darkSurface3 = Color(0xFF23264A);
  static const Color darkSurface4 = Color(0xFF2A2E58);

  static const Color darkTextPrimary = Color(0xFFF0EEFF);
  static const Color darkTextSecondary = Color(0xFF8B8FAD);
  static const Color darkTextTertiary = Color(0xFF4A4E6B);
  static const Color darkBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // ── Light Theme — "Morning Clarity" ──────────────────────────────────
  static const Color lightBg = Color(0xFFF8F9FE);
  static const Color lightSurface1 = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF1F3FF);
  static const Color lightSurface3 = Color(0xFFE8EBFF);

  static const Color lightTextPrimary = Color(0xFF1E1B4B);
  static const Color lightTextSecondary = Color(0xFF63627E);
  static const Color lightTextTertiary = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0x0F000000); // rgba(0,0,0,0.06)
  static const Color lightShadow = Color(0x146366F1); // rgba(99,102,241,0.08)

  // ── Shared Accent Colors ─────────────────────────────────────────────
  static const Color primaryDark = Color(0xFF7C5CE4);
  static const Color primaryLight = Color(0xFF6B4ED9);
  static const Color primaryGlowDark = Color(0x4D7C5CE4); // rgba(124,92,228,0.3)
  static const Color primaryGlowLight = Color(0x336B4ED9); // rgba(107,78,217,0.2)
  static const Color primaryLighter = Color(0xFFA78DF5);

  static const Color mint = Color(0xFF00C9A7);
  static const Color mintLight = Color(0xFF00A88B);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFD97706);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFDC2626);
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
  static const double sm = 14;
  static const double md = 20;
  static const double lg = 28;
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
