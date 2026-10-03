import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ASCENT FLOW — TYPOGRAPHY
// One family in two widths, borrowed from trail and highway signage:
// Barlow Condensed for headings and numbers (time, altitude, counts) and
// Barlow for reading. Numbers use tabular figures so they don't jitter.
// ─────────────────────────────────────────────────────────────────────────────

class AppTypography {
  AppTypography._();

  static const _tabular = [FontFeature.tabularFigures()];

  // ── Barlow Condensed — Display & Headings ────────────────────────────

  static TextStyle get displayXl => GoogleFonts.barlowCondensed(
        fontSize: 64,
        fontWeight: FontWeight.w500,
        height: 1.0,
        fontFeatures: _tabular,
      );

  static TextStyle get display => GoogleFonts.barlowCondensed(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.1,
      );

  static TextStyle get heading1 => GoogleFonts.barlowCondensed(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.15,
      );

  static TextStyle get heading2 => GoogleFonts.barlowCondensed(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get heading3 => GoogleFonts.barlow(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  // ── Barlow — Body & UI ───────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.barlow(
        fontSize: 16.5,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get body => GoogleFonts.barlow(
        fontSize: 15.5,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get label => GoogleFonts.barlow(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        height: 1.35,
      );

  static TextStyle get caption => GoogleFonts.barlow(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.35,
      );

  /// Section heading inside a screen ("Today's plan") — condensed, sentence
  /// case, sized to read as a heading rather than a tag above one.
  static TextStyle get eyebrow => GoogleFonts.barlowCondensed(
        fontSize: 19,
        fontWeight: FontWeight.w600,
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
