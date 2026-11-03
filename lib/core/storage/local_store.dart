import 'package:shared_preferences/shared_preferences.dart';

/// Small typed wrapper around [SharedPreferences].
///
/// Everything stored here is non-sensitive device data: onboarding progress,
/// guest cart, guest wishlist, theme choice, and demo-only records.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kOnboardingSeen = 'onboarding_seen';
  static const _kThemeMode = 'theme_mode';
  static const _kRecentSearches = 'recent_searches';
  static const _kCart = 'cart_v1';
  static const _kWishlist = 'wishlist_v1';
  static const _kDemoUser = 'demo_user_v1';
  static const _kDemoProfile = 'demo_profile_v1';
  static const _kDemoAddresses = 'demo_addresses_v1';
  static const _kDemoOrders = 'demo_orders_v1';
  static const _kDemoNotifications = 'demo_notifications_v1';
  static const _kNotifyOrders = 'notify_orders';
  static const _kNotifyAccount = 'notify_account';
  static const _kDemoOrderSequence = 'demo_order_sequence';

  bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool value) =>
      _prefs.setBool(_kOnboardingSeen, value);

  String? get themeMode => _prefs.getString(_kThemeMode);
  Future<void> setThemeMode(String value) =>
      _prefs.setString(_kThemeMode, value);

  List<String> get recentSearches =>
      _prefs.getStringList(_kRecentSearches) ?? const <String>[];
  Future<void> setRecentSearches(List<String> values) =>
      _prefs.setStringList(_kRecentSearches, values);

  String? readString(String key) => _prefs.getString(key);
  Future<void> writeString(String key, String value) =>
      _prefs.setString(key, value);
  Future<void> remove(String key) => _prefs.remove(key);

  String? get cartJson => _prefs.getString(_kCart);
  Future<void> setCartJson(String value) => _prefs.setString(_kCart, value);
  Future<void> clearCart() => _prefs.remove(_kCart);

  String? get wishlistJson => _prefs.getString(_kWishlist);
  Future<void> setWishlistJson(String value) =>
      _prefs.setString(_kWishlist, value);

  String? get demoUserJson => _prefs.getString(_kDemoUser);
  Future<void> setDemoUserJson(String value) =>
      _prefs.setString(_kDemoUser, value);
  Future<void> clearDemoUser() => _prefs.remove(_kDemoUser);

  String? get demoProfileJson => _prefs.getString(_kDemoProfile);
  Future<void> setDemoProfileJson(String value) =>
      _prefs.setString(_kDemoProfile, value);

  String? get demoAddressesJson => _prefs.getString(_kDemoAddresses);
  Future<void> setDemoAddressesJson(String value) =>
      _prefs.setString(_kDemoAddresses, value);

  String? get demoOrdersJson => _prefs.getString(_kDemoOrders);
  Future<void> setDemoOrdersJson(String value) =>
      _prefs.setString(_kDemoOrders, value);

  String? get demoNotificationsJson => _prefs.getString(_kDemoNotifications);
  Future<void> setDemoNotificationsJson(String value) =>
      _prefs.setString(_kDemoNotifications, value);

  bool get notifyOrders => _prefs.getBool(_kNotifyOrders) ?? true;
  Future<void> setNotifyOrders(bool value) =>
      _prefs.setBool(_kNotifyOrders, value);

  bool get notifyAccount => _prefs.getBool(_kNotifyAccount) ?? true;
  Future<void> setNotifyAccount(bool value) =>
      _prefs.setBool(_kNotifyAccount, value);

  int get demoOrderSequence => _prefs.getInt(_kDemoOrderSequence) ?? 20482;
  Future<void> setDemoOrderSequence(int value) =>
      _prefs.setInt(_kDemoOrderSequence, value);
}
