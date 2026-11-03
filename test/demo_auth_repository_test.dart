import 'package:epicyclic/core/config/app_config.dart';
import 'package:epicyclic/core/storage/local_store.dart';
import 'package:epicyclic/features/auth/data/auth_repository.dart';
import 'package:epicyclic/features/auth/data/demo_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = LocalStore(await SharedPreferences.getInstance());
  });

  group('DemoAuthRepository', () {
    test('signs in with the documented demo account', () async {
      final repository = DemoAuthRepository(store);

      final user = await repository.signIn(
        email: '  ALEX.MORGAN@EPICYCLIC.DEMO ',
        password: AppConfig.demoPassword,
      );

      expect(user.fullName, 'Alex Morgan');
      expect(user.email, AppConfig.demoEmail);
      expect(repository.currentUser?.id, user.id);
      expect(store.demoUserJson, isNotNull);
    });

    test('rejects any other credentials', () async {
      final repository = DemoAuthRepository(store);

      await expectLater(
        repository.signIn(
          email: AppConfig.demoEmail,
          password: 'wrong-password',
        ),
        throwsA(isA<AuthFailure>()),
      );
      expect(repository.currentUser, isNull);
    });

    test('restores a saved demo session on construction', () async {
      final first = DemoAuthRepository(store);
      await first.signIn(
        email: AppConfig.demoEmail,
        password: AppConfig.demoPassword,
      );

      final second = DemoAuthRepository(store);

      expect(second.currentUser?.email, AppConfig.demoEmail);
    });

    test('sign out clears both the session and stored user', () async {
      final repository = DemoAuthRepository(store);
      await repository.signIn(
        email: AppConfig.demoEmail,
        password: AppConfig.demoPassword,
      );

      await repository.signOut();

      expect(repository.currentUser, isNull);
      expect(store.demoUserJson, isNull);
      expect(DemoAuthRepository(store).currentUser, isNull);
    });

    test('sign up rejects passwords shorter than eight characters', () async {
      final repository = DemoAuthRepository(store);

      await expectLater(
        repository.signUp(
          fullName: 'New Shopper',
          email: 'shopper@example.com',
          password: 'short',
        ),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('sign up stores a local-only account', () async {
      final repository = DemoAuthRepository(store);

      final user = await repository.signUp(
        fullName: '  New Shopper ',
        email: 'SHOPPER@example.com ',
        password: 'long-enough',
      );

      expect(user.fullName, 'New Shopper');
      expect(user.email, 'shopper@example.com');
      expect(user.id, startsWith('demo-'));
      expect(repository.currentUser?.email, 'shopper@example.com');
    });

    test('profile updates require a signed-in user', () async {
      final repository = DemoAuthRepository(store);

      await expectLater(
        repository.updateProfile(fullName: 'Nobody'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('demo password reset is explicit about not sending email', () async {
      final repository = DemoAuthRepository(store);

      await expectLater(
        repository.sendPasswordReset('someone@example.com'),
        throwsA(
          isA<AuthFailure>().having(
            (error) => error.message,
            'message',
            contains('does not send email'),
          ),
        ),
      );
    });
  });
}
