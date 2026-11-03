import 'package:epicyclic/core/storage/local_store.dart';
import 'package:epicyclic/features/wishlist/presentation/wishlist_controller.dart';
import 'package:epicyclic/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = LocalStore(await SharedPreferences.getInstance());
  });

  ProviderContainer createContainer() {
    final created = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
    );
    addTearDown(created.dispose);
    return created;
  }

  test('wishlist starts empty', () async {
    final container = createContainer();
    final state = await container.read(wishlistControllerProvider.future);

    expect(state, isEmpty);
  });

  test('toggle adds and removes product ids from the wishlist', () async {
    final container = createContainer();
    final controller = container.read(wishlistControllerProvider.notifier);
    await container.read(wishlistControllerProvider.future);
    expect(await controller.toggle('keychron-k2-pro'), isTrue);
    expect(await controller.toggle('keychron-k2-pro'), isFalse);

    final state = await container.read(wishlistControllerProvider.future);
    expect(state, isEmpty);
  });

  test('persist keeps the watched product ids in local storage', () async {
    final container = createContainer();
    final controller = container.read(wishlistControllerProvider.notifier);
    await container.read(wishlistControllerProvider.future);
    await controller.toggle('keychron-k2-pro');

    final state = await container.read(wishlistControllerProvider.future);
    expect(state, contains('keychron-k2-pro'));
    expect(store.wishlistJson, isNotNull);
  });
}
