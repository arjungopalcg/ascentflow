import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';

class BadgesGalleryScreen extends StatelessWidget {
  const BadgesGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text('Summits', style: AppTypography.heading1.copyWith(color: colors.textPrimary)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl,
        ),
        itemCount: _summits.length,
        separatorBuilder: (_, _) => Divider(color: colors.border),
        itemBuilder: (context, index) {
          final (name, how, reached) = _summits[index];
          final tone = reached ? colors.summit : colors.textTertiary;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: reached
                        ? colors.summit.withValues(alpha: colors.isDark ? 0.18 : 0.12)
                        : colors.surface2,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Icon(
                    reached ? LucideIcons.mountainSnow : LucideIcons.mountain,
                    size: 22,
                    color: tone,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.heading2.copyWith(
                          color: reached ? colors.textPrimary : colors.textSecondary,
                        ),
                      ),
                      Text(
                        how,
                        style: AppTypography.caption.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (reached)
                  Icon(LucideIcons.check, size: 18, color: colors.summit),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Name, how to reach it, and whether it's been reached.
const _summits = [
  ('First steps', 'Finish your first task', true),
  ('Base camp', 'Plan out a whole day', true),
  ('Clear head', 'Complete a 25-minute focus session', true),
  ('A week on the trail', 'Show up seven days in a row', true),
  ('Steady pace', 'Write 30 journal entries', false),
  ('Deep focus', 'Focus for 10 hours in one week', false),
  ('Saver\'s ridge', 'Reach one of your savings goals', false),
  ('High camp', 'Reach Camp 10', false),
  ('The summit', 'Show up 100 days in a row', false),
];
