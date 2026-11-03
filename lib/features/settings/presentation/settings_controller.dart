import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.notifyOrders,
    required this.notifyAccount,
  });

  final ThemeMode themeMode;
  final bool notifyOrders;
  final bool notifyAccount;
}

ThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.light;
  }
}

String themeModeValue(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final store = ref.read(localStoreProvider);
    return AppSettings(
      themeMode: _themeModeFromString(store.themeMode),
      notifyOrders: store.notifyOrders,
      notifyAccount: store.notifyAccount,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AppSettings(
      themeMode: mode,
      notifyOrders: state.notifyOrders,
      notifyAccount: state.notifyAccount,
    );
    await ref.read(localStoreProvider).setThemeMode(themeModeValue(mode));
  }

  Future<void> setNotifyOrders(bool value) async {
    state = AppSettings(
      themeMode: state.themeMode,
      notifyOrders: value,
      notifyAccount: state.notifyAccount,
    );
    await ref.read(localStoreProvider).setNotifyOrders(value);
  }

  Future<void> setNotifyAccount(bool value) async {
    state = AppSettings(
      themeMode: state.themeMode,
      notifyOrders: state.notifyOrders,
      notifyAccount: value,
    );
    await ref.read(localStoreProvider).setNotifyAccount(value);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});
