import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';
import '../domain/cart_models.dart';

class PromoFailure implements Exception {
  const PromoFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class CartController extends AsyncNotifier<CartState> {
  @override
  Future<CartState> build() async {
    final raw = ref.read(localStoreProvider).cartJson;
    if (raw == null) return const CartState();
    try {
      return CartState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const CartState();
    }
  }

  Future<void> _persist(CartState next) async {
    state = AsyncData(next);
    await ref.read(localStoreProvider).setCartJson(jsonEncode(next.toJson()));
  }

  CartState get _current => state.value ?? const CartState();

  Future<void> addLine(CartLine line) async {
    final current = _current;
    final index = current.lines.indexWhere(
      (existing) =>
          existing.productId == line.productId &&
          existing.variantId == line.variantId,
    );
    final lines = [...current.lines];
    if (index >= 0) {
      final merged = lines[index].copyWith(
        quantity: (lines[index].quantity + line.quantity).clamp(1, 20),
        unitPriceCents: line.unitPriceCents,
      );
      lines[index] = merged;
    } else {
      lines.add(line);
    }
    await _persist(current.copyWith(lines: lines));
  }

  Future<void> setQuantity(
    String productId,
    String variantId,
    int quantity,
  ) async {
    if (quantity < 1) return;
    final current = _current;
    final lines = [
      for (final line in current.lines)
        if (line.productId == productId && line.variantId == variantId)
          line.copyWith(quantity: quantity.clamp(1, 20))
        else
          line,
    ];
    await _persist(current.copyWith(lines: lines));
  }

  Future<void> removeLine(String productId, String variantId) async {
    final current = _current;
    final lines = current.lines
        .where(
          (line) =>
              !(line.productId == productId && line.variantId == variantId),
        )
        .toList();
    await _persist(current.copyWith(lines: lines));
  }

  Future<void> clear() async {
    await _persist(const CartState());
  }

  Future<void> applyPromo(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw const PromoFailure('Enter a promo code.');
    }
    if (normalized != demoPromo.code) {
      throw const PromoFailure('That promo code is not valid.');
    }
    await _persist(_current.copyWith(promo: demoPromo));
  }

  Future<void> removePromo() async {
    await _persist(_current.copyWith(clearPromo: true));
  }
}

final cartControllerProvider = AsyncNotifierProvider<CartController, CartState>(
  CartController.new,
);

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartControllerProvider).value?.itemCount ?? 0;
});
