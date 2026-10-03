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
        title: Text('Badges Gallery', style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.lg,
          childAspectRatio: 0.8,
        ),
        itemCount: 9, // Example count
        itemBuilder: (context, index) {
          final isUnlocked = index < 4;
          return Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked ? colors.primary.withValues(alpha: 0.15) : colors.surface2,
                  border: Border.all(
                    color: isUnlocked ? colors.primary : colors.surface3,
                    width: isUnlocked ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isUnlocked ? LucideIcons.award : LucideIcons.lock,
                    size: 28,
                    color: isUnlocked ? colors.primary : colors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Badge ${index + 1}',
                style: AppTypography.caption.copyWith(
                  color: isUnlocked ? colors.textPrimary : colors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}
