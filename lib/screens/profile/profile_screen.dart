import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../game/climb_engine.dart';
import '../../providers/prefs_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/analytics.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/buttons.dart';
import '../analytics/analytics_screen.dart';

import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'theme_appearance_screen.dart';
import 'badges_gallery_screen.dart';
import 'friends_screen.dart';
import 'help_faq_screen.dart';
import 'app_tour_screen.dart';
import 'widget_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userProfileProvider.select((p) => p.name));
    final climb = ref.watch(climbProvider);
    final n = NumberFormat.decimalPattern();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          'Profile',
          style: AppTypography.heading1.copyWith(color: colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            // Avatar Row
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: 0.15),
                    border: Border.all(color: colors.primary, width: 2),
                  ),
                  child: Icon(
                    LucideIcons.user,
                    size: 40,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Your profile' : name,
                        style: AppTypography.heading2.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppChip(
                        label: 'Camp ${climb.camp}',
                        variant: ChipVariant.summit,
                        icon: LucideIcons.mountain,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // XP shown as altitude: every XP point is a metre climbed.
            const EyebrowLabel('Altitude'),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${n.format(climb.altitude)} m',
                  style: AppTypography.displayXl.copyWith(
                    color: colors.textPrimary,
                    fontSize: 52,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    '${climb.metresToNextCamp} m to Camp ${climb.camp + 1}',
                    style: AppTypography.label.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.borderRadiusPill,
              child: LinearProgressIndicator(
                value: climb.campProgress,
                minHeight: 6,
                backgroundColor: colors.surface2,
                valueColor: AlwaysStoppedAnimation(colors.summit),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'You gain altitude by finishing tasks, focus sessions and journal entries.',
              style: AppTypography.caption.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Menu Sections
            _MenuSection(
              title: 'Settings & Profile',
              items: [
                _MenuItemData(
                  icon: LucideIcons.userCog,
                  label: 'Edit Profile',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                ),
                _MenuItemData(
                  icon: LucideIcons.layoutGrid,
                  label: 'Edit home screen',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WidgetSettingsScreen(),
                    ),
                  ),
                ),
                _MenuItemData(
                  icon: LucideIcons.bellRing,
                  label: 'Notifications',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
                _MenuItemData(
                  icon: LucideIcons.palette,
                  label: 'Theme & Appearance',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ThemeAppearanceScreen(),
                    ),
                  ),
                ),
              ],
              colors: colors,
            ),

            _MenuSection(
              title: 'Insights & Social',
              items: [
                _MenuItemData(
                  icon: LucideIcons.barChart2,
                  label: 'Full Analytics',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnalyticsScreen(),
                      ),
                    );
                  },
                ),
                _MenuItemData(
                  icon: LucideIcons.mountainSnow,
                  label: 'Summits',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BadgesGalleryScreen(),
                    ),
                  ),
                ),
                _MenuItemData(
                  icon: LucideIcons.users,
                  label: 'Friends',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FriendsScreen()),
                  ),
                ),
              ],
              colors: colors,
            ),

            _MenuSection(
              title: 'Support',
              items: [
                _MenuItemData(
                  icon: LucideIcons.shieldCheck,
                  label: 'Privacy',
                  onTap: () => _showPrivacySheet(context, ref),
                ),
                _MenuItemData(
                  icon: LucideIcons.helpCircle,
                  label: 'Help & FAQs',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpFaqScreen()),
                  ),
                ),
                _MenuItemData(
                  icon: LucideIcons.compass,
                  label: 'App Tour',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppTourScreen()),
                  ),
                ),
                _MenuItemData(
                  icon: LucideIcons.logOut,
                  label: 'Log Out',
                  isDestructive: true,
                ),
              ],
              colors: colors,
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  _MenuItemData({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.title,
    required this.items,
    required this.colors,
  });

  final String title;
  final List<_MenuItemData> items;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        EyebrowLabel(title),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: AppRadius.borderRadiusLg,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: item.isDestructive
                          ? colors.danger
                          : colors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      item.label,
                      style: AppTypography.body.copyWith(
                        color: item.isDestructive
                            ? colors.danger
                            : colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: item.isDestructive
                        ? null
                        : Icon(
                            LucideIcons.chevronRight,
                            size: 16,
                            color: colors.textTertiary,
                          ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (item.onTap != null) {
                        item.onTap!();
                      } else if (item.isDestructive) {
                        _showLogoutDialog(context, colors);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: isLast
                          ? const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            )
                          : index == 0
                          ? const BorderRadius.vertical(
                              top: Radius.circular(16),
                            )
                          : BorderRadius.zero,
                    ),
                  ),
                  if (!isLast)
                    Divider(height: 1, color: colors.border, indent: 56),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AppColorsExtension colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface1,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
        title: Text(
          'Log Out',
          style: AppTypography.heading3.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to log out of Ascent Flow?',
          style: AppTypography.body.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
          ),
          PillButton(
            label: 'Log Out',
            variant: PillButtonVariant.destructive,
            onTap: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
          ),
        ],
      ),
    );
  }
}

/// Lets people turn usage analytics off.
void _showPrivacySheet(BuildContext context, WidgetRef ref) {
  final prefs = ref.read(sharedPrefsProvider);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final colors = ctx.colors;
      return StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy', style: AppTypography.heading1.copyWith(color: colors.textPrimary)),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: Analytics.enabled,
                  onChanged: (on) async {
                    await Analytics.setEnabled(prefs, on);
                    setSheetState(() {});
                  },
                  title: Text('Share usage data', style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
                  subtitle: Text(
                    'Anonymous info about which features you use helps us make AscentFlow better. '
                    'We never send your tasks, journal or names, and screen recordings hide all text.',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
