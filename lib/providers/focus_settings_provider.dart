import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FOCUS SETTINGS — whether focus sessions lock the phone, and which apps are
// blocked while one runs. Saved on the device.
// ─────────────────────────────────────────────────────────────────────────────

class FocusSettings {
  const FocusSettings({this.lockEnabled = true, this.blocked = const {}});

  /// Focus lock on: pin the app and block the chosen apps during focus.
  final bool lockEnabled;
  final Set<String> blocked;
}

class FocusSettingsNotifier extends StateNotifier<FocusSettings> {
  FocusSettingsNotifier(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;
  static const _kLock = 'focus.lock';
  static const _kBlocked = 'focus.blocked';

  static FocusSettings _read(SharedPreferences p) => FocusSettings(
        lockEnabled: p.getBool(_kLock) ?? true,
        blocked: (p.getStringList(_kBlocked) ?? const []).toSet(),
      );

  Future<void> setLock(bool on) async {
    await _prefs.setBool(_kLock, on);
    state = _read(_prefs);
  }

  Future<void> toggleBlocked(String package) async {
    final next = {...state.blocked};
    next.contains(package) ? next.remove(package) : next.add(package);
    await _prefs.setStringList(_kBlocked, next.toList());
    state = _read(_prefs);
  }
}

final focusSettingsProvider =
    StateNotifierProvider<FocusSettingsNotifier, FocusSettings>(
  (ref) => FocusSettingsNotifier(ref.watch(sharedPrefsProvider)),
);
