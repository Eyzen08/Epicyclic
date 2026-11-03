import '../domain/app_user.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  AppUser? get currentUser;
  Stream<AppUser?> authStateChanges();

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signInWithGoogle();

  Future<AppUser> updateProfile({required String fullName, String? phone});

  Future<void> signOut();
}
