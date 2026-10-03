import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    _NavItem(icon: LucideIcons.home, activeIcon: LucideIcons.home, label: 'HOME'),
    _NavItem(icon: LucideIcons.checkSquare, activeIcon: LucideIcons.checkSquare, label: 'TASKS'),
    _NavItem(icon: LucideIcons.timer, activeIcon: LucideIcons.timer, label: 'FOCUS'),
    _NavItem(icon: LucideIcons.bookOpen, activeIcon: LucideIcons.bookOpen, label: 'JOURNAL'),
    _NavItem(icon: LucideIcons.layoutGrid, activeIcon: LucideIcons.layoutGrid, label: 'MORE'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: colors.isDark ? 24 : 20,
          sigmaY: colors.isDark ? 24 : 20,
        ),
        child: Container(
          height: 80 + bottomPadding,
          padding: EdgeInsets.only(
            bottom: bottomPadding,
            left: AppSpacing.md,
            right: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colors.isDark
                ? const Color(0xE00A0A12) 
                : const Color(0xEBFFFFFF), 
            // Removed the top border to eliminate the white line
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (i) {
              final isActive = i == widget.currentIndex;
              return _AnimNavTabButton(
                item: _items[i],
                isActive: isActive,
                onTap: () => widget.onTap(i),
                colors: colors,
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV TAB BUTTON — Bouncy minimal slide animation
// ─────────────────────────────────────────────────────────────────────────────

class _AnimNavTabButton extends StatelessWidget {
  const _AnimNavTabButton({
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        width: 64, // Fixed touch target width per tab
        height: 70, // Explicit height for correct Stack positioning
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The Icon smoothly sliding up when active
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              top: isActive ? 8.0 : 20.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isActive ? 1.0 : 0.6,
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: 26,
                  color: isActive ? colors.primary : colors.textTertiary,
                ),
              ),
            ),
            
            // The label appearing below
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              bottom: isActive ? 16.0 : 4.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isActive ? 1.0 : 0.0,
                child: Text(
                  item.label,
                  style: AppTypography.eyebrow.copyWith(
                    color: colors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            
            // A tiny glowing dot below the label
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              bottom: isActive ? 6.0 : -4.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                scale: isActive ? 1.0 : 0.0,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primaryGlow,
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ]
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
