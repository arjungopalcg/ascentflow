import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/common.dart';
import '../profile/profile_screen.dart';
import '../goals/goals_screen.dart';
import '../chat/chat_screen.dart';
import '../planner/planner_screen.dart';
import '../lists/lists_screen.dart';
import '../savings/savings_screen.dart';
import '../calendar/calendar_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  static const _menuItems = [
    _MenuItem(icon: LucideIcons.target, title: 'Goals', subtitle: 'Track targets', color: AppColors.primaryDark),
    _MenuItem(icon: LucideIcons.messageSquare, title: 'AI Chat', subtitle: 'Your AI coach', color: AppColors.mint),
    _MenuItem(icon: LucideIcons.calendarCheck, title: 'Planner', subtitle: 'Daily planning', color: AppColors.amber),
    _MenuItem(icon: LucideIcons.list, title: 'My Lists', subtitle: 'Personal lists', color: AppColors.primaryLighter),
    _MenuItem(icon: LucideIcons.piggyBank, title: 'Savings', subtitle: 'Financial goals', color: AppColors.mint),
    _MenuItem(icon: LucideIcons.calendar, title: 'Calendar', subtitle: 'Unified view', color: AppColors.amber),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxl),

            // ── Header ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'More',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.display.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Profile pill
                Flexible(
                  child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: AppRadius.borderRadiusPill,
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary.withValues(alpha: 0.15),
                          ),
                          child: Icon(LucideIcons.user, size: 14, color: colors.primary),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            'Alex',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Icon(LucideIcons.chevronRight, size: 14, color: colors.textTertiary),
                      ],
                    ),
                  ),
                ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Tools Grid ──────────────────────────────────────
            const EyebrowLabel('Tools'),
            const SizedBox(height: AppSpacing.sm),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Tile height follows the text-size setting: fixed padding and
              // icon, plus the title and subtitle lines scaled by the user.
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisExtent: 100 + MediaQuery.textScalerOf(context).scale(44),
              ),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                return _AnimatedMenuCard(
                  item: _menuItems[index],
                  index: index,
                  controller: _staggerController,
                  colors: colors,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GoalsScreen()),
                      );
                    } else if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    } else if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlannerScreen()),
                      );
                    } else if (index == 3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ListsScreen()),
                      );
                    } else if (index == 4) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavingsScreen()),
                      );
                    } else if (index == 5) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarScreen()),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED MENU CARD — Staggered scale+fade entry
// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedMenuCard extends StatelessWidget {
  const _AnimatedMenuCard({
    required this.item,
    required this.index,
    required this.controller,
    required this.colors,
    required this.onTap,
  });

  final _MenuItem item;
  final int index;
  final AnimationController controller;
  final AppColorsExtension colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.08).clamp(0.0, 0.6);
    final end = (start + 0.35).clamp(0.0, 1.0);

    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: AppCurves.easeOut),
      ),
    );
    final scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: AppCurves.easeOutBack),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: opacity.value,
          child: Transform.scale(
            scale: scale.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface1,
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: colors.border, width: 1),
            boxShadow: colors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: colors.isDark ? 0.18 : 0.1),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(item.icon, size: 20, color: colors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODEL
// ═══════════════════════════════════════════════════════════════════════════

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}
