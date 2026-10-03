import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_widgets_provider.dart';
import 'prefs_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// USER PROFILE — name, whether first-launch setup is done, and what the person
// said they want help with. Stored on the device.
// ─────────────────────────────────────────────────────────────────────────────

/// What a person can ask AscentFlow to help with during setup.
enum FocusArea {
  plan('Plan my days', 'A clear list of what\'s next and what\'s due'),
  focus('Focus deeply', 'Timed sessions with distractions blocked'),
  goals('Build habits and reach goals', 'Daily habits, targets and challenges'),
  reflect('Reflect and journal', 'Mood check-ins and a place to write'),
  money('Save money', 'Savings goals you can see grow'),
  lists('Keep lists', 'Groceries, reading, gifts, shared or private');

  const FocusArea(this.title, this.description);
  final String title;
  final String description;
}

class UserProfile {
  const UserProfile({
    this.name = '',
    this.onboarded = false,
    this.focusAreas = const {},
  });

  final String name;
  final bool onboarded;
  final Set<FocusArea> focusAreas;
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier(this._prefs, this._ref) : super(_read(_prefs));

  final SharedPreferences _prefs;
  final Ref _ref;

  static const _kName = 'profile.name';
  static const _kOnboarded = 'profile.onboarded';
  static const _kAreas = 'profile.focusAreas';

  static UserProfile _read(SharedPreferences p) => UserProfile(
        name: p.getString(_kName) ?? '',
        onboarded: p.getBool(_kOnboarded) ?? false,
        focusAreas: {
          for (final n in p.getStringList(_kAreas) ?? const <String>[])
            ...FocusArea.values.where((a) => a.name == n),
        },
      );

  /// Finishes first-launch setup and lays out the home screen.
  Future<void> completeOnboarding({
    required String name,
    required Set<FocusArea> areas,
    required List<String> homeWidgets,
  }) async {
    await _ref.read(homeWidgetsProvider.notifier).setEnabled(homeWidgets);
    await _prefs.setString(_kName, name.trim());
    await _prefs.setStringList(_kAreas, [for (final a in areas) a.name]);
    await _prefs.setBool(_kOnboarded, true);
    state = _read(_prefs);
  }

  Future<void> setName(String name) async {
    await _prefs.setString(_kName, name.trim());
    state = _read(_prefs);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (ref) => UserProfileNotifier(ref.watch(sharedPrefsProvider), ref),
);
