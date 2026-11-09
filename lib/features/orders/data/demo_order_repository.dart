import 'dart:convert';

import '../../../core/storage/local_store.dart';
import '../../cart/domain/cart_models.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/domain/catalog_data.dart';
import '../../profile/domain/address.dart';
import '../domain/app_notification.dart';
import '../domain/order.dart';
import '../domain/order_request.dart';
import 'order_repository.dart';

class DemoOrderRepository implements OrderRepository {
  DemoOrderRepository(this._store, this._catalog);

  final LocalStore _store;
  final CatalogRepository _catalog;

  @override
  Future<List<Order>> getOrders() async {
    final orders = await _loadOrders();
    orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return orders;
  }

  @override
  Future<Order> getOrder(String id) async {
    final orders = await _loadOrders();
    for (final order in orders) {
      if (order.id == id) return order;
    }
    throw const OrderException('That order could not be found.');
  }

  @override
  Future<Order> createOrder(CreateOrderRequest request) async {
    if (request.lines.isEmpty) {
      throw const OrderException('Your cart is empty.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final catalog = await _catalog.loadCatalog();
    final now = DateTime.now();
    final items = <OrderItem>[];
    var subtotal = 0;

    for (final line in request.lines) {
      if (line.quantity <= 0) {
        throw const OrderException('Item quantities must be at least one.');
      }
      final resolved = _resolveLine(catalog, line);
      subtotal += resolved.unitPriceCents * line.quantity;
      items.add(
        OrderItem(
          productId: resolved.productId,
          variantId: resolved.variantId,
          productName: resolved.productName,
          variantName: resolved.variantName,
          image: resolved.image,
          unitPriceCents: resolved.unitPriceCents,
          quantity: line.quantity,
        ),
      );
    }

    var discount = 0;
    if (request.promoCode != null && request.promoCode!.trim().isNotEmpty) {
      if (request.promoCode!.trim().toUpperCase() != demoPromo.code) {
        throw const OrderException('That promo code is not valid.');
      }
      discount = demoPromo.discountFor(subtotal);
    }

    final sequence = _store.demoOrderSequence;
    await _store.setDemoOrderSequence(sequence + 1);
    final orders = await _loadOrders();
    final id = 'demo-order-$sequence';
    final order = Order(
      id: id,
      orderNumber: 'EP-$sequence',
      placedAt: now,
      status: OrderStatus.processing,
      items: items,
      subtotalCents: subtotal,
      deliveryCents: 0,
      discountCents: discount,
      totalCents: subtotal - discount,
      address: request.address,
      paymentMethod: request.paymentMethod,
      contactEmail: request.contactEmail,
      events: [
        OrderEvent(
          status: OrderStatus.placed,
          title: 'Order Placed',
          description: 'We received your order.',
          occurredAt: now.subtract(const Duration(minutes: 4)),
        ),
        OrderEvent(
          status: OrderStatus.confirmed,
          title: 'Confirmed',
          description: 'Your order was confirmed.',
          occurredAt: now.subtract(const Duration(minutes: 2)),
        ),
        OrderEvent(
          status: OrderStatus.processing,
          title: 'Processing',
          description: "We're preparing your order.",
          occurredAt: now,
        ),
      ],
    );
    orders.insert(0, order);
    await _saveOrders(orders);

    final notifications = await _loadNotifications();
    notifications.insert(
      0,
      AppNotification(
        id: 'notif-${now.millisecondsSinceEpoch}',
        title: 'Order Confirmed',
        body: 'Order #${order.orderNumber} is being prepared.',
        createdAt: now,
        type: AppNotificationType.order,
        orderId: order.id,
      ),
    );
    await _saveNotifications(notifications);
    return order;
  }

  CartLine _resolveLine(CatalogData catalog, CartLine line) {
    final product = catalog.byId(line.productId);
    if (product == null || !product.isActive) {
      throw const OrderException(
        'One of the products in your cart is no longer available.',
      );
    }
    final variant = product.variantById(line.variantId);
    if (variant == null) {
      throw OrderException(
        '${product.name} is no longer available in that option.',
      );
    }
    if (variant.stock < line.quantity) {
      throw OrderException(
        '${product.name} (${variant.name}) only has ${variant.stock} left.',
      );
    }
    return CartLine(
      productId: product.id,
      variantId: variant.id,
      productName: product.name,
      variantName: variant.name,
      tagline: product.tagline,
      image: product.primaryImage,
      unitPriceCents: variant.priceCents,
      quantity: line.quantity,
    );
  }

  @override
  Future<List<AppNotification>> getNotifications() async {
    final notifications = await _loadNotifications();
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  @override
  Future<void> markAllNotificationsRead() async {
    final notifications = await _loadNotifications();
    await _saveNotifications([
      for (final notification in notifications)
        notification.copyWith(read: true),
    ]);
  }

  Future<List<Order>> _loadOrders() async {
    final raw = _store.demoOrdersJson;
    if (raw == null) {
      final seeded = _seedOrders();
      await _saveOrders(seeded);
      return seeded;
    }
    try {
      return [
        for (final item in jsonDecode(raw) as List<dynamic>)
          Order.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      final seeded = _seedOrders();
      await _saveOrders(seeded);
      return seeded;
    }
  }

  Future<void> _saveOrders(List<Order> orders) {
    return _store.setDemoOrdersJson(
      jsonEncode(orders.map((order) => order.toJson()).toList()),
    );
  }

  Future<List<AppNotification>> _loadNotifications() async {
    final raw = _store.demoNotificationsJson;
    if (raw == null) {
      final now = DateTime.now();
      final seeded = <AppNotification>[
        AppNotification(
          id: 'notif-order-confirmed',
          title: 'Order Confirmed',
          body: 'Order #EP-20481 is being prepared.',
          createdAt: now.subtract(const Duration(hours: 2)),
          type: AppNotificationType.order,
          orderId: 'demo-order-20481',
        ),
        AppNotification(
          id: 'notif-welcome',
          title: 'Welcome to Epicyclic',
          body: 'Discover gear picked for your setup.',
          createdAt: now.subtract(const Duration(days: 1)),
          type: AppNotificationType.welcome,
          read: true,
        ),
      ];
      await _saveNotifications(seeded);
      return seeded;
    }
    try {
      return [
        for (final item in jsonDecode(raw) as List<dynamic>)
          AppNotification.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveNotifications(List<AppNotification> notifications) {
    return _store.setDemoNotificationsJson(
      jsonEncode(
        notifications.map((notification) => notification.toJson()).toList(),
      ),
    );
  }

  List<Order> _seedOrders() {
    final now = DateTime.now();
    final address = Address(
      id: 'addr-seed',
      fullName: 'Christian Demo',
      line1: 'Unit 12, 123 Sample Street',
      line2: 'Barangay San Lorenzo',
      city: 'Makati City',
      state: 'Metro Manila',
      postalCode: '1223',
      country: 'Philippines',
      phone: '+63 917 555 0147',
      isDefault: true,
    );
    final firstPlaced = now.subtract(const Duration(days: 5, hours: 2));
    final secondPlaced = now.subtract(const Duration(days: 11, hours: 4));

    return <Order>[
      Order(
        id: 'demo-order-20481',
        orderNumber: 'EP-20481',
        placedAt: firstPlaced,
        status: OrderStatus.processing,
        items: [
          OrderItem(
            productId: 'aula-f75',
            variantId: 'black-gradient-grey',
            productName: 'AULA F75',
            variantName: 'Black / Gradient Grey',
            image: 'assets/images/products/aula-f75.jpg',
            unitPriceCents: 259500,
            quantity: 1,
          ),
        ],
        subtotalCents: 259500,
        deliveryCents: 0,
        discountCents: 0,
        totalCents: 259500,
        address: address,
        paymentMethod: 'GCash',
        contactEmail: 'christian.tester@epicyclic.demo',
        events: [
          OrderEvent(
            status: OrderStatus.placed,
            title: 'Order Placed',
            description: 'Order received.',
            occurredAt: firstPlaced,
          ),
          OrderEvent(
            status: OrderStatus.confirmed,
            title: 'Confirmed',
            description: 'Payment method accepted.',
            occurredAt: firstPlaced.add(const Duration(minutes: 48)),
          ),
          OrderEvent(
            status: OrderStatus.processing,
            title: 'Processing',
            description: "We're preparing your order.",
            occurredAt: firstPlaced.add(const Duration(hours: 3)),
          ),
        ],
      ),
      Order(
        id: 'demo-order-20396',
        orderNumber: 'EP-20396',
        placedAt: secondPlaced,
        status: OrderStatus.delivered,
        items: [
          OrderItem(
            productId: 'logitech-g102',
            variantId: 'black',
            productName: 'Logitech G102 LIGHTSYNC',
            variantName: 'Black',
            image: 'assets/images/products/logitech-g102.jpg',
            unitPriceCents: 94100,
            quantity: 1,
          ),
        ],
        subtotalCents: 94100,
        deliveryCents: 0,
        discountCents: 0,
        totalCents: 94100,
        address: address,
        paymentMethod: 'Cash On Delivery',
        contactEmail: 'christian.tester@epicyclic.demo',
        events: [
          OrderEvent(
            status: OrderStatus.placed,
            title: 'Order Placed',
            description: 'Order received.',
            occurredAt: secondPlaced,
          ),
          OrderEvent(
            status: OrderStatus.confirmed,
            title: 'Confirmed',
            description: 'Payment method accepted.',
            occurredAt: secondPlaced.add(const Duration(hours: 1)),
          ),
          OrderEvent(
            status: OrderStatus.processing,
            title: 'Processing',
            description: 'Order prepared for dispatch.',
            occurredAt: secondPlaced.add(const Duration(hours: 6)),
          ),
          OrderEvent(
            status: OrderStatus.shipped,
            title: 'Shipped',
            description: 'Handed to the carrier.',
            occurredAt: secondPlaced.add(const Duration(days: 1)),
          ),
          OrderEvent(
            status: OrderStatus.delivered,
            title: 'Delivered',
            description: 'Delivered to the front desk.',
            occurredAt: secondPlaced.add(const Duration(days: 3)),
          ),
        ],
      ),
    ];
  }
}
