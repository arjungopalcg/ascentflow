import 'package:flutter/material.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text('Friends', style: AppTypography.heading1.copyWith(color: colors.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.userPlus, color: colors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 5, // Mock data
        separatorBuilder: (_, _) => Divider(color: colors.surface3, height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(LucideIcons.user, color: Colors.white),
            ),
            title: Text('Friend ${index + 1}', style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary)),
            subtitle: Text('LVL ${5 + index} • Focused', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
            trailing: _buildRankBadge(colors, index + 1),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          );
        },
      ),
    );
  }

  Widget _buildRankBadge(AppColorsExtension colors, int rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface3,
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text('#$rank', style: AppTypography.label.copyWith(color: colors.textSecondary)),
    );
  }
}
