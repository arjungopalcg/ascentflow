import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../game/climb_engine.dart';
import '../screens/main_scaffold.dart';
import 'ascent_mark.dart';
import 'pip.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TRAIL MAP — the Daily climb as a winding path up the mountain.
// Bottom to top: three task stops, a focus stop, a reflection stop, then the
// summit flag. Pip waits at the next stop. Tap a stop to go and do it.
// ─────────────────────────────────────────────────────────────────────────────

class _Stop {
  const _Stop(this.icon, this.label, this.tab);
  final IconData icon;
  final String label;
  final int tab;
}

const _stops = [
  _Stop(LucideIcons.squareCheck, 'Finish a task', AppTab.tasks),
  _Stop(LucideIcons.squareCheck, 'Finish a task', AppTab.tasks),
  _Stop(LucideIcons.squareCheck, 'Finish a task', AppTab.tasks),
  _Stop(LucideIcons.timer, 'Focus session', AppTab.focus),
  _Stop(LucideIcons.bookOpen, 'Reflect', AppTab.journal),
];

/// Horizontal position of each stop (0–1), zig-zagging up the slope.
const _xs = [0.30, 0.66, 0.36, 0.70, 0.40];

class TrailMap extends ConsumerWidget {
  const TrailMap({super.key});

  static const _height = 470.0;
  static const _node = 60.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final climb = ref.watch(climbProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final done = [
      for (var i = 0; i < 3; i++) climb.tasksToday > i,
      climb.focusToday > 0,
      climb.reflectToday > 0,
    ];
    final next = done.indexOf(false); // -1 when every stop is done
    final summited = next == -1;
    const ink = Color(0xFFF7FBFF);

    return Semantics(
      label: 'Daily climb: ${climb.stepsDone} of ${DailyClimb.steps} steps done.',
      child: Container(
        height: _height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.skyNight : AppColors.sky,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF12304A) : AppColors.skyDeep,
              width: 5,
            ),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            // Stops from bottom (index 0) to top; summit above the last stop.
            Offset at(int i) {
              final top = 150.0, bottom = _height - 70;
              final y = bottom - (bottom - top) * (i / (_stops.length - 1));
              return Offset(w * _xs[i], y);
            }

            final summit = Offset(w * 0.62, 92);
            final points = [for (var i = 0; i < _stops.length; i++) at(i), summit];

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Mountain, contours and the trail itself.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TrailPainter(
                      points: points,
                      reached: summited ? points.length - 1 : math.max(0, next),
                      isDark: isDark,
                    ),
                  ),
                ),
                // Header
                Positioned(
                  left: AppSpacing.lg,
                  top: AppSpacing.md,
                  right: AppSpacing.lg,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily climb',
                              style: AppTypography.label.copyWith(color: ink.withValues(alpha: 0.85)),
                            ),
                            Text(
                              summited
                                  ? 'Summit reached!'
                                  : '${climb.stepsDone} of ${DailyClimb.steps} steps',
                              style: AppTypography.display.copyWith(color: ink, fontSize: 30),
                            ),
                          ],
                        ),
                      ),
                      _Pill(text: '+${climb.metresToday} m today'),
                    ],
                  ),
                ),
                // Summit flag
                Positioned(
                  left: summit.dx - 22,
                  top: summit.dy - 46,
                  child: _SummitFlag(reached: summited),
                ),
                // Stops
                for (var i = 0; i < _stops.length; i++)
                  Positioned(
                    left: points[i].dx - _node / 2,
                    top: points[i].dy - _node / 2,
                    child: _StopNode(
                      stop: _stops[i],
                      state: done[i]
                          ? _NodeState.done
                          : i == next
                              ? _NodeState.next
                              : _NodeState.locked,
                      size: _node,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(navIndexProvider.notifier).state = _stops[i].tab;
                      },
                    ),
                  ),
                // Label beside the next stop
                if (!summited)
                  Positioned(
                    top: points[next].dy - 16,
                    left: _xs[next] < 0.5 ? points[next].dx + _node / 2 + 10 : null,
                    right: _xs[next] >= 0.5 ? w - points[next].dx + _node / 2 + 10 : null,
                    child: _Pill(text: _stops[next].label, strong: true),
                  ),
                // Pip, beside the next stop (or on the summit)
                Positioned(
                  left: summited
                      ? summit.dx - 92
                      : (_xs[next] < 0.5 ? points[next].dx - _node / 2 - 64 : points[next].dx + _node / 2 + 4),
                  top: summited ? summit.dy - 28 : points[next].dy - 34,
                  child: IgnorePointer(
                    child: Pip(size: 62, mood: summited ? PipMood.cheer : PipMood.idle),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum _NodeState { done, next, locked }

class _StopNode extends StatefulWidget {
  const _StopNode({required this.stop, required this.state, required this.size, required this.onTap});

  final _Stop stop;
  final _NodeState state;
  final double size;
  final VoidCallback onTap;

  @override
  State<_StopNode> createState() => _StopNodeState();
}

class _StopNodeState extends State<_StopNode> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _StopNode old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _syncPulse();
  }

  void _syncPulse() {
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.state == _NodeState.next && !still) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final (face, edge, iconColor) = switch (widget.state) {
      _NodeState.done => (AppColors.primaryLight, const Color(0xFF17773F), Colors.white),
      _NodeState.next => (Colors.white, const Color(0xFFC9D8E4), AppColors.skyDeep),
      _NodeState.locked => (const Color(0xFFB9D4EA), const Color(0xFF8FB4D3), Colors.white),
    };
    const edgeH = 5.0;

    return Semantics(
      button: true,
      label: '${widget.stop.label}, ${widget.state.name}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: SizedBox(
          width: s,
          height: s,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (widget.state == _NodeState.next)
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => Container(
                    width: s + 18 * _pulse.value,
                    height: s + 18 * _pulse.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.35 * (1 - _pulse.value)),
                    ),
                  ),
                ),
              // Edge, then face pressed into it.
              Positioned(
                top: edgeH,
                child: Container(
                  width: s,
                  height: s - edgeH,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: edge),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 60),
                top: _pressed ? edgeH : 0,
                child: Container(
                  width: s,
                  height: s - edgeH,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: face),
                  child: Icon(
                    widget.state == _NodeState.done ? LucideIcons.check : widget.stop.icon,
                    color: iconColor,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummitFlag extends StatelessWidget {
  const _SummitFlag({required this.reached});
  final bool reached;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 50,
      child: CustomPaint(painter: _FlagPainter(reached: reached)),
    );
  }
}

