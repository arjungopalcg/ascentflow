import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/prefs_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CLIMB ENGINE — turns real actions into altitude.
//
// • Every action earns metres (a task, a focus session, a journal entry…).
// • The Daily climb is 3 tasks + 1 focus session + 1 reflection. Finish it and
//   you summit the day.
// • The campfire streak counts days with any climb. Every 7 days banks a rest
//   day (max 2) that quietly covers a missed day.
// • Camps every 500 m. Expeditions climb real mountains, one after another.
// Everything is saved on the device.
// ─────────────────────────────────────────────────────────────────────────────

enum ClimbAction {
  task(20, 'Task done'),
  habit(20, 'Goal met'),
  focus(40, 'Focus session'),
  journal(30, 'Journal entry'),
  mood(10, 'Mood logged');

  const ClimbAction(this.metres, this.label);
  final int metres;
  final String label;
}

/// What the Daily climb asks for.
abstract final class DailyClimb {
  static const tasks = 3;
  static const focus = 1;
  static const reflect = 1;
  static const steps = tasks + focus + reflect;
}

class Peak {
  const Peak(this.name, this.metres, this.region, this.note);
  final String name;
  final int metres;
  final String region;
  final String note;
}

/// Real mountains, climbed in order. Each starts from base camp (0 m).
const expeditions = [
  Peak('Ben Nevis', 1345, 'Scotland', 'The UK\'s highest peak. A good first summit.'),
  Peak('Mount Fuji', 3776, 'Japan', 'A perfect cone, climbed by night to see sunrise.'),
  Peak('Mont Blanc', 4806, 'France and Italy', 'The roof of the Alps.'),
  Peak('Kilimanjaro', 5895, 'Tanzania', 'Africa\'s highest, a free-standing giant.'),
  Peak('Denali', 6190, 'Alaska', 'North America\'s coldest, tallest peak.'),
  Peak('Aconcagua', 6961, 'Argentina', 'The highest mountain outside Asia.'),
  Peak('Everest', 8849, 'Nepal and Tibet', 'The top of the world.'),
];

const campEvery = 500;

/// How far you slip for giving up a focus session. More than a session earns
/// (40 m), so quitting costs more than not starting. Camps are safe ledges:
/// you never fall below the last one you reached.
const focusFallMetres = 50;

sealed class ClimbEvent {
  const ClimbEvent();
}

class GainEvent extends ClimbEvent {
  const GainEvent(this.metres, this.label, {this.action});
  final int metres;
  final String label;
  final ClimbAction? action;
}

class StreakEvent extends ClimbEvent {
  const StreakEvent(this.days, {this.usedRestDay = false});
  final int days;
  final bool usedRestDay;
}

class CampEvent extends ClimbEvent {
  const CampEvent(this.camp);
  final int camp;
}

class DaySummitEvent extends ClimbEvent {
  const DaySummitEvent({required this.metresToday, required this.streak});
  final int metresToday;
  final int streak;
}

class SlipEvent extends ClimbEvent {
  const SlipEvent(this.metres, {this.caughtByCamp = false});

  /// How far you actually fell (may be less than [focusFallMetres]).
  final int metres;

  /// True when the camp ledge stopped the fall short.
  final bool caughtByCamp;
}

class PeakSummitEvent extends ClimbEvent {
  const PeakSummitEvent(this.peak);
  final Peak peak;
}

class ClimbState {
  const ClimbState({
    this.altitude = 0,
    this.day = '',
    this.metresToday = 0,
    this.tasksToday = 0,
    this.focusToday = 0,
    this.reflectToday = 0,
    this.summitedToday = false,
    this.streak = 0,
    this.lastClimbDay,
    this.restDays = 0,
    this.bestStreak = 0,
    this.summitDays = 0,
    this.falls = 0,
  });

  final int altitude;
  final String day;
  final int metresToday;
  final int tasksToday;
  final int focusToday;
  final int reflectToday;
  final bool summitedToday;
  final int streak;
  final String? lastClimbDay;
  final int restDays;
  final int bestStreak;
  final int summitDays;

  /// Focus sessions given up.
  final int falls;

  int get camp => altitude ~/ campEvery + 1;
  int get metresToNextCamp => campEvery - altitude % campEvery;
  double get campProgress => (altitude % campEvery) / campEvery;

