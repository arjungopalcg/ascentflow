import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/cards.dart';
import '../../widgets/climb_panel.dart';
import '../../widgets/common.dart';

import '../../models/goal_model.dart';
import '../../providers/data_providers.dart';
import '../../providers/home_widgets_provider.dart';
import '../profile/profile_screen.dart';
import '../savings/savings_screen.dart';
import '../profile/widget_settings_screen.dart';
import '../main_scaffold.dart';
import '../goals/goals_screen.dart';
import '../chat/chat_screen.dart';
import '../../widgets/buttons.dart';
import '../../providers/user_profile_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Widget _buildWidget(String id, AppColorsExtension colors) {
    return switch (id) {
      'progress' => _TodayProgressCard(colors: colors),
      'plan' => _TodayPlanCard(colors: colors),
      'focus' => _FocusQuickStart(colors: colors),
      'reminders' => _TaskReminderWidget(colors: colors),
      'goals' => _GoalProgressWidget(colors: colors),
      'challenge' => _DailyChallengeCard(colors: colors),
      'mood' => _MoodCheckIn(colors: colors),
      'savings' => _SavingsSummaryCard(colors: colors),
      'lists' => _MyListsWidget(colors: colors),
      'coach' => _CoachPrompt(colors: colors),
      'altitude' => _AltitudeWidget(colors: colors),
      'motivation' => _MotivationCard(colors: colors),
      _ => const SizedBox.shrink(),
    };
  }

  void _editHome() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WidgetSettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final visible = ref.watch(homeWidgetsProvider).visible;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            _HeaderRow(colors: colors),
            const SizedBox(height: AppSpacing.xxs),
            _GreetingBlock(colors: colors),
            const SizedBox(height: AppSpacing.xl),

            if (visible.isEmpty)
              _EmptyHome(colors: colors, onAdd: _editHome)
            else
              // Long-press a widget to drag it somewhere else.
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) => Material(
                  color: Colors.transparent,
                  child: Transform.scale(scale: 1.02, child: child),
                ),
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final id = visible[index];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(id),
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildWidget(id, colors),
                    ),
                  );
                },
                onReorderItem: (oldIndex, newIndex) => ref
                    .read(homeWidgetsProvider.notifier)
                    .reorderVisible(oldIndex, newIndex),
              ),

            if (visible.isNotEmpty)
              Center(
                child: TextButton.icon(
                  onPressed: _editHome,
                  icon: Icon(LucideIcons.slidersHorizontal, size: 18, color: colors.textSecondary),
                  label: Text(
                    'Edit home',
                    style: AppTypography.label.copyWith(color: colors.textSecondary),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.colors, required this.onAdd});
  final AppColorsExtension colors;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return PlainSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowLabel('Your home is empty'),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Add widgets from any part of the app: tasks, focus, journal, goals, savings and more.',
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          PillButton(label: 'Add widgets', icon: LucideIcons.plus, onTap: onAdd),
        ],
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
        Expanded(
          child: Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(color: colors.textSecondary),
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
              color: colors.surface1,
              border: Border.all(color: colors.border),
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

class _GreetingBlock extends ConsumerWidget {
  const _GreetingBlock({required this.colors});
  final AppColorsExtension colors;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userProfileProvider.select((p) => p.name));
    return Text(
      name.isEmpty ? _greeting : '$_greeting, $name',
      style: AppTypography.display.copyWith(color: colors.textPrimary),
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
              color: colors.summit.withValues(alpha: colors.isDark ? 0.18 : 0.12),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(LucideIcons.flag, color: colors.summit, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EyebrowLabel('Daily challenge'),
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
          AppChip(label: '+30 XP', variant: ChipVariant.summit),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TODAY'S PROGRESS
// ═══════════════════════════════════════════════════════════════════════════

class _TodayProgressCard extends ConsumerWidget {
  const _TodayProgressCard({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final goals = ref.watch(goalsProvider);
    final tasksDone = tasks.where((t) => t.isCompleted).length;
    final goalsDone = goals.where((g) => g.progress >= g.target).length;
    final nextGoal = goals.where((g) => g.progress < g.target).firstOrNull;
    final nextTask = tasks.where((t) => !t.isCompleted).firstOrNull;

    return ClimbPanel(
      done: tasksDone + goalsDone,
      total: tasks.length + goals.length,
      nextUp: nextGoal?.title ?? nextTask?.title,
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

    return PlainSection(
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

    return PlainSection(
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
    return PlainSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: EyebrowLabel('Today\'s plan')),
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
    return PlainSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowLabel('A thought for today'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '“The secret of getting ahead is getting started.”',
            style: AppTypography.heading2.copyWith(
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
    final goals = ref.watch(savingsProvider);
    final saved = goals.fold<double>(0, (s, g) => s + g.current);
    final money = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return _TappableSection(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Savings', trailing: '${money.format(saved)} saved', colors: colors),
          const SizedBox(height: AppSpacing.sm),
          if (goals.isEmpty)
            Text('No savings goals yet. Tap to add one.', style: AppTypography.body.copyWith(color: colors.textSecondary))
          else
            for (final g in goals.take(3)) ...[
              Row(
                children: [
                  Expanded(child: Text(g.title, style: AppTypography.label.copyWith(color: colors.textPrimary))),
                  Text(
                    '${money.format(g.current)} of ${money.format(g.target)}',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _Bar(value: g.target == 0 ? 0 : g.current / g.target, color: g.color, colors: colors),
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NEW SECTION WIDGETS — one per part of the app, so Home can be built from
// whatever the person cares about.
// ═══════════════════════════════════════════════════════════════════════════

/// Heading row used by plain Home sections.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.colors, this.trailing});
  final String title;
  final String? trailing;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: EyebrowLabel(title)),
        if (trailing != null)
          Text(trailing!, style: AppTypography.caption.copyWith(color: colors.textTertiary)),
      ],
    );
  }
}

/// A plain section that opens its source screen when tapped.
class _TappableSection extends StatelessWidget {
  const _TappableSection({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: PlainSection(child: child),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.color, required this.colors});
  final double value;
  final Color color;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.borderRadiusPill,
      child: LinearProgressIndicator(
        value: value.clamp(0, 1).toDouble(),
        minHeight: 6,
        backgroundColor: colors.surface2,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

class _FocusQuickStart extends ConsumerWidget {
  const _FocusQuickStart({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlainSection(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EyebrowLabel('Focus'),
                Text(
                  'One thing for 25 minutes.',
                  style: AppTypography.body.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PillButton(
            label: 'Start',
            icon: LucideIcons.play,
            onTap: () => ref.read(navIndexProvider.notifier).state = AppTab.focus,
          ),
        ],
      ),
    );
  }
}

class _GoalProgressWidget extends ConsumerWidget {
  const _GoalProgressWidget({required this.colors});
  final AppColorsExtension colors;

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(goalsProvider).where((g) => g.progress < g.target).take(3).toList();
    return _TappableSection(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Goals', trailing: '${active.length} active', colors: colors),
          const SizedBox(height: AppSpacing.sm),
          if (active.isEmpty)
            Text('Every goal is met. Tap to set a new one.', style: AppTypography.body.copyWith(color: colors.textSecondary))
          else
            for (final g in active) ...[
              Row(
                children: [
                  Expanded(child: Text(g.title, style: AppTypography.label.copyWith(color: colors.textPrimary))),
                  Text(
                    '${_fmt(g.progress)} / ${_fmt(g.target)}${g.unit.isEmpty ? '' : ' ${g.unit}'}',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _Bar(value: g.target == 0 ? 0 : g.progress / g.target, color: g.progressColor, colors: colors),
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

/// Today's mood, shared between the Home check-in and anything else that reads it.
final todayMoodProvider = StateProvider<int?>((ref) => null);

class _MoodCheckIn extends ConsumerWidget {
  const _MoodCheckIn({required this.colors});
  final AppColorsExtension colors;

  static const _moods = [('😢', 'Rough'), ('😕', 'Low'), ('😐', 'Okay'), ('🙂', 'Good'), ('😊', 'Great')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(todayMoodProvider);
    return PlainSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(mood == null ? 'How are you feeling?' : 'Feeling ${_moods[mood].$2.toLowerCase()} today'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _moods.length; i++)
                Semantics(
                  button: true,
                  selected: mood == i,
                  label: _moods[i].$2,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(todayMoodProvider.notifier).state = i;
                    },
                    child: AnimatedContainer(
                      duration: AppDuration.fast,
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mood == i ? colors.primary.withValues(alpha: colors.isDark ? 0.22 : 0.12) : colors.surface1,
                        border: Border.all(color: mood == i ? colors.primary : colors.border, width: mood == i ? 1.5 : 1),
                      ),
                      child: Text(_moods[i].$1, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
            ],
          ),
          if (mood != null)
            TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => ref.read(navIndexProvider.notifier).state = AppTab.journal,
              child: Text('Write about it in your journal', style: AppTypography.label.copyWith(color: colors.primary)),
            ),
        ],
      ),
    );
  }
}

class _CoachPrompt extends StatelessWidget {
  const _CoachPrompt({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return _TappableSection(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: colors.isDark ? 0.18 : 0.1),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(LucideIcons.messageCircle, size: 20, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EyebrowLabel('Ask your coach'),
                Text(
                  '“What should I tackle first today?”',
                  style: AppTypography.body.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: colors.textTertiary),
        ],
      ),
    );
  }
}

class _AltitudeWidget extends StatelessWidget {
  const _AltitudeWidget({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    // Sample numbers until XP is tracked; matches the Profile screen.
    return _TappableSection(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Altitude', trailing: 'Camp 7', colors: colors),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('2,450 m', style: AppTypography.display.copyWith(color: colors.textPrimary)),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text('550 m to Camp 8', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _Bar(value: 2450 / 3000, color: colors.summit, colors: colors),
        ],
      ),
    );
  }
}
