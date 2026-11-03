import 'package:flutter/foundation.dart';

import '../../cart/domain/cart_models.dart';
import '../../profile/domain/address.dart';

@immutable
class OrderLineRequest {
  const OrderLineRequest({
    required this.productId,
    required this.variantId,
    required this.quantity,
  });

  final String productId;
  final String variantId;
  final int quantity;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'product_id': productId,
    'variant_id': variantId,
    'quantity': quantity,
  };
}

@immutable
class CreateOrderRequest {
  const CreateOrderRequest({
    required this.lines,
    required this.address,
    required this.paymentMethod,
    required this.contactEmail,
    this.promoCode,
  });

  final List<CartLine> lines;
  final Address address;
  final String paymentMethod;
  final String contactEmail;
  final String? promoCode;
}

class OrderException implements Exception {
  const OrderException(this.message);

  final String message;

  @override
  String toString() => message;
}
