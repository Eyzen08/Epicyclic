import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/bottom_bar.dart';
import '../../../shared/widgets/epicyclic_logo.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../../orders/domain/order.dart';

enum _OrderFilter { all, processing, delivered }

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  _OrderFilter _filter = _OrderFilter.all;

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);
    final user = ref.watch(currentUserProvider);
    final isDemo = ref.watch(appConfigProvider).isDemo;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: user == null
            ? EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Sign In To See Orders',
                message:
                    'Your order history and tracking live with your account.',
                actionLabel: 'Sign In',
                onAction: () => context.push('/login?next=/orders'),
              )
            : orders.when(
                loading: () => const AppLoading(label: 'Loading your orders'),
                error: (error, stackTrace) => AppErrorState(
                  message: 'We could not load your orders.',
                  onRetry: () => ref.invalidate(ordersProvider),
                ),
                data: (allOrders) {
                  final filtered = allOrders.where((order) {
                    switch (_filter) {
                      case _OrderFilter.all:
                        return true;
                      case _OrderFilter.processing:
                        return order.status.isProcessing;
                      case _OrderFilter.delivered:
                        return order.status.isDelivered;
                    }
                  }).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => context.canPop()
                                      ? context.pop()
                                      : context.go('/home'),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                    width: 36,
                                    height: 44,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const EpicyclicLogo(markSize: 28, textSize: 23),
                                const Spacer(),
                                if (isDemo) const DemoModeChip(compact: true),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'My orders',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 18),
                            _Filters(
                              filter: _filter,
                              onChanged: (value) =>
                                  setState(() => _filter = value),
                            ),
                            const SizedBox(height: 18),
                            if (filtered.isEmpty)
                              EmptyState(
                                icon: Icons.receipt_long_outlined,
                                title: _filter == _OrderFilter.all
                                    ? 'No orders yet'
                                    : 'Nothing in this view',
                                message: _filter == _OrderFilter.all
                                    ? 'When you place an order, its tracking timeline appears here.'
                                    : 'Try another tab to see your other orders.',
                                actionLabel: _filter == _OrderFilter.all
                                    ? 'Start Shopping'
                                    : 'View all orders',
                                onAction: () => _filter == _OrderFilter.all
                                    ? context.go('/categories')
                                    : setState(
                                        () => _filter = _OrderFilter.all,
                                      ),
                              )
                            else
                              for (final order in filtered)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _OrderCard(order: order),
                                ),
                            if (isDemo && filtered.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              const DemoNotice(
                                message: 'These orders are local demo records. They are not connected to a payment processor or carrier.',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: EpicyclicBottomBar(
        destinations: const [
          homeDestination,
          ordersDestination,
          wishlistDestination,
          profileDestination,
        ],
        selectedIndex: 1,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              break;
            case 2:
              context.go('/wishlist');
            case 3:
              context.go('/profile');
          }
        },
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.filter, required this.onChanged});

  final _OrderFilter filter;
  final ValueChanged<_OrderFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          for (final option in _OrderFilter.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: filter == option
                        ? palette.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    switch (option) {
                      _OrderFilter.all => 'All',
                      _OrderFilter.processing => 'Processing',
                      _OrderFilter.delivered => 'Delivered',
                    },
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: filter == option
                          ? Colors.white
                          : palette.textSecondary,
                      fontWeight: filter == option
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final firstItem = order.items.firstOrNull;
    final extra = order.items.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderNumber}',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatShortDate(order.placedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          Divider(color: palette.border, height: 24),
          if (firstItem != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ProductImage(
                    path: firstItem.image,
                    padding: const EdgeInsets.all(3),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem.productName,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        firstItem.variantName.isEmpty
                            ? 'Qty: ${firstItem.quantity}'
                            : '${firstItem.variantName} · Qty: ${firstItem.quantity}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (extra > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+ $extra more ${extra == 1 ? 'item' : 'items'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: palette.primary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          Divider(color: palette.border, height: 24),
          Row(
            children: [
              Text('Total', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 8),
              Text(
                formatMoney(order.totalCents),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/orders/${order.id}'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View Order'),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward_rounded, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    late Color background;
    late Color foreground;
    late IconData icon;

    if (status == OrderStatus.delivered) {
      background = palette.successSoft;
      foreground = palette.success;
      icon = Icons.check_circle_outline_rounded;
    } else if (status == OrderStatus.cancelled) {
      background = palette.dangerSoft;
      foreground = palette.danger;
      icon = Icons.cancel_outlined;
    } else if (status == OrderStatus.shipped ||
        status == OrderStatus.outForDelivery) {
      background = palette.warningSoft;
      foreground = palette.warning;
      icon = Icons.local_shipping_outlined;
    } else {
      background = palette.primarySoft;
      foreground = palette.primary;
      icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
