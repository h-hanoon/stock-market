/// Supabase project settings, passed in at build time:
///
///   flutter run --dart-define-from-file=supabase.json
///
/// where supabase.json is {"SUPABASE_URL": "...", "SUPABASE_PUBLISHABLE_KEY": "..."}.
class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static void assertConfigured() {
    if (url.isEmpty || publishableKey.isEmpty) {
      throw StateError(
        'Missing Supabase config. Run with '
        '--dart-define-from-file=supabase.json (see supabase.example.json).',
      );
    }
  }
}
