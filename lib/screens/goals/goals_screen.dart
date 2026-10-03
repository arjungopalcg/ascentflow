import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

import '../../models/goal_model.dart';
import '../../providers/data_providers.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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

  void _showCreateGoalModal() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateGoalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Goals', style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.primary,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textTertiary,
          labelStyle: AppTypography.label,
          dividerColor: colors.border,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Paused'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(LucideIcons.filter, color: colors.textSecondary),
          ),
          IconButton(
            onPressed: _showCreateGoalModal,
            icon: Icon(LucideIcons.plus, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GoalsList(colors: colors, active: true),
          _GoalsList(colors: colors, paused: true),
          _GoalsList(colors: colors, completed: true),
        ],
      ),
    );
  }
}

class _GoalsList extends ConsumerWidget {
  const _GoalsList({
    required this.colors,
    this.active = false,
    this.paused = false,
    this.completed = false,
  });

  final AppColorsExtension colors;
  final bool active;
  final bool paused;
  final bool completed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGoals = ref.watch(goalsProvider);

    final goals = allGoals.where((g) {
      if (active) return g.progress < g.target;
      if (completed) return g.progress >= g.target;
      return false; // Paused not fully supported via model yet
    }).toList();

    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.target, size: 48, color: colors.surface3),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No goals found here.',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _GoalCard(goal: goal, colors: colors),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GOAL CARD
// ═══════════════════════════════════════════════════════════════════════════

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.colors});

  final GoalModel goal;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    final target = goal.target > 0 ? goal.target : 1.0;
    final ratio = (goal.progress / target).clamp(0.0, 1.0);
    
    final deadlineText = goal.deadline != null 
        ? '${goal.deadline!.day}/${goal.deadline!.month}/${goal.deadline!.year}'
        : 'No Deadline';
    
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: goal.progressColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(goal.icon, size: 20, color: goal.progressColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
                    Text(goal.category, style: AppTypography.caption.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ),
              Icon(LucideIcons.flag, size: 16, color: colors.amber),
              const SizedBox(width: 4),
              Text(deadlineText, style: AppTypography.caption.copyWith(color: colors.textTertiary)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.progress.toInt()}${goal.unit} / ${goal.target.toInt()}${goal.unit}',
                style: AppTypography.body.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
              ),
              Text(
                '${(ratio * 100).toInt()}%',
                style: AppTypography.caption.copyWith(color: colors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.borderRadiusPill,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: colors.surface3,
              valueColor: AlwaysStoppedAnimation(goal.progressColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CREATE GOAL SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _CreateGoalSheet extends ConsumerStatefulWidget {
  const _CreateGoalSheet();

  @override
  ConsumerState<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<_CreateGoalSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _unitController = TextEditingController();
  final _rewardController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Personal';
  String _selectedTargetType = 'Numeric';
  String _selectedPriority = 'Medium';
  String _selectedReminderFreq = 'Daily';
  
  DateTime? _targetDate;
  TimeOfDay? _reminderTime;

  static const _categories = [
    'Personal', 'Health and fitness', 'Career', 'Education', 
    'Financial', 'Relationships', 'Hobbies', 'Travel', 
    'Creative', 'Spiritual'
  ];
  
  static const _targetTypes = ['Numeric', 'Yes/No', 'Daily Habit'];
  static const _priorities = ['Low', 'Medium', 'High'];
  static const _reminderFreqs = ['Daily', 'Weekly', 'Monthly'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetValueController.dispose();
    _unitController.dispose();
    _rewardController.dispose();
    _notesController.dispose();
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
      setState(() => _targetDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  Widget _buildDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged, AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowLabel(label.toUpperCase()),
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

  Widget _buildTextField(String label, TextEditingController controller, AppColorsExtension colors, {String? hint, int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowLabel(label.toUpperCase()),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
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
        EyebrowLabel(label.toUpperCase()),
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
                  _targetDate == null ? 'Select Date' : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                  style: AppTypography.body.copyWith(
                    color: _targetDate == null ? colors.textTertiary : colors.textPrimary,
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

  Widget _buildTimePicker(String label, AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowLabel(label.toUpperCase()),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: _pickTime,
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
                  _reminderTime == null ? 'Select Time' : _reminderTime!.format(context),
                  style: AppTypography.body.copyWith(
                    color: _reminderTime == null ? colors.textTertiary : colors.textPrimary,
                  ),
                ),
                Icon(LucideIcons.clock, size: 18, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.surface1.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ColorFilter.mode(colors.surface1.withValues(alpha: 0.8), BlendMode.dstATop),
              child: Container(color: colors.surface1.withValues(alpha: 0.5)),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Create Goal', style: AppTypography.heading2.copyWith(color: colors.textPrimary)),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(LucideIcons.x, color: colors.textSecondary),
                        style: IconButton.styleFrom(backgroundColor: colors.surface2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField('Goal Title', _titleController, colors, hint: 'e.g. Run a Marathon'),
                        const SizedBox(height: AppSpacing.md),
                        
                        _buildDropdown('Category', _categories, _selectedCategory, (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        }, colors),
                        const SizedBox(height: AppSpacing.md),
                        
                        _buildTextField('Description', _descController, colors, hint: 'Details about your goal', maxLines: 3),
                        const SizedBox(height: AppSpacing.md),

                        _buildDropdown('Target Type', _targetTypes, _selectedTargetType, (val) {
                          if (val != null) setState(() => _selectedTargetType = val);
                        }, colors),
                        const SizedBox(height: AppSpacing.md),

                        if (_selectedTargetType == 'Numeric') ...[
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField('Target Value', _targetValueController, colors, hint: 'e.g. 100', keyboardType: TextInputType.number),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 1,
                                child: _buildTextField('Unit', _unitController, colors, hint: 'e.g. km'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        
                        _buildDropdown('Priority', _priorities, _selectedPriority, (val) {
                          if (val != null) setState(() => _selectedPriority = val);
                        }, colors),
                        const SizedBox(height: AppSpacing.md),

                        _buildDatePicker('Target Date', colors),
                        const SizedBox(height: AppSpacing.md),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown('Reminder Frequency', _reminderFreqs, _selectedReminderFreq, (val) {
                                if (val != null) setState(() => _selectedReminderFreq = val);
                              }, colors),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: _buildTimePicker('Reminder Time', colors)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        _buildTextField('Reward', _rewardController, colors, hint: 'What will you reward yourself with?'),
                        const SizedBox(height: AppSpacing.md),
                        
                        _buildTextField('Notes', _notesController, colors, hint: 'Any additional notes', maxLines: 3),
                        
                        const SizedBox(height: AppSpacing.xxxl),

                        SizedBox(
                          width: double.infinity,
                          child: PillButton(
                            label: 'Set Goal',
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              
                              final targetTypeMapped = switch (_selectedTargetType) {
                                'Daily Habit' => GoalTargetType.dailyHabit,
                                'Yes/No' => GoalTargetType.yesNo,
                                _ => GoalTargetType.numeric,
                              };

                              final newGoal = GoalModel(
                                id: const Uuid().v4(),
                                title: _titleController.text.isNotEmpty ? _titleController.text : 'New Goal',
                                category: _selectedCategory,
                                targetType: targetTypeMapped,
                                deadline: _targetDate,
                                icon: LucideIcons.target,
                                progressColor: const Color(0xFF63C2A5), // Mint
                                target: double.tryParse(_targetValueController.text) ?? 1.0,
                                unit: _unitController.text,
                              );

                              ref.read(goalsProvider.notifier).addGoal(newGoal);

                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
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
