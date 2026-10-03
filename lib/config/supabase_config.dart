// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE CONFIG
// ─────────────────────────────────────────────────────────────────────────────
//
// The publishable key is safe to ship in the app: every table is protected by
// row level security, so a user can only read and write their own rows.
// Override either value at build time with:
//   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_KEY=...

class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mvnwxlaxqsvdulenuayt.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'sb_publishable_eSEcw5WCaSQu1ma8nJvxbw_u_AdnGKl',
  );
}
