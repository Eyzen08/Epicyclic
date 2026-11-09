import 'package:epicyclic/core/storage/local_store.dart';
import 'package:epicyclic/features/cart/domain/cart_models.dart';
import 'package:epicyclic/features/catalog/data/demo_catalog_repository.dart';
import 'package:epicyclic/features/orders/data/demo_order_repository.dart';
import 'package:epicyclic/features/orders/domain/order.dart';
import 'package:epicyclic/features/orders/domain/order_request.dart';
import 'package:epicyclic/features/profile/domain/address.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const address = Address(
  id: 'addr-test',
  fullName: 'Alex Morgan',
  line1: 'Unit 12, 123 Sample Street',
  line2: 'Barangay San Lorenzo',
  city: 'Makati City',
  state: 'Metro Manila',
  postalCode: '1223',
  country: 'Philippines',
  phone: '+63 917 555 0147',
  isDefault: true,
);

CartLine line({
  String productId = 'aula-f75',
  String variantId = 'black-gradient-grey',
  int quantity = 1,
}) {
  return CartLine(
    productId: productId,
    variantId: variantId,
    productName: 'untrusted client name',
    variantName: 'untrusted client variant',
    tagline: '',
    image: '',
    unitPriceCents: 1,
    quantity: quantity,
  );
}

CreateOrderRequest request({List<CartLine>? lines, String? promoCode}) {
  return CreateOrderRequest(
    lines: lines ?? [line()],
    address: address,
    paymentMethod: 'GCash',
    contactEmail: 'christian.tester@epicyclic.demo',
    promoCode: promoCode,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DemoOrderRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore(await SharedPreferences.getInstance());
    repository = DemoOrderRepository(store, DemoCatalogRepository());
  });

  group('DemoOrderRepository read paths', () {
    test('seeds two example orders on first load', () async {
      final orders = await repository.getOrders();

      expect(orders, hasLength(2));
      expect(orders.map((order) => order.orderNumber), contains('EP-20481'));
      expect(orders.map((order) => order.orderNumber), contains('EP-20396'));
    });

    test('returns an order by id and throws for unknown ids', () async {
      final order = await repository.getOrder('demo-order-20481');

      expect(order.status, OrderStatus.processing);
      expect(order.items.single.productName, 'AULA F75');

      await expectLater(
        repository.getOrder('missing'),
        throwsA(isA<OrderException>()),
      );
    });

    test('seeds notifications with an unread order update', () async {
      final notifications = await repository.getNotifications();

      expect(notifications, isNotEmpty);
      expect(notifications.any((item) => !item.read), isTrue);
      expect(notifications.first.type.name, 'order');
    });

    test('markAllNotificationsRead marks every notification read', () async {
      await repository.markAllNotificationsRead();

      final notifications = await repository.getNotifications();
      expect(notifications.every((item) => item.read), isTrue);
    });
  });

  group('DemoOrderRepository.createOrder', () {
    test('prices the order from the trusted catalog, not the cart', () async {
      final order = await repository.createOrder(request());

      expect(order.items.single.productName, 'AULA F75');
      expect(order.items.single.variantName, 'Black / Gradient Grey');
      expect(order.items.single.unitPriceCents, 259500);
      expect(order.subtotalCents, 259500);
      expect(order.totalCents, 259500);
      expect(order.status, OrderStatus.processing);
      expect(order.events, hasLength(3));
      expect(order.address.city, 'Makati City');
    });

    test('applies a valid promo code to the server-side total', () async {
      final order = await repository.createOrder(
        request(lines: [line(quantity: 2)], promoCode: ' epic10 '),
      );

      expect(order.subtotalCents, 519000);
      expect(order.discountCents, 51900);
      expect(order.totalCents, 467100);
    });

    test('rejects unknown promo codes', () async {
      await expectLater(
        repository.createOrder(request(promoCode: 'FREESTUFF')),
        throwsA(isA<OrderException>()),
      );
    });

    test('rejects empty carts', () async {
      await expectLater(
        repository.createOrder(request(lines: const [])),
        throwsA(isA<OrderException>()),
      );
    });

    test('rejects quantities above available stock', () async {
      await expectLater(
        repository.createOrder(request(lines: [line(quantity: 99)])),
        throwsA(isA<OrderException>()),
      );
    });

    test('rejects unknown products and variants', () async {
      await expectLater(
        repository.createOrder(
          request(lines: [line(productId: 'not-a-product')]),
        ),
        throwsA(isA<OrderException>()),
      );
      await expectLater(
        repository.createOrder(
          request(lines: [line(variantId: 'not-a-variant')]),
        ),
        throwsA(isA<OrderException>()),
      );
    });

    test('persists the new order and a matching notification', () async {
      final created = await repository.createOrder(request());

      final orders = await repository.getOrders();
      expect(orders.first.id, created.id);
      expect(orders, hasLength(3));

      final notifications = await repository.getNotifications();
      expect(notifications.first.orderId, created.id);
      expect(notifications.first.body, contains(created.orderNumber));
    });

    test('assigns sequential, unique order numbers', () async {
      final first = await repository.createOrder(request());
      final second = await repository.createOrder(request());

      expect(first.orderNumber, 'EP-20482');
      expect(second.orderNumber, 'EP-20483');
      expect(first.id, isNot(second.id));
    });
  });
}