class _FlagPainter extends CustomPainter {
  _FlagPainter({required this.reached});
  final bool reached;

  @override
  void paint(Canvas canvas, Size size) {
    final pole = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.5, size.height), Offset(size.width * 0.5, 4), pole);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, 4)
        ..lineTo(size.width * 0.5 + 20, 11)
        ..lineTo(size.width * 0.5, 18)
        ..close(),
      Paint()..color = reached ? AppColors.summitDark : Colors.white.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _FlagPainter old) => old.reached != reached;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.strong = false});
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: strong ? Colors.white : Colors.white.withValues(alpha: 0.2),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text(
        text,
        style: AppTypography.label.copyWith(
          color: strong ? AppColors.skyDeep : Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  _TrailPainter({required this.points, required this.reached, required this.isDark});

  final List<Offset> points;
  final int reached;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // Contour lines in the sky, then the mountain the trail climbs.
    ContourPainter(color: Colors.white.withValues(alpha: 0.07), centre: const Alignment(0.9, -1.1))
        .paint(canvas, size);

    final back = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width * 0.22, size.height * 0.38)
      ..lineTo(size.width * 0.36, size.height * 0.46)
      ..lineTo(size.width * 0.62, size.height * 0.16)
      ..lineTo(size.width * 0.86, size.height * 0.42)
      ..lineTo(size.width, size.height * 0.34)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(back, Paint()..color = Colors.white.withValues(alpha: isDark ? 0.06 : 0.13));

    // Snow cap on the main peak.
    final cap = Path()
      ..moveTo(size.width * 0.53, size.height * 0.26)
      ..lineTo(size.width * 0.62, size.height * 0.16)
      ..lineTo(size.width * 0.71, size.height * 0.26)
      ..lineTo(size.width * 0.66, size.height * 0.24)
      ..lineTo(size.width * 0.62, size.height * 0.28)
      ..lineTo(size.width * 0.58, size.height * 0.24)
      ..close();
    canvas.drawPath(cap, Paint()..color = Colors.white.withValues(alpha: isDark ? 0.18 : 0.35));

    // Smooth trail through every stop.
    final path = Path()..moveTo(points.first.dx, points.first.dy + 40);
    path.lineTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1], b = points[i];
      final midY = (a.dy + b.dy) / 2;
      path.cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
    }

    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (s, m) => s + m.length);

    // Length along the path up to the reached stop.
    double lengthTo(int index) {
      final probe = Path()..moveTo(points.first.dx, points.first.dy + 40);
      probe.lineTo(points.first.dx, points.first.dy);
      for (var i = 1; i <= index; i++) {
        final a = points[i - 1], b = points[i];
        final midY = (a.dy + b.dy) / 2;
        probe.cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
      }
      return probe.computeMetrics().fold<double>(0, (s, m) => s + m.length);
    }

    final walked = lengthTo(reached).clamp(0, total).toDouble();

    // Dashed path ahead.
    final dash = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (final m in metrics) {
      for (var d = walked; d < m.length; d += 18) {
        canvas.drawPath(m.extractPath(d, math.min(d + 8, m.length)), dash);
      }
    }
    // Solid path already walked.
    final solid = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (final m in metrics) {
      canvas.drawPath(m.extractPath(0, math.min(walked, m.length)), solid);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter old) =>
      old.reached != reached || old.isDark != isDark || old.points != points;
}
