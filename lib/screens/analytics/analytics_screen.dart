import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math' as math;

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  int _selectedTimeframe = 0; // 0: 7 Days, 1: 30 Days

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 1000)
    )..forward();
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Analytics', style: AppTypography.heading1.copyWith(color: colors.textPrimary)),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: FadeTransition(
          opacity: _animController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Yesterday's Narrative
              _YesterdaySummary(colors: colors),
              const SizedBox(height: AppSpacing.xl),

              // 2. Highlights
              const EyebrowLabel('YOUR HIGHLIGHTS'),
              const SizedBox(height: AppSpacing.sm),
              _HighlightsRow(colors: colors),
              const SizedBox(height: AppSpacing.xl),

              // 3. Actionable Insights
              const EyebrowLabel('AI INSIGHTS'),
              const SizedBox(height: AppSpacing.sm),
              _InsightsList(colors: colors),
              const SizedBox(height: AppSpacing.xl),

              // 4. Heatmap View
              const EyebrowLabel('Goal check-ins, last 13 weeks'),
              const SizedBox(height: AppSpacing.sm),
              _GoalHeatmap(colors: colors),
              const SizedBox(height: AppSpacing.xl),

              // 5. Category Breakdown
              const EyebrowLabel('Where your tasks go'),
              const SizedBox(height: AppSpacing.sm),
              _CategoryBreakdown(colors: colors),
              const SizedBox(height: AppSpacing.xl),

              // 6. Graphical Analysis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Expanded(child: EyebrowLabel('Tasks finished per day')),
                   // Timeframe selector
                   Row(
                     children: [
                       _TimeframeChip(label: 'Week', isSelected: _selectedTimeframe == 0, onTap: () => setState(() => _selectedTimeframe = 0), colors: colors),
                       const SizedBox(width: AppSpacing.xs),
                       _TimeframeChip(label: 'Month', isSelected: _selectedTimeframe == 1, onTap: () => setState(() => _selectedTimeframe = 1), colors: colors),
                     ],
                   )
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _TrendChart(colors: colors, isMonthly: _selectedTimeframe == 1),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _YesterdaySummary extends StatelessWidget {
  const _YesterdaySummary({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return ElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, size: 16, color: colors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Yesterday in review', style: AppTypography.heading3.copyWith(color: colors.textPrimary))),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You had a highly productive Tuesday, clearing 6 tasks and logging 90 mins of deep focus. Your mood dropped slightly in the afternoon, but you recovered after your 4pm walk.',
            style: AppTypography.body.copyWith(color: colors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _HighlightsRow extends StatelessWidget {
  const _HighlightsRow({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _HighlightCard(icon: LucideIcons.flame, title: 'Longest streak', value: '14 days', color: colors.summit, colors: colors),
          _HighlightCard(icon: LucideIcons.checkCircle, title: 'Top category', value: 'Work', color: colors.primary, colors: colors),
          _HighlightCard(icon: LucideIcons.smile, title: 'Best mood', value: 'Fridays', color: colors.primary, colors: colors),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon, required this.title, required this.value, required this.color, required this.colors
  });
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const Spacer(),
          Text(title, style: AppTypography.caption.copyWith(color: colors.textTertiary)),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
        ],
      ),
    );
  }
}

class _InsightsList extends StatelessWidget {
  const _InsightsList({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: Column(
        children: [
          _InsightRow(
            text: 'You complete 40% more tasks on days you journal. Try journaling before 9am.',
            colors: colors,
          ),
          Divider(color: colors.border, height: 24),
          _InsightRow(
            text: 'Your focus time drops sharply after 3pm. Schedule admin and emails then.',
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.text, required this.colors});
  final String text;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(LucideIcons.lightbulb, size: 18, color: colors.textTertiary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(text, style: AppTypography.body.copyWith(color: colors.textSecondary)),
        ),
      ],
    );
  }
}

