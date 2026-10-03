import 'package:flutter/material.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/buttons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppTourScreen extends StatefulWidget {
  const AppTourScreen({super.key});

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _tourPages = [
    {
      'icon': LucideIcons.layoutDashboard,
      'title': 'Welcome to Ascent Flow',
      'body': 'Your all-in-one productivity and wellbeing companion. Track tasks, focus, and journal your way to success.',
    },
    {
      'icon': LucideIcons.timer,
      'title': 'Deep Focus Sessions',
      'body': 'Eliminate distractions with our Pomodoro timer and App Blocker. Every session climbs 40 m.',
    },
    {
      'icon': LucideIcons.lineChart,
      'title': 'Insights & Analytics',
      'body': 'Understand your habits. View detailed analytics to find out when you are most productive.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Skip', style: AppTypography.label.copyWith(color: colors.textSecondary)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemCount: _tourPages.length,
              itemBuilder: (context, index) {
                final page = _tourPages[index];
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(page['icon'] as IconData, size: 80, color: colors.primary),
                      const SizedBox(height: AppSpacing.xxxl),
                      Text(
                        page['title'] as String,
                        style: AppTypography.heading2.copyWith(color: colors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        page['body'] as String,
                        style: AppTypography.bodyLarge.copyWith(color: colors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_tourPages.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? colors.primary : colors.surface3,
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                PillButton(
                  label: _currentPage == _tourPages.length - 1 ? 'Get Started' : 'Next',
                  onTap: () {
                    if (_currentPage == _tourPages.length - 1) {
                      Navigator.pop(context);
                    } else {
                      _pageController.nextPage(
                        duration: AppDuration.medium,
                        curve: AppCurves.easeOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