  /// Steps of the Daily climb done today (0–5).
  int get stepsDone =>
      tasksToday.clamp(0, DailyClimb.tasks) +
      focusToday.clamp(0, DailyClimb.focus) +
      reflectToday.clamp(0, DailyClimb.reflect);

  /// The expedition in progress, and metres climbed on it.
  ({int index, Peak peak, int metres}) get expedition {
    var left = altitude;
    for (var i = 0; i < expeditions.length; i++) {
      if (left < expeditions[i].metres) return (index: i, peak: expeditions[i], metres: left);
      left -= expeditions[i].metres;
    }
    final last = expeditions.length - 1;
    return (index: last, peak: expeditions[last], metres: expeditions[last].metres);
  }

  ClimbState copyWith({
    int? altitude,
    String? day,
    int? metresToday,
    int? tasksToday,
    int? focusToday,
    int? reflectToday,
    bool? summitedToday,
    int? streak,
    String? lastClimbDay,
    int? restDays,
    int? bestStreak,
    int? summitDays,
    int? falls,
  }) =>
      ClimbState(
        altitude: altitude ?? this.altitude,
        day: day ?? this.day,
        metresToday: metresToday ?? this.metresToday,
        tasksToday: tasksToday ?? this.tasksToday,
        focusToday: focusToday ?? this.focusToday,
        reflectToday: reflectToday ?? this.reflectToday,
        summitedToday: summitedToday ?? this.summitedToday,
        streak: streak ?? this.streak,
        lastClimbDay: lastClimbDay ?? this.lastClimbDay,
        restDays: restDays ?? this.restDays,
        bestStreak: bestStreak ?? this.bestStreak,
        summitDays: summitDays ?? this.summitDays,
        falls: falls ?? this.falls,
      );

  Map<String, Object?> toJson() => {
        'altitude': altitude,
        'day': day,
        'metresToday': metresToday,
        'tasksToday': tasksToday,
        'focusToday': focusToday,
        'reflectToday': reflectToday,
        'summitedToday': summitedToday,
        'streak': streak,
        'lastClimbDay': lastClimbDay,
        'restDays': restDays,
        'bestStreak': bestStreak,
        'summitDays': summitDays,
        'falls': falls,
      };

  factory ClimbState.fromJson(Map<String, Object?> j) => ClimbState(
        altitude: j['altitude'] as int? ?? 0,
        day: j['day'] as String? ?? '',
        metresToday: j['metresToday'] as int? ?? 0,
        tasksToday: j['tasksToday'] as int? ?? 0,
        focusToday: j['focusToday'] as int? ?? 0,
        reflectToday: j['reflectToday'] as int? ?? 0,
        summitedToday: j['summitedToday'] as bool? ?? false,
        streak: j['streak'] as int? ?? 0,
        lastClimbDay: j['lastClimbDay'] as String?,
        restDays: j['restDays'] as int? ?? 0,
        bestStreak: j['bestStreak'] as int? ?? 0,
        summitDays: j['summitDays'] as int? ?? 0,
        falls: j['falls'] as int? ?? 0,
      );
}

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

int _daysBetween(String a, String b) =>
    DateTime.parse(b).difference(DateTime.parse(a)).inDays;

class ClimbNotifier extends StateNotifier<ClimbState> {
  ClimbNotifier(this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const ClimbState()) {
    final raw = _prefs.getString(_key);
    final loaded = raw == null
        ? const ClimbState()
        : ClimbState.fromJson(jsonDecode(raw) as Map<String, Object?>);
    state = _rollover(loaded);
  }

  static const _key = 'climb.state';
  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  final _events = StreamController<ClimbEvent>.broadcast();

  /// Celebration moments, in the order they happened.
  Stream<ClimbEvent> get events => _events.stream;

  String get _today => dayKey(_clock());

  /// Resets today's counters on a new day, and lets the streak lapse if the
  /// gap is longer than the banked rest days can cover.
  ClimbState _rollover(ClimbState s) {
    final today = _today;
    var next = s;
    if (s.day != today) {
      next = next.copyWith(
        day: today,
        metresToday: 0,
        tasksToday: 0,
        focusToday: 0,
        reflectToday: 0,
        summitedToday: false,
      );
    }
    final last = s.lastClimbDay;
    if (last != null && _daysBetween(last, today) - 1 > s.restDays) {
      next = next.copyWith(streak: 0);
    }
    return next;
  }

