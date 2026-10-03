import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../game/climb_engine.dart';
import 'ascent_mark.dart';
import 'buttons.dart';
import 'pip.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SUMMIT POSTCARD — a shareable card for each real peak you summit:
// Pip with the flag on top, the peak's name and height, and the AscentFlow
// mark. Captured as an image and handed to the system share sheet.
// ─────────────────────────────────────────────────────────────────────────────

class SummitPostcard extends StatelessWidget {
  const SummitPostcard({super.key, required this.peak, this.name = ''});

  final Peak peak;
  final String name;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFFF7FBFF);
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.skyDeep,
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PostcardPainter(),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              top: 70,
              child: Center(child: Pip(size: 120, mood: PipMood.cheer)),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'Summit reached' : '$name reached the summit',
                    style: AppTypography.label.copyWith(color: ink.withValues(alpha: 0.85)),
                  ),
                  Text(peak.name, style: AppTypography.displayXl.copyWith(color: ink, fontSize: 46)),
                  Text(
                    '${_fmt(peak.metres)} m, ${peak.region}',
                    style: AppTypography.bodyLarge.copyWith(color: ink),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const AscentMark(size: 22, color: ink),
                      const SizedBox(width: 8),
                      Text('AscentFlow', style: AppTypography.heading3.copyWith(color: ink)),
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

  static String _fmt(int m) => m.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (x) => '${x[1]},');
}

class _PostcardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    ContourPainter(color: Colors.white.withValues(alpha: 0.08), centre: const Alignment(0.8, -0.9)).paint(canvas, size);
    final w = size.width, h = size.height;
    // Alpenglow sky band behind the peak.
    canvas.drawCircle(Offset(w * 0.5, h * 0.36), w * 0.42, Paint()..color = AppColors.summitDark.withValues(alpha: 0.18));
    final peak = Path()
      ..moveTo(0, h * 0.68)
      ..lineTo(w * 0.28, h * 0.5)
      ..lineTo(w * 0.5, h * 0.34)
      ..lineTo(w * 0.72, h * 0.5)
      ..lineTo(w, h * 0.62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(peak, Paint()..color = Colors.white.withValues(alpha: 0.16));
    final snow = Path()
      ..moveTo(w * 0.40, h * 0.41)
      ..lineTo(w * 0.5, h * 0.34)
      ..lineTo(w * 0.60, h * 0.41)
      ..lineTo(w * 0.55, h * 0.40)
      ..lineTo(w * 0.5, h * 0.43)
      ..lineTo(w * 0.45, h * 0.40)
      ..close();
    canvas.drawPath(snow, Paint()..color = Colors.white.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Shows the postcard in a sheet with a Share button.
Future<void> showPostcardSheet(BuildContext context, {required Peak peak, String name = ''}) {
  final key = GlobalKey();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: RepaintBoundary(key: key, child: SummitPostcard(peak: peak, name: name)),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: 'Share postcard',
                icon: LucideIcons.share2,
                onTap: () => sharePostcard(key, peak),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Captures the postcard under [key] and opens the share sheet.
Future<void> sharePostcard(GlobalKey key, Peak peak) async {
  final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return;
  final image = await boundary.toImage(pixelRatio: 3);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) return;
  await SharePlus.instance.share(
    ShareParams(
      text: 'I just summited ${peak.name} (${peak.metres} m) on AscentFlow.',
      files: [
        XFile.fromData(bytes.buffer.asUint8List(), mimeType: 'image/png', name: 'ascentflow-${peak.name.toLowerCase().replaceAll(' ', '-')}.png'),
      ],
    ),
  );
}
