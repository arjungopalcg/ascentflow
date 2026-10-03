import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_provider.dart';
import 'user_profile_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME WIDGETS — the catalog of widgets any section can put on Home, and the
// person's chosen layout (which are on, in what order). Saved on the device.
// ─────────────────────────────────────────────────────────────────────────────

class HomeWidgetModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  /// The part of the app the widget comes from, used to group the catalog.
  final String section;

  const HomeWidgetModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.section,
  });
}

/// Every widget available for Home, in their default order.
const allHomeWidgets = [
  HomeWidgetModel(
    id: 'progress',
    name: 'Today\'s climb',
    description: 'Your day drawn as a climb: how far you\'ve come and what\'s next.',
    icon: LucideIcons.mountain,
    section: 'Today',
  ),
  HomeWidgetModel(
    id: 'plan',
    name: 'Today\'s plan',
    description: 'Habits and tasks for today in one list you can tick off.',
    icon: LucideIcons.listChecks,
    section: 'Today',
  ),
  HomeWidgetModel(
    id: 'focus',
    name: 'Focus session',
    description: 'Start a focus session in one tap.',
    icon: LucideIcons.timer,
    section: 'Focus',
  ),
  HomeWidgetModel(
    id: 'reminders',
    name: 'Due soon',
    description: 'Tasks with a deadline coming up.',
    icon: LucideIcons.alarmClock,
    section: 'Tasks',
  ),
  HomeWidgetModel(
    id: 'goals',
    name: 'Goal progress',
    description: 'How far along your active goals are.',
    icon: LucideIcons.target,
    section: 'Goals',
  ),
  HomeWidgetModel(
    id: 'challenge',
    name: 'Daily challenge',
    description: 'A small stretch goal each day for extra altitude.',
    icon: LucideIcons.flag,
    section: 'Goals',
  ),
  HomeWidgetModel(
    id: 'mood',
    name: 'Mood check-in',
    description: 'Log how you feel in one tap.',
    icon: LucideIcons.smile,
    section: 'Journal',
  ),
  HomeWidgetModel(
    id: 'savings',
    name: 'Savings',
    description: 'What you\'ve saved toward each goal.',
    icon: LucideIcons.piggyBank,
    section: 'Money',
  ),
  HomeWidgetModel(
    id: 'lists',
    name: 'My lists',
    description: 'Jump straight into your lists.',
    icon: LucideIcons.list,
    section: 'Lists',
  ),
  HomeWidgetModel(
    id: 'coach',
    name: 'Ask your coach',
    description: 'A question to start a conversation with your AI coach.',
    icon: LucideIcons.messageCircle,
    section: 'Coach',
  ),
  HomeWidgetModel(
    id: 'altitude',
    name: 'Altitude',
    description: 'Your total climb and the distance to the next camp.',
    icon: LucideIcons.mountainSnow,
    section: 'Progress',
  ),
  HomeWidgetModel(
    id: 'motivation',
    name: 'A thought for today',
    description: 'A short quote to start the day.',
    icon: LucideIcons.quote,
    section: 'Today',
  ),
];

final _defaultOrder = [for (final w in allHomeWidgets) w.id];

const _defaultEnabled = ['progress', 'plan', 'challenge', 'motivation'];

/// The starting home layout for what someone said they want help with.
List<String> widgetsForFocusAreas(Set<FocusArea> areas) {
  final ids = <String>{'progress'};
  for (final area in areas) {
    ids.addAll(switch (area) {
      FocusArea.plan => ['plan', 'reminders'],
      FocusArea.focus => ['focus'],
      FocusArea.goals => ['goals', 'challenge'],
      FocusArea.reflect => ['mood', 'coach'],
      FocusArea.money => ['savings'],
      FocusArea.lists => ['lists'],
    });
  }
  // Keep the catalog's order so related widgets sit together.
  return [for (final id in _defaultOrder) if (ids.contains(id)) id];
}

class HomeWidgetsState {
  final List<String> enabledIds;
  final List<String> order;

  HomeWidgetsState({
    required this.enabledIds,
    required this.order,
  });

  /// Enabled widgets in display order.
  List<String> get visible => [for (final id in order) if (enabledIds.contains(id)) id];

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
  HomeWidgetsNotifier(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;

  static const _kEnabled = 'home.enabled';
  static const _kOrder = 'home.order';

  static HomeWidgetsState _read(SharedPreferences p) {
    final saved = p.getStringList(_kOrder) ?? const <String>[];
    // Keep the saved order, then append widgets added in newer versions.
    final order = [
      for (final id in saved) if (_defaultOrder.contains(id)) id,
      for (final id in _defaultOrder) if (!saved.contains(id)) id,
    ];
    return HomeWidgetsState(
      enabledIds: p.getStringList(_kEnabled) ?? List.of(_defaultEnabled),
      order: order,
    );
  }

  Future<void> _save() async {
    await _prefs.setStringList(_kEnabled, state.enabledIds);
    await _prefs.setStringList(_kOrder, state.order);
  }

  /// Turns on exactly [ids], placing them first in the given order.
  Future<void> setEnabled(List<String> ids) async {
    state = HomeWidgetsState(
      enabledIds: List.of(ids),
      order: [...ids, for (final id in _defaultOrder) if (!ids.contains(id)) id],
    );
    await _save();
  }

  void toggleWidget(String id) {
    final List<String> newEnabledIds = List.from(state.enabledIds);
    if (newEnabledIds.contains(id)) {
      newEnabledIds.remove(id);
    } else {
      newEnabledIds.add(id);
    }
    state = state.copyWith(enabledIds: newEnabledIds);
    _save();
  }

  /// Reorders within the visible widgets. [newIndex] is already adjusted for
  /// the removed item (onReorderItem).
  void reorderVisible(int oldIndex, int newIndex) {
    final visible = state.visible;
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);
    state = state.copyWith(
      order: [...visible, for (final id in state.order) if (!visible.contains(id)) id],
    );
    _save();
  }
}

final homeWidgetsProvider =
    StateNotifierProvider<HomeWidgetsNotifier, HomeWidgetsState>((ref) {
  return HomeWidgetsNotifier(ref.watch(sharedPrefsProvider));
});
