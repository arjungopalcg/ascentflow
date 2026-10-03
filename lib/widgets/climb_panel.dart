import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CLIMB PANEL — Today's progress drawn as a climb.
// The ridge is a fixed elevation profile; the solid part is how far you've
// come (done / total), the marker is where you are, the flag is the summit.
// This is the app's one bold element — everything around it stays quiet.
// ─────────────────────────────────────────────────────────────────────────────

class ClimbPanel extends StatefulWidget {
  const ClimbPanel({
    super.key,
    required this.done,
    required this.total,
    this.nextUp,
  });

  final int done;
  final int total;

  /// The next unfinished item, shown under the profile.
  final String? nextUp;

  @override
  State<ClimbPanel> createState() => _ClimbPanelState();
}

class _ClimbPanelState extends State<ClimbPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _draw;

  @override
  void initState() {
    super.initState();
    _draw = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // One orchestrated moment: the ridge draws in once. Skipped entirely
    // when the user has asked the system to reduce motion.
    if (MediaQuery.of(context).disableAnimations) {
      _draw.value = 1;
    } else if (!_draw.isAnimating && _draw.value == 0) {
      _draw.forward();
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = widget.total == 0 ? 0.0 : widget.done / widget.total;
    final reachedSummit = widget.total > 0 && widget.done >= widget.total;
    // Deep lake water in both themes; text sits on it in snow white.
    final panel = colors.isDark ? const Color(0xFF1F4A5E) : AppColors.primaryLight;
    const ink = Color(0xFFF3F7F9);

    final headline = widget.total == 0
        ? 'No climb planned yet'
        : reachedSummit
            ? 'Summit reached'
            : '${widget.done} of ${widget.total} done';

    return Semantics(
      label: 'Today\'s climb. $headline.',
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: panel,
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _draw,
                builder: (context, _) => CustomPaint(
                  painter: _ClimbPainter(
                    progress: progress,
                    reveal: Curves.easeInOutCubic.transform(_draw.value),
                    line: ink,
                    summit: colors.isDark
                        ? AppColors.summitDark
                        : const Color(0xFFF6A3AE),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s climb',
                    style: AppTypography.label.copyWith(
                      color: ink.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    headline,
                    style: AppTypography.display.copyWith(color: ink),
                  ),
                  // Room for the drawn ridge.
                  const SizedBox(height: 92),
                  Row(
                    children: [
                      Icon(
                        reachedSummit ? LucideIcons.mountainSnow : LucideIcons.footprints,
                        size: 16,
                        color: ink.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          reachedSummit
                              ? 'Everything on today\'s plan is done.'
                              : widget.nextUp == null
                                  ? 'Add a task to start the climb.'
                                  : 'Next: ${widget.nextUp}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(color: ink),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClimbPainter extends CustomPainter {
  _ClimbPainter({
    required this.progress,
    required this.reveal,
    required this.line,
    required this.summit,
  });

  final double progress;
  final double reveal;
  final Color line;
  final Color summit;

  // Elevation profile: x across the day, y as height (0 = top).
  static const _ridge = [
    Offset(0.00, 0.92), Offset(0.10, 0.80), Offset(0.18, 0.85),
    Offset(0.30, 0.62), Offset(0.39, 0.70), Offset(0.52, 0.45),
    Offset(0.60, 0.53), Offset(0.73, 0.33), Offset(0.82, 0.40),
    Offset(0.94, 0.20), Offset(1.00, 0.24),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintContours(canvas, size);

    // The ridge lives in a band in the lower-middle of the panel.
    final band = Rect.fromLTWH(
      AppSpacing.lg, size.height * 0.40,
      size.width - AppSpacing.lg * 2, size.height * 0.36,
    );
    final pts = [
      for (final p in _ridge)
        Offset(band.left + p.dx * band.width, band.top + p.dy * band.height),
    ];
    final ridge = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      ridge.lineTo(p.dx, p.dy);
    }

    // Ground under the ridge.
    final ground = Path()
      ..moveTo(0, pts.first.dy)
      ..addPolygon(pts, false)
      ..lineTo(size.width, pts.last.dy)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(ground, Paint()..color = line.withValues(alpha: 0.07 * reveal));

    final metric = ridge.computeMetrics().first;
    final drawn = metric.length * reveal;

    // The whole route, faint.
    canvas.drawPath(
      metric.extractPath(0, drawn),
      Paint()
        ..color = line.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );

    // The part already climbed, solid.
    final climbed = math.min(drawn, metric.length * progress);
    if (climbed > 0) {
      canvas.drawPath(
        metric.extractPath(0, climbed),
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Summit flag.
    if (reveal > 0.95) {
      final top = pts[pts.length - 2];
      final pole = Paint()
        ..color = line
        ..strokeWidth = 1.5;
      canvas.drawLine(top, top.translate(0, -18), pole);
      canvas.drawPath(
        Path()
          ..moveTo(top.dx, top.dy - 18)
          ..lineTo(top.dx + 12, top.dy - 14)
          ..lineTo(top.dx, top.dy - 10)
          ..close(),
        Paint()..color = summit,
      );
    }

    // You are here.
    final here = metric.getTangentForOffset(climbed)?.position ?? pts.first;
    canvas.drawCircle(here, 7, Paint()..color = line);
    canvas.drawCircle(here, 3.5, Paint()..color = summit);
  }

  /// Faint topographic contour lines around an off-panel peak.
  void _paintContours(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = line.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final centre = Offset(size.width * 0.86, size.height * 0.05);
    for (var i = 1; i <= 7; i++) {
      final r = 34.0 * i;
      final path = Path();
      for (var a = 0; a <= 72; a++) {
        final t = a / 72 * 2 * math.pi;
        final wobble = 1 + 0.07 * math.sin(3 * t + i) + 0.04 * math.cos(5 * t - i);
        final p = centre + Offset(math.cos(t) * r * 1.35 * wobble, math.sin(t) * r * wobble);
        a == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClimbPainter old) =>
      old.progress != progress || old.reveal != reveal || old.line != line;
}
