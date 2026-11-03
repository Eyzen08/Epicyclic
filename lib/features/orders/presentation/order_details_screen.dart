import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../domain/order.dart';
import 'orders_screen.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId));
    final user = ref.watch(currentUserProvider);
    final palette = context.palette;
    final isDemo = ref.watch(appConfigProvider).isDemo;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: order.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorState(
            message: 'We could not load this order.',
            onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
          ),
          data: (data) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.canPop()
                                ? context.pop()
                                : context.go('/orders'),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 21,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 40,
                              height: 44,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Order details',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${data.orderNumber}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Placed ${formatShortDate(data.placedAt)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            OrderStatusBadge(status: data.status),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final item in data.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: palette.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: palette.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    color: palette.surfaceAlt,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ProductImage(
                                    path: item.image,
                                    padding: const EdgeInsets.all(3),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      if (item.variantName.isNotEmpty)
                                        Text(
                                          item.variantName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Qty: ${item.quantity}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatMoney(item.lineTotalCents),
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: palette.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shipment tracking',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 18),
                            _Timeline(order: data),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: palette.border),
                        ),
                        child: Column(
                          children: [
                            KeyValueRow(
                              label: 'Subtotal',
                              value: formatMoney(data.subtotalCents),
                            ),
                            KeyValueRow(
                              label: 'Delivery',
                              value: data.deliveryCents == 0
                                  ? 'Free'
                                  : formatMoney(data.deliveryCents),
                            ),
                            if (data.discountCents > 0)
                              KeyValueRow(
                                label: 'Discount',
                                value: '−${formatMoney(data.discountCents)}',
                              ),
                            Divider(color: palette.border, height: 20),
                            KeyValueRow(
                              label: 'Order Total',
                              value: formatMoney(data.totalCents),
                              emphasized: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: palette.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery address',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.address.multiLine,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: palette.textSecondary,
                                    height: 1.65,
                                  ),
                            ),
                            Divider(color: palette.border, height: 24),
                            Row(
                              children: [
                                Text(
                                  'Payment method',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.paymentMethod,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: palette.textSecondary),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              data.contactEmail,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (isDemo) ...[
                        const SizedBox(height: 12),
                        const DemoNotice(
                          message: 'This is a local demo order. Status changes are illustrative and not connected to a carrier.',
                        ),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/help'),
                        icon: const Icon(Icons.help_outline_rounded, size: 19),
                        label: const Text('Get help with this order'),
                      ),
                      if (user != null) const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});

  final Order order;

  List<OrderStatus> get _steps {
    final steps = <OrderStatus>[
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
    ];
    if (order.status == OrderStatus.outForDelivery ||
        order.events.any(
          (event) => event.status == OrderStatus.outForDelivery,
        )) {
      steps.add(OrderStatus.outForDelivery);
    }
    steps.add(OrderStatus.delivered);
    return steps;
  }

  OrderEvent? _eventFor(OrderStatus status) {
    for (final event in order.events) {
      if (event.status == status) return event;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final steps = _steps;
    final currentIndex = order.status.stepIndex;

    return Column(
      children: [
        for (var index = 0; index < steps.length; index++)
          _TimelineStep(
            status: steps[index],
            event: _eventFor(steps[index]),
            isLast: index == steps.length - 1,
            stepIndex: _stepIndex(steps[index]),
            currentIndex: currentIndex,
            cancelled: order.status == OrderStatus.cancelled,
            palette: palette,
          ),
      ],
    );
  }

  int _stepIndex(OrderStatus status) {
    switch (status) {
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
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.status,
    required this.event,
    required this.isLast,
    required this.stepIndex,
    required this.currentIndex,
    required this.cancelled,
    required this.palette,
  });

  final OrderStatus status;
  final OrderEvent? event;
  final bool isLast;
  final int stepIndex;
  final int currentIndex;
  final bool cancelled;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final isCurrent = !cancelled && stepIndex == currentIndex;
    final isComplete = event != null;
    final isUpcoming = !isComplete && !isCurrent;

    final circleColor = isComplete || isCurrent
        ? palette.primary
        : palette.surface;
    final borderColor = isComplete || isCurrent
        ? palette.primary
        : palette.border;

    String subtitle;
    if (event != null) {
      subtitle = formatDateTime(event!.occurredAt);
    } else if (isCurrent) {
      subtitle = 'In progress';
    } else if (status == OrderStatus.shipped) {
      subtitle = 'Tracking details will appear when your order ships.';
    } else if (status == OrderStatus.delivered) {
      subtitle = 'Delivery confirmation will appear here.';
    } else {
      subtitle = 'Next update will appear here.';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isComplete ? palette.primary : circleColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: isComplete
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        )
                      : isCurrent
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: isComplete && !isUpcoming
                          ? palette.primary
                          : palette.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isCurrent ? palette.primary : palette.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(height: 1.45),
                  ),
                  if (isCurrent && event != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      event!.description,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: palette.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
