import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/typography.dart';
import '../../providers/home_widgets_provider.dart';
import '../../widgets/common.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EDIT HOME — what's on Home (drag to reorder, remove), then every widget the
// app offers, grouped by the section it comes from.
// ─────────────────────────────────────────────────────────────────────────────

class WidgetSettingsScreen extends ConsumerWidget {
  const WidgetSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(homeWidgetsProvider);
    final notifier = ref.read(homeWidgetsProvider.notifier);
    final visible = state.visible;
    final available = allHomeWidgets.where((w) => !visible.contains(w.id)).toList();
    final sections = <String>[
      for (final w in available)
        if (!available.takeWhile((x) => x != w).any((x) => x.section == w.section)) w.section,
    ];
    HomeWidgetModel byId(String id) => allHomeWidgets.firstWhere((w) => w.id == id);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit home')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.sm),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EyebrowLabel('On your home'),
                  Text(
                    visible.isEmpty
                        ? 'Nothing yet. Add widgets from the sections below.'
                        : 'Drag to change the order.',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverReorderableList(
              itemCount: visible.length,
              onReorderItem: notifier.reorderVisible,
              proxyDecorator: (child, _, _) => Material(color: Colors.transparent, child: child),
              itemBuilder: (context, i) {
                final w = byId(visible[i]);
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(w.id),
                  index: i,
                  child: _WidgetRow(
                    widget: w,
                    colors: colors,
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Icon(LucideIcons.gripVertical, size: 20, color: colors.textTertiary),
                      ),
                    ),
                    action: IconButton(
                      tooltip: 'Remove ${w.name}',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        notifier.toggleWidget(w.id);
                      },
                      icon: Icon(LucideIcons.circleMinus, color: colors.danger),
                    ),
                  ),
                );
              },
            ),
          ),
          if (available.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xxl),
              sliver: SliverList.list(
                children: [
                  const EyebrowLabel('Add widgets'),
                  Text(
                    'Every part of the app has something you can bring to Home.',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                  for (final section in sections) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxs),
                      child: Text(
                        section,
                        style: AppTypography.label.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final w in available.where((w) => w.section == section))
                      _WidgetRow(
                        widget: w,
                        colors: colors,
                        action: IconButton(
                          tooltip: 'Add ${w.name}',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            notifier.toggleWidget(w.id);
                          },
                          icon: Icon(LucideIcons.circlePlus, color: colors.primary),
                        ),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _WidgetRow extends StatelessWidget {
  const _WidgetRow({
    required this.widget,
    required this.colors,
    required this.action,
    this.leading,
  });

  final HomeWidgetModel widget;
  final AppColorsExtension colors;
  final Widget action;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          ?leading,
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: colors.isDark ? 0.18 : 0.1),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(widget.icon, size: 20, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
                Text(widget.description, style: AppTypography.caption.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}
