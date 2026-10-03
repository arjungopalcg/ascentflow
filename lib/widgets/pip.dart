import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PIP — AscentFlow's marmot guide. Drawn in code (no assets), with a few
// moods. Pip breathes and blinks while idle, waves hello, jumps when you win,
// and naps while you focus. All motion stops when the system asks to reduce
// motion.
// ─────────────────────────────────────────────────────────────────────────────

enum PipMood { idle, wave, cheer, sleep, oops }

class Pip extends StatefulWidget {
  const Pip({super.key, this.size = 96, this.mood = PipMood.idle});

  final double size;
  final PipMood mood;

  @override
  State<Pip> createState() => _PipState();
}

class _PipState extends State<Pip> with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  );
  Timer? _blinkTimer;
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _sync();
  }

  @override
  void didUpdateWidget(covariant Pip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) _sync();
  }

  void _sync() {
    _blinkTimer?.cancel();
    if (_still) {
      _loop.stop();
      _loop.value = 0.25;
      return;
    }
    _loop.duration = Duration(
      milliseconds: switch (widget.mood) {
        PipMood.cheer => 700,
        PipMood.wave => 900,
        PipMood.sleep => 3200,
        PipMood.idle => 2600,
        PipMood.oops => 700,
      },
    );
    _loop.repeat();
    if (widget.mood != PipMood.sleep) _scheduleBlink();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 2200 + math.Random().nextInt(2400)), () async {
      if (!mounted) return;
      await _blink.forward();
      if (!mounted) return;
      await _blink.reverse();
      if (mounted) _scheduleBlink();
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _loop.dispose();
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = switch (widget.mood) {
      PipMood.cheer => 'Pip the marmot, cheering',
      PipMood.wave => 'Pip the marmot, waving',
      PipMood.sleep => 'Pip the marmot, napping',
      PipMood.oops => 'Pip the marmot, slipping',
      PipMood.idle => 'Pip the marmot',
    };
    return Semantics(
      label: label,
      image: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_loop, _blink]),
          builder: (context, _) => CustomPaint(
            size: Size.square(widget.size),
            painter: _PipPainter(
              t: _loop.value,
              blink: _blink.value,
              mood: widget.mood,
            ),
          ),
        ),
      ),
    );
  }
}

class _PipPainter extends CustomPainter {
  _PipPainter({required this.t, required this.blink, required this.mood});

  final double t;
  final double blink;
  final PipMood mood;

  static const _fur = Color(0xFFB8794A);
  static const _furDark = Color(0xFF8E5A33);
  static const _belly = Color(0xFFF0D6B0);
  static const _muzzle = Color(0xFFF7E7CD);
  static const _ink = Color(0xFF2A1E17);
  static const _hat = Color(0xFFE5507A);
  static const _hatBand = Color(0xFFC63C64);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    canvas.scale(s);
    final wave = math.sin(t * 2 * math.pi);

