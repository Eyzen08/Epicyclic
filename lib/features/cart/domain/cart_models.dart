import 'package:flutter/foundation.dart';

@immutable
class CartLine {
  const CartLine({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.tagline,
    required this.image,
    required this.unitPriceCents,
    required this.quantity,
  });

  final String productId;
  final String variantId;
  final String productName;
  final String variantName;
  final String tagline;
  final String image;
  final int unitPriceCents;
  final int quantity;

  int get lineTotalCents => unitPriceCents * quantity;

  CartLine copyWith({int? quantity, int? unitPriceCents}) {
    return CartLine(
      productId: productId,
      variantId: variantId,
      productName: productName,
      variantName: variantName,
      tagline: tagline,
      image: image,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'productId': productId,
    'variantId': variantId,
    'productName': productName,
    'variantName': variantName,
    'tagline': tagline,
    'image': image,
    'unitPriceCents': unitPriceCents,
    'quantity': quantity,
  };

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      productId: json['productId'] as String,
      variantId: json['variantId'] as String,
      productName: json['productName'] as String,
      variantName: (json['variantName'] as String?) ?? '',
      tagline: (json['tagline'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      unitPriceCents: (json['unitPriceCents'] as int?) ?? 0,
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }
}

@immutable
class Promo {
  const Promo({required this.code, required this.percentOff});

  final String code;
  final int percentOff;

  int discountFor(int subtotalCents) =>
      (subtotalCents * percentOff / 100).round();
}

/// Demo-only promo. Real checkout validation lives in the Supabase RPC.
const demoPromo = Promo(code: 'EPIC10', percentOff: 10);

@immutable
class CartState {
  const CartState({this.lines = const [], this.promo});

  final List<CartLine> lines;
  final Promo? promo;

  bool get isEmpty => lines.isEmpty;
  int get itemCount => lines.fold(0, (total, line) => total + line.quantity);

  int get subtotalCents =>
      lines.fold(0, (total, line) => total + line.lineTotalCents);

  int get discountCents => promo?.discountFor(subtotalCents) ?? 0;

  int get deliveryCents => 0;

  int get totalCents => subtotalCents - discountCents + deliveryCents;

  CartState copyWith({
    List<CartLine>? lines,
    Promo? promo,
    bool clearPromo = false,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      promo: clearPromo ? null : (promo ?? this.promo),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'lines': lines.map((line) => line.toJson()).toList(),
    'promo': promo == null
        ? null
        : {'code': promo!.code, 'percentOff': promo!.percentOff},
  };

  factory CartState.fromJson(Map<String, dynamic> json) {
    final promoJson = json['promo'];
    return CartState(
      lines: [
        for (final line in (json['lines'] as List<dynamic>? ?? const []))
          CartLine.fromJson(line as Map<String, dynamic>),
      ],
      promo: promoJson is Map<String, dynamic>
          ? Promo(
              code: promoJson['code'] as String,
              percentOff: (promoJson['percentOff'] as int?) ?? 0,
            )
          : null,
    );
  }
}
