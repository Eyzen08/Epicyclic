import 'package:flutter/material.dart';

enum AppMode { demo, supabase }

/// Environment-driven configuration.
///
/// The app never ships privileged Supabase keys. Only the public anon key is
/// read, and only through `--dart-define` values or a local launch config.
@immutable
class AppConfig {
  const AppConfig({
    required this.mode,
    this.supabaseUrl,
    this.supabaseAnonKey,
    this.configError,
  });

  final AppMode mode;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  /// Non-null when the requested mode cannot be honored. The app shows a
  /// blocking setup message instead of silently falling back to demo mode.
  final String? configError;

  static const String appName = 'Epicyclic';
  static const String tagline = 'Find Your Next Upgrade.';

  /// Demo credentials are deliberately public and only exist in demo mode.
  static const String demoEmail = 'alex.morgan@epicyclic.demo';
  static const String demoPassword = 'Epicyclic123!';

  static const String _envMode = String.fromEnvironment('APP_MODE');
  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  factory AppConfig.fromEnvironment() {
    final hasCredentials =
        _envUrl.trim().isNotEmpty && _envAnonKey.trim().isNotEmpty;
    final wantsSupabase = _envMode.toLowerCase() == 'supabase';
    if (wantsSupabase && hasCredentials) {
      return const AppConfig(
        mode: AppMode.supabase,
        supabaseUrl: _envUrl,
        supabaseAnonKey: _envAnonKey,
      );
    }
    if (wantsSupabase) {
      return const AppConfig(
        mode: AppMode.demo,
        configError:
            'APP_MODE=supabase requires both SUPABASE_URL and SUPABASE_ANON_KEY. '
            'Add them as --dart-define values, then restart the app.',
      );
    }
    return const AppConfig(mode: AppMode.demo);
  }

  bool get isDemo => mode == AppMode.demo;
  bool get hasSupabase => mode == AppMode.supabase;
}