  /// Streak as it should be shown right now (0 if it has lapsed).
  int get displayStreak => _rollover(state).streak;

  void record(ClimbAction action) {
    var s = _rollover(state);
    final before = s;
    final today = _today;

    // Streak: the first climb of a day keeps the campfire burning.
    var streakChanged = false;
    var usedRest = false;
    if (s.lastClimbDay != today) {
      final gap = s.lastClimbDay == null ? 1 : _daysBetween(s.lastClimbDay!, today);
      final missed = gap - 1;
      var rest = s.restDays;
      int streak;
      if (s.streak > 0 && missed <= rest) {
        rest -= missed;
        usedRest = missed > 0;
        streak = s.streak + 1;
      } else {
        streak = 1;
      }
      if (streak % 7 == 0 && rest < 2) rest += 1;
      s = s.copyWith(
        streak: streak,
        lastClimbDay: today,
        restDays: rest,
        bestStreak: streak > s.bestStreak ? streak : s.bestStreak,
      );
      streakChanged = true;
    }

    s = s.copyWith(
      altitude: s.altitude + action.metres,
      metresToday: s.metresToday + action.metres,
      tasksToday: s.tasksToday + (action == ClimbAction.task ? 1 : 0),
      focusToday: s.focusToday + (action == ClimbAction.focus ? 1 : 0),
      reflectToday: s.reflectToday +
          (action == ClimbAction.journal || action == ClimbAction.mood ? 1 : 0),
    );

    final summitNow = !s.summitedToday && s.stepsDone >= DailyClimb.steps;
    if (summitNow) s = s.copyWith(summitedToday: true, summitDays: s.summitDays + 1);

    state = s;
    _save();

    _events.add(GainEvent(action.metres, action.label, action: action));
    if (streakChanged) _events.add(StreakEvent(s.streak, usedRestDay: usedRest));
    if (s.camp > before.camp) _events.add(CampEvent(s.camp));
    if (s.expedition.index > before.expedition.index) {
      _events.add(PeakSummitEvent(before.expedition.peak));
    }
    if (summitNow) {
      _events.add(DaySummitEvent(metresToday: s.metresToday, streak: s.streak));
    }
  }

  /// Takes back an action that was undone (e.g. a task un-ticked) so altitude
  /// can't be farmed. A summit already reached today stays reached.
  void undo(ClimbAction action) {
    final s = _rollover(state);
    state = s.copyWith(
      altitude: (s.altitude - action.metres).clamp(0, 1 << 31),
      metresToday: (s.metresToday - action.metres).clamp(0, 1 << 31),
      tasksToday: action == ClimbAction.task ? (s.tasksToday - 1).clamp(0, 99) : null,
      focusToday: action == ClimbAction.focus ? (s.focusToday - 1).clamp(0, 99) : null,
      reflectToday: action == ClimbAction.journal || action == ClimbAction.mood
          ? (s.reflectToday - 1).clamp(0, 99)
          : null,
    );
    _save();
  }

  /// Giving up a focus session: slip down the mountain, but never below the
  /// last camp you reached.
  void slip([int metres = focusFallMetres]) {
    final s = _rollover(state);
    final campFloor = (s.altitude ~/ campEvery) * campEvery;
    final target = s.altitude - metres;
    final landed = target < campFloor ? campFloor : target;
    final fell = s.altitude - landed;
    state = s.copyWith(
      altitude: landed,
      metresToday: (s.metresToday - fell).clamp(0, 1 << 31),
      falls: s.falls + 1,
    );
    _save();
    _events.add(SlipEvent(fell, caughtByCamp: fell < metres));
  }

  void _save() => _prefs.setString(_key, jsonEncode(state.toJson()));

  @override
  void dispose() {
    _events.close();
    super.dispose();
  }
}

final climbProvider = StateNotifierProvider<ClimbNotifier, ClimbState>(
  (ref) => ClimbNotifier(ref.watch(sharedPrefsProvider)),
);
