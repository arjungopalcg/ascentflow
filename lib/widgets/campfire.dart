import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CAMPFIRE — the streak symbol. A small flame that flickers, grows with the
// streak ([intensity] 0–1), and goes out (grey embers) when the streak is 0.
// ─────────────────────────────────────────────────────────────────────────────

class Campfire extends StatefulWidget {
  const Campfire({super.key, this.size = 24, this.intensity = 0.5, this.lit = true});

  final double size;
  final double intensity;
  final bool lit;

  @override
  State<Campfire> createState() => _CampfireState();
}

class _CampfireState extends State<Campfire> with SingleTickerProviderStateMixin {
  late final AnimationController _flicker = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (still || !widget.lit) {
      _flicker.stop();
    } else if (!_flicker.isAnimating) {
      _flicker.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant Campfire old) {
    super.didUpdateWidget(old);
    if (old.lit != widget.lit) didChangeDependencies();
  }

  @override
  void dispose() {
    _flicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _flicker,
        builder: (context, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _FlamePainter(
            t: _flicker.value,
            intensity: widget.intensity.clamp(0, 1).toDouble(),
            lit: widget.lit,
          ),
        ),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({required this.t, required this.intensity, required this.lit});

  final double t;
  final double intensity;
  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Logs
    final log = Paint()..color = const Color(0xFF8E5A33);
    canvas.save();
    canvas.translate(w / 2, h * 0.88);
    for (final a in [-0.35, 0.35]) {
      canvas.save();
      canvas.rotate(a);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w * 0.8, height: h * 0.13), Radius.circular(h * 0.06)),
        log,
      );
      canvas.restore();
    }
    canvas.restore();

    if (!lit) {
      final ember = Paint()..color = const Color(0xFFB0BCC6);
      canvas.drawCircle(Offset(w * 0.5, h * 0.72), w * 0.09, ember);
      canvas.drawCircle(Offset(w * 0.38, h * 0.76), w * 0.05, ember);
      return;
    }

    final sway = math.sin(t * 2 * math.pi) * 0.06;
    final grow = 0.75 + 0.25 * intensity + math.sin(t * 4 * math.pi) * 0.03;
    Path flame(double scale, double lean) {
      final base = Offset(w * 0.5, h * 0.82);
      final top = Offset(w * (0.5 + lean), h * (0.82 - 0.72 * scale * grow));
      return Path()
        ..moveTo(base.dx - w * 0.28 * scale, base.dy)
        ..quadraticBezierTo(base.dx - w * 0.34 * scale, base.dy - h * 0.34 * scale, top.dx, top.dy)
        ..quadraticBezierTo(base.dx + w * 0.34 * scale, base.dy - h * 0.34 * scale, base.dx + w * 0.28 * scale, base.dy)
        ..close();
    }

    canvas.drawPath(flame(1.0, sway), Paint()..color = AppColors.campfireDeep);
    canvas.drawPath(flame(0.72, -sway * 0.8), Paint()..color = AppColors.campfire);
    canvas.drawPath(flame(0.42, sway * 0.5), Paint()..color = const Color(0xFFFFE08A));
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) =>
      old.t != t || old.intensity != intensity || old.lit != lit;
}
