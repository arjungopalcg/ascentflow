import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/tokens.dart';
import '../../design/typography.dart';
import '../../game/climb_engine.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/confetti.dart';
import '../../widgets/pip.dart';
import '../../widgets/summit_postcard.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SUMMIT — the big moment. The mountain rises, Pip climbs to the top and plants
// the flag, snow-confetti falls. Shown when you finish the Daily climb, and
// (with a postcard) when your altitude summits a real peak.
// ─────────────────────────────────────────────────────────────────────────────

class SummitScreen extends ConsumerStatefulWidget {
  const SummitScreen.day({super.key, required this.metresToday, required this.streak}) : peak = null;
  const SummitScreen.peak({super.key, required Peak this.peak})
      : metresToday = 0,
        streak = 0;

  final int metresToday;
  final int streak;

  /// Set when a real mountain was summited.
  final Peak? peak;

  @override
  ConsumerState<SummitScreen> createState() => _SummitScreenState();
}

class _SummitScreenState extends ConsumerState<SummitScreen> with TickerProviderStateMixin {
  late final AnimationController _story = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );
  late final AnimationController _snow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  bool _planted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_story.isAnimating || _story.isCompleted) return;
    if (MediaQuery.of(context).disableAnimations) {
      _story.value = 1;
      _snow.value = 0.35;
      _planted = true;
    } else {
      _story.addListener(_onStory);
      _story.forward();
      _snow.repeat();
    }
  }

  void _onStory() {
    if (!_planted && _story.value >= 0.72) {
      _planted = true;
      HapticFeedback.heavyImpact();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _story.dispose();
    _snow.dispose();
    super.dispose();
  }

  double _phase(double start, double end, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_story.value - start) / (end - start)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final peak = widget.peak;
    final name = ref.watch(userProfileProvider.select((p) => p.name));
    const ink = Color(0xFFF7FBFF);
    final next = peak == null ? null : expeditions.skipWhile((p) => p != peak).skip(1).firstOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.skyNight : AppColors.sky,
      body: AnimatedBuilder(
        animation: Listenable.merge([_story, _snow]),
        builder: (context, _) {
          final rise = _phase(0.0, 0.35);
          final climb = _phase(0.30, 0.72, Curves.easeInOutCubic);
          final flag = _phase(0.70, 0.85, Curves.elasticOut);
          final text = _phase(0.78, 1.0);

          return LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth, h = c.maxHeight;
              final top = Offset(w * 0.5, h * 0.40);
              final foot = Offset(w * 0.12, h * 0.70);
              final pip = Offset.lerp(foot, top, climb)!;
              return Stack(
                children: [
                  // Alpenglow sun behind the peak
                  Positioned(
                    left: w * 0.5 - w * 0.45,
                    top: h * 0.40 - w * 0.45 + (1 - rise) * 80,
                    child: Container(
                      width: w * 0.9,
                      height: w * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.16 * rise),
                      ),
                    ),
                  ),
                  // Mountain rising
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(0, (1 - rise) * h * 0.5),
                      child: CustomPaint(painter: _MountainPainter(top: top)),
                    ),
                  ),
                  // Flag
                  Positioned(
                    left: top.dx - 2,
                    top: top.dy - 64,
                    child: Transform.scale(
                      scale: flag,
                      alignment: Alignment.bottomLeft,
                      child: const _Flag(),
                    ),
                  ),
                  // Pip climbing, then cheering
                  Positioned(
                    left: pip.dx - 44 - (climb >= 1 ? 30 : 0),
                    top: pip.dy - 82 + (1 - rise) * h * 0.5,
                    child: Pip(size: 88, mood: climb >= 1 ? PipMood.cheer : PipMood.idle),
                  ),
                  // Snow confetti
                  if (_planted)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(painter: ConfettiPainter(t: _snow.value)),
                      ),
                    ),
                  // Words and actions
                  Positioned(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Opacity(
                        opacity: text,
                        child: Transform.translate(
                          offset: Offset(0, (1 - text) * 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                peak == null ? 'You summited today!' : 'You summited ${peak.name}!',
                                style: AppTypography.display.copyWith(color: ink, fontSize: 36),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                peak == null
                                    ? 'Every step of the Daily climb is done. +${widget.metresToday} m today'
                                        '${widget.streak > 1 ? ', and your streak is ${widget.streak} days.' : '.'}'
                                    : '${peak.metres} m in ${peak.region}. '
                                        '${next == null ? 'You have climbed them all.' : 'Next expedition: ${next.name}.'}',
                                style: AppTypography.bodyLarge.copyWith(color: ink.withValues(alpha: 0.9)),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              if (peak != null) ...[
                                _InkButton(
                                  label: 'Share postcard',
                                  icon: LucideIcons.share2,
                                  onTap: () => showPostcardSheet(context, peak: peak, name: name),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              _InkButton(
                                label: 'Keep climbing',
                                filled: peak == null,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _MountainPainter extends CustomPainter {
  _MountainPainter({required this.top});
  final Offset top;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final back = Path()
      ..moveTo(0, h * 0.62)
      ..lineTo(w * 0.22, h * 0.50)
      ..lineTo(w * 0.36, h * 0.58)
      ..lineTo(w * 0.82, h * 0.46)
      ..lineTo(w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = Colors.white.withValues(alpha: 0.12));
    final main = Path()
      ..moveTo(-w * 0.1, h)
      ..lineTo(w * 0.12, h * 0.70)
      ..lineTo(top.dx, top.dy)
      ..lineTo(w * 0.92, h * 0.74)
      ..lineTo(w * 1.1, h)
      ..close();
    canvas.drawPath(main, Paint()..color = Colors.white.withValues(alpha: 0.22));
    final snow = Path()
      ..moveTo(top.dx - w * 0.12, top.dy + h * 0.07)
      ..lineTo(top.dx, top.dy)
      ..lineTo(top.dx + w * 0.13, top.dy + h * 0.07)
      ..lineTo(top.dx + w * 0.06, top.dy + h * 0.055)
      ..lineTo(top.dx, top.dy + h * 0.08)
      ..lineTo(top.dx - w * 0.05, top.dy + h * 0.055)
      ..close();
    canvas.drawPath(snow, Paint()..color = Colors.white.withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(covariant _MountainPainter old) => old.top != top;
}

class _Flag extends StatelessWidget {
  const _Flag();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 64,
      child: CustomPaint(
        painter: _FlagPainter(),
      ),
    );
  }
}

class _FlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(2, size.height), const Offset(2, 2), Paint()..color = Colors.white..strokeWidth = 4..strokeCap = StrokeCap.round);
    canvas.drawPath(
      Path()
        ..moveTo(2, 2)
        ..lineTo(46, 14)
        ..lineTo(2, 28)
        ..close(),
      Paint()..color = AppColors.summitDark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InkButton extends StatelessWidget {
  const _InkButton({required this.label, required this.onTap, this.icon, this.filled = true});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    const snow = Color(0xFFF7FBFF);
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: filled ? snow : Colors.white.withValues(alpha: 0.18),
        borderRadius: AppRadius.borderRadiusMd,
        child: InkWell(
          borderRadius: AppRadius.borderRadiusMd,
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 19, color: filled ? AppColors.skyDeep : snow),
                  const SizedBox(width: 8),
                ],
                Text(label, style: AppTypography.heading3.copyWith(color: filled ? AppColors.skyDeep : snow)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
