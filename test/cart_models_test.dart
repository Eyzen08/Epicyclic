import 'package:epicyclic/features/cart/domain/cart_models.dart';
import 'package:flutter_test/flutter_test.dart';

CartLine line({
  String productId = 'product-1',
  String variantId = 'variant-1',
  int unitPriceCents = 12900,
  int quantity = 1,
}) {
  return CartLine(
    productId: productId,
    variantId: variantId,
    productName: 'Test Product',
    variantName: 'Graphite',
    tagline: 'Test tagline',
    image: 'assets/images/products/keyboard_white.png',
    unitPriceCents: unitPriceCents,
    quantity: quantity,
  );
}

void main() {
  group('CartLine', () {
    test('computes the line total from unit price and quantity', () {
      expect(line(unitPriceCents: 7900, quantity: 3).lineTotalCents, 23700);
    });

    test('round trips through JSON', () {
      final original = line(quantity: 2);
      final restored = CartLine.fromJson(original.toJson());

      expect(restored.productId, original.productId);
      expect(restored.variantId, original.variantId);
      expect(restored.variantName, original.variantName);
      expect(restored.unitPriceCents, original.unitPriceCents);
      expect(restored.quantity, original.quantity);
    });
  });

  group('CartState', () {
    test('is empty by default', () {
      const state = CartState();

      expect(state.isEmpty, isTrue);
      expect(state.itemCount, 0);
      expect(state.subtotalCents, 0);
      expect(state.totalCents, 0);
    });

    test('sums quantities and line totals across variants', () {
      final state = CartState(
        lines: [
          line(unitPriceCents: 12900, quantity: 2),
          line(
            productId: 'product-2',
            variantId: 'variant-2',
            unitPriceCents: 5900,
            quantity: 1,
          ),
        ],
      );

      expect(state.itemCount, 3);
      expect(state.subtotalCents, 31700);
      expect(state.totalCents, 31700);
    });

    test('applies the demo promo to the subtotal', () {
      final state = CartState(
        lines: [line(unitPriceCents: 12900, quantity: 2)],
        promo: demoPromo,
      );

      expect(state.subtotalCents, 25800);
      expect(state.discountCents, 2580);
      expect(state.totalCents, 23220);
    });

    test('rounds percentage discounts to the nearest cent', () {
      expect(demoPromo.discountFor(1999), 200);
      expect(demoPromo.discountFor(1), 0);
    });

    test('copyWith can clear a promo without clearing lines', () {
      final state = CartState(lines: [line()], promo: demoPromo);

      final cleared = state.copyWith(clearPromo: true);

      expect(cleared.lines, hasLength(1));
      expect(cleared.promo, isNull);
      expect(cleared.discountCents, 0);
    });

    test('round trips lines and promo through JSON', () {
      final original = CartState(
        lines: [
          line(quantity: 2),
          line(productId: 'product-2'),
        ],
        promo: demoPromo,
      );

      final restored = CartState.fromJson(original.toJson());

      expect(restored.lines, hasLength(2));
      expect(restored.lines.first.quantity, 2);
      expect(restored.promo?.code, demoPromo.code);
      expect(restored.totalCents, original.totalCents);
    });
  });
}
