import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ASCENT MARK — the AscentFlow logo: two peaks, a snow line, and an
// alpenglow flag on the summit. Drawn, so it stays sharp at any size.
// The brand lives here, on the welcome screen and the app icon — not on Home.
// ─────────────────────────────────────────────────────────────────────────────

class AscentMark extends StatelessWidget {
  const AscentMark({
    super.key,
    this.size = 64,
    this.color = Colors.white,
    this.flag = AppColors.summitDark,
  });

  final double size;
  final Color color;
  final Color flag;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'AscentFlow',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _MarkPainter(color: color, flag: flag),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.color, required this.flag});

  final Color color;
  final Color flag;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Back peak, softer.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.44, h * 0.92)
        ..lineTo(w * 0.70, h * 0.40)
        ..lineTo(w * 0.98, h * 0.92)
        ..close(),
      Paint()..color = color.withValues(alpha: 0.45),
    );
    // Front peak.
    final summit = Offset(w * 0.40, h * 0.22);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.02, h * 0.92)
        ..lineTo(summit.dx, summit.dy)
        ..lineTo(w * 0.80, h * 0.92)
        ..close(),
      Paint()..color = color,
    );
    // Snow line: a cut across the front peak.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.27, h * 0.46)
        ..lineTo(w * 0.34, h * 0.52)
        ..lineTo(w * 0.41, h * 0.45)
        ..lineTo(w * 0.47, h * 0.51)
        ..lineTo(w * 0.53, h * 0.46),
      Paint()
        ..color = color.computeLuminance() > 0.5
            ? Colors.black.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, w * 0.035)
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    // Flag on the summit.
    final pole = Paint()
      ..color = color
      ..strokeWidth = math.max(1.2, w * 0.03)
      ..strokeCap = StrokeCap.round;
    final top = summit.translate(0, -h * 0.20);
    canvas.drawLine(summit, top, pole);
    canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy)
        ..lineTo(top.dx + w * 0.20, top.dy + h * 0.06)
        ..lineTo(top.dx, top.dy + h * 0.12)
        ..close(),
      Paint()..color = flag,
    );
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) =>
      old.color != color || old.flag != flag;
}

/// Faint topographic contour lines, for brand surfaces (welcome, climb panel).
class ContourPainter extends CustomPainter {
  ContourPainter({required this.color, this.centre = const Alignment(0.7, -0.9)});

  final Color color;
  final Alignment centre;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final c = centre.alongSize(size);
    final step = size.shortestSide / 7;
    for (var i = 1; i <= 12; i++) {
      final r = step * i * 0.6;
      final path = Path();
      for (var a = 0; a <= 90; a++) {
        final t = a / 90 * 2 * math.pi;
        final wobble = 1 + 0.07 * math.sin(3 * t + i) + 0.04 * math.cos(5 * t - i);
        final p = c + Offset(math.cos(t) * r * 1.35 * wobble, math.sin(t) * r * wobble);
        a == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ContourPainter old) =>
      old.color != color || old.centre != centre;
}
