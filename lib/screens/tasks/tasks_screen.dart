import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/buttons.dart';

import '../../models/task_model.dart';
import '../../providers/data_providers.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

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

  void _showCreateTaskModal() {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (context) => _CreateTaskSheet(colors: colors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final allTasks = ref.watch(tasksProvider);
    
    // Split tasks for simple categorization
    final upcomingTasks = allTasks.where((t) => !t.isCompleted).toList();
    final completedTasks = allTasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Tasks',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.display.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppChip(
                              label: '${upcomingTasks.length} left',
                              variant: ChipVariant.violet,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              onPressed: _showCreateTaskModal,
                              icon: Icon(LucideIcons.plus, color: colors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

                // ── UPCOMING TASKS ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: EyebrowLabel('Upcoming'),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Dismissible(
                        key: ValueKey(upcomingTasks[index].id),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            HapticFeedback.mediumImpact();
                            ref.read(tasksProvider.notifier).toggleTaskCompletion(upcomingTasks[index].id);
                            return false;
                          }
                          return true;
                        },
                        onDismissed: (direction) {
                          HapticFeedback.heavyImpact();
                          ref.read(tasksProvider.notifier).deleteTask(upcomingTasks[index].id);
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colors.mint.withValues(alpha: 0.15),
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.check, color: colors.mint, size: 20),
                              const SizedBox(width: AppSpacing.xs),
                              Text('Complete',
                                style: AppTypography.label.copyWith(color: colors.mint),
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colors.danger.withValues(alpha: 0.15),
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Delete',
                                style: AppTypography.label.copyWith(color: colors.danger),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Icon(LucideIcons.trash2, color: colors.danger, size: 20),
                            ],
                          ),
                        ),
                        child: _TaskCard(
                          task: upcomingTasks[index],
                          colors: colors,
                          onRefTask: ref,
                        ),
                      ),
                      childCount: upcomingTasks.length,
                    ),
                  ),
                ),
                
                // ── COMPLETED TASKS ──────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      top: AppSpacing.xl,
                    ),
                    child: EyebrowLabel('COMPLETED'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    top: AppSpacing.sm,
                    bottom: 120, // Pad for bottom nav
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Dismissible(
                        key: ValueKey(completedTasks[index].id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          HapticFeedback.heavyImpact();
                          ref.read(tasksProvider.notifier).deleteTask(completedTasks[index].id);
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            color: colors.danger.withValues(alpha: 0.15),
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colors.danger.withValues(alpha: 0.15),
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Delete',
                                style: AppTypography.label.copyWith(color: colors.danger),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Icon(LucideIcons.trash2, color: colors.danger, size: 20),
                            ],
                          ),
                        ),
                        child: _TaskCard(
                          task: completedTasks[index],
                          colors: colors,
                          onRefTask: ref,
                        ),
                      ),
                      childCount: completedTasks.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TASK CARD
// ═══════════════════════════════════════════════════════════════════════════

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.colors,
    required this.onRefTask,
  });

  final TaskModel task;
  final AppColorsExtension colors;
  final WidgetRef onRefTask;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    
    // Map priorities to chip styles
    String priorityLabel = 'Medium';
    ChipVariant chipVariant = ChipVariant.amber;
    Color? accentColor = colors.amber;
    
    if (task.priority == TaskPriority.high) {
      priorityLabel = 'High';
      chipVariant = ChipVariant.danger;
      accentColor = colors.danger;
    } else if (task.priority == TaskPriority.low) {
      priorityLabel = 'Low';
      chipVariant = ChipVariant.gray;
      accentColor = colors.textTertiary;
    }

    return SolidCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      leftAccentColor: isCompleted ? null : accentColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onRefTask.read(tasksProvider.notifier).toggleTaskCompletion(task.id);
        },
        child: Row(
        children: [
          // Priority checkbox
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? colors.mint.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? colors.mint
                    : accentColor,
                width: 1.5,
              ),
            ),
            child: isCompleted
                ? Icon(LucideIcons.check, size: 12, color: colors.mint)
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.body.copyWith(
                    color: isCompleted
                        ? colors.textTertiary
                        : colors.textPrimary,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.dueTime.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.dueTime,
                    style: AppTypography.caption.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Priority badge
          if (!isCompleted)
            AppChip(
              label: priorityLabel,
              variant: chipVariant,
            ),
        ],
      ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CREATE TASK MODAL
// ═══════════════════════════════════════════════════════════════════════════

class _CreateTaskSheet extends ConsumerStatefulWidget {
  const _CreateTaskSheet({required this.colors});
  final AppColorsExtension colors;

  @override
  ConsumerState<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<_CreateTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  String _selectedCategory = 'Work';
  String _selectedPriority = 'Medium';
  DateTime? _dueDate;

  static const _categories = ['Work', 'Personal', 'Health', 'Learning', 'Shopping', 'Other'];
  static const _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  Widget _buildDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged, AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowLabel(label),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: colors.surface2,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
              icon: Icon(LucideIcons.chevronDown, color: colors.textSecondary),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, AppColorsExtension colors, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowLabel(label),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.body.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: colors.textTertiary),
            filled: true,
            fillColor: colors.surface2,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusMd,
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusMd,
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusMd,
              borderSide: BorderSide(color: colors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowLabel(label),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: _pickDate,
          borderRadius: AppRadius.borderRadiusMd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dueDate == null ? 'Select Date' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                  style: AppTypography.body.copyWith(
                    color: _dueDate == null ? colors.textTertiary : colors.textPrimary,
                  ),
                ),
                Icon(LucideIcons.calendar, size: 18, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textTertiary,
                borderRadius: AppRadius.borderRadiusPill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('New Task', style: AppTypography.heading2.copyWith(color: colors.textPrimary)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(LucideIcons.x, color: colors.textSecondary),
                style: IconButton.styleFrom(backgroundColor: colors.surface2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Title', _titleController, colors, hint: 'e.g. Finish quarterly report'),
                  const SizedBox(height: AppSpacing.md),

                  _buildTextField('Description', _descController, colors, hint: 'Details about the task', maxLines: 3),
                  const SizedBox(height: AppSpacing.md),

                  _buildDropdown('Category', _categories, _selectedCategory, (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  }, colors),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildDropdown('Priority', _priorities, _selectedPriority, (val) {
                    if (val != null) setState(() => _selectedPriority = val);
                  }, colors),
                  const SizedBox(height: AppSpacing.md),

                  _buildDatePicker('Due Date', colors),
                  const SizedBox(height: AppSpacing.xxl),

                  SizedBox(
                    width: double.infinity,
                    child: PillButton(
                      label: 'Add Task',
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        
                        final priorityMapped = switch (_selectedPriority) {
                          'High' => TaskPriority.high,
                          'Low' => TaskPriority.low,
                          _ => TaskPriority.medium,
                        };

                        final newTask = TaskModel(
                          id: const Uuid().v4(),
                          title: _titleController.text.isNotEmpty ? _titleController.text : 'New Task',
                          description: _descController.text,
                          category: _selectedCategory,
                          priority: priorityMapped,
                          dueDate: _dueDate,
                          dueTime: _dueDate == null ? '' : 'Due to date', // Or generic format
                        );

                        ref.read(tasksProvider.notifier).addTask(newTask);

                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
