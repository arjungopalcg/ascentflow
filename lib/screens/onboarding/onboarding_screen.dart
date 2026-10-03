import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/typography.dart';
import '../../providers/home_widgets_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/ascent_mark.dart';
import '../../widgets/buttons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING — first launch. Welcome (the one place the brand is front and
// centre), then name → what you want help with → a preview of the home
// screen built from those answers, which the person can adjust.
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  final _name = TextEditingController();
  final Set<FocusArea> _areas = {};
  List<String> _widgets = [];
  int _step = 0;

  static const _areaIcons = {
    FocusArea.plan: LucideIcons.listChecks,
    FocusArea.focus: LucideIcons.timer,
    FocusArea.goals: LucideIcons.target,
    FocusArea.reflect: LucideIcons.bookOpen,
    FocusArea.money: LucideIcons.piggyBank,
    FocusArea.lists: LucideIcons.list,
  };

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  void _go(int step) {
    FocusScope.of(context).unfocus();
    if (step == 3) _widgets = widgetsForFocusAreas(_areas);
    setState(() => _step = step);
    final reduce = MediaQuery.of(context).disableAnimations;
    reduce
        ? _pages.jumpToPage(step)
        : _pages.animateToPage(step, duration: AppDuration.slow, curve: AppCurves.easeInOutCubic);
  }

  Future<void> _finish() async {
    HapticFeedback.mediumImpact();
    await ref.read(userProfileProvider.notifier).completeOnboarding(
          name: _name.text,
          areas: _areas,
          homeWidgets: _widgets,
        );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _go(_step - 1);
      },
      child: Scaffold(
        body: PageView(
          controller: _pages,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _Welcome(onStart: () => _go(1)),
            _Step(
              step: 1,
              title: 'What should we call you?',
              body: 'Just a first name is fine. It\'s only used to greet you.',
              onBack: () => _go(0),
              primaryLabel: 'Continue',
              onPrimary: () => _go(2),
              secondaryLabel: 'Skip',
              onSecondary: () {
                _name.clear();
                _go(2);
              },
              child: _NameField(controller: _name, onSubmitted: () => _go(2)),
            ),
            _Step(
              step: 2,
              title: 'What would you like help with?',
              body: 'Pick as many as you like. We\'ll set up your home screen around them.',
              onBack: () => _go(1),
              primaryLabel: 'Continue',
              onPrimary: _areas.isEmpty ? null : () => _go(3),
              child: Column(
                children: [
                  for (final area in FocusArea.values)
                    _ChoiceTile(
                      icon: _areaIcons[area]!,
                      title: area.title,
                      subtitle: area.description,
                      selected: _areas.contains(area),
                      onTap: () => setState(() {
                        HapticFeedback.selectionClick();
                        _areas.contains(area) ? _areas.remove(area) : _areas.add(area);
                      }),
                    ),
                ],
              ),
            ),
            _Step(
              step: 3,
              title: _name.text.trim().isEmpty
                  ? 'Here\'s your home screen'
                  : 'Here\'s your home screen, ${_name.text.trim()}',
              body: 'Built from what you picked. Untick anything you don\'t want. '
                  'You can add widgets from any section later.',
              onBack: () => _go(2),
              primaryLabel: 'Start climbing',
              onPrimary: _widgets.isEmpty ? null : _finish,
              child: Column(
                children: [
                  for (final w in allHomeWidgets.where((w) => widgetsForFocusAreas(_areas).contains(w.id)))
                    _ChoiceTile(
                      icon: w.icon,
                      title: w.name,
                      subtitle: w.description,
                      selected: _widgets.contains(w.id),
                      onTap: () => setState(() {
                        HapticFeedback.selectionClick();
                        final on = _widgets.contains(w.id);
                        // Rebuild in catalog order so the layout stays tidy.
                        _widgets = [
                          for (final x in allHomeWidgets)
                            if (x.id == w.id ? !on : _widgets.contains(x.id)) x.id,
                        ];
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Welcome ───────────────────────────────────────────────────────────────

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final panel = colors.isDark ? const Color(0xFF1F4A5E) : AppColors.primaryLight;
    const ink = Color(0xFFF3F7F9);

    return Container(
      color: panel,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ContourPainter(color: ink.withValues(alpha: 0.08)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),
                  const AscentMark(size: 72, color: ink),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'AscentFlow',
                    style: AppTypography.displayXl.copyWith(color: ink, fontSize: 56),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      'Plan your day, focus on what matters, and see how far you\'ve climbed.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: ink.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  SizedBox(
                    width: double.infinity,
                    child: _InkButton(label: 'Get started', onTap: onStart, panel: panel),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text(
                      'Setup takes about a minute.',
                      style: AppTypography.caption.copyWith(color: ink.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Snow-white button for use on the lake-blue brand panel.
class _InkButton extends StatelessWidget {
  const _InkButton({required this.label, required this.onTap, required this.panel});
  final String label;
  final VoidCallback onTap;
  final Color panel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F7F9),
      borderRadius: AppRadius.borderRadiusMd,
      child: InkWell(
        borderRadius: AppRadius.borderRadiusMd,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.heading3.copyWith(color: panel),
          ),
        ),
      ),
    );
  }
}

// ── Question step ─────────────────────────────────────────────────────────

class _Step extends StatelessWidget {
  const _Step({
    required this.step,
    required this.title,
    required this.body,
    required this.child,
    required this.onBack,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final int step;
  final String title;
  final String body;
  final Widget child;
  final VoidCallback onBack;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  static const _steps = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.lg, 0),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: onBack,
                  icon: Icon(LucideIcons.arrowLeft, color: colors.textPrimary),
                ),
                const Spacer(),
                Text(
                  'Step $step of $_steps',
                  style: AppTypography.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          // A real sequence, so a progress track is honest here.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                for (var i = 1; i <= _steps; i++)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: i == _steps ? 0 : 4),
                      decoration: BoxDecoration(
                        color: i <= step ? colors.primary : colors.surface3,
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg,
              ),
              children: [
                Text(title, style: AppTypography.display.copyWith(color: colors.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: AppTypography.body.copyWith(color: colors.textSecondary)),
                const SizedBox(height: AppSpacing.xl),
                child,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Row(
              children: [
                if (secondaryLabel != null) ...[
                  Expanded(
                    child: PillButton(
                      label: secondaryLabel!,
                      onTap: onSecondary,
                      variant: PillButtonVariant.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  flex: 2,
                  child: PillButton(label: primaryLabel, onTap: onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.onSubmitted});
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      maxLength: 30,
      onSubmitted: (_) => onSubmitted(),
      style: AppTypography.display.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Your name',
        hintStyle: AppTypography.display.copyWith(color: colors.textTertiary),
        counterText: '',
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border, width: 2)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.primary, width: 2)),
      ),
    );
  }
}

/// A selectable row: icon, title, one line of explanation, and a check.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Semantics(
        checked: selected,
        button: true,
        child: Material(
          color: selected
              ? colors.primary.withValues(alpha: colors.isDark ? 0.16 : 0.08)
              : colors.surface1,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
            side: BorderSide(
              color: selected ? colors.primary : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: AppRadius.borderRadiusMd,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: selected ? colors.primary : colors.textSecondary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
                        Text(subtitle, style: AppTypography.caption.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedSwitcher(
                    duration: AppDuration.fast,
                    child: Icon(
                      selected ? LucideIcons.circleCheck : LucideIcons.circle,
                      key: ValueKey(selected),
                      size: 22,
                      color: selected ? colors.primary : colors.surface3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