    // Ground shadow stays put while Pip moves.
    final jump = mood == PipMood.cheer ? (math.sin(t * math.pi)).abs() * 10 : 0.0;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 95), width: 46 - jump * 1.5, height: 6),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    canvas.save();
    canvas.translate(0, -jump);
    if (mood == PipMood.oops) {
      // A dizzy wobble.
      canvas.translate(50, 94);
      canvas.rotate(0.12 * wave);
      canvas.translate(-50, -94);
    }
    if (mood == PipMood.idle || mood == PipMood.sleep) {
      // Gentle breathing.
      final breathe = 1 + 0.018 * wave;
      canvas.translate(50, 94);
      canvas.scale(1, breathe);
      canvas.translate(-50, -94);
    }

    final fur = Paint()..color = _fur;

    // Feet
    final feet = Paint()..color = _furDark;
    canvas.drawOval(Rect.fromCenter(center: const Offset(39, 92), width: 15, height: 7), feet);
    canvas.drawOval(Rect.fromCenter(center: const Offset(61, 92), width: 15, height: 7), feet);

    // Body and belly
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 66), width: 58, height: 56), fur);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 71), width: 36, height: 38),
      Paint()..color = _belly,
    );

    // Arms
    final (leftUp, rightUp) = switch (mood) {
      PipMood.cheer => (1.0, 1.0),
      PipMood.wave => (0.0, 0.85 + 0.15 * wave),
      _ => (0.0, 0.0),
    };
    _arm(canvas, const Offset(27, 64), leftUp, mirror: true);
    _arm(canvas, const Offset(73, 64), rightUp);

    // Ears
    canvas.drawCircle(const Offset(31, 25), 6.5, fur);
    canvas.drawCircle(const Offset(69, 25), 6.5, fur);
    final inner = Paint()..color = _furDark;
    canvas.drawCircle(const Offset(31, 25), 3.2, inner);
    canvas.drawCircle(const Offset(69, 25), 3.2, inner);

    // Head
    canvas.drawCircle(const Offset(50, 38), 22, fur);

    // Beanie: crown, band, pompom.
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(0, 0, 100, 29));
    canvas.drawCircle(const Offset(50, 38), 23, Paint()..color = _hat);
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(26.5, 25, 47, 7), const Radius.circular(3.5)),
      Paint()..color = _hatBand,
    );
    canvas.drawCircle(const Offset(50, 13.5), 5, Paint()..color = const Color(0xFFFFF1F5));

    // Cheeks
    final cheek = Paint()..color = const Color(0xFFFF8FA6).withValues(alpha: 0.45);
    canvas.drawCircle(const Offset(35, 45), 3.6, cheek);
    canvas.drawCircle(const Offset(65, 45), 3.6, cheek);

    // Muzzle
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 47), width: 24, height: 15),
      Paint()..color = _muzzle,
    );

    // Eyes
    final ink = Paint()..color = _ink;
    if (mood == PipMood.sleep) {
      final closed = Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      for (final x in [41.0, 59.0]) {
        canvas.drawArc(Rect.fromCenter(center: Offset(x, 38), width: 7, height: 5), 0.15, math.pi - 0.3, false, closed);
      }
    } else if (mood == PipMood.oops) {
      // Squeezed "> <" eyes.
      final squeeze = Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(Path()..moveTo(38, 35)..lineTo(43, 38)..lineTo(38, 41), squeeze);
      canvas.drawPath(Path()..moveTo(62, 35)..lineTo(57, 38)..lineTo(62, 41), squeeze);
    } else if (mood == PipMood.cheer) {
      // Happy "^ ^" eyes.
      final happy = Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (final x in [41.0, 59.0]) {
        canvas.drawArc(Rect.fromCenter(center: Offset(x, 39), width: 7, height: 6), math.pi + 0.2, math.pi - 0.4, false, happy);
      }
    } else {
      final open = 1 - blink;
      for (final x in [41.0, 59.0]) {
        canvas.drawOval(Rect.fromCenter(center: Offset(x, 38), width: 6.4, height: 7 * open + 0.6), ink);
        if (open > 0.5) {
          canvas.drawCircle(Offset(x + 1.2, 36.6), 1.2, Paint()..color = Colors.white);
        }
      }
    }

    // Nose
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(50, 43.5), width: 6, height: 4), const Radius.circular(2)),
      Paint()..color = const Color(0xFF4A2E22),
    );

    // Mouth: open grin when cheering, "o" when slipping, otherwise a smile.
    if (mood == PipMood.oops) {
      canvas.drawOval(Rect.fromCenter(center: const Offset(50, 50), width: 5, height: 6), ink);
    } else if (mood == PipMood.cheer) {
      final mouth = Path()
        ..moveTo(44, 47.5)
        ..quadraticBezierTo(50, 57, 56, 47.5)
        ..close();
      canvas.drawPath(mouth, ink);
      canvas.drawOval(Rect.fromCenter(center: const Offset(50, 52), width: 6, height: 3), Paint()..color = const Color(0xFFFF7B93));
    } else {
      canvas.drawRect(const Rect.fromLTWH(48, 46, 4, 3.6), Paint()..color = Colors.white);
      canvas.drawLine(const Offset(50, 46), const Offset(50, 49.6), Paint()..color = _muzzle..strokeWidth = 0.6);
      final smile = Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCenter(center: const Offset(46.5, 46), width: 7, height: 5), 0.2, math.pi * 0.6, false, smile);
      canvas.drawArc(Rect.fromCenter(center: const Offset(53.5, 46), width: 7, height: 5), math.pi * 0.2, math.pi * 0.6, false, smile);
    }
    canvas.restore();

    // Floating Z's while napping.
    if (mood == PipMood.sleep) {
      for (var i = 0; i < 3; i++) {
        final p = (t + i / 3) % 1;
        final tp = TextPainter(
          text: TextSpan(
            text: 'z',
            style: TextStyle(
              fontSize: 9 + p * 7,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF7FA9C9).withValues(alpha: (1 - p) * 0.9),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(70 + p * 14, 22 - p * 20));
      }
    }
  }

  /// An arm hinged at the shoulder; [up] 0 = resting, 1 = raised overhead.
  void _arm(Canvas canvas, Offset shoulder, double up, {bool mirror = false}) {
    canvas.save();
    canvas.translate(shoulder.dx, shoulder.dy);
    final angle = (0.35 - up * 2.6) * (mirror ? -1 : 1);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-4.5, -2, 9, 20), const Radius.circular(4.5)),
      Paint()..color = _fur,
    );
    canvas.drawCircle(const Offset(0, 17), 4.6, Paint()..color = _furDark);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PipPainter old) =>
      old.t != t || old.blink != blink || old.mood != mood;
}
