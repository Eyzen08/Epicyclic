import 'package:flutter/foundation.dart';

import '../../profile/domain/address.dart';

enum OrderStatus {
  placed,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get shortLabel {
    switch (this) {
      case OrderStatus.outForDelivery:
        return 'Out for delivery';
      default:
        return label;
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.processing:
        return 2;
      case OrderStatus.shipped:
        return 3;
      case OrderStatus.outForDelivery:
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  bool get isDelivered => this == OrderStatus.delivered;
  bool get isProcessing =>
      this == OrderStatus.placed ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.processing;

  static OrderStatus fromString(String? value) {
    switch (value) {
      case 'placed':
        return OrderStatus.placed;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'processing':
      default:
        return OrderStatus.processing;
    }
  }

  String get wireValue {
    switch (this) {
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      default:
        return name;
    }
  }
}

@immutable
class OrderEvent {
  const OrderEvent({
    required this.status,
    required this.title,
    required this.description,
    required this.occurredAt,
  });

  final OrderStatus status;
  final String title;
  final String description;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'status': status.wireValue,
    'title': title,
    'description': description,
    'occurredAt': occurredAt.toIso8601String(),
  };

  factory OrderEvent.fromJson(Map<String, dynamic> json) {
    return OrderEvent(
      status: OrderStatus.fromString(json['status'] as String?),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      occurredAt:
          DateTime.tryParse((json['occurredAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

@immutable
class OrderItem {
  const OrderItem({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.image,
    required this.unitPriceCents,
    required this.quantity,
  });

  final String productId;
  final String variantId;
  final String productName;
  final String variantName;
  final String image;
  final int unitPriceCents;
  final int quantity;

  int get lineTotalCents => unitPriceCents * quantity;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'productId': productId,
    'variantId': variantId,
    'productName': productName,
    'variantName': variantName,
    'image': image,
    'unitPriceCents': unitPriceCents,
    'quantity': quantity,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['productId'] as String?) ?? '',
      variantId: (json['variantId'] as String?) ?? '',
      productName: (json['productName'] as String?) ?? 'Product',
      variantName: (json['variantName'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      unitPriceCents: (json['unitPriceCents'] as int?) ?? 0,
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }
}

@immutable
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.placedAt,
    required this.status,
    required this.items,
    required this.subtotalCents,
    required this.deliveryCents,
    required this.discountCents,
    required this.totalCents,
    required this.address,
    required this.paymentMethod,
    required this.contactEmail,
    required this.events,
  });

  final String id;
  final String orderNumber;
  final DateTime placedAt;
  final OrderStatus status;
  final List<OrderItem> items;
  final int subtotalCents;
  final int deliveryCents;
  final int discountCents;
  final int totalCents;
  final Address address;
  final String paymentMethod;
  final String contactEmail;
  final List<OrderEvent> events;

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'orderNumber': orderNumber,
    'placedAt': placedAt.toIso8601String(),
    'status': status.wireValue,
    'items': items.map((item) => item.toJson()).toList(),
    'subtotalCents': subtotalCents,
    'deliveryCents': deliveryCents,
    'discountCents': discountCents,
    'totalCents': totalCents,
    'address': address.toJson(),
    'paymentMethod': paymentMethod,
    'contactEmail': contactEmail,
    'events': events.map((event) => event.toJson()).toList(),
  };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: (json['orderNumber'] as String?) ?? '',
      placedAt:
          DateTime.tryParse((json['placedAt'] as String?) ?? '') ??
          DateTime.now(),
      status: OrderStatus.fromString(json['status'] as String?),
      items: [
        for (final item in (json['items'] as List<dynamic>? ?? const []))
          OrderItem.fromJson(item as Map<String, dynamic>),
      ],
      subtotalCents: (json['subtotalCents'] as int?) ?? 0,
      deliveryCents: (json['deliveryCents'] as int?) ?? 0,
      discountCents: (json['discountCents'] as int?) ?? 0,
      totalCents: (json['totalCents'] as int?) ?? 0,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      paymentMethod: (json['paymentMethod'] as String?) ?? 'Card',
      contactEmail: (json['contactEmail'] as String?) ?? '',
      events: [
        for (final event in (json['events'] as List<dynamic>? ?? const []))
          OrderEvent.fromJson(event as Map<String, dynamic>),
      ],
    );
  }
}
