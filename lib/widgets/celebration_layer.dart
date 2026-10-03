import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../game/climb_engine.dart';
import '../screens/celebrations/summit_screen.dart';
import 'campfire.dart';
import 'confetti.dart';
import 'pip.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CELEBRATION LAYER — listens to the climb engine and plays the moment:
// • every gain: a "+20 m" chip floats up with a sparkle burst
// • streak / new camp: a banner slides down, one at a time
// • day summit / real peak summit: the full-screen Summit story
// ─────────────────────────────────────────────────────────────────────────────

class CelebrationLayer extends ConsumerStatefulWidget {
  const CelebrationLayer({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<CelebrationLayer> createState() => _CelebrationLayerState();
}

class _CelebrationLayerState extends ConsumerState<CelebrationLayer> {
  StreamSubscription<ClimbEvent>? _sub;
  final _gains = <_Gain>[];
  final Queue<ClimbEvent> _banners = Queue();
  ClimbEvent? _banner;
  var _nextId = 0;

  @override
  void initState() {
    super.initState();
    _sub = ref.read(climbProvider.notifier).events.listen(_onEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onEvent(ClimbEvent e) {
    if (!mounted) return;
    switch (e) {
      case GainEvent():
        HapticFeedback.mediumImpact();
        setState(() => _gains.add(_Gain(_nextId++, e)));
      case SlipEvent():
        HapticFeedback.heavyImpact();
        _banners.add(e);
        _showNextBanner();
      case StreakEvent() || CampEvent():
        _banners.add(e);
        _showNextBanner();
      case DaySummitEvent(:final metresToday, :final streak):
        _pushSummit(SummitScreen.day(metresToday: metresToday, streak: streak));
      case PeakSummitEvent(:final peak):
        _pushSummit(SummitScreen.peak(peak: peak));
    }
  }

  void _showNextBanner() {
    if (_banner != null || _banners.isEmpty) return;
    setState(() => _banner = _banners.removeFirst());
    Future<void>.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() => _banner = null);
      Future<void>.delayed(const Duration(milliseconds: 350), _showNextBanner);
    });
  }

  void _pushSummit(Widget screen) {
    // Let the "+m" chip land first.
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, _, _) => screen,
          transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Floating gains, just above the navigation bar.
        for (final g in _gains)
          Positioned(
            left: 0,
            right: 0,
            bottom: 96,
            child: IgnorePointer(
              child: _FloatingGain(
                key: ValueKey(g.id),
                gain: g.event,
                onDone: () => setState(() => _gains.remove(g)),
              ),
            ),
          ),
        // Banner for streaks and camps.
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: 0,
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween(begin: const Offset(0, -1.2), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
                child: child,
              ),
              child: _banner == null
                  ? const SizedBox.shrink()
                  : _Banner(key: ValueKey(_banner), event: _banner!),
            ),
          ),
        ),
      ],
    );
  }
}

class _Gain {
  _Gain(this.id, this.event);
  final int id;
  final GainEvent event;
}

class _FloatingGain extends StatefulWidget {
  const _FloatingGain({super.key, required this.gain, required this.onDone});
  final GainEvent gain;
  final VoidCallback onDone;

  @override
  State<_FloatingGain> createState() => _FloatingGainState();
}

class _FloatingGainState extends State<_FloatingGain> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward().whenComplete(() {
      if (mounted) widget.onDone();
    });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final rise = still ? 0.0 : Curves.easeOutCubic.transform(t) * 70;
        final pop = still ? 1.0 : Curves.elasticOut.transform((t / 0.4).clamp(0, 1));
        final fade = t < 0.75 ? 1.0 : 1 - (t - 0.75) / 0.25;
        return Opacity(
          opacity: fade.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, -rise),
            child: Center(
              child: SizedBox(
                width: 180,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!still)
                      Positioned.fill(
                        child: CustomPaint(painter: BurstPainter(t: (t / 0.5).clamp(0, 1), color: AppColors.campfire)),
                      ),
                    Transform.scale(
                      scale: pop,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.skyDeep,
                          borderRadius: AppRadius.borderRadiusPill,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.mountainSnow, size: 18, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              '+${widget.gain.metres} m',
                              style: AppTypography.heading2.copyWith(color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({super.key, required this.event});
  final ClimbEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Widget icon, String title, String body) = switch (event) {
      StreakEvent(:final days, :final usedRestDay) => (
          Campfire(size: 44, intensity: (days / 30).clamp(0.3, 1).toDouble()),
          days == 1 ? 'Campfire lit' : '$days-day streak!',
          usedRestDay
              ? 'A saved rest day kept your fire going.'
              : days == 1
                  ? 'Climb tomorrow to keep it burning.'
                  : 'Your campfire is growing. See you tomorrow.',
        ),
      SlipEvent(:final metres, :final caughtByCamp) => (
          const Pip(size: 52, mood: PipMood.oops),
          'Pip slipped $metres m',
          caughtByCamp
              ? 'You left focus early. Your last camp caught the fall.'
              : 'You left focus early. Finish the next one to climb back up.',
        ),
      CampEvent(:final camp) => (
          Icon(LucideIcons.tent, size: 40, color: AppColors.sky),
          'Camp $camp reached',
          'Another $campEvery m climbed. Keep going.',
        ),
      _ => (const SizedBox.shrink(), '', ''),
    };
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(color: colors.border, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: colors.isDark ? 0.4 : 0.12), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTypography.heading2.copyWith(color: colors.textPrimary)),
                  Text(body, style: AppTypography.caption.copyWith(color: colors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
