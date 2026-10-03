import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/buttons.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMoodIndex = -1;
  final TextEditingController _textController = TextEditingController();
  int _wordCount = 0;
  bool _showAnalysis = false;
  bool _isRecording = false;
  DateTimeRange? _analysisRange;

  late final AnimationController _staggerController;

  static const _moods = [
    _Mood(emoji: '😢', label: 'Rough'),
    _Mood(emoji: '😕', label: 'Low'),
    _Mood(emoji: '😐', label: 'Okay'),
    _Mood(emoji: '🙂', label: 'Good'),
    _Mood(emoji: '😊', label: 'Great'),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _textController.addListener(() {
      final wc = _textController.text
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .length;
      if (wc != _wordCount) setState(() => _wordCount = wc);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _selectMood(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedMoodIndex = index);
  }

  void _toggleRecording() {
    HapticFeedback.lightImpact();
    setState(() {
      _isRecording = !_isRecording;
    });
    if (!_isRecording) {
      // Simulate transcribing complete
      final currentText = _textController.text;
      _textController.text = "$currentText${currentText.isNotEmpty ? ' ' : ''}What an amazing deep focus session. I feel incredibly productive and ready to tackle the rest of the day.";
    }
  }

  Future<void> _requestAnalysis() async {
    HapticFeedback.selectionClick();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.colors.primary,
              onPrimary: context.colors.textPrimary,
              surface: context.colors.surface1,
            ),
          ),
          child: child!,
        );
      },
    );
    if (range != null) {
      setState(() {
        _analysisRange = range;
        _showAnalysis = true;
      });
    }
  }

  String _formatDateRange() {
    if (_analysisRange == null) return '';
    return '${_analysisRange!.start.month}/${_analysisRange!.start.day} - ${_analysisRange!.end.month}/${_analysisRange!.end.day}';
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
            Text(
              'Journal',
              style: AppTypography.display.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Mood Check-in ───────────────────────────────────
            SolidCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EyebrowLabel('HOW ARE YOU FEELING?'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_moods.length, (i) {
                      final isSelected = i == _selectedMoodIndex;
                      return GestureDetector(
                        onTap: () => _selectMood(i),
                        child: AnimatedContainer(
                          duration: AppDuration.normal,
                          width: isSelected ? 58 : 48,
                          height: isSelected ? 58 : 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? colors.primary.withValues(alpha: 0.15)
                                : colors.surface2,
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : colors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: colors.primaryGlow,
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _moods[i].emoji,
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 22,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  if (_selectedMoodIndex >= 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Text(
                        _moods[_selectedMoodIndex].label,
                        style: AppTypography.label.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
              const SizedBox(height: AppSpacing.md),

            // ── Text Editor ─────────────────────────────────────
            SolidCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: colors.border, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        _ToolbarButton(icon: LucideIcons.bold, colors: colors),
                        _ToolbarButton(icon: LucideIcons.italic, colors: colors),
                        _ToolbarButton(icon: LucideIcons.list, colors: colors),
                        const Spacer(),
                        // Voice record button
                        GestureDetector(
                          onTap: _toggleRecording,
                          child: AnimatedContainer(
                            duration: AppDuration.fast,
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording 
                                  ? colors.danger 
                                  : colors.danger.withValues(alpha: 0.12),
                            ),
                            child: Icon(
                              LucideIcons.mic,
                              size: 16,
                              color: _isRecording ? Colors.white : colors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text area
                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      style: AppTypography.body.copyWith(
                        color: colors.textPrimary,
                        height: 1.7,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Start writing your thoughts...',
                        hintStyle: AppTypography.body.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: colors.border, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_wordCount words',
                          style: AppTypography.caption.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                        PillButton(
                          label: 'Save Entry',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Entry saved!', style: AppTypography.body.copyWith(color: Colors.white)), backgroundColor: colors.mint)
                            );
                            _textController.clear();
                          },
                          variant: PillButtonVariant.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── AI Analysis Request ──────────────────────────────
            SolidCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Row(
                     children: [
                       Icon(LucideIcons.sparkles, color: colors.primary),
                       const SizedBox(width: AppSpacing.sm),
                       Text('Analyse with AI', style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
                     ],
                   ),
                   const SizedBox(height: AppSpacing.sm),
                   Text('Select a date range to generate a comprehensive AI summary of your mood and writing patterns.', style: AppTypography.body.copyWith(color: colors.textSecondary)),
                   const SizedBox(height: AppSpacing.md),
                   PillButton(
                     label: _analysisRange == null ? 'Select Date Range' : 'Analyze ${_formatDateRange()}',
                     onTap: _requestAnalysis,
                     variant: PillButtonVariant.secondary,
                   ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── AI Mood Analysis Result ───────────────────────────
            if (_showAnalysis) _MoodAnalysisCard(colors: colors),
            if (_showAnalysis) const SizedBox(height: AppSpacing.md),

            // ── Calendar View ───────────────────────────────────
            _CalendarCard(colors: colors),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TOOLBAR BUTTON
// ═══════════════════════════════════════════════════════════════════════════

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.icon, required this.colors});
  final IconData icon;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(icon, size: 18, color: colors.textSecondary),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MOOD ANALYSIS CARD
// ═══════════════════════════════════════════════════════════════════════════

class _MoodAnalysisCard extends StatelessWidget {
  const _MoodAnalysisCard({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return ElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.brain, size: 18, color: colors.primary),
              const SizedBox(width: AppSpacing.xs),
              const EyebrowLabel('AI MOOD ANALYSIS'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Mock arc gauge
          Center(
            child: Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(50),
                ),
                border: Border.all(
                  color: colors.mint,
                  width: 4,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              'Mood Score: 7.5 / 10',
              style: AppTypography.bodyLarge.copyWith(
                color: colors.mint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your writing today shows a positive and reflective tone. You seem focused on gratitude, which is strongly correlated with sustained productivity.',
            style: AppTypography.body.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppChip(label: '📈 UPWARD TREND', variant: ChipVariant.mint),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CALENDAR CARD — Mood-colored dots
// ═══════════════════════════════════════════════════════════════════════════

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0=Sun

    // Mock mood data for some days
    final moodData = <int, Color>{
      3: AppColors.mint,
      5: AppColors.primaryDark,
      7: AppColors.amber,
      8: AppColors.mint,
      10: AppColors.mint,
      12: AppColors.danger,
      14: AppColors.primaryDark,
      15: AppColors.mint,
      17: AppColors.amber,
      18: AppColors.mint,
      20: AppColors.mint,
      21: AppColors.primaryDark,
    };

    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EyebrowLabel('MOOD CALENDAR'),
              Text(
                _monthName(now.month),
                style: AppTypography.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          d,
                          style: AppTypography.caption.copyWith(
                            color: colors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Calendar grid
          ...List.generate(6, (week) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayOfWeek) {
                  final dayNumber =
                      week * 7 + dayOfWeek - firstWeekday + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(width: 32, height: 32);
                  }

                  final isToday = dayNumber == now.day;
                  final moodColor = moodData[dayNumber];

                  return SizedBox(
                    width: 32,
                    height: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isToday)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        Text(
                          '$dayNumber',
                          style: AppTypography.caption.copyWith(
                            color: isToday
                                ? colors.primary
                                : colors.textSecondary,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 11,
                          ),
                        ),
                        if (moodColor != null)
                          Positioned(
                            bottom: 2,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: moodColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════════════

class _Mood {
  const _Mood({required this.emoji, required this.label});
  final String emoji;
  final String label;
}
