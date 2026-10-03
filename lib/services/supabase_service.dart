import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE SERVICE — Initialisation + anonymous sign-in
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseService {
  static bool _ready = false;

  /// True once Supabase is initialised and a user session exists.
  /// When false, the app falls back to local sample data.
  static bool get isReady => _ready;

  static SupabaseClient get client => Supabase.instance.client;

  static String? get userId => client.auth.currentUser?.id;

  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );

      // Every device gets an anonymous account until real sign-up exists.
      // Requires "Allow anonymous sign-ins" in Supabase Auth settings.
      if (client.auth.currentSession == null) {
        await client.auth.signInAnonymously();
      }
      _ready = client.auth.currentSession != null;
    } catch (e) {
      debugPrint('Supabase unavailable, using local data: $e');
      _ready = false;
    }
  }
}
