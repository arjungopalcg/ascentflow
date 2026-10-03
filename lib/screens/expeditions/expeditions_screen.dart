import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/typography.dart';
import '../../game/climb_engine.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/campfire.dart';
import '../../widgets/common.dart';
import '../../widgets/pip.dart';
import '../../widgets/summit_postcard.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EXPEDITIONS — every metre you earn climbs a real mountain. Shows the peak in
// progress (with Pip on the slope), your streak, and the whole range from
// Ben Nevis to Everest. Summited peaks have a postcard to share.
// ─────────────────────────────────────────────────────────────────────────────

class ExpeditionsScreen extends ConsumerWidget {
  const ExpeditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final climb = ref.watch(climbProvider);
    final streak = ref.read(climbProvider.notifier).displayStreak;
    final name = ref.watch(userProfileProvider.select((p) => p.name));
    final exp = climb.expedition;
    final n = NumberFormat.decimalPattern();

    return Scaffold(
      appBar: AppBar(title: const Text('Expeditions')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.xxl),
        children: [
          _CurrentPeak(peak: exp.peak, metres: exp.metres),
          const SizedBox(height: AppSpacing.lg),

          // Streak and camp
          Row(
            children: [
              Expanded(
                child: _Stat(
                  leading: Campfire(size: 30, lit: streak > 0, intensity: (streak / 30).clamp(0.2, 1).toDouble()),
                  value: '$streak',
                  label: 'day streak',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Stat(
                  leading: Icon(LucideIcons.tent, size: 28, color: AppColors.sky),
                  value: 'Camp ${climb.camp}',
                  label: '${climb.metresToNextCamp} m to go',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _Stat(leading: Icon(LucideIcons.flag, size: 26, color: colors.summit), value: '${climb.summitDays}', label: 'days summited')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Stat(
                  leading: Icon(LucideIcons.bed, size: 26, color: colors.textSecondary),
                  value: '${climb.restDays}',
                  label: climb.restDays == 1 ? 'rest day saved' : 'rest days saved',
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'Every 7-day streak saves a rest day (up to 2). A rest day covers a day you miss, so your campfire stays lit.',
              style: AppTypography.caption.copyWith(color: colors.textSecondary),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          const EyebrowLabel('The range'),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < expeditions.length; i++)
            _PeakRow(
              peak: expeditions[i],
              status: i < exp.index
                  ? _PeakStatus.summited
                  : i == exp.index
                      ? _PeakStatus.climbing
                      : _PeakStatus.ahead,
              progress: i == exp.index ? exp.metres / exp.peak.metres : null,
              onPostcard: () => showPostcardSheet(context, peak: expeditions[i], name: name),
              metresLabel: '${n.format(expeditions[i].metres)} m',
            ),
        ],
      ),
    );
  }
}

class _CurrentPeak extends StatelessWidget {
  const _CurrentPeak({required this.peak, required this.metres});
  final Peak peak;
  final int metres;

  @override
  Widget build(BuildContext context) {
    final isDark = context.colors.isDark;
    final progress = (metres / peak.metres).clamp(0.0, 1.0);
    final n = NumberFormat.decimalPattern();
    const ink = Color(0xFFF7FBFF);

    return Container(
      height: 340,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? AppColors.skyNight : AppColors.sky,
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          // Pip's spot on the slope, from bottom-left foot to the summit.
          final foot = Offset(w * 0.08, h * 0.92), top = Offset(w * 0.62, h * 0.46);
          final pip = Offset.lerp(foot, top, progress)!;
          return Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _SlopePainter(progress: progress))),
              Positioned(
                left: AppSpacing.lg,
                top: AppSpacing.md,
                right: AppSpacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Now climbing', style: AppTypography.label.copyWith(color: ink.withValues(alpha: 0.85))),
                    Text(peak.name, style: AppTypography.display.copyWith(color: ink)),
                    Text(
                      '${n.format(metres)} of ${n.format(peak.metres)} m, ${peak.region}',
                      style: AppTypography.label.copyWith(color: ink),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: pip.dx - 30,
                top: pip.dy - 58,
                child: const Pip(size: 60),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SlopePainter extends CustomPainter {
  _SlopePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final mountain = Path()
      ..moveTo(0, h)
      ..lineTo(w * 0.08, h * 0.92)
      ..lineTo(w * 0.62, h * 0.46)
      ..lineTo(w * 0.86, h * 0.62)
      ..lineTo(w, h * 0.55)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(mountain, Paint()..color = Colors.white.withValues(alpha: 0.18));
    final snow = Path()
      ..moveTo(w * 0.53, h * 0.55)
      ..lineTo(w * 0.62, h * 0.46)
      ..lineTo(w * 0.70, h * 0.56)
      ..lineTo(w * 0.65, h * 0.54)
      ..lineTo(w * 0.62, h * 0.58)
      ..lineTo(w * 0.58, h * 0.54)
      ..close();
    canvas.drawPath(snow, Paint()..color = Colors.white.withValues(alpha: 0.6));

    // The ridge route: solid where you've climbed, faint ahead.
    final a = Offset(w * 0.08, h * 0.92), b = Offset(w * 0.62, h * 0.46);
    final here = Offset.lerp(a, b, progress)!;
    canvas.drawLine(here, b, Paint()..color = Colors.white.withValues(alpha: 0.35)..strokeWidth = 4..strokeCap = StrokeCap.round);
    canvas.drawLine(a, here, Paint()..color = Colors.white..strokeWidth = 6..strokeCap = StrokeCap.round);
    // Flag on top.
    canvas.drawLine(b, b.translate(0, -26), Paint()..color = Colors.white..strokeWidth = 2.5);
    canvas.drawPath(
      Path()
        ..moveTo(b.dx, b.dy - 26)
        ..lineTo(b.dx + 18, b.dy - 20)
        ..lineTo(b.dx, b.dy - 14)
        ..close(),
      Paint()..color = AppColors.summitDark,
    );
  }

  @override
  bool shouldRepaint(covariant _SlopePainter old) => old.progress != progress;
}

class _Stat extends StatelessWidget {
  const _Stat({required this.leading, required this.value, required this.label});
  final Widget leading;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: colors.border, width: 2),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTypography.heading1.copyWith(color: colors.textPrimary, fontSize: 22)),
                Text(label, style: AppTypography.caption.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _PeakStatus { summited, climbing, ahead }

class _PeakRow extends StatelessWidget {
  const _PeakRow({
    required this.peak,
    required this.status,
    required this.onPostcard,
    required this.metresLabel,
    this.progress,
  });

  final Peak peak;
  final _PeakStatus status;
  final double? progress;
  final VoidCallback onPostcard;
  final String metresLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, tone) = switch (status) {
      _PeakStatus.summited => (LucideIcons.mountainSnow, colors.summit),
      _PeakStatus.climbing => (LucideIcons.mountain, AppColors.sky),
      _PeakStatus.ahead => (LucideIcons.mountain, colors.textTertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: colors.isDark ? 0.2 : 0.14),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(icon, color: tone, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peak.name,
                  style: AppTypography.heading2.copyWith(
                    color: status == _PeakStatus.ahead ? colors.textSecondary : colors.textPrimary,
                  ),
                ),
                Text('$metresLabel, ${peak.region}', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
                if (progress != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusPill,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: colors.surface2,
                      valueColor: const AlwaysStoppedAnimation(AppColors.sky),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (status == _PeakStatus.summited)
            TextButton(onPressed: onPostcard, child: const Text('Postcard')),
        ],
      ),
    );
  }
}
