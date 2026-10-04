import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/typography.dart';
import '../../game/climb_engine.dart';
import '../../providers/focus_settings_provider.dart';
import '../../services/focus_guard.dart';
import '../../widgets/pip.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FOCUS LOCK SETTINGS — turn the lock on, grant the Android permissions it
// needs, and choose which apps stay usable during focus (everything else is
// locked, like Forest's Deep Focus).
// ─────────────────────────────────────────────────────────────────────────────

void showAppBlockerSettings(BuildContext context) {
  HapticFeedback.selectionClick();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _FocusLockSheet(),
  );
}

class _FocusLockSheet extends ConsumerStatefulWidget {
  const _FocusLockSheet();

  @override
  ConsumerState<_FocusLockSheet> createState() => _FocusLockSheetState();
}

class _FocusLockSheetState extends ConsumerState<_FocusLockSheet> with WidgetsBindingObserver {
  bool _usage = false;
  bool _overlay = false;
  bool _notify = false;
  List<InstalledApp>? _apps;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    if (FocusGuard.supported) {
      FocusGuard.launchableApps().then((apps) {
        if (mounted) setState(() => _apps = apps);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Coming back from Settings: re-check what was granted.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final usage = await FocusGuard.hasUsageAccess();
    final overlay = await FocusGuard.hasOverlayPermission();
    final notify = await FocusGuard.hasNotificationPermission();
    if (!mounted) return;
    setState(() {
      _usage = usage;
      _overlay = overlay;
      _notify = notify;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final settings = ref.watch(focusSettingsProvider);
    final notifier = ref.read(focusSettingsProvider.notifier);
    final apps = (_apps ?? const <InstalledApp>[])
        .where((a) => a.label.toLowerCase().contains(_query.toLowerCase()))
        .toList()
      // Allowed apps first, then alphabetical.
      ..sort((a, b) {
        final ab = settings.allowed.contains(a.package), bb = settings.allowed.contains(b.package);
        if (ab != bb) return ab ? -1 : 1;
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      });

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.86,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    const Pip(size: 64),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Focus lock', style: AppTypography.display.copyWith(color: colors.textPrimary, fontSize: 30)),
                          Text(
                            'Stay on the mountain until the timer ends.',
                            style: AppTypography.body.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _Card(
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: settings.lockEnabled,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      notifier.setLock(v);
                    },
                    title: Text('Lock my phone during focus', style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
                    subtitle: Text(
                      'Every app except the ones you allow below is locked until the timer ends. '
                      'Calls always get through. Giving up makes Pip slip $focusFallMetres m.',
                      style: AppTypography.caption.copyWith(color: colors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (!FocusGuard.supported)
                  _Card(
                    child: Text(
                      'The phone lock works on Android. On iPhone it needs Apple\'s '
                      'Screen Time permission, which is coming in a later version. Leaving a '
                      'focus session early still makes Pip slip.',
                      style: AppTypography.body.copyWith(color: colors.textSecondary),
                    ),
                  )
                else ...[
                  Text('Set up the lock', style: AppTypography.eyebrow.copyWith(color: colors.textPrimary)),
                  Text(
                    'Android needs these so AscentFlow can see which app you open, lock it, '
                    'and show the timer on your lock screen.',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _PermissionRow(
                    granted: _usage,
                    title: 'Usage access',
                    body: 'Find AscentFlow in the list and turn it on.',
                    onAllow: FocusGuard.openUsageAccessSettings,
                  ),
                  _PermissionRow(
                    granted: _overlay,
                    title: 'Display over other apps',
                    body: 'Lets AscentFlow cover locked apps and bring you back.',
                    onAllow: FocusGuard.openOverlaySettings,
                  ),
                  _PermissionRow(
                    granted: _notify,
                    title: 'Notifications',
                    body: 'Shows the running timer on your lock screen.',
                    onAllow: () async {
                      await FocusGuard.requestNotificationPermission();
                      await Future<void>.delayed(const Duration(seconds: 1));
                      await _refresh();
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Apps you can still use', style: AppTypography.eyebrow.copyWith(color: colors.textPrimary)),
                      ),
                      Text(
                        '${settings.allowed.length} allowed',
                        style: AppTypography.caption.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                  Text(
                    'Like Maps or Music. Everything else is locked during focus.',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search apps',
                      prefixIcon: const Icon(LucideIcons.search, size: 18),
                      filled: true,
                      fillColor: colors.surface1,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMd,
                        borderSide: BorderSide(color: colors.border, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMd,
                        borderSide: BorderSide(color: colors.border, width: 2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (FocusGuard.supported)
            _apps == null
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                    sliver: SliverList.builder(
                      itemCount: apps.length,
                      itemBuilder: (context, i) {
                        final app = apps[i];
                        final on = settings.allowed.contains(app.package);
                        return SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: on,
                          onChanged: (_) {
                            HapticFeedback.selectionClick();
                            notifier.toggleAllowed(app.package);
                          },
                          secondary: ClipRRect(
                            borderRadius: AppRadius.borderRadiusSm,
                            child: app.icon == null
                                ? Icon(LucideIcons.appWindow, color: colors.textTertiary)
                                : Image.memory(app.icon!, width: 40, height: 40, gaplessPlayback: true),
                          ),
                          title: Text(app.label, style: AppTypography.label.copyWith(color: colors.textPrimary)),
                        );
                      },
                    ),
                  ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: colors.border, width: 2),
      ),
      child: child,
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.granted,
    required this.title,
    required this.body,
    required this.onAllow,
  });

  final bool granted;
  final String title;
  final String body;
  final Future<void> Function() onAllow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            granted ? LucideIcons.circleCheck : LucideIcons.circleAlert,
            color: granted ? colors.mint : AppColors.campfireDeep,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label.copyWith(color: colors.textPrimary)),
                Text(granted ? 'Allowed' : body, style: AppTypography.caption.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
          if (!granted)
            FilledButton.tonal(
              onPressed: () {
                HapticFeedback.selectionClick();
                onAllow();
              },
              child: const Text('Allow'),
            ),
        ],
      ),
    );
  }
}
