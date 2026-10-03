import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';

class PlannerPlanItem {
  final String id;
  final String title;
  final String description;
  final String? time;
  final DateTime date;
  bool isCompleted;

  PlannerPlanItem({
    required this.id,
    required this.title,
    this.description = '',
    this.time,
    required this.date,
    this.isCompleted = false,
  });
}

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<PlannerPlanItem> _allPlans = [
    PlannerPlanItem(
      id: '1',
      title: 'Morning Workout',
      description: 'Cardio + Strength',
      time: '07:00 AM',
      date: DateTime.now(),
    ),
    PlannerPlanItem(
      id: '2',
      title: 'Deep Work Session',
      description: 'Ship marketing report',
      time: '09:30 AM',
      date: DateTime.now(),
    ),
    PlannerPlanItem(
      id: '3',
      title: 'Lunch & Walk',
      time: '12:00 PM',
      date: DateTime.now(),
    ),
    PlannerPlanItem(
      id: '4',
      title: 'Review Phase 9 Specs',
      description: 'Feature planning doc',
      time: '02:00 PM',
      date: DateTime.now().add(const Duration(days: 1)),
    ),
    PlannerPlanItem(
      id: '5',
      title: 'Call with designer',
      time: '11:00 AM',
      date: DateTime.now().add(const Duration(days: 1)),
    ),
  ];

  List<PlannerPlanItem> get _todayPlans {
    final today = DateTime.now();
    return _allPlans.where((p) {
      return p.date.year == today.year &&
          p.date.month == today.month &&
          p.date.day == today.day;
    }).toList();
  }

  List<PlannerPlanItem> get _scheduledPlans {
    final today = DateTime.now();
    return _allPlans.where((p) {
      final d = p.date;
      return !(d.year == today.year && d.month == today.month && d.day == today.day);
    }).toList();
  }

  List<PlannerPlanItem> get _archivedPlans {
    final today = DateTime.now();
    return _allPlans.where((p) {
      return p.date.isBefore(DateTime(today.year, today.month, today.day)) ||
          p.isCompleted;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddPlanModal({DateTime? prefillDate}) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreatePlanSheet(
        prefillDate: prefillDate,
        onAdd: (item) {
          setState(() => _allPlans.add(item));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Daily Planner',
            style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        actions: [
          IconButton(
            onPressed: () => _showAddPlanModal(),
            icon: Icon(LucideIcons.plus, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.primary,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textTertiary,
          labelStyle: AppTypography.label,
          dividerColor: colors.border,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Schedule'),
            Tab(text: 'Archive'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TodayView(
            colors: colors,
            plans: _todayPlans,
            onToggle: (id) => setState(() {
              final p = _allPlans.firstWhere((x) => x.id == id);
              p.isCompleted = !p.isCompleted;
            }),
            onAddPlan: () => _showAddPlanModal(),
          ),
          _ScheduleView(
            colors: colors,
            plans: _scheduledPlans,
            onToggle: (id) => setState(() {
              final p = _allPlans.firstWhere((x) => x.id == id);
              p.isCompleted = !p.isCompleted;
            }),
            onAddPlan: (date) => _showAddPlanModal(prefillDate: date),
          ),
          _ArchiveView(
            colors: colors,
            plans: _archivedPlans,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// TODAY VIEW
// ══════════════════════════════════════════════════════════════════════════

class _TodayView extends StatelessWidget {
  const _TodayView({
    required this.colors,
    required this.plans,
    required this.onToggle,
    required this.onAddPlan,
  });
  final AppColorsExtension colors;
  final List<PlannerPlanItem> plans;
  final void Function(String id) onToggle;
  final VoidCallback onAddPlan;

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today',
                      style: AppTypography.display
                          .copyWith(color: colors.textPrimary)),
                  Text(today,
                      style: AppTypography.body
                          .copyWith(color: colors.textSecondary)),
                ],
              ),
              GestureDetector(
                onTap: onAddPlan,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderRadiusPill,
                    border:
                        Border.all(color: colors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.plus, size: 14, color: colors.primary),
                      const SizedBox(width: 4),
                      Text('Add Plan',
                          style: AppTypography.caption
                              .copyWith(color: colors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: plans.isEmpty
              ? _EmptyState(
                  icon: LucideIcons.calendarCheck,
                  label: 'No plans for today',
                  subtitle: 'Tap + to add your first plan',
                  colors: colors,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  itemCount: plans.length,
                  itemBuilder: (ctx, i) => _PlanCard(
                    plan: plans[i],
                    colors: colors,
                    onToggle: () => onToggle(plans[i].id),
                  ),
                ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SCHEDULE VIEW
// ══════════════════════════════════════════════════════════════════════════

class _ScheduleView extends StatefulWidget {
  const _ScheduleView({
    required this.colors,
    required this.plans,
    required this.onToggle,
    required this.onAddPlan,
  });
  final AppColorsExtension colors;
  final List<PlannerPlanItem> plans;
  final void Function(String id) onToggle;
  final void Function(DateTime date) onAddPlan;

  @override
  State<_ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<_ScheduleView> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final filtered = widget.plans.where((p) {
      return p.date.year == _selectedDate.year &&
          p.date.month == _selectedDate.month &&
          p.date.day == _selectedDate.day;
    }).toList();

    return Column(
      children: [
        // Date selector strip
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: 14,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (ctx, i) {
              final date = DateTime.now().add(Duration(days: i + 1));
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : colors.surface2,
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? Colors.white70 : colors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date.day.toString(),
                        style: AppTypography.heading3.copyWith(
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Plans for selected date
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, MMM d').format(_selectedDate),
                style: AppTypography.heading3.copyWith(color: colors.textPrimary),
              ),
              GestureDetector(
                onTap: () => widget.onAddPlan(_selectedDate),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderRadiusPill,
                    border: Border.all(
                        color: colors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.plus, size: 14, color: colors.primary),
                      const SizedBox(width: 4),
                      Text('Add Plan',
                          style: AppTypography.caption
                              .copyWith(color: colors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(
                  icon: LucideIcons.calendarPlus,
                  label: 'No plans scheduled',
                  subtitle: 'Tap + to schedule a plan for this date',
                  colors: colors,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _PlanCard(
                    plan: filtered[i],
                    colors: colors,
                    onToggle: () => widget.onToggle(filtered[i].id),
                  ),
                ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ARCHIVE VIEW
// ══════════════════════════════════════════════════════════════════════════

class _ArchiveView extends StatelessWidget {
  const _ArchiveView({required this.colors, required this.plans});
  final AppColorsExtension colors;
  final List<PlannerPlanItem> plans;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return _EmptyState(
        icon: LucideIcons.archive,
        label: 'Nothing archived yet',
        subtitle: 'Completed plans will appear here',
        colors: colors,
      );
    }

    // Group by date
    final grouped = <String, List<PlannerPlanItem>>{};
    for (final p in plans) {
      final key = DateFormat('EEEE, MMMM d').format(p.date);
      grouped.putIfAbsent(key, () => []).add(p);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(entry.key,
                style: AppTypography.label.copyWith(color: colors.textTertiary)),
          ),
          for (final plan in entry.value)
            _PlanCard(plan: plan, colors: colors, isArchive: true),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// PLAN CARD
// ══════════════════════════════════════════════════════════════════════════

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.colors,
    this.onToggle,
    this.isArchive = false,
  });
  final PlannerPlanItem plan;
  final AppColorsExtension colors;
  final VoidCallback? onToggle;
  final bool isArchive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SolidCard(
        leftAccentColor: plan.isCompleted ? colors.mint : colors.primary,
        child: Row(
          children: [
            if (onToggle != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggle!();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: plan.isCompleted
                        ? colors.mint.withValues(alpha: 0.15)
                        : Colors.transparent,
                    border: Border.all(
                      color: plan.isCompleted ? colors.mint : colors.primary,
                      width: 1.5,
                    ),
                  ),
                  child: plan.isCompleted
                      ? Icon(LucideIcons.check, size: 12, color: colors.mint)
                      : null,
                ),
              )
            else
              Icon(LucideIcons.archiveRestore, size: 18, color: colors.textTertiary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: AppTypography.body.copyWith(
                      color: plan.isCompleted
                          ? colors.textTertiary
                          : colors.textPrimary,
                      decoration:
                          plan.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (plan.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(plan.description,
                        style: AppTypography.caption
                            .copyWith(color: colors.textSecondary)),
                  ],
                ],
              ),
            ),
            if (plan.time != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surface3,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  plan.time!,
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.colors,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: colors.surface3),
          const SizedBox(height: AppSpacing.md),
          Text(label,
              style: AppTypography.heading3.copyWith(color: colors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle,
              style: AppTypography.body.copyWith(color: colors.textTertiary)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// CREATE PLAN MODAL
// ══════════════════════════════════════════════════════════════════════════

class _CreatePlanSheet extends StatefulWidget {
  const _CreatePlanSheet({this.prefillDate, required this.onAdd});
  final DateTime? prefillDate;
  final void Function(PlannerPlanItem item) onAdd;

  @override
  State<_CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<_CreatePlanSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TimeOfDay? _selectedTime;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.prefillDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    HapticFeedback.heavyImpact();
    final timeStr =
        _selectedTime?.format(context);
    widget.onAdd(PlannerPlanItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      time: timeStr,
      date: _selectedDate,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: AppRadius.borderRadiusPill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Plan',
                  style:
                      AppTypography.heading2.copyWith(color: colors.textPrimary)),
              IconButton(
                icon: Icon(LucideIcons.x, color: colors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title
          _FieldLabel('PLAN TITLE', colors),
          const SizedBox(height: AppSpacing.xs),
          _StyledInput(
            controller: _titleController,
            hint: 'e.g. Deep Work Session',
            colors: colors,
          ),
          const SizedBox(height: AppSpacing.md),

          // Description
          _FieldLabel('DESCRIPTION (optional)', colors),
          const SizedBox(height: AppSpacing.xs),
          _StyledInput(
            controller: _descController,
            hint: 'Add notes...',
            colors: colors,
          ),
          const SizedBox(height: AppSpacing.md),

          // Date & Time row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('DATE', colors),
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      onTap: _pickDate,
                      child: _PickerBox(
                        icon: LucideIcons.calendar,
                        label: DateFormat('MMM d, yyyy').format(_selectedDate),
                        colors: colors,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('TIME (optional)', colors),
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      onTap: _pickTime,
                      child: _PickerBox(
                        icon: LucideIcons.clock,
                        label: _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Anytime',
                        colors: colors,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          SizedBox(
            width: double.infinity,
            child: PillButton(label: 'Add to Planner', onTap: _submit),
          ),
        ],
      ),
    );
  }
}

// Helpers
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, this.colors);
  final String text;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTypography.caption.copyWith(
            color: colors.textTertiary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8));
  }
}

class _StyledInput extends StatelessWidget {
  const _StyledInput(
      {required this.controller, required this.hint, required this.colors});
  final TextEditingController controller;
  final String hint;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: colors.border),
      ),
      child: TextField(
        controller: controller,
        style: AppTypography.body.copyWith(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.body.copyWith(color: colors.textTertiary),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _PickerBox extends StatelessWidget {
  const _PickerBox(
      {required this.icon, required this.label, required this.colors});
  final IconData icon;
  final String label;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
