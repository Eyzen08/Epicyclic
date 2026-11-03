import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_user.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  AppUser _mapUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final email = user.email ?? '';
    final fallbackName = email.contains('@')
        ? email.split('@').first
        : 'Customer';
    return AppUser(
      id: user.id,
      email: email,
      fullName: (metadata['full_name'] as String?)?.trim().isNotEmpty == true
          ? (metadata['full_name'] as String).trim()
          : fallbackName,
      phone: user.phone,
    );
  }

  @override
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((state) {
      final user = state.session?.user;
      return user == null ? null : _mapUser(user);
    });
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Sign in did not return an account.');
      }
      return _mapUser(user);
    } on AuthException catch (error) {
      throw AuthFailure(_friendly(error.message));
    }
  }

  @override
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Sign up did not return an account.');
      }
      return _mapUser(user);
    } on AuthException catch (error) {
      throw AuthFailure(_friendly(error.message));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'com.epicyclic.epicyclic://reset-password',
      );
    } on AuthException catch (error) {
      throw AuthFailure(_friendly(error.message));
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.epicyclic.epicyclic://login-callback',
      );
    } on AuthException catch (error) {
      throw AuthFailure(_friendly(error.message));
    }
  }

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          data: {'full_name': fullName.trim()},
          phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
        ),
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Profile update did not return an account.');
      }
      return _mapUser(user);
    } on AuthException catch (error) {
      throw AuthFailure(_friendly(error.message));
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String _friendly(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'That email and password combination is incorrect.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Confirm your email address, then try again.';
    }
    if (lower.contains('already registered')) {
      return 'An account with that email already exists.';
    }
    if (lower.contains('rate limit')) {
      return 'Too many attempts. Wait a moment and try again.';
    }
    return message;
  }
}
