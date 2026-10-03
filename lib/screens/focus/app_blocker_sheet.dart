import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';

void showAppBlockerSettings(BuildContext context) {
  HapticFeedback.selectionClick();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AppBlockerSheet(),
  );
}

class _AppBlockerSheet extends StatefulWidget {
  const _AppBlockerSheet();

  @override
  State<_AppBlockerSheet> createState() => _AppBlockerSheetState();
}

class _AppBlockerSheetState extends State<_AppBlockerSheet> {
  final Map<String, bool> _apps = {
    'Instagram': true,
    'TikTok': true,
    'YouTube': false,
    'Twitter / X': true,
    'Messages': false,
    'WhatsApp': true,
    'Slack': false,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colors.surface1.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ColorFilter.mode(colors.surface1.withValues(alpha: 0.8), BlendMode.dstATop),
              child: Container(color: colors.surface1.withValues(alpha: 0.5)),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('App Blocker', style: AppTypography.heading2.copyWith(color: colors.textPrimary)),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(LucideIcons.x, color: colors.textSecondary),
                            style: IconButton.styleFrom(backgroundColor: colors.surface2),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Select apps to block during your focus sessions. Phone calls are always allowed.',
                        style: AppTypography.body.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    itemCount: _apps.keys.length,
                    itemBuilder: (context, index) {
                      final appName = _apps.keys.elementAt(index);
                      final isBlocked = _apps[appName]!;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: colors.surface2,
                          borderRadius: AppRadius.borderRadiusMd,
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.1),
                                    borderRadius: AppRadius.borderRadiusSm,
                                  ),
                                  child: Icon(LucideIcons.smartphone, size: 16, color: colors.primary),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  appName,
                                  style: AppTypography.body.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: isBlocked,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _apps[appName] = val);
                              },
                              activeThumbColor: colors.mint,
                              activeTrackColor: colors.mint.withValues(alpha: 0.2),
                              inactiveThumbColor: colors.textTertiary,
                              inactiveTrackColor: colors.surface3,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
