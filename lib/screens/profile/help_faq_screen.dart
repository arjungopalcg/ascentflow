import 'package:flutter/material.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text('Help & FAQs', style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        children: [
          _buildFaqItem(colors, 'How do I earn XP and level up?', 'You earn XP by completing tasks on your schedule, finishing focus sessions, and maintaining streaks. Check the Analytics screen for a detailed breakdown.'),
          const SizedBox(height: AppSpacing.md),
          _buildFaqItem(colors, 'Can I change the timer durations?', 'Yes! Head to the Focus screen. You can choose from presets like 15m or 25m, or use the Custom duration option to set any length up to 120 minutes.'),
          const SizedBox(height: AppSpacing.md),
          _buildFaqItem(colors, 'What is the App Blocker?', 'The App Blocker allows you to restrict access to distracting apps during a focus session. You can manage which apps are blocked in the settings menu on the Focus screen.'),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text('Contact Support Support', style: AppTypography.label.copyWith(color: colors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(AppColorsExtension colors, String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Text(answer, style: AppTypography.body.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }
}
