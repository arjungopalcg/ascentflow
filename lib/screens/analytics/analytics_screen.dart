import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
        title: Text('Analytics', style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
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
              const EyebrowLabel('GOAL ACTIVITY (LAST 90 DAYS)'),
              const SizedBox(height: AppSpacing.sm),
              _GoalHeatmap(colors: colors),
              const SizedBox(height: AppSpacing.xl),

              // 5. Category Breakdown
              const EyebrowLabel('TASK DISTRIBUTION'),
              const SizedBox(height: AppSpacing.sm),
              _CategoryBreakdown(colors: colors),
              const SizedBox(height: AppSpacing.xl),

              // 6. Graphical Analysis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const EyebrowLabel('TRENDS'),
                   // Timeframe selector
                   Row(
                     children: [
                       _TimeframeChip(label: '7D', isSelected: _selectedTimeframe == 0, onTap: () => setState(() => _selectedTimeframe = 0), colors: colors),
                       const SizedBox(width: AppSpacing.xs),
                       _TimeframeChip(label: '30D', isSelected: _selectedTimeframe == 1, onTap: () => setState(() => _selectedTimeframe = 1), colors: colors),
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
              Text('Yesterday in Review', style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
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
          _HighlightCard(icon: LucideIcons.flame, title: 'Longest Streak', value: '14 Days', color: colors.amber, colors: colors),
          _HighlightCard(icon: LucideIcons.checkCircle, title: 'Top Category', value: 'Work', color: colors.mint, colors: colors),
          _HighlightCard(icon: LucideIcons.smile, title: 'Best Mood', value: 'Friday', color: colors.primary, colors: colors),
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
        Icon(LucideIcons.lightbulb, size: 18, color: colors.primaryLighter),
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

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // days in week
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 14 * 7, // 14 weeks
              itemBuilder: (context, index) {
                // Random intensity
                final intensity = math.Random(index).nextDouble();
                Color cellColor = colors.surface3;
                if (intensity > 0.8) {
                  cellColor = colors.primary;
                } else if (intensity > 0.6) {
                  cellColor = colors.primary.withValues(alpha: 0.7);
                } else if (intensity > 0.4) {
                  cellColor = colors.primary.withValues(alpha: 0.4);
                } else if (intensity > 0.2) {
                  cellColor = colors.primary.withValues(alpha: 0.2);
                }
                
                return Container(
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: AppTypography.caption.copyWith(color: colors.textTertiary)),
              const SizedBox(width: 4),
              _LegendBlock(colors.surface3),
              _LegendBlock(colors.primary.withValues(alpha: 0.3)),
              _LegendBlock(colors.primary.withValues(alpha: 0.6)),
              _LegendBlock(colors.primary),
              const SizedBox(width: 4),
              Text('More', style: AppTypography.caption.copyWith(color: colors.textTertiary)),
            ],
          )
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

// DONUT CHART
class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(color: colors.primary, value: 40, title: '', radius: 20),
                    PieChartSectionData(color: colors.mint, value: 30, title: '', radius: 20),
                    PieChartSectionData(color: colors.amber, value: 15, title: '', radius: 20),
                    PieChartSectionData(color: colors.danger, value: 15, title: '', radius: 20),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendRow(color: colors.primary, label: 'Work (40%)', colors: colors),
                  _LegendRow(color: colors.mint, label: 'Personal (30%)', colors: colors),
                  _LegendRow(color: colors.amber, label: 'Health (15%)', colors: colors),
                  _LegendRow(color: colors.danger, label: 'Finance (15%)', colors: colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label, required this.colors});
  final Color color;
  final String label;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.body.copyWith(color: colors.textSecondary)),
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
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, meta) {
                    if (val % 2 != 0) return const SizedBox();
                    return Text(val.toInt().toString(), style: AppTypography.caption.copyWith(color: colors.textTertiary));
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: isMonthly 
                  ? const [FlSpot(0, 3), FlSpot(5, 4), FlSpot(10, 2), FlSpot(15, 6), FlSpot(20, 8), FlSpot(25, 7), FlSpot(30, 9)]
                  : const [FlSpot(0, 1), FlSpot(1, 4), FlSpot(2, 2), FlSpot(3, 8), FlSpot(4, 5), FlSpot(5, 7), FlSpot(6, 9)],
                isCurved: true,
                color: colors.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: colors.primary.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
