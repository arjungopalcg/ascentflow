import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../main.dart'; // To access themeModeProvider

class ThemeAppearanceScreen extends ConsumerStatefulWidget {
  const ThemeAppearanceScreen({super.key});

  @override
  ConsumerState<ThemeAppearanceScreen> createState() => _ThemeAppearanceScreenState();
}

class _ThemeAppearanceScreenState extends ConsumerState<ThemeAppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentMode = ref.watch(themeModeProvider);
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text('Theme & Appearance', style: AppTypography.heading1.copyWith(color: colors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _buildThemeOption(colors, 'System Default', LucideIcons.smartphone, ThemeMode.system, currentMode),
          Divider(color: colors.surface3, height: 1),
          _buildThemeOption(colors, 'Light Mode', LucideIcons.sun, ThemeMode.light, currentMode),
          Divider(color: colors.surface3, height: 1),
          _buildThemeOption(colors, 'Dark Mode', LucideIcons.moon, ThemeMode.dark, currentMode),
        ],
      ),
    );
  }

  Widget _buildThemeOption(AppColorsExtension colors, String title, IconData icon, ThemeMode mode, ThemeMode currentMode) {
    final isSelected = currentMode == mode;
    
    return ListTile(
      leading: Icon(icon, color: isSelected ? colors.primary : colors.textSecondary, size: 24),
      title: Text(title, style: AppTypography.bodyLarge.copyWith(
        color: isSelected ? colors.primary : colors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      )),
      trailing: isSelected 
          ? Icon(LucideIcons.check, color: colors.primary, size: 20)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
    );
  }
}