// MOCK HEATMAP
class _GoalHeatmap extends StatelessWidget {
  const _GoalHeatmap({required this.colors});
  final AppColorsExtension colors;

  static const _weeks = 13;
  static const _gap = 3.0;

  @override
  Widget build(BuildContext context) {
    // Sequential: one hue, light to dark. Steps are mixed (not faded with
    // alpha) so the legend swatches match the cells exactly.
    final levels = [
      for (final t in [0.0, 0.3, 0.55, 0.8, 1.0])
        Color.lerp(colors.surface2, colors.primary, t)!,
    ];
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cell = (constraints.maxWidth - _gap * (_weeks - 1)) / _weeks;
              return Row(
                children: [
                  for (var w = 0; w < _weeks; w++)
                    Padding(
                      padding: EdgeInsets.only(right: w == _weeks - 1 ? 0 : _gap),
                      child: Column(
                        children: [
                          for (var d = 0; d < 7; d++)
                            Container(
                              width: cell,
                              height: cell,
                              margin: EdgeInsets.only(bottom: d == 6 ? 0 : _gap),
                              decoration: BoxDecoration(
                                // Sample data until goal check-ins are stored.
                                color: levels[(math.Random(w * 7 + d).nextDouble() * 5).floor()],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Fewer check-ins', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
              const SizedBox(width: 6),
              for (final c in levels) _LegendBlock(c),
              const SizedBox(width: 6),
              Text('More', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendBlock extends StatelessWidget {
  const _LegendBlock(this.color);
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 10, height: 10, margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
  );
}

// CATEGORY BREAKDOWN — ranked bars. Each bar is labelled, so one hue is
// enough; status colours stay reserved for status.
class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.colors});
  final AppColorsExtension colors;

  static const _shares = [('Work', 40), ('Personal', 30), ('Health', 15), ('Finance', 15)];

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: Column(
        children: [
          for (final (label, pct) in _shares)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 76,
                    child: Text(label, style: AppTypography.label.copyWith(color: colors.textPrimary)),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) => Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: c.maxWidth * pct / 100,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '$pct%',
                      textAlign: TextAlign.right,
                      style: AppTypography.label.copyWith(
                        color: colors.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
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


class _TimeframeChip extends StatelessWidget {
  const _TimeframeChip({required this.label, required this.isSelected, required this.onTap, required this.colors});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(color: isSelected ? colors.primary : colors.border),
        ),
        child: Text(label, style: AppTypography.caption.copyWith(color: isSelected ? colors.primary : colors.textTertiary)),
      ),
    );
  }
}

// LINE CHART
class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.colors, required this.isMonthly});
  final AppColorsExtension colors;
  final bool isMonthly;

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            // Recessive horizontal grid only; no chart border.
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: 2,
              getDrawingHorizontalLine: (_) => FlLine(color: colors.border, strokeWidth: 1),
            ),
            minY: 0,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => colors.textPrimary,
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    LineTooltipItem(
                      '${s.y.toInt()} tasks',
                      AppTypography.caption.copyWith(color: colors.background, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: isMonthly ? 5 : 1,
                  getTitlesWidget: (val, meta) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    final text = isMonthly ? 'Day ${val.toInt() + 1}' : days[val.toInt() % 7];
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(text, style: AppTypography.caption.copyWith(color: colors.textSecondary)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  reservedSize: 24,
                  getTitlesWidget: (val, meta) => Text(
                    val.toInt().toString(),
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: isMonthly 
                  ? const [FlSpot(0, 3), FlSpot(5, 4), FlSpot(10, 2), FlSpot(15, 6), FlSpot(20, 8), FlSpot(25, 7), FlSpot(30, 9)]
                  : const [FlSpot(0, 1), FlSpot(1, 4), FlSpot(2, 2), FlSpot(3, 8), FlSpot(4, 5), FlSpot(5, 7), FlSpot(6, 9)],
                isCurved: true,
                color: colors.primary,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: colors.primary.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
