import 'package:epicyclic/core/storage/local_store.dart';
import 'package:epicyclic/features/cart/domain/cart_models.dart';
import 'package:epicyclic/features/cart/presentation/cart_controller.dart';
import 'package:epicyclic/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

CartLine _line({
  String productId = 'keychron-k2-pro',
  String variantId = 'graphite',
}) {
  return CartLine(
    productId: productId,
    variantId: variantId,
    productName: 'Keychron K2 Pro',
    variantName: 'Graphite',
    tagline: 'Wireless Mechanical Keyboard',
    image: 'assets/images/products/keyboard_white.png',
    unitPriceCents: 12900,
    quantity: 1,
  );
}

Future<CartState> _currentState(ProviderContainer container) async {
  return await container.read(cartControllerProvider.future);
}

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

  group('CartController', () {
    test('starts with an empty cart', () async {
      final container = createContainer();
      final state = await _currentState(container);

      expect(state.isEmpty, isTrue);
      expect(state.itemCount, 0);
      expect(state.subtotalCents, 0);
    });

    test('adds a line and computes totals', () async {
      final container = createContainer();
      final controller = container.read(cartControllerProvider.notifier);
      await container.read(cartControllerProvider.future);
      await controller.addLine(_line());
      final state = await _currentState(container);

      expect(state.lines, hasLength(1));
      expect(state.itemCount, 1);
      expect(state.subtotalCents, 12900);
      expect(state.totalCents, 12900);
      expect(store.cartJson, isNotNull);
      final persisted = jsonDecode(store.cartJson!) as Map<String, dynamic>;
      expect((persisted['lines'] as List).single['quantity'], 1);
    });

    test('merges lines that share product and variant', () async {
      final container = createContainer();
      final controller = container.read(cartControllerProvider.notifier);
      await container.read(cartControllerProvider.future);
      await controller.addLine(_line());
      await controller.addLine(_line());
      final state = await _currentState(container);

      expect(state.lines, hasLength(1));
      expect(state.itemCount, 2);
      expect(state.subtotalCents, 25800);
    });

    test('quantity changes recalculate the line and cart total', () async {
      final container = createContainer();
      final controller = container.read(cartControllerProvider.notifier);
      await container.read(cartControllerProvider.future);
      await controller.addLine(_line());
      await controller.setQuantity('keychron-k2-pro', 'graphite', 3);
      final state = await _currentState(container);

      expect(state.lines.single.quantity, 3);
      expect(state.subtotalCents, 38700);
    });

    test('removeLine deletes the targeted cart line', () async {
      final container = createContainer();
      final controller = container.read(cartControllerProvider.notifier);
      await container.read(cartControllerProvider.future);
      await controller.addLine(_line());
      await controller.addLine(_line(productId: 'pulse-wireless-mouse'));
      await controller.removeLine('keychron-k2-pro', 'graphite');
      final state = await _currentState(container);

      expect(state.lines, hasLength(1));
      expect(state.lines.first.productId, 'pulse-wireless-mouse');
    });

    test('clear resets the cart', () async {
      final container = createContainer();
      final controller = container.read(cartControllerProvider.notifier);
      await container.read(cartControllerProvider.future);
      await controller.addLine(_line());
      await controller.clear();
      final state = await _currentState(container);

      expect(state.isEmpty, isTrue);
      expect(state.lines, isEmpty);
      expect(jsonDecode(store.cartJson!)['lines'], isEmpty);
    });

    test('applies the supported promo and computes the discount', () async {
      final container = createContainer();
      final controller = container.read(cartControllerProvider.notifier);
      await container.read(cartControllerProvider.future);
      await controller.addLine(_line());
      await controller.applyPromo('epic10');
      final state = await _currentState(container);

      expect(state.promo?.code, 'EPIC10');
      expect(state.discountCents, 1290);
      expect(state.totalCents, 11610);
    });

    test('removePromo clears the discount', () async {
      final container = createContainer();
      final controller = container.read(cartControllerProvider.notifier);
      await container.read(cartControllerProvider.future);
      await controller.addLine(_line());
      await controller.applyPromo('EPIC10');
      await controller.removePromo();
      final state = await _currentState(container);

      expect(state.promo, isNull);
      expect(state.discountCents, 0);
    });

    test('rejects an unsupported promo code', () async {
      final container = createContainer();
      final controller = container.read(cartControllerProvider.notifier);
      await container.read(cartControllerProvider.future);
      await controller.addLine(_line());
      await expectLater(
        controller.applyPromo('NOT_A_CODE'),
        throwsA(isA<PromoFailure>()),
      );
      final state = await _currentState(container);
      expect(state.promo, isNull);
    });
  });
}
