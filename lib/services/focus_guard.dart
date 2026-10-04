import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FOCUS GUARD — Dart side of the focus session service (Android for now).
// • A countdown notification shows the running timer on the lock screen.
// • The lock: while a session runs, any app that isn't on the allowed list is
//   covered by a full-screen lock and the user is sent back, like Forest's
//   Deep Focus. Calls always get through.
// On other platforms every call is a safe no-op. iPhone blocking needs Apple's
// Screen Time (FamilyControls) entitlement and is planned separately.
// ─────────────────────────────────────────────────────────────────────────────

class InstalledApp {
  const InstalledApp({required this.package, required this.label, this.icon});
  final String package;
  final String label;
  final Uint8List? icon;
}

class FocusGuard {
  FocusGuard._();

  static const _channel = MethodChannel('ascentflow/focus');
  static final _blocked = StreamController<String>.broadcast();
  static final _giveUps = StreamController<void>.broadcast();

  /// Prefs key the service sets when AscentFlow is closed mid-session.
  static const pendingSlipKey = 'focus.pendingSlip';

  /// Whether this device has the lock and lock-screen timer (Android).
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Labels of locked apps the user tried to open during focus.
  static Stream<String> get blockedApps => _blocked.stream;

  /// The user gave up from the lock screen over another app.
  static Stream<void> get giveUps => _giveUps.stream;

  static void init() {
    if (!supported) return;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'blockedApp':
          final args = Map<String, Object?>.from(call.arguments as Map);
          _blocked.add(args['label'] as String? ?? 'That app');
        case 'giveUp':
          _giveUps.add(null);
      }
    });
    _call<void>('ready');
  }

  static Future<T?> _call<T>(String method, [Object? args]) async {
    if (!supported) return null;
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      debugPrint('FocusGuard.$method failed: ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Starts the countdown notification and, with [guard], the lock.
  static Future<void> startSession({
    required DateTime endAt,
    required Duration total,
    required bool guard,
    required Iterable<String> allowed,
  }) =>
      _call<void>('startSession', {
        'endAt': endAt.millisecondsSinceEpoch,
        'totalMs': total.inMilliseconds,
        'guard': guard,
        'allowed': allowed.toList(),
      });

  static Future<void> stopSession() => _call<void>('stopSession');

  /// "Come back or Pip slips" alert, for sessions without the lock.
  static Future<void> warnLeaving(int seconds) => _call<void>('warnLeaving', {'seconds': seconds});
  static Future<void> clearWarning() => _call<void>('clearWarning');

  /// False when the screen is off — turning the screen off isn't leaving.
  static Future<bool> isScreenOn() async => await _call<bool>('isScreenOn') ?? true;

  static Future<bool> hasUsageAccess() async => await _call<bool>('hasUsageAccess') ?? false;
  static Future<void> openUsageAccessSettings() => _call<void>('openUsageAccessSettings');
  static Future<bool> hasOverlayPermission() async => await _call<bool>('hasOverlayPermission') ?? false;
  static Future<void> openOverlaySettings() => _call<void>('openOverlaySettings');
  static Future<bool> hasNotificationPermission() async =>
      await _call<bool>('hasNotificationPermission') ?? false;
  static Future<void> requestNotificationPermission() => _call<void>('requestNotificationPermission');

  /// Both permissions the lock needs.
  static Future<bool> canLock() async => await hasUsageAccess() && await hasOverlayPermission();

  static Future<List<InstalledApp>> launchableApps() async {
    final raw = await _call<List<Object?>>('launchableApps') ?? const [];
    return [
      for (final item in raw)
        if (item is Map)
          InstalledApp(
            package: item['package'] as String,
            label: item['label'] as String,
            icon: item['icon'] as Uint8List?,
          ),
    ];
  }
}
