import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/buttons.dart';
import 'app_blocker_sheet.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with TickerProviderStateMixin {
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
  bool _isBlockerEnabled = false;

  @override
  void initState() {
    super.initState();
    _timerController =
        AnimationController(
          vsync: this,
          duration: Duration(minutes: _sessionMinutes),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            HapticFeedback.heavyImpact();
            setState(() => _isCompleted = true);
          }
        });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_isRunning) {
        _timerController.stop();
        _isRunning = false;
      } else {
        _timerController.duration = Duration(minutes: _sessionMinutes);
        _timerController.forward(from: _timerController.value);
        _isRunning = true;
      }
    });
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    setState(() {
      _timerController.reset();
      _isRunning = false;
      _isCompleted = false;
    });
  }

  void _toggleMode(bool isFocus) {
    if (_isFocusMode == isFocus) return;
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
                              color: _isBlockerEnabled
                                  ? colors.mint
                                  : colors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Flexible(
                              child: Text(
                                'App Blocker',
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label.copyWith(
                                  color: _isBlockerEnabled
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Switch(
                              value: _isBlockerEnabled,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _isBlockerEnabled = val);
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
                        SizedBox(
                          width: 260,
                          height: 260,
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
                      isPlaying: _isRunning,
                      onTap: _toggleTimer,
                      colors: colors,
                    ),
                    const SizedBox(width: AppSpacing.xxl),
                    _CircleButton(
                      icon: LucideIcons.skipForward,
                      onTap: () {
                        _timerController.value = 1.0;
                      },
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
    required this.isPlaying,
    required this.onTap,
    required this.colors,
  });

  final bool isPlaying;
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
            isPlaying ? LucideIcons.pause : LucideIcons.play,
            key: ValueKey(isPlaying),
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

class _BottomStats extends StatelessWidget {
  const _BottomStats({required this.colors});
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _StatItem(value: '4', label: 'Sessions', colors: colors),
          ),
          Container(width: 1, height: 28, color: colors.border),
          Expanded(
            child: _StatItem(
              value: '1h 40m',
              label: 'Focused today',
              colors: colors,
            ),
          ),
          Container(width: 1, height: 28, color: colors.border),
          Expanded(
            child: _StatItem(value: '7 days', label: 'Streak', colors: colors),
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
              value: 50,
              suffix: ' XP',
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
