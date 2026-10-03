import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ASCENT FLOW — TYPOGRAPHY
// Playful and chunky: Baloo 2 for headings and big numbers (round, heavy,
// friendly), Nunito for everything you read (rounded terminals, very legible).
// Numbers use tabular figures so counters don't jitter.
// ─────────────────────────────────────────────────────────────────────────────

class AppTypography {
  AppTypography._();

  static const _tabular = [FontFeature.tabularFigures()];

  // ── Baloo 2 — Display & Headings ─────────────────────────────────────

  static TextStyle get displayXl => GoogleFonts.baloo2(
        fontSize: 60,
        fontWeight: FontWeight.w800,
        height: 1.0,
        fontFeatures: _tabular,
      );

  static TextStyle get display => GoogleFonts.baloo2(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.1,
      );

  static TextStyle get heading1 => GoogleFonts.baloo2(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        height: 1.15,
      );

  static TextStyle get heading2 => GoogleFonts.baloo2(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get heading3 => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        height: 1.3,
      );

  // ── Nunito — Body & UI ───────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16.5,
        fontWeight: FontWeight.w700,
        height: 1.4,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        height: 1.45,
      );

  static TextStyle get label => GoogleFonts.nunito(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        height: 1.35,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  /// Section heading inside a screen ("Today's plan").
  static TextStyle get eyebrow => GoogleFonts.baloo2(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );
}

const _acronyms = {'ai': 'AI', 'xp': 'XP', 'faq': 'FAQ', 'faqs': 'FAQs'};

/// "TODAY'S PROGRESS" → "Today's progress"; "AI INSIGHTS" → "AI insights".
/// Leaves mixed-case text alone.
String sentenceCase(String text) {
  if (text.isEmpty || text != text.toUpperCase()) return text;
  final words = text.toLowerCase().split(' ').map((w) => _acronyms[w] ?? w);
  final lower = words.join(' ');
  return lower[0].toUpperCase() + lower.substring(1);
}
