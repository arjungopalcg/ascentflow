import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FOCUS SETTINGS — whether focus sessions lock the phone, and which apps stay
// usable while one runs (everything else is locked, like Forest). Saved on the
// device. Also a small log of focus time for the stats on the Focus tab.
// ─────────────────────────────────────────────────────────────────────────────

class FocusSettings {
  const FocusSettings({this.lockEnabled = true, this.allowed = const {}});

  /// Focus lock on: lock every app except [allowed] during focus.
  final bool lockEnabled;
  final Set<String> allowed;
}

class FocusSettingsNotifier extends StateNotifier<FocusSettings> {
  FocusSettingsNotifier(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;
  static const _kLock = 'focus.lock';
  static const _kAllowed = 'focus.allowed';

  static FocusSettings _read(SharedPreferences p) => FocusSettings(
        lockEnabled: p.getBool(_kLock) ?? true,
        allowed: (p.getStringList(_kAllowed) ?? const []).toSet(),
      );

  Future<void> setLock(bool on) async {
    await _prefs.setBool(_kLock, on);
    state = _read(_prefs);
  }

  Future<void> toggleAllowed(String package) async {
    final next = {...state.allowed};
    next.contains(package) ? next.remove(package) : next.add(package);
    await _prefs.setStringList(_kAllowed, next.toList());
    state = _read(_prefs);
  }
}

final focusSettingsProvider =
    StateNotifierProvider<FocusSettingsNotifier, FocusSettings>(
  (ref) => FocusSettingsNotifier(ref.watch(sharedPrefsProvider)),
);

// ── Focus stats ──────────────────────────────────────────────────────────────

class FocusStats {
  const FocusStats({this.day = '', this.sessionsToday = 0, this.minutesToday = 0, this.totalMinutes = 0});

  final String day;
  final int sessionsToday;
  final int minutesToday;
  final int totalMinutes;
}

class FocusStatsNotifier extends StateNotifier<FocusStats> {
  FocusStatsNotifier(this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const FocusStats()) {
    state = _rollover(_read());
  }

  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  static const _kDay = 'focus.stats.day';
  static const _kSessions = 'focus.stats.sessions';
  static const _kMinutes = 'focus.stats.minutes';
  static const _kTotal = 'focus.stats.total';

  String get _today {
    final d = _clock();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  FocusStats _read() => FocusStats(
        day: _prefs.getString(_kDay) ?? '',
        sessionsToday: _prefs.getInt(_kSessions) ?? 0,
        minutesToday: _prefs.getInt(_kMinutes) ?? 0,
        totalMinutes: _prefs.getInt(_kTotal) ?? 0,
      );

  FocusStats _rollover(FocusStats s) => s.day == _today
      ? s
      : FocusStats(day: _today, totalMinutes: s.totalMinutes);

  /// Refreshes "today" after midnight.
  void refresh() => state = _rollover(state);

  Future<void> addSession(int minutes) async {
    final s = _rollover(state);
    state = FocusStats(
      day: s.day,
      sessionsToday: s.sessionsToday + 1,
      minutesToday: s.minutesToday + minutes,
      totalMinutes: s.totalMinutes + minutes,
    );
    await _prefs.setString(_kDay, state.day);
    await _prefs.setInt(_kSessions, state.sessionsToday);
    await _prefs.setInt(_kMinutes, state.minutesToday);
    await _prefs.setInt(_kTotal, state.totalMinutes);
  }
}

final focusStatsProvider = StateNotifierProvider<FocusStatsNotifier, FocusStats>(
  (ref) => FocusStatsNotifier(ref.watch(sharedPrefsProvider)),
);
