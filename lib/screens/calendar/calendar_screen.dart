import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/buttons.dart';

class _CalendarEvent {
  final String id;
  final String title;
  final String category;
  final Color color;
  final String? time;
  final DateTime date;

  _CalendarEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.color,
    this.time,
    required this.date,
  });
}

const _eventCategories = [
  {'label': 'Task', 'color': Color(0xFF9E77F1)},
  {'label': 'Habit', 'color': Color(0xFF10F1D3)},
  {'label': 'Event', 'color': Color(0xFFFFB053)},
  {'label': 'Savings', 'color': Color(0xFF4D9FF4)},
  {'label': 'Goal', 'color': Color(0xFF63C2A5)},
];

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final List<_CalendarEvent> _events = [
    _CalendarEvent(
      id: 'e1',
      title: 'Ship Phase 9',
      category: 'Task',
      color: const Color(0xFF9E77F1),
      time: '10:00 AM',
      date: DateTime.now(),
    ),
    _CalendarEvent(
      id: 'e2',
      title: 'Drink 2L Water',
      category: 'Habit',
      color: const Color(0xFF10F1D3),
      time: 'Anytime',
      date: DateTime.now(),
    ),
    _CalendarEvent(
      id: 'e3',
      title: '\$50 to Emergency Fund',
      category: 'Savings',
      color: const Color(0xFFFFB053),
      time: 'Auto-Transfer',
      date: DateTime.now().add(const Duration(days: 1)),
    ),
    _CalendarEvent(
      id: 'e4',
      title: 'Team Meeting',
      category: 'Event',
      color: const Color(0xFF4D9FF4),
      time: '2:00 PM',
      date: DateTime.now().add(const Duration(days: 1)),
    ),
  ];

  List<Color> _getColorsForDay(DateTime day) {
    return _events
        .where((e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day)
        .map((e) => e.color)
        .toSet()
        .toList();
  }

  List<_CalendarEvent> get _selectedEvents {
    return _events
        .where((e) =>
            e.date.year == _selectedDay.year &&
            e.date.month == _selectedDay.month &&
            e.date.day == _selectedDay.day)
        .toList();
  }

  void _showAddEventSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateEventSheet(
        initialDate: _selectedDay,
        onAdd: (event) => setState(() => _events.add(event)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Unified Calendar',
            style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(LucideIcons.listFilter, color: colors.textSecondary),
          ),
          IconButton(
            onPressed: _showAddEventSheet,
            icon: Icon(LucideIcons.plus, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // ── Calendar ───────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface1,
              borderRadius: AppRadius.borderRadiusLg,
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: TableCalendar<Color>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: _getColorsForDay,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTypography.heading3
                    .copyWith(color: colors.textPrimary),
                leftChevronIcon: Icon(LucideIcons.chevronLeft,
                    color: colors.textSecondary),
                rightChevronIcon: Icon(LucideIcons.chevronRight,
                    color: colors.textSecondary),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTypography.caption
                    .copyWith(color: colors.textTertiary),
                weekendStyle: AppTypography.caption
                    .copyWith(color: colors.textSecondary),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: AppTypography.body
                    .copyWith(color: colors.textPrimary),
                weekendTextStyle: AppTypography.body
                    .copyWith(color: colors.textSecondary),
                outsideTextStyle: AppTypography.body
                    .copyWith(color: colors.textTertiary),
                todayDecoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: AppTypography.body
                    .copyWith(color: colors.primary, fontWeight: FontWeight.bold),
                selectedDecoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: AppTypography.body
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox();
                  return Positioned(
                    bottom: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(3).map((color) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: color),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Day Agenda ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(_selectedDay),
                  style: AppTypography.heading2
                      .copyWith(color: colors.textPrimary),
                ),
                GestureDetector(
                  onTap: _showAddEventSheet,
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
                        Icon(LucideIcons.plus,
                            size: 14, color: colors.primary),
                        const SizedBox(width: 4),
                        Text('Add',
                            style: AppTypography.caption
                                .copyWith(color: colors.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.calendarOff,
                            size: 40, color: colors.surface3),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Nothing scheduled',
                            style: AppTypography.body
                                .copyWith(color: colors.textTertiary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                    itemCount: _selectedEvents.length,
                    itemBuilder: (ctx, i) => _AgendaItem(
                      event: _selectedEvents[i],
                      colors: colors,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventSheet,
        backgroundColor: colors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// AGENDA ITEM
// ══════════════════════════════════════════════════════════════════════════

class _AgendaItem extends StatelessWidget {
  const _AgendaItem({required this.event, required this.colors});
  final _CalendarEvent event;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: AppRadius.borderRadiusPill,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: AppTypography.body.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600)),
                Text('${event.time ?? ''} · ${event.category}',
                    style: AppTypography.caption
                        .copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Text(event.category,
                style: AppTypography.caption.copyWith(
                    color: event.color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// CREATE EVENT SHEET
// ══════════════════════════════════════════════════════════════════════════

class _CreateEventSheet extends StatefulWidget {
  const _CreateEventSheet({required this.initialDate, required this.onAdd});
  final DateTime initialDate;
  final void Function(_CalendarEvent event) onAdd;

  @override
  State<_CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<_CreateEventSheet> {
  final _titleCtrl = TextEditingController();
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  int _categoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (result != null) setState(() => _selectedDate = result);
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (result != null) setState(() => _selectedTime = result);
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) return;
    HapticFeedback.heavyImpact();
    final cat = _eventCategories[_categoryIndex];
    widget.onAdd(_CalendarEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      category: cat['label'] as String,
      color: cat['color'] as Color,
      time: _selectedTime?.format(context),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                Text('Add Event',
                    style: AppTypography.heading2
                        .copyWith(color: colors.textPrimary)),
                IconButton(
                  icon: Icon(LucideIcons.x, color: colors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            _Label('TITLE', colors),
            const SizedBox(height: AppSpacing.xs),
            _Input(ctrl: _titleCtrl, hint: 'e.g. Team Meeting', colors: colors),
            const SizedBox(height: AppSpacing.md),

            // Category
            _Label('CATEGORY', colors),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(_eventCategories.length, (i) {
                final cat = _eventCategories[i];
                final isSelected = i == _categoryIndex;
                final color = cat['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _categoryIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : colors.surface2,
                      borderRadius: AppRadius.borderRadiusPill,
                      border: Border.all(
                          color: isSelected ? color : colors.border),
                    ),
                    child: Text(
                      cat['label'] as String,
                      style: AppTypography.caption.copyWith(
                        color: isSelected ? color : colors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),

            // Date & Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('DATE', colors),
                      const SizedBox(height: AppSpacing.xs),
                      GestureDetector(
                        onTap: _pickDate,
                        child: _PickerBox(
                          icon: LucideIcons.calendar,
                          label: DateFormat('MMM d, yyyy')
                              .format(_selectedDate),
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
                      _Label('TIME', colors),
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
              child: PillButton(label: 'Add to Calendar', onTap: _submit),
            ),
          ],
        ),
      ),
    );
  }
}

// Helpers
class _Label extends StatelessWidget {
  const _Label(this.text, this.colors);
  final String text;
  final AppColorsExtension colors;
  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTypography.caption.copyWith(
          color: colors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8));
}

class _Input extends StatelessWidget {
  const _Input({required this.ctrl, required this.hint, required this.colors});
  final TextEditingController ctrl;
  final String hint;
  final AppColorsExtension colors;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: colors.border),
        ),
        child: TextField(
          controller: ctrl,
          autofocus: true,
          style: AppTypography.body.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTypography.body.copyWith(color: colors.textTertiary),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      );
}

class _PickerBox extends StatelessWidget {
  const _PickerBox(
      {required this.icon, required this.label, required this.colors});
  final IconData icon;
  final String label;
  final AppColorsExtension colors;
  @override
  Widget build(BuildContext context) => Container(
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
              child: Text(label,
                  style:
                      AppTypography.body.copyWith(color: colors.textPrimary),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
}
