import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFETTI SNOW — falling flakes and paper in the app's celebration colours.
// [t] loops 0→1; each piece has its own speed, drift and spin.
// ─────────────────────────────────────────────────────────────────────────────

class ConfettiPainter extends CustomPainter {
  ConfettiPainter({required this.t, this.count = 70, this.seed = 7, this.opacity = 1});

  final double t;
  final int count;
  final int seed;
  final double opacity;

  static const _colors = [
    Colors.white,
    AppColors.summitDark,
    AppColors.campfire,
    AppColors.primaryDark,
    Color(0xFFFFE08A),
    Colors.white,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    for (var i = 0; i < count; i++) {
      final x0 = rnd.nextDouble();
      final speed = 0.6 + rnd.nextDouble() * 0.8;
      final phase = rnd.nextDouble();
      final drift = (rnd.nextDouble() - 0.5) * 0.15;
      final spin = (rnd.nextDouble() - 0.5) * 12;
      final w = 5 + rnd.nextDouble() * 6;
      final color = _colors[i % _colors.length];
      final p = (t * speed + phase) % 1;
      final x = (x0 + drift * math.sin(p * 2 * math.pi)) * size.width;
      final y = -20 + p * (size.height + 40);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(spin * p);
      final paint = Paint()..color = color.withValues(alpha: opacity * (i.isEven ? 0.95 : 0.8));
      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, w * 0.45, paint); // snowflake
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: w * 0.55), const Radius.circular(1.5)),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter old) => old.t != t || old.opacity != opacity;
}

/// A short radial burst of sparkles, [t] 0→1 once.
class BurstPainter extends CustomPainter {
  BurstPainter({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final c = size.center(Offset.zero);
    final ease = Curves.easeOutCubic.transform(t);
    final paint = Paint()
      ..color = color.withValues(alpha: 1 - t)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 10; i++) {
      final a = i / 10 * 2 * math.pi;
      final inner = 18 + 22 * ease;
      final outer = inner + 10 * (1 - t);
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * inner,
        c + Offset(math.cos(a), math.sin(a)) * outer,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BurstPainter old) => old.t != t;
}
