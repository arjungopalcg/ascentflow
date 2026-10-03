import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

import '../../models/goal_model.dart';
import '../../providers/data_providers.dart';
import '../../providers/home_widgets_provider.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  // Removed local _widgetOrder, using homeWidgetsProvider instead.

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = (index * 0.08).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: AppCurves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = (index * 0.08).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: AppCurves.easeOut),
      ),
    );
  }

  Widget _buildDraggableWidget(String id, AppColorsExtension colors) {
    switch (id) {
      case 'challenge':
        return _DailyChallengeCard(colors: colors);
      case 'progress':
        return _TodayProgressCard(colors: colors);
      case 'plan':
        return _TodayPlanCard(colors: colors);
      case 'savings':
        return _SavingsSummaryCard(colors: colors);
      case 'lists':
        return _MyListsWidget(colors: colors);
      case 'reminders':
        return _TaskReminderWidget(colors: colors);
      case 'motivation':
        return _MotivationCard(colors: colors);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final widgetState = ref.watch(homeWidgetsProvider);
    final enabledOrder = widgetState.order.where((id) => widgetState.enabledIds.contains(id)).toList();

    return Stack(
      children: [
        // ── Ambient Background ─────────────────────────────────────
        if (colors.isDark) _AmbientBg(controller: _staggerController),

        // ── Main Content ───────────────────────────────────────────
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                // ── Header Row ─────────────────────────────────────
                _StaggeredWidget(
                  index: 0,
                  controller: _staggerController,
                  fade: _staggeredFade(0),
                  slide: _staggeredSlide(0),
                  child: _HeaderRow(colors: colors),
                ),
                const SizedBox(height: AppSpacing.xxs),

                // ── Greeting ───────────────────────────────────────
                _StaggeredWidget(
                  index: 1,
                  controller: _staggerController,
                  fade: _staggeredFade(1),
                  slide: _staggeredSlide(1),
                  child: _GreetingBlock(colors: colors),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Draggable Widgets ──────────────────────────────
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      color: Colors.transparent,
                      elevation: 0,
                      child: Transform.scale(
                        scale: 1.02,
                        child: child,
                      ),
                    );
                  },
                  itemCount: enabledOrder.length,
                  itemBuilder: (context, index) {
                    final id = enabledOrder[index];
                    return ReorderableDelayedDragStartListener(
                      key: ValueKey(id),
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _StaggeredWidget(
                          index: index + 2,
                          controller: _staggerController,
                          fade: _staggeredFade(index + 2),
                          slide: _staggeredSlide(index + 2),
                          child: _buildDraggableWidget(id, colors),
                        ),
                      ),
                    );
                  },
                  onReorderItem: (oldIndex, newIndex) {
                    ref.read(homeWidgetsProvider.notifier).reorderWidgets(oldIndex, newIndex);
                  },
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),

      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STAGGERED ANIMATION WRAPPER
// ═══════════════════════════════════════════════════════════════════════════

class _StaggeredWidget extends StatelessWidget {
  const _StaggeredWidget({
    required this.index,
    required this.controller,
    required this.fade,
    required this.slide,
    required this.child,
  });

  final int index;
  final AnimationController controller;
  final Animation<double> fade;
  final Animation<Offset> slide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Opacity(
          opacity: fade.value,
          child: Transform.translate(
            offset: slide.value,
            child: child,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AMBIENT BACKGROUND — Subtle pulsing radial gradient (dark only)
// ═══════════════════════════════════════════════════════════════════════════

class _AmbientBg extends StatelessWidget {
  const _AmbientBg({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final pulse = 0.06 + 0.05 * (0.5 + 0.5 * controller.value);
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  AppColors.primaryDark.withValues(alpha: pulse),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HEADER ROW
// ═══════════════════════════════════════════════════════════════════════════

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [colors.primary, colors.primaryLighter],
          ).createShader(bounds),
          child: Text(
            'Ascent Flow',
            style: AppTypography.heading3.copyWith(color: Colors.white),
          ),
        ),
        // Profile avatar
        GestureDetector(
          onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface2,
              border: Border.all(
                color: colors.primary.withValues(alpha: colors.isDark ? 0.5 : 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              LucideIcons.user,
              size: 20,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GREETING BLOCK
// ═══════════════════════════════════════════════════════════════════════════

class _GreetingBlock extends StatelessWidget {
  const _GreetingBlock({required this.colors});
  final AppColorsExtension colors;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting,',
          style: AppTypography.heading1.copyWith(
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              'Alex',
              style: AppTypography.display.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppChip(
              label: 'LVL 7 · FOCUSED',
              variant: ChipVariant.violet,
              icon: LucideIcons.hexagon,
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DAILY CHALLENGE CARD
// ═══════════════════════════════════════════════════════════════════════════

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return ElevatedCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(LucideIcons.zap, color: colors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '✨ ',
                      style: TextStyle(fontSize: 14),
                    ),
                    EyebrowLabel('DAILY CHALLENGE'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete 3 high-priority tasks today',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          AppChip(label: '+30 XP', variant: ChipVariant.mint),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TODAY'S PROGRESS
// ═══════════════════════════════════════════════════════════════════════════

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: Column(
        children: [
          const EyebrowLabel('TODAY\'S PROGRESS'),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _StatBox(
                  value: 5,
                  label: 'Tasks',
                  suffix: '/8',
                  colors: colors,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatBox(
                  value: 75,
                  label: 'Focus min',
                  suffix: '',
                  colors: colors,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatBox(
                  value: 3,
                  label: 'Goals',
                  suffix: '',
                  colors: colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Streak indicators centered
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StreakPill(emoji: '🔥', count: 12, label: 'Journal', variant: ChipVariant.mint),
                const SizedBox(width: AppSpacing.xs),
                _StreakPill(emoji: '🔥', count: 7, label: 'Focus', variant: ChipVariant.violet),
                const SizedBox(width: AppSpacing.xs),
                _StreakPill(emoji: '🔥', count: 5, label: 'Tasks', variant: ChipVariant.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.suffix,
    required this.colors,
  });

  final double value;
  final String label;
  final String suffix;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface2.withValues(alpha: 0.5),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CountUpText(
                value: value,
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              if (suffix.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    suffix,
                    style: AppTypography.caption.copyWith(
                      color: colors.textTertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: colors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NEW WIDGETS: MY LISTS & TASK REMINDERS
// ═══════════════════════════════════════════════════════════════════════════

class _MyListsWidget extends ConsumerWidget {
  const _MyListsWidget({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(listsProvider);
    final displayLists = lists.take(3).toList();

    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EyebrowLabel('MY LISTS'),
              Icon(LucideIcons.listTodo, size: 16, color: colors.textTertiary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (lists.isEmpty)
            Text('No lists yet.', style: AppTypography.body.copyWith(color: colors.textSecondary))
          else
            ...displayLists.map((list) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(list.icon, size: 16, color: colors.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(list.title, style: AppTypography.body.copyWith(color: colors.textPrimary)),
                  ),
                  Text('${list.itemCnt} items', style: AppTypography.caption.copyWith(color: colors.textTertiary)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _TaskReminderWidget extends ConsumerWidget {
  const _TaskReminderWidget({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final now = DateTime.now();

    final reminders = tasks.where((t) {
      if (t.isCompleted || t.dueDate == null) return false;
      final diff = t.dueDate!.difference(DateTime(now.year, now.month, now.day)).inDays;
      return [1, 3, 5, 10].contains(diff);
    }).toList();

    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EyebrowLabel('DUE SOON'),
              Icon(LucideIcons.alarmClock, size: 16, color: colors.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (reminders.isEmpty)
            Text('No upcoming deadlines.', style: AppTypography.body.copyWith(color: colors.textSecondary))
          else
            ...reminders.map((task) {
              final diff = task.dueDate!.difference(DateTime(now.year, now.month, now.day)).inDays;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.danger.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: Text(
                        'In $diff d',
                        style: AppTypography.caption.copyWith(color: colors.danger, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(task.title, style: AppTypography.body.copyWith(color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({
    required this.emoji,
    required this.count,
    required this.label,
    required this.variant,
  });

  final String emoji;
  final int count;
  final String label;
  final ChipVariant variant;

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: '$emoji $count $label',
      variant: variant,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TODAY'S PLAN
// ═══════════════════════════════════════════════════════════════════════════

class _PlanItem {
  final String id;
  final String title;
  final bool isGoal;
  final bool isCompleted;

  _PlanItem(this.id, this.title, this.isGoal, this.isCompleted);
}

class _TodayPlanCard extends ConsumerWidget {
  const _TodayPlanCard({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final goals = ref.watch(goalsProvider);

    final todayTasks = tasks.where((t) {
      if (t.dueDate == null) return false;
      final now = DateTime.now();
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).toList();

    final dailyGoals = goals.where((g) => g.targetType == GoalTargetType.dailyHabit).toList();

    final combinedItems = [
      ...dailyGoals.map((g) => _PlanItem(g.id, g.title, true, g.progress >= g.target)),
      ...todayTasks.map((t) => _PlanItem(t.id, t.title, false, t.isCompleted)),
    ];
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EyebrowLabel('TODAY\'S PLAN'),
              Text(
                '${combinedItems.length} items',
                style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          
          if (combinedItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Your plan is clear for today!',
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              ),
            )
          else
            ...List.generate(combinedItems.length, (i) {
              final item = combinedItems[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (item.isGoal) {
                      final goal = goals.firstWhere((g) => g.id == item.id);
                      ref.read(goalsProvider.notifier).updateGoalProgress(item.id, item.isCompleted ? 0 : goal.target);
                    } else {
                      ref.read(tasksProvider.notifier).toggleTaskCompletion(item.id);
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: item.isCompleted
                                ? colors.mint
                                : colors.border,
                            width: 1.5,
                          ),
                          color: item.isCompleted
                              ? colors.mint.withValues(alpha: 0.15)
                              : Colors.transparent,
                        ),
                        child: item.isCompleted
                            ? Icon(LucideIcons.check, size: 12, color: colors.mint)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.body.copyWith(
                            color: item.isCompleted
                                ? colors.textTertiary
                                : colors.textPrimary,
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MOTIVATION QUOTE
// ═══════════════════════════════════════════════════════════════════════════

class _MotivationCard extends StatelessWidget {
  const _MotivationCard({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('✨ ', style: TextStyle(fontSize: 14)),
              EyebrowLabel('DAILY MOTIVATION'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '"The secret of getting ahead is getting started."',
            style: AppTypography.bodyLarge.copyWith(
              color: colors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '— Mark Twain',
            style: AppTypography.caption.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SAVINGS SUMMARY CARD
// ═══════════════════════════════════════════════════════════════════════════

class _SavingsSummaryCard extends ConsumerWidget {
  const _SavingsSummaryCard({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final savingsGoals = goals.where((g) => g.targetType == GoalTargetType.numeric).take(2).toList();

    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EyebrowLabel('SAVINGS PROGRESS'),
              Icon(LucideIcons.piggyBank, size: 16, color: colors.textTertiary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (savingsGoals.isEmpty)
            Text('No active savings goals.', style: AppTypography.body.copyWith(color: colors.textSecondary))
          else
            ...savingsGoals.map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(goal.title, style: AppTypography.label.copyWith(color: colors.textPrimary)),
                      Text('${((goal.progress / goal.target) * 100).toInt()}%', 
                        style: AppTypography.caption.copyWith(color: colors.primary, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusPill,
                    child: LinearProgressIndicator(
                      value: (goal.progress / goal.target).clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: colors.surface2,
                      valueColor: AlwaysStoppedAnimation(colors.primary),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
