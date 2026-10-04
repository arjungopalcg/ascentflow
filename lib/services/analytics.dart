import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/climb_engine.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — product analytics with PostHog (EU cloud), so we can see how
// people use AscentFlow: where onboarding loses them, whether they come back,
// how focus sessions end.
//
// Privacy: no names, task titles or journal text are ever sent; session
// replays mask every text and image. People can turn it off in Profile ›
// Privacy. Nothing is sent until [init] runs (never in tests).
// ─────────────────────────────────────────────────────────────────────────────

class Analytics {
  Analytics._();

  /// The project token is public by design (it can only send events).
  static const _token = 'phc_xw5VZAKauHSG5QyGjvJJgj6QzK7YE66oG7eZigfJprEG';
  static const _host = 'https://eu.i.posthog.com';
  static const enabledKey = 'analytics.enabled';

  static bool _ready = false;
  static bool _enabled = true;

  static bool get enabled => _enabled;

  static Future<void> init(SharedPreferences prefs) async {
    if (kIsWeb) return;
    _enabled = prefs.getBool(enabledKey) ?? true;
    final config = PostHogConfig(_token)
      ..host = _host
      ..captureApplicationLifecycleEvents = true
      ..optOut = !_enabled
      ..sessionReplay = true
      ..sessionReplayConfig.maskAllTexts = true
      ..sessionReplayConfig.maskAllImages = true
      ..debug = kDebugMode;
    try {
      await Posthog().setup(config);
      _ready = true;
    } catch (e) {
      debugPrint('Analytics off: $e');
    }
  }

  static Future<void> setEnabled(SharedPreferences prefs, bool on) async {
    _enabled = on;
    await prefs.setBool(enabledKey, on);
    if (!_ready) return;
    on ? await Posthog().enable() : await Posthog().disable();
  }

  static void capture(String event, [Map<String, Object>? properties]) {
    if (!_ready || !_enabled) return;
    unawaited(Posthog().capture(eventName: event, properties: properties));
  }

  static void screen(String name) {
    if (!_ready || !_enabled) return;
    unawaited(Posthog().screen(screenName: name));
  }

  /// Links this device's events to a signed-in account (Supabase user id).
  static void identify(String userId) {
    if (!_ready) return;
    unawaited(Posthog().identify(userId: userId));
  }

  /// Turns climb engine moments into events.
  static void climbEvent(ClimbEvent event) {
    switch (event) {
      case GainEvent(:final action, :final metres):
        capture('climb_action', {'action': action?.name ?? 'other', 'metres': metres});
      case StreakEvent(:final days, :final usedRestDay):
        capture('streak_extended', {'days': days, 'used_rest_day': usedRestDay});
      case CampEvent(:final camp):
        capture('camp_reached', {'camp': camp});
      case DaySummitEvent(:final metresToday, :final streak):
        capture('daily_summit', {'metres_today': metresToday, 'streak': streak});
      case SlipEvent(:final metres):
        capture('pip_slipped', {'metres': metres});
      case PeakSummitEvent(:final peak):
        capture('peak_summited', {'peak': peak.name});
    }
  }
}
