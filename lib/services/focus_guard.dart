import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FOCUS GUARD — Dart side of the focus lock (Android only for now).
// • Lock: Android app pinning keeps the phone on AscentFlow during focus.
// • Block: a foreground service sends you back here if you open an app you
//   chose to block, and reports which one.
// On other platforms every call is a safe no-op. iPhone blocking needs Apple's
// Screen Time (FamilyControls) entitlement and is planned separately.
// ─────────────────────────────────────────────────────────────────────────────

class BlockableApp {
  const BlockableApp({required this.package, required this.label, this.icon});
  final String package;
  final String label;
  final Uint8List? icon;
}

class FocusGuard {
  FocusGuard._();

  static const _channel = MethodChannel('ascentflow/focus');
  static final _blocked = StreamController<String>.broadcast();

  /// Whether this device can lock and block (Android).
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Labels of blocked apps the user tried to open during focus.
  static Stream<String> get blockedApps => _blocked.stream;

  static void init() {
    if (!supported) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'blockedApp') {
        final args = Map<String, Object?>.from(call.arguments as Map);
        _blocked.add(args['label'] as String? ?? 'That app');
      }
    });
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

  static Future<void> startLock() => _call<void>('startLock');
  static Future<void> stopLock() => _call<void>('stopLock');
  static Future<bool> isLocked() async => await _call<bool>('isLocked') ?? false;

  /// False when the screen is off — turning the screen off isn't leaving.
  static Future<bool> isScreenOn() async => await _call<bool>('isScreenOn') ?? true;

  static Future<bool> hasUsageAccess() async => await _call<bool>('hasUsageAccess') ?? false;
  static Future<void> openUsageAccessSettings() => _call<void>('openUsageAccessSettings');
  static Future<bool> hasOverlayPermission() async => await _call<bool>('hasOverlayPermission') ?? false;
  static Future<void> openOverlaySettings() => _call<void>('openOverlaySettings');
  static Future<void> openPinningSettings() => _call<void>('openPinningSettings');

  static Future<List<BlockableApp>> launchableApps() async {
    final raw = await _call<List<Object?>>('launchableApps') ?? const [];
    return [
      for (final item in raw)
        if (item is Map)
          BlockableApp(
            package: item['package'] as String,
            label: item['label'] as String,
            icon: item['icon'] as Uint8List?,
          ),
    ];
  }

  static Future<void> startBlocking(List<String> packages) =>
      _call<void>('startBlocking', {'packages': packages});
  static Future<void> stopBlocking() => _call<void>('stopBlocking');
}
