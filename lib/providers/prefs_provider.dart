import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's SharedPreferences, loaded once in `main()` and injected with
/// `sharedPrefsProvider.overrideWithValue(prefs)` so reads are synchronous.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPrefsProvider in main()'),
);
