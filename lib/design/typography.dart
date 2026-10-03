import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ASCENT FLOW — TYPOGRAPHY
// Two typefaces: Sora (display/headings) + Inter (body/UI)
// ─────────────────────────────────────────────────────────────────────────────

class AppTypography {
  AppTypography._();

  // ── Sora — Display & Headings ────────────────────────────────────────

  static TextStyle get displayXl => GoogleFonts.sora(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.1,
      );

  static TextStyle get display => GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );

  static TextStyle get heading1 => GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  static TextStyle get heading2 => GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get heading3 => GoogleFonts.sora(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  // ── Inter — Body & UI ───────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  /// Tracked-caps eyebrow label — the editorial signature element.
  /// Usage: section headers like "TASKS · TODAY", "YOUR STREAKS", etc.
  static TextStyle get eyebrow => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 1.8,
      );
}
