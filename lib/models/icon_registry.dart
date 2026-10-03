import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ICON REGISTRY — Maps icons to stable names for storage in the database
// ─────────────────────────────────────────────────────────────────────────────

const Map<String, IconData> iconRegistry = {
  'target': LucideIcons.target,
  'moon': LucideIcons.moon,
  'book': LucideIcons.book,
  'bookOpen': LucideIcons.bookOpen,
  'activity': LucideIcons.activity,
  'shoppingCart': LucideIcons.shoppingCart,
  'map': LucideIcons.map,
  'gift': LucideIcons.gift,
  'home': LucideIcons.home,
  'briefcase': LucideIcons.briefcase,
  'heart': LucideIcons.heart,
  'star': LucideIcons.star,
  'music': LucideIcons.music,
};

IconData iconFromName(String? name, {IconData fallback = LucideIcons.target}) =>
    iconRegistry[name] ?? fallback;

String iconToName(IconData icon) {
  for (final entry in iconRegistry.entries) {
    if (entry.value == icon) return entry.key;
  }
  return 'target';
}
