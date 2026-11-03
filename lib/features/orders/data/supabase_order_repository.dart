import 'package:supabase_flutter/supabase_flutter.dart';

import '../../profile/domain/address.dart';
import '../domain/app_notification.dart';
import '../domain/order.dart';
import '../domain/order_request.dart';
import 'order_repository.dart';

class SupabaseOrderRepository implements OrderRepository {
  SupabaseOrderRepository(this._client);

  final SupabaseClient _client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const OrderException('Sign in to view your orders.');
    }
    return user.id;
  }

  @override
  Future<List<Order>> getOrders() async {
    try {
      final rows = await _client
          .from('orders')
          .select('*, order_items(*), order_status_events(*)')
          .eq('user_id', _userId)
          .order('created_at', ascending: false);
      return [for (final row in rows) _mapOrder(row)];
    } on PostgrestException catch (error) {
      throw OrderException(error.message);
    }
  }

  @override
  Future<Order> getOrder(String id) async {
    try {
      final row = await _client
          .from('orders')
          .select('*, order_items(*), order_status_events(*)')
          .eq('user_id', _userId)
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        throw const OrderException('That order could not be found.');
      }
      return _mapOrder(row);
    } on PostgrestException catch (error) {
      throw OrderException(error.message);
    }
  }

  @override
  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      final result = await _client.rpc<dynamic>(
        'create_order',
        params: {
          'p_items': [
            for (final line in request.lines)
              {
                'product_id': line.productId,
                'variant_id': line.variantId,
                'quantity': line.quantity,
              },
          ],
          'p_address': _addressJson(request.address),
          'p_payment_method': request.paymentMethod,
          'p_contact_email': request.contactEmail,
          'p_promo_code': request.promoCode,
        },
      );
      final orderId = result is String
          ? result
          : (result is Map<String, dynamic> ? result['id'] as String? : null);
      if (orderId == null) {
        throw const OrderException(
          'The order was created without an identifier.',
        );
      }
      return await getOrder(orderId);
    } on PostgrestException catch (error) {
      throw OrderException(error.message);
    }
  }

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      final rows = await _client
          .from('notifications')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);
      return [for (final row in rows) _mapNotification(row)];
    } on PostgrestException catch (error) {
      throw OrderException(error.message);
    }
  }

  @override
  Future<void> markAllNotificationsRead() async {
    try {
      await _client
          .from('notifications')
          .update({'read': true})
          .eq('user_id', _userId)
          .eq('read', false);
    } on PostgrestException catch (error) {
      throw OrderException(error.message);
    }
  }

  Order _mapOrder(Map<String, dynamic> row) {
    final rawAddress =
        (row['shipping_address'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final itemRows = (row['order_items'] as List<dynamic>? ?? const []);
    final eventRows =
        (row['order_status_events'] as List<dynamic>? ?? const []);
    final placedAt =
        DateTime.tryParse((row['created_at'] as String?) ?? '') ??
        DateTime.now();

    final events = <OrderEvent>[
      for (final item in eventRows)
        OrderEvent(
          status: OrderStatus.fromString(
            (item as Map<String, dynamic>)['status'] as String?,
          ),
          title: (item['title'] as String?) ?? '',
          description: (item['description'] as String?) ?? '',
          occurredAt:
              DateTime.tryParse((item['created_at'] as String?) ?? '') ??
              placedAt,
        ),
    ]..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    return Order(
      id: row['id'] as String,
      orderNumber: (row['order_number'] as String?) ?? '',
      placedAt: placedAt,
      status: OrderStatus.fromString(row['status'] as String?),
      items: [
        for (final item in itemRows)
          OrderItem(
            productId:
                ((item as Map<String, dynamic>)['product_id'] as String?) ?? '',
            variantId: (item['variant_id'] as String?) ?? '',
            productName: (item['product_name'] as String?) ?? 'Product',
            variantName: (item['variant_name'] as String?) ?? '',
            image: (item['image_url'] as String?) ?? '',
            unitPriceCents: (item['unit_price_cents'] as int?) ?? 0,
            quantity: (item['quantity'] as int?) ?? 1,
          ),
      ],
      subtotalCents: (row['subtotal_cents'] as int?) ?? 0,
      deliveryCents: (row['delivery_cents'] as int?) ?? 0,
      discountCents: (row['discount_cents'] as int?) ?? 0,
      totalCents: (row['total_cents'] as int?) ?? 0,
      address: Address(
        id: (rawAddress['id'] as String?) ?? 'checkout',
        fullName:
            (rawAddress['full_name'] ?? rawAddress['fullName'] ?? '') as String,
        line1: (rawAddress['line1'] as String?) ?? '',
        line2: rawAddress['line2'] as String?,
        city: (rawAddress['city'] as String?) ?? '',
        state: (rawAddress['state'] as String?) ?? '',
        postalCode:
            (rawAddress['postal_code'] ?? rawAddress['postalCode'] ?? '')
                as String,
        country: (rawAddress['country'] as String?) ?? 'Philippines',
        phone: (rawAddress['phone'] as String?) ?? '',
      ),
      paymentMethod: (row['payment_method'] as String?) ?? 'Card',
      contactEmail: (row['contact_email'] as String?) ?? '',
      events: events,
    );
  }

  AppNotification _mapNotification(Map<String, dynamic> row) {
    return AppNotification(
      id: row['id'] as String,
      title: (row['title'] as String?) ?? '',
      body: (row['body'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.now(),
      type: AppNotificationType.values.firstWhere(
        (type) => type.name == row['type'],
        orElse: () => AppNotificationType.account,
      ),
      read: (row['read'] as bool?) ?? false,
      orderId: row['order_id'] as String?,
    );
  }

  Map<String, dynamic> _addressJson(Address address) => {
    'id': address.id,
    'full_name': address.fullName,
    'line1': address.line1,
    'line2': address.line2,
    'city': address.city,
    'state': address.state,
    'postal_code': address.postalCode,
    'country': address.country,
    'phone': address.phone,
  };
}
