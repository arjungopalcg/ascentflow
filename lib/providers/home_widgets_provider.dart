import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';

class HomeWidgetModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const HomeWidgetModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

const allHomeWidgets = [
  HomeWidgetModel(
    id: 'challenge',
    name: 'Daily Challenge',
    description: 'Special daily tasks to earn extra XP.',
    icon: LucideIcons.zap,
  ),
  HomeWidgetModel(
    id: 'progress',
    name: 'Today\'s Progress',
    description: 'Summary of your tasks and focus time.',
    icon: LucideIcons.barChart2,
  ),
  HomeWidgetModel(
    id: 'plan',
    name: 'Today\'s Plan',
    description: 'Combined view of habits and upcoming tasks.',
    icon: LucideIcons.listChecks,
  ),
  HomeWidgetModel(
    id: 'savings',
    name: 'Savings Summary',
    description: 'Quick look at your active savings goals.',
    icon: LucideIcons.piggyBank,
  ),
  HomeWidgetModel(
    id: 'lists',
    name: 'My Lists',
    description: 'Quick access to your custom lists.',
    icon: LucideIcons.list,
  ),
  HomeWidgetModel(
    id: 'reminders',
    name: 'Task Reminders',
    description: 'Alerts for tasks due in 1, 3, 5, or 10 days.',
    icon: LucideIcons.alarmClock,
  ),
  HomeWidgetModel(
    id: 'motivation',
    name: 'Daily Motivation',
    description: 'Inspirational quotes to keep you going.',
    icon: LucideIcons.quote,
  ),
];

class HomeWidgetsState {
  final List<String> enabledIds;
  final List<String> order;

  HomeWidgetsState({
    required this.enabledIds,
    required this.order,
  });

  HomeWidgetsState copyWith({
    List<String>? enabledIds,
    List<String>? order,
  }) {
    return HomeWidgetsState(
      enabledIds: enabledIds ?? this.enabledIds,
      order: order ?? this.order,
    );
  }
}

class HomeWidgetsNotifier extends StateNotifier<HomeWidgetsState> {
  HomeWidgetsNotifier()
      : super(HomeWidgetsState(
          enabledIds: ['challenge', 'progress', 'plan', 'motivation'],
          order: ['challenge', 'progress', 'plan', 'savings', 'lists', 'reminders', 'motivation'],
        ));

  void toggleWidget(String id) {
    final List<String> newEnabledIds = List.from(state.enabledIds);
    if (newEnabledIds.contains(id)) {
      newEnabledIds.remove(id);
    } else {
      newEnabledIds.add(id);
    }
    state = state.copyWith(enabledIds: newEnabledIds);
  }

  void reorderWidgets(int oldIndex, int newIndex) {
    final List<String> newOrder = List.from(state.order);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    state = state.copyWith(order: newOrder);
  }
}

final homeWidgetsProvider =
    StateNotifierProvider<HomeWidgetsNotifier, HomeWidgetsState>((ref) {
  return HomeWidgetsNotifier();
});
