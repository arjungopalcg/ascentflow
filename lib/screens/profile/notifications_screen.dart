import 'package:flutter/material.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _remindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text('Notifications', style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _buildSwitch(
            colors, 
            'Push Notifications', 
            'Get insights and weekly summaries on your device', 
            _pushEnabled, 
            (val) => setState(() => _pushEnabled = val),
          ),
          Divider(color: colors.surface3, height: 1),
          _buildSwitch(
            colors, 
            'Email Summaries', 
            'Receive a weekly breakdown of your progress by email', 
            _emailEnabled, 
            (val) => setState(() => _emailEnabled = val),
          ),
          Divider(color: colors.surface3, height: 1),
          _buildSwitch(
            colors, 
            'Daily Reminders', 
            'Morning prompt to plan your day', 
            _remindersEnabled, 
            (val) => setState(() => _remindersEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(AppColorsExtension colors, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary)),
      subtitle: Text(subtitle, style: AppTypography.body.copyWith(color: colors.textSecondary)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: colors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
    );
  }
}
