import 'dart:async';
import 'dart:convert';

import '../../../core/config/app_config.dart';
import '../../../core/storage/local_store.dart';
import '../domain/app_user.dart';
import 'auth_repository.dart';

/// Local-only authentication used when Supabase is not configured.
///
/// This is intentionally not presented as a live account system. The demo
/// account exists so reviewers can explore authenticated screens offline.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this._store) {
    final raw = _store.demoUserJson;
    if (raw == null) return;
    try {
      final stored = AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (stored.id == _demoUserId && stored.email != AppConfig.demoEmail) {
        // The documented demo address changed; refresh saved demo sessions so
        // an existing reviewer sees the current account without signing out.
        _currentUser = AppUser(
          id: stored.id,
          email: AppConfig.demoEmail,
          fullName: stored.fullName,
          phone: stored.phone,
          avatarUrl: stored.avatarUrl,
        );
        unawaited(_store.setDemoUserJson(jsonEncode(_currentUser!.toJson())));
      } else {
        _currentUser = stored;
      }
    } catch (_) {
      _currentUser = null;
    }
  }

  static const String _demoUserId = 'demo-alex-morgan';

  final LocalStore _store;
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  void _emit(AppUser? user) {
    _currentUser = user;
    if (!_controller.isClosed) _controller.add(user);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final normalized = email.trim().toLowerCase();
    if (normalized != AppConfig.demoEmail ||
        password != AppConfig.demoPassword) {
      throw const AuthFailure(
        'Demo mode accepts only the demo account shown on this screen.',
      );
    }
    final user = AppUser(
      id: _demoUserId,
      email: AppConfig.demoEmail,
      fullName: 'Alex Morgan',
      phone: '+63 917 555 0147',
    );
    await _store.setDemoUserJson(jsonEncode(user.toJson()));
    _emit(user);
    return user;
  }

  @override
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (password.length < 8) {
      throw const AuthFailure('Password must be at least 8 characters.');
    }
    final user = AppUser(
      id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim().toLowerCase(),
      fullName: fullName.trim(),
    );
    await _store.setDemoUserJson(jsonEncode(user.toJson()));
    _emit(user);
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    throw const AuthFailure(
      'Demo mode does not send email. Sign in with the demo account instead.',
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    throw const AuthFailure(
      'Google sign-in is available only when Supabase is configured.',
    );
  }

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw const AuthFailure('Sign in to update your profile.');
    }
    final updated = user.copyWith(
      fullName: fullName.trim(),
      phone: phone?.trim(),
    );
    await _store.setDemoUserJson(jsonEncode(updated.toJson()));
    _emit(updated);
    return updated;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _store.clearDemoUser();
    _emit(null);
  }
}
