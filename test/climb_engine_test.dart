import 'package:ascent_flow/game/climb_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DateTime now;
  late SharedPreferences prefs;

  Future<ClimbNotifier> engine() async => ClimbNotifier(prefs, clock: () => now);

  setUp(() async {
    now = DateTime(2026, 10, 3, 9);
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('actions earn altitude and count toward the Daily climb', () async {
    final e = await engine();
    final events = <ClimbEvent>[];
    e.events.listen(events.add);

    e.record(ClimbAction.task);
    expect(e.state.altitude, 20);
    expect(e.state.stepsDone, 1);
    expect(e.state.streak, 1);
    await Future<void>.delayed(Duration.zero);
    expect(events.whereType<GainEvent>().single.metres, 20);
    expect(events.whereType<StreakEvent>().single.days, 1);
  });

  test('three tasks, a focus session and a reflection summit the day once', () async {
    final e = await engine();
    final events = <ClimbEvent>[];
    e.events.listen(events.add);

    for (var i = 0; i < 3; i++) {
      e.record(ClimbAction.task);
    }
    e.record(ClimbAction.focus);
    expect(e.state.summitedToday, isFalse);
    e.record(ClimbAction.mood);
    e.record(ClimbAction.task);
    await Future<void>.delayed(Duration.zero);

    expect(e.state.summitedToday, isTrue);
    expect(events.whereType<DaySummitEvent>(), hasLength(1));
    expect(e.state.summitDays, 1);
  });

  test('streak grows day to day, a rest day covers one miss, longer gaps reset', () async {
    final e = await engine();
    for (var d = 0; d < 7; d++) {
      now = DateTime(2026, 10, 3 + d, 9);
      e.record(ClimbAction.task);
    }
    expect(e.state.streak, 7);
    expect(e.state.restDays, 1, reason: 'a week banks a rest day');

    now = DateTime(2026, 10, 11, 9); // skipped the 10th
    e.record(ClimbAction.task);
    expect(e.state.streak, 8);
    expect(e.state.restDays, 0);

    now = DateTime(2026, 10, 14, 9); // skipped two days, no rest left
    expect(e.displayStreak, 0);
    e.record(ClimbAction.task);
    expect(e.state.streak, 1);
    expect(e.state.bestStreak, 8);
  });

  test('a new day resets today but keeps altitude; undo cannot go below zero', () async {
    final e = await engine();
    e.record(ClimbAction.focus);
    now = DateTime(2026, 10, 4, 9);
    e.undo(ClimbAction.task);
    expect(e.state.tasksToday, 0);
    expect(e.state.metresToday, 0);
    expect(e.state.altitude, 20);
  });

  test('camps every 500 m and expeditions climb real peaks in order', () async {
    final e = await engine();
    final events = <ClimbEvent>[];
    e.events.listen(events.add);
    for (var i = 0; i < 34; i++) {
      e.record(ClimbAction.focus); // 1,360 m
    }
    await Future<void>.delayed(Duration.zero);
    expect(e.state.camp, 3);
    expect(events.whereType<CampEvent>().map((c) => c.camp), [2, 3]);
    expect(events.whereType<PeakSummitEvent>().single.peak.name, 'Ben Nevis');
    expect(e.state.expedition.peak.name, 'Mount Fuji');
    expect(e.state.expedition.metres, 15);
  });

  test('state survives a restart', () async {
    (await engine()).record(ClimbAction.journal);
    final again = await engine();
    expect(again.state.altitude, 30);
    expect(again.state.reflectToday, 1);
  });

  test('giving up focus slips 50 m, but a camp catches the fall', () async {
    final e = await engine();
    final events = <ClimbEvent>[];
    e.events.listen(events.add);
    for (var i = 0; i < 14; i++) {
      e.record(ClimbAction.focus); // 560 m: Camp 2 starts at 500 m
    }
    e.slip();
    expect(e.state.altitude, 510);
    e.slip();
    expect(e.state.altitude, 500, reason: 'camp ledge');
    expect(e.state.falls, 2);
    await Future<void>.delayed(Duration.zero);
    final slips = events.whereType<SlipEvent>().toList();
    expect(slips.map((s) => s.metres), [50, 10]);
    expect(slips.last.caughtByCamp, isTrue);
  });
}
