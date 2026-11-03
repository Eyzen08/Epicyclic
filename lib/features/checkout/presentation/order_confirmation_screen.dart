import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/ui_helpers.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId));
    final isDemo = ref.watch(appConfigProvider).isDemo;
    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        child: order.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorState(
            message: 'We could not load your order confirmation.',
            onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
          ),
          data: (data) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: palette.successSoft,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 44,
                            color: palette.success,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        isDemo ? 'Demo order placed' : 'Order placed',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontSize: 30),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order #${data.orderNumber} is confirmed. We will keep you posted as it moves.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (isDemo)
                        const DemoNotice(
                          message: 'This order exists only in local demo storage. No payment was taken and no shipment will occur.',
                        )
                      else
                        const DemoNotice(
                          message: 'This order was written to Supabase. Payment capture and fulfillment are not implemented in this build.',
                        ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: palette.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _Summary(
                                    label: 'Order number',
                                    value: '#${data.orderNumber}',
                                  ),
                                ),
                                Expanded(
                                  child: _Summary(
                                    label: 'Estimated delivery',
                                    value: formatShortDate(
                                      data.placedAt.add(
                                        const Duration(days: 4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: palette.border, height: 28),
                            for (final item in data.items) ...[
                              Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: palette.surfaceAlt,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ProductImage(
                                      path: item.image,
                                      padding: const EdgeInsets.all(3),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${item.productName} × ${item.quantity}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    formatMoney(item.lineTotalCents),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                            Divider(color: palette.border, height: 18),
                            KeyValueRow(
                              label: 'Total',
                              value: formatMoney(data.totalCents),
                              emphasized: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.go('/orders/${data.id}'),
                        icon: const Icon(
                          Icons.local_shipping_outlined,
                          size: 19,
                        ),
                        label: const Text('Track order'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('Continue shopping'),
                      ),
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

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
