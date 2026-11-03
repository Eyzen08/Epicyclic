import '../domain/app_notification.dart';
import '../domain/order.dart';
import '../domain/order_request.dart';

abstract interface class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order> getOrder(String id);
  Future<Order> createOrder(CreateOrderRequest request);

  Future<List<AppNotification>> getNotifications();
  Future<void> markAllNotificationsRead();
}
