import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import 'home/home_screen.dart';
import 'tasks/tasks_screen.dart';
import 'focus/focus_screen.dart';
import 'journal/journal_screen.dart';
import 'more/more_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCAFFOLD — IndexedStack + NavPillBar
// ─────────────────────────────────────────────────────────────────────────────

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fadeController;

  final List<Widget> _screens = const [
    HomeScreen(),
    TasksScreen(),
    FocusScreen(),
    JournalScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _NavPillBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV PILL BAR — Custom bottom navigation with floating pill indicator
// ─────────────────────────────────────────────────────────────────────────────

class _NavPillBar extends StatefulWidget {
  const _NavPillBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<_NavPillBar> createState() => _NavPillBarState();
}

class _NavPillBarState extends State<_NavPillBar>
    with SingleTickerProviderStateMixin {
  
  static const _items = [
    _NavItem(icon: LucideIcons.home, label: 'Today'),
    _NavItem(icon: LucideIcons.checkSquare, label: 'Tasks'),
    _NavItem(icon: LucideIcons.timer, label: 'Focus'),
    _NavItem(icon: LucideIcons.bookOpen, label: 'Journal'),
    _NavItem(icon: LucideIcons.layoutGrid, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: bottomPadding + AppSpacing.xs,
        left: AppSpacing.xs,
        right: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface1,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          return Expanded(
            child: _NavTabButton(
              item: _items[i],
              isActive: i == widget.currentIndex,
              onTap: () => widget.onTap(i),
              colors: colors,
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV TAB BUTTON — Every tab is labelled; the active one sits on a soft pill.
// ─────────────────────────────────────────────────────────────────────────────

class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? colors.textPrimary : colors.textTertiary;
    return Semantics(
      button: true,
      selected: isActive,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // No fixed height: the tab grows with the user's text-size setting.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppDuration.normal,
                curve: AppCurves.easeOut,
                width: 56,
                height: 30,
                decoration: BoxDecoration(
                  color: isActive
                      ? colors.primary.withValues(alpha: colors.isDark ? 0.18 : 0.12)
                      : Colors.transparent,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Icon(
                  item.icon,
                  size: 21,
                  color: isActive ? colors.primary : color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
