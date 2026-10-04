import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../game/climb_engine.dart';
import '../../providers/focus_settings_provider.dart';
import '../../providers/prefs_provider.dart';
import '../../services/analytics.dart';
import '../../services/focus_guard.dart';
import '../../widgets/common.dart';
import '../../widgets/buttons.dart';
import '../../widgets/pip.dart';
import 'app_blocker_sheet.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _timerController;

  int _sessionMinutes = 25;
  bool _isFocusMode = true;
  int _selectedFocusDurationIndex = 1; // Defaults to 25
  int _selectedBreakDurationIndex = 0; // Defaults to 5
  int _customMinutes = 60; // Default custom minutes

  static const _focusDurations = [15, 25, 30, 45, -1]; // -1 represents custom
  static const _breakDurations = [5, 10, 15];

  int _selectedSoundIndex = 0; // Default to Silent

  bool _isRunning = false;
  bool _isCompleted = false;

  // ── Focus session state ────────────────────────────────────────────
  /// A focus session is under way. Like a Forest tree, it can't be paused,
  /// and ending it early makes Pip slip.
  bool _sessionStarted = false;

  /// The lock covers other apps for this session (Android, with permission).
  /// It also deals with leaving, so the 10-second rule is only for sessions
  /// without it.
  bool _locked = false;

  /// Wall-clock timing, so the session keeps counting while the screen is off.
  DateTime? _runStartedAt;
  double _runStartFraction = 0;

  /// When the user left the app (screen still on) during a session.
  DateTime? _leftAt;
  static const _leaveGrace = Duration(seconds: 10);
  StreamSubscription<String>? _blockedSub;
  StreamSubscription<void>? _giveUpSub;

  @override
  void initState() {
    super.initState();
    _timerController =
        AnimationController(
          vsync: this,
          duration: Duration(minutes: _sessionMinutes),
          // A real clock: "remove animations" must not shorten the session.
          animationBehavior: AnimationBehavior.preserve,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            HapticFeedback.heavyImpact();
            if (_isFocusMode) {
              Analytics.capture('focus_completed', {'minutes': _sessionMinutes, 'locked': _locked});
              ref.read(climbProvider.notifier).record(ClimbAction.focus);
              ref.read(focusStatsProvider.notifier).addSession(_sessionMinutes);
            }
            _endSession();
            setState(() {
              _isRunning = false;
              _isCompleted = true;
            });
          }
        });
    WidgetsBinding.instance.addObserver(this);
    _blockedSub = FocusGuard.blockedApps.listen((label) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label is locked until your session ends. Back to it!')),
      );
    });
    // "Give up" tapped on the lock screen over another app.
    _giveUpSub = FocusGuard.giveUps.listen((_) {
      if (!mounted) return;
      if (_sessionStarted) {
        _giveUp(reason: 'You gave up. Pip slipped $focusFallMetres m.', how: 'lock_screen');
      } else {
        ref.read(climbProvider.notifier).slip();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyPendingSlip());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _blockedSub?.cancel();
    _giveUpSub?.cancel();
    if (_sessionStarted) _endSession();
    _timerController.dispose();
    super.dispose();
  }

  /// AscentFlow was closed from Recents during focus last time.
  void _applyPendingSlip() {
    final prefs = ref.read(sharedPrefsProvider);
    if (prefs.getBool(FocusGuard.pendingSlipKey) != true) return;
    prefs.remove(FocusGuard.pendingSlipKey);
    Analytics.capture('focus_given_up', {'how': 'closed_app'});
    ref.read(climbProvider.notifier).slip();
  }

  // ── Leaving the app during a session ───────────────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_sessionStarted || !_isFocusMode) return;
    if (state == AppLifecycleState.resumed) {
      FocusGuard.clearWarning();
      final left = _leftAt;
      _leftAt = null;
      _resyncFromClock();
      if (left != null && DateTime.now().difference(left) > _leaveGrace && _sessionStarted && !_isCompleted) {
        _giveUp(reason: 'You left AscentFlow during focus, so Pip slipped $focusFallMetres m.', how: 'left_app');
      }
    } else if (state == AppLifecycleState.paused && !_locked) {
      // Turning the screen off isn't leaving; only count it if it's on.
      FocusGuard.isScreenOn().then((on) {
        if (on && _sessionStarted && _leftAt == null) {
          _leftAt = DateTime.now();
          FocusGuard.warnLeaving(_leaveGrace.inSeconds);
        }
      });
    }
  }

  // ── Timer ──────────────────────────────────────────────────────────
  Duration get _total => Duration(minutes: _sessionMinutes);
  Duration get _remaining => _total * (1 - _timerController.value);

  void _startRunning() {
    _runStartedAt = DateTime.now();
    _runStartFraction = _timerController.value;
    _timerController.duration = _total;
    _timerController.forward(from: _runStartFraction);
    _isRunning = true;
  }

  void _stopRunning() {
    _timerController.stop();
    _isRunning = false;
    _runStartedAt = null;
  }

  /// Catches the timer up with the real clock (frames stop while the app is
  /// in the background, but the session keeps going).
  void _resyncFromClock() {
    final started = _runStartedAt;
    if (!_isRunning || started == null) return;
    final fraction = _runStartFraction +
        DateTime.now().difference(started).inMilliseconds / _total.inMilliseconds;
    if (fraction >= 1) {
      _timerController.value = 1; // completes the session
    } else {
      _timerController.forward(from: fraction);
    }
  }

  // ── Focus lock ─────────────────────────────────────────────────────
  /// Before a session: if the lock is on but not set up, offer to set it up.
  Future<bool> _readyToStart() async {
    if (!FocusGuard.supported || !ref.read(focusSettingsProvider).lockEnabled) return true;
    if (await FocusGuard.canLock()) {
      if (!await FocusGuard.hasNotificationPermission()) {
        await FocusGuard.requestNotificationPermission();
      }
      return true;
    }
    if (!mounted) return false;
    final colors = context.colors;
    final setUp = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Pip(size: 72, mood: PipMood.wave),
        title: Text('Set up the focus lock', style: AppTypography.heading1.copyWith(color: colors.textPrimary)),
        content: Text(
          'Give AscentFlow two permissions so it can lock your other apps while you '
          'focus and show the timer on your lock screen. You only do this once.',
          style: AppTypography.body.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Start without lock'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Set up'),
          ),
        ],
      ),
    );
    if (setUp == true && mounted) showAppBlockerSettings(context);
    return setUp == false;
  }

  Future<void> _beginSession() async {
    _sessionStarted = true;
    final settings = ref.read(focusSettingsProvider);
    final locked = settings.lockEnabled && FocusGuard.supported && await FocusGuard.canLock();
    if (!_sessionStarted) return; // ended while we were checking
    _locked = locked;
    Analytics.capture('focus_started', {'minutes': _sessionMinutes, 'locked': locked});
    await FocusGuard.startSession(
      endAt: DateTime.now().add(_remaining),
      total: _total,
      guard: locked,
      allowed: settings.allowed,
    );
  }

  void _endSession() {
    if (!_sessionStarted) return;
    _sessionStarted = false;
    _locked = false;
    _leftAt = null;
    FocusGuard.stopSession();
  }

  /// Ends the focus session early: Pip slips down the mountain.
  void _giveUp({String? reason, String how = 'button'}) {
    if (!_sessionStarted) return; // it finished while we were asking
    Analytics.capture('focus_given_up', {
      'minutes': _sessionMinutes,
      'minutes_left': _remaining.inMinutes,
      'how': how,
      'locked': _locked,
    });
    ref.read(climbProvider.notifier).slip();
    _endSession();
    if (!mounted) return;
    setState(() {
      _stopRunning();
      _timerController.reset();
      _isCompleted = false;
    });
    if (reason != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reason)));
    }
  }

  Future<bool> _confirmGiveUp() async {
    final colors = context.colors;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Pip(size: 72, mood: PipMood.oops),
        title: Text('Give up this climb?', style: AppTypography.heading1.copyWith(color: colors.textPrimary)),
        content: Text(
          'Pip will slip $focusFallMetres m down the mountain. Your last camp will catch the fall.',
          style: AppTypography.body.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Give up', style: TextStyle(color: colors.danger)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep focusing'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Blocks changing mode or length mid-session.
  bool _guardSession() {
    if (!_sessionStarted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finish this session first, or give up.')),
    );
    return true;
  }

  Future<void> _toggleTimer() async {
    HapticFeedback.mediumImpact();
    if (!_isFocusMode) {
      // Breaks can pause.
      setState(_isRunning ? _stopRunning : _startRunning);
      return;
    }
    if (_sessionStarted) {
      // Focus can't pause, only give up.
      if (await _confirmGiveUp()) _giveUp();
      return;
    }
    if (!await _readyToStart() || !mounted) return;
    setState(_startRunning);
    _beginSession();
  }

  Future<void> _resetTimer() async {
    HapticFeedback.lightImpact();
    if (_sessionStarted && _isFocusMode) {
      if (await _confirmGiveUp()) _giveUp();
      return;
    }
    setState(() {
      _stopRunning();
      _timerController.reset();
      _isCompleted = false;
    });
  }

  Future<void> _skip() async {
    if (_isFocusMode) {
      // Skipping focus isn't finishing it.
      if (_sessionStarted && await _confirmGiveUp()) _giveUp();
      return;
    }
    _timerController.value = 1.0; // end the break
  }

  void _toggleMode(bool isFocus) {
    if (_isFocusMode == isFocus) return;
    if (_guardSession()) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isFocusMode = isFocus;
      if (_isRunning) {
        _timerController.stop();
        _isRunning = false;
      }
      _updateTimerDuration();
    });
  }

  void _updateTimerDuration() {
    if (_isFocusMode) {
      if (_focusDurations[_selectedFocusDurationIndex] != -1) {
        _sessionMinutes = _focusDurations[_selectedFocusDurationIndex];
      } else {
        _sessionMinutes = _customMinutes;
      }
    } else {
      _sessionMinutes = _breakDurations[_selectedBreakDurationIndex];
    }
    _timerController.duration = Duration(minutes: _sessionMinutes);
    _timerController.reset();
    _isCompleted = false;
  }

  void _selectBreakDuration(int index) {
    if (_isFocusMode) return;
    if (_guardSession()) return;
    HapticFeedback.selectionClick();

    if (_isRunning) {
      _timerController.stop();
      _isRunning = false;
    }

    setState(() {
      _selectedBreakDurationIndex = index;
      _updateTimerDuration();
    });
  }

  void _selectFocusDuration(int index) {
    if (!_isFocusMode) return;
    if (_guardSession()) return;
    HapticFeedback.selectionClick();

    if (_isRunning) {
      _timerController.stop();
      _isRunning = false;
    }

    if (_focusDurations[index] == -1) {
      _showCustomDurationDialog(index);
      return;
    }

    setState(() {
      _selectedFocusDurationIndex = index;
      _updateTimerDuration();
    });
  }

  void _showCustomDurationDialog(int index) {
    final colors = context.colors;
    int tempValue = _customMinutes;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface1,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
          title: Text(
            'Custom Duration',
            style: AppTypography.heading1.copyWith(color: colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter minutes between 1 and 120.',
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                keyboardType: TextInputType.number,
                autofocus: true,
                style: AppTypography.body.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Minutes',
                  hintStyle: AppTypography.body.copyWith(
                    color: colors.textTertiary,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors.primary),
                  ),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null && parsed > 0 && parsed <= 120) {
                    tempValue = parsed;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTypography.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            PillButton(
              label: 'Set Timer',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _customMinutes = tempValue;
                  _selectedFocusDurationIndex = index;
                  _updateTimerDuration();
                });
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(double progress) {
    final totalSeconds = (_sessionMinutes * 60 * (1 - progress)).round();
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildDurationSelector(AppColorsExtension colors) {
    final items = _isFocusMode ? _focusDurations : _breakDurations;
    final selectedIndex = _isFocusMode
        ? _selectedFocusDurationIndex
        : _selectedBreakDurationIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: List.generate(items.length, (i) {
          final isSelected = i == selectedIndex;
          final label = items[i] == -1
              ? (isSelected ? '${_customMinutes}m' : 'Custom')
              : '${items[i]}m';

          return GestureDetector(
            onTap: () {
              if (_isFocusMode) {
                _selectFocusDuration(i);
              } else {
                _selectBreakDuration(i);
              }
            },
            child: AnimatedContainer(
              duration: AppDuration.medium,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withValues(
                        alpha: colors.isDark ? 0.18 : 0.1,
                      )
                    : colors.surface1,
                borderRadius: AppRadius.borderRadiusPill,
                border: Border.all(
                  color: isSelected ? Colors.transparent : colors.border,
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: AppTypography.label.copyWith(
                  color: isSelected ? colors.primary : colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lockOn = ref.watch(focusSettingsProvider).lockEnabled;

    if (_isCompleted) {
      return _CompletedView(colors: colors, onReset: _resetTimer);
    }

    return Stack(
      children: [
        // ── Content ────────────────────────────────────────────────
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),

                // ── Header: App Blocker ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.shieldCheck,
                              size: 20,
                              color: lockOn
                                  ? colors.mint
                                  : colors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Flexible(
                              child: Text(
                                'Focus lock',
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label.copyWith(
                                  color: lockOn
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Switch(
                              value: lockOn,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                ref.read(focusSettingsProvider.notifier).setLock(val);
                              },
                              activeThumbColor: colors.mint,
                              activeTrackColor: colors.mint.withValues(
                                alpha: 0.2,
                              ),
                              inactiveThumbColor: colors.textTertiary,
                              inactiveTrackColor: colors.surface3,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => showAppBlockerSettings(context),
                        icon: Icon(
                          LucideIcons.settings,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Mode Toggle (Focus vs Break) ────────────────────
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 240,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: AppRadius.borderRadiusPill,
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleMode(true),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isFocusMode
                                    ? colors.primary.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: AppRadius.borderRadiusPill,
                              ),
                              child: Center(
                                child: Text(
                                  'Focus',
                                  style: AppTypography.label.copyWith(
                                    color: _isFocusMode
                                        ? colors.primary
                                        : colors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleMode(false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: !_isFocusMode
                                    ? colors.mint.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: AppRadius.borderRadiusPill,
                              ),
                              child: Center(
                                child: Text(
                                  'Break',
                                  style: AppTypography.label.copyWith(
                                    color: !_isFocusMode
                                        ? colors.mint
                                        : colors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Timer Ring ──────────────────────────────────────
                AnimatedBuilder(
                  animation: _timerController,
                  builder: (context, child) {
                    final progress = _timerController.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: _FocusSky(
                            progress: progress,
                            napping: _isRunning && _isFocusMode,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: CustomPaint(
                            painter: _TimerRingPainter(
                              progress: progress,
                              primaryColor: colors.primary,
                              trackColor: colors.surface3,
                              glowColor: colors.primaryGlow,
                              isDark: colors.isDark,
                            ),
                            child: Padding(
                              // Keep the readout inside the ring at any text size.
                              padding: const EdgeInsets.all(AppSpacing.xxl),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatTime(progress),
                                      style: AppTypography.displayXl.copyWith(
                                        color: colors.textPrimary,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isFocusMode
                                          ? 'Stay with one thing'
                                          : 'Rest your eyes',
                                      style: AppTypography.label.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ── Controls ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CircleButton(
                      icon: LucideIcons.rotateCcw,
                      onTap: _resetTimer,
                      colors: colors,
                    ),
                    const SizedBox(width: AppSpacing.xxl),
                    _PlayButton(
                      icon: _isFocusMode && _sessionStarted
                          ? LucideIcons.flag // give up
                          : _isRunning
                              ? LucideIcons.pause
                              : LucideIcons.play,
                      label: _isFocusMode && _sessionStarted
                          ? 'Give up'
                          : _isRunning
                              ? 'Pause'
                              : 'Start',
                      onTap: _toggleTimer,
                      colors: colors,
                    ),
                    const SizedBox(width: AppSpacing.xxl),
                    _CircleButton(
                      icon: LucideIcons.skipForward,
                      onTap: _skip,
                      colors: colors,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ── Duration Selector ───────────────────────────────
                _buildDurationSelector(colors),

                const SizedBox(height: AppSpacing.xl),

                _SoundscapeRow(
                  colors: colors,
                  selectedIndex: _selectedSoundIndex,
                  onSelect: (idx) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSoundIndex = idx);
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ── Bottom Stats ────────────────────────────────────
                _BottomStats(colors: colors),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TIMER RING — CustomPainter
// ═══════════════════════════════════════════════════════════════════════════

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
    required this.glowColor,
    required this.isDark,
  });

  final double progress;
  final Color primaryColor;
  final Color trackColor;
  final Color glowColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    const strokeWidth = 6.0;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Determine arc color (amber warning at 80%+ progress)
    final arcColor = progress > 0.8
        ? Color.lerp(
            primaryColor,
            const Color(0xFFBB850E),
            (progress - 0.8) / 0.2,
          )!
        : primaryColor;

    // Progress arc with gradient
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);

    // Dot at the end of the arc
    final dotAngle = startAngle + sweepAngle;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);

    // Dot
    final dotPaint = Paint()..color = arcColor;
    canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);

    // Inner white
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(dotX, dotY), 2, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Removed _SessionSelector in favor of inline building

// ═══════════════════════════════════════════════════════════════════════════
// CONTROLS
// ═══════════════════════════════════════════════════════════════════════════

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primary,
        ),
        child: AnimatedSwitcher(
          duration: AppDuration.fast,
          child: Icon(
            icon,
            key: ValueKey(icon),
            semanticLabel: label,
            color: colors.isDark ? AppColors.darkBg : Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final VoidCallback onTap;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface2,
          border: Border.all(color: colors.border),
        ),
        child: Icon(icon, size: 18, color: colors.textSecondary),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SOUNDSCAPE ROW
// ═══════════════════════════════════════════════════════════════════════════

class _SoundscapeRow extends StatelessWidget {
  const _SoundscapeRow({
    required this.colors,
    required this.selectedIndex,
    required this.onSelect,
  });

  final AppColorsExtension colors;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _sounds = [
    (LucideIcons.volumeX, 'Silent'),
    (LucideIcons.cloudRain, 'Rain'),
    (LucideIcons.waves, 'Ocean'),
    (LucideIcons.coffee, 'Café'),
    (LucideIcons.trees, 'Forest'),
    (LucideIcons.flame, 'Fireplace'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: EyebrowLabel('Background sound'),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: _sounds.length,
            itemBuilder: (context, i) {
              final isSelected = i == selectedIndex;
              return GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(
                            alpha: colors.isDark ? 0.18 : 0.1,
                          )
                        : colors.surface1,
                    borderRadius: AppRadius.borderRadiusPill,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : colors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _sounds[i].$1,
                        size: 16,
                        color: isSelected
                            ? colors.primary
                            : colors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _sounds[i].$2,
                        style: AppTypography.label.copyWith(
                          color: isSelected
                              ? colors.primary
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOTTOM STATS
// ═══════════════════════════════════════════════════════════════════════════

class _BottomStats extends ConsumerWidget {
  const _BottomStats({required this.colors});
  final AppColorsExtension colors;

  static String _minutes(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60, rest = m % 60;
    return rest == 0 ? '${h}h' : '${h}h ${rest}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(focusStatsProvider);
    ref.watch(climbProvider);
    final streak = ref.read(climbProvider.notifier).displayStreak;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _StatItem(value: '${stats.sessionsToday}', label: 'Sessions today', colors: colors),
          ),
          Container(width: 1, height: 28, color: colors.border),
          Expanded(
            child: _StatItem(
              value: _minutes(stats.minutesToday),
              label: 'Focused today',
              colors: colors,
            ),
          ),
          Container(width: 1, height: 28, color: colors.border),
          Expanded(
            child: _StatItem(
              value: streak == 1 ? '1 day' : '$streak days',
              label: 'Streak',
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.colors,
  });

  final String value;
  final String label;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPLETED VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _CompletedView extends StatelessWidget {
  const _CompletedView({required this.colors, required this.onReset});

  final AppColorsExtension colors;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.mint.withValues(alpha: 0.15),
              ),
              child: Icon(LucideIcons.check, size: 34, color: colors.mint),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Nicely done',
              style: AppTypography.heading1.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '25 minutes of deep focus',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            CountUpText(
              value: 40,
              suffix: ' m climbed',
              style: AppTypography.display.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            PillButton(label: 'Start New Session', onTap: onReset),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// FOCUS SKY — a window onto the mountain. As the session runs the sun arcs
// across and sets: day → golden hour → alpenglow → night with stars. Pip naps
// on the ridge while you focus.
// ═══════════════════════════════════════════════════════════════════════════

class _FocusSky extends StatelessWidget {
  const _FocusSky({required this.progress, required this.napping});

  final double progress;
  final bool napping;

  static const _stops = [
    Color(0xFF7CC6F2), // day
    Color(0xFFFFC27A), // golden hour
    Color(0xFFF2709C), // alpenglow
    Color(0xFF1C4466), // night
  ];

  static Color _skyAt(double t) {
    final scaled = t.clamp(0.0, 1.0) * (_stops.length - 1);
    final i = scaled.floor().clamp(0, _stops.length - 2);
    return Color.lerp(_stops[i], _stops[i + 1], scaled - i)!;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: napping ? 'Focusing. Pip is napping.' : 'Focus sky',
      child: Container(
        height: 132,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _skyAt(progress),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _SkyPainter(progress: progress))),
            Positioned(
              right: 28,
              bottom: 6,
              child: Pip(size: 64, mood: napping ? PipMood.sleep : PipMood.idle),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = progress.clamp(0.0, 1.0);

    // Stars fade in for the last third.
    final stars = ((p - 0.66) / 0.34).clamp(0.0, 1.0);
    if (stars > 0) {
      final rnd = math.Random(3);
      final star = Paint()..color = Colors.white.withValues(alpha: 0.85 * stars);
      for (var i = 0; i < 26; i++) {
        canvas.drawCircle(Offset(rnd.nextDouble() * w, rnd.nextDouble() * h * 0.6), 0.8 + rnd.nextDouble() * 1.2, star);
      }
    }

    // Sun (then moon) on an arc from left to right.
    // Starts high on the left, sets behind the ridge on the right.
    final angle = math.pi * (0.8 - 0.8 * p);
    final sun = Offset(w * 0.5 + math.cos(angle) * w * 0.42, h * 0.95 - math.sin(angle) * h * 0.72);
    final isMoon = p > 0.85;
    canvas.drawCircle(
      sun,
      isMoon ? 11 : 16,
      Paint()..color = isMoon ? const Color(0xFFF4F1E6) : const Color(0xFFFFE08A),
    );

    // Two mountain ridges.
    final far = Path()
      ..moveTo(0, h * 0.72)
      ..lineTo(w * 0.2, h * 0.5)
      ..lineTo(w * 0.38, h * 0.66)
      ..lineTo(w * 0.6, h * 0.42)
      ..lineTo(w * 0.82, h * 0.64)
      ..lineTo(w, h * 0.52)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(far, Paint()..color = Colors.black.withValues(alpha: 0.12 + 0.12 * p));
    final near = Path()
      ..moveTo(0, h * 0.86)
      ..quadraticBezierTo(w * 0.3, h * 0.7, w * 0.55, h * 0.82)
      ..quadraticBezierTo(w * 0.8, h * 0.92, w, h * 0.78)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(near, Paint()..color = Colors.black.withValues(alpha: 0.2 + 0.15 * p));
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => old.progress != progress;
}
