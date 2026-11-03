import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/local_store.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/demo_auth_repository.dart';
import '../../features/auth/data/supabase_auth_repository.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/catalog/data/catalog_repository.dart';
import '../../features/catalog/data/demo_catalog_repository.dart';
import '../../features/catalog/data/supabase_catalog_repository.dart';
import '../../features/catalog/domain/catalog_data.dart';
import '../../features/orders/data/demo_order_repository.dart';
import '../../features/orders/data/order_repository.dart';
import '../../features/orders/data/supabase_order_repository.dart';
import '../../features/orders/domain/app_notification.dart';
import '../../features/orders/domain/order.dart';
import '../../features/profile/data/demo_profile_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/data/supabase_profile_repository.dart';
import '../../features/profile/domain/address.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider must be overridden.'),
);

final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('localStoreProvider must be overridden.'),
);

/// Null in demo mode. Overridden in main only when Supabase is configured.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.isDemo) {
    return DemoAuthRepository(ref.watch(localStoreProvider));
  }
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase mode selected without an initialized client.');
  }
  return SupabaseAuthRepository(client);
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).value;
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.isDemo) return DemoCatalogRepository();
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase mode selected without an initialized client.');
  }
  return SupabaseCatalogRepository(client);
});

final catalogProvider = FutureProvider<CatalogData>((ref) {
  return ref.watch(catalogRepositoryProvider).loadCatalog();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.isDemo) {
    return DemoProfileRepository(
      ref.watch(localStoreProvider),
      ref.watch(authRepositoryProvider),
    );
  }
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase mode selected without an initialized client.');
  }
  return SupabaseProfileRepository(client, ref.watch(authRepositoryProvider));
});

final profileProvider = FutureProvider<AppUser?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(profileRepositoryProvider).getProfile();
});

final addressesProvider = FutureProvider<List<Address>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(profileRepositoryProvider).getAddresses();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.isDemo) {
    return DemoOrderRepository(
      ref.watch(localStoreProvider),
      ref.watch(catalogRepositoryProvider),
    );
  }
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase mode selected without an initialized client.');
  }
  return SupabaseOrderRepository(client);
});

final ordersProvider = FutureProvider<List<Order>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(orderRepositoryProvider).getOrders();
});

final orderByIdProvider = FutureProvider.family<Order, String>((ref, id) {
  ref.watch(authStateProvider);
  return ref.watch(orderRepositoryProvider).getOrder(id);
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(orderRepositoryProvider).getNotifications();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? const [];
  return notifications.where((notification) => !notification.read).length;
});
