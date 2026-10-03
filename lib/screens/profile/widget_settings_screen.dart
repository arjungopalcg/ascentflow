import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/common.dart';
import '../../providers/home_widgets_provider.dart';

class WidgetSettingsScreen extends ConsumerWidget {
  const WidgetSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final widgetState = ref.watch(homeWidgetsProvider);
    final notifier = ref.read(homeWidgetsProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          'Widget Settings',
          style: AppTypography.heading3.copyWith(color: colors.textPrimary),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Customize your Home screen by enabling or reordering widgets below.',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: EyebrowLabel('VISIBLE WIDGETS'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: widgetState.order.length,
              onReorderItem: notifier.reorderWidgets,
              buildDefaultDragHandles: false, // Custom drag handle
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Transform.scale(
                    scale: 1.02,
                    child: child,
                  ),
                );
              },
              itemBuilder: (context, index) {
                final id = widgetState.order[index];
                final widgetInfo = allHomeWidgets.firstWhere((w) => w.id == id);
                final isEnabled = widgetState.enabledIds.contains(id);

                return Padding(
                  key: ValueKey(id),
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: AppRadius.borderRadiusLg,
                      border: Border.all(
                        color: isEnabled ? colors.primary.withValues(alpha: 0.3) : colors.border,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isEnabled 
                              ? colors.primary.withValues(alpha: 0.1) 
                              : colors.textTertiary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widgetInfo.icon,
                          color: isEnabled ? colors.primary : colors.textTertiary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        widgetInfo.name,
                        style: AppTypography.label.copyWith(
                          color: isEnabled ? colors.textPrimary : colors.textTertiary,
                        ),
                      ),
                      subtitle: Text(
                        widgetInfo.description,
                        style: AppTypography.caption.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch.adaptive(
                            value: isEnabled,
                            activeTrackColor: colors.primary,
                            onChanged: (_) {
                              HapticFeedback.lightImpact();
                              notifier.toggleWidget(id);
                            },
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(
                              LucideIcons.gripVertical,
                              color: colors.textTertiary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
