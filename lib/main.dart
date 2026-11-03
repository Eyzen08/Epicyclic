import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/storage/local_store.dart';
import 'shared/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  if (config.configError != null) {
    runApp(_StartupErrorApp(message: config.configError!));
    return;
  }

  SupabaseClient? client;
  if (config.hasSupabase) {
    try {
      await Supabase.initialize(
        url: config.supabaseUrl!,
        publishableKey: config.supabaseAnonKey!,
      );
      client = Supabase.instance.client;
    } catch (error) {
      runApp(
        _StartupErrorApp(
          message:
              'Supabase could not be initialized. Check SUPABASE_URL and SUPABASE_ANON_KEY, then restart.\n\n$error',
        ),
      );
      return;
    }
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        localStoreProvider.overrideWithValue(LocalStore(prefs)),
        supabaseClientProvider.overrideWithValue(client),
      ],
      child: const EpicyclicApp(),
    ),
  );
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Epicyclic Setup',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F8BF7)),
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.settings_suggest_outlined, size: 54),
                    const SizedBox(height: 18),
                    Text(
                      'Epicyclic needs configuration',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'See docs/setup.md for the exact command.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
