import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ASCENT FLOW — TYPOGRAPHY
// Two typefaces: Fraunces (headings — a soft, warm serif, like a good
// notebook) + Figtree (body/UI — friendly and very legible at small sizes).
// Weights stay moderate; nothing shouts.
// ─────────────────────────────────────────────────────────────────────────────

class AppTypography {
  AppTypography._();

  // ── Fraunces — Display & Headings ────────────────────────────────────

  static TextStyle get displayXl => GoogleFonts.fraunces(
        fontSize: 44,
        fontWeight: FontWeight.w500,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle get display => GoogleFonts.fraunces(
        fontSize: 30,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get heading1 => GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.25,
      );

  static TextStyle get heading2 => GoogleFonts.fraunces(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  static TextStyle get heading3 => GoogleFonts.figtree(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  // ── Figtree — Body & UI ──────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.figtree(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.45,
      );

  static TextStyle get body => GoogleFonts.figtree(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get label => GoogleFonts.figtree(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.figtree(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  /// Quiet section header in sentence case ("Today's plan").
  static TextStyle get eyebrow => GoogleFonts.figtree(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );
}

/// "TODAY'S PROGRESS" → "Today's progress". Leaves mixed-case text alone.
String sentenceCase(String text) {
  if (text.isEmpty || text != text.toUpperCase()) return text;
  final lower = text.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}
