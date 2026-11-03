import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/epicyclic_logo.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../../cart/domain/cart_models.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../orders/domain/order_request.dart';
import '../../profile/domain/address.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0;
  String _paymentMethod = 'GCash';
  String? _addressId;
  bool _placing = false;
  String? _error;

  void _next() {
    if (_step < 2) setState(() => _step += 1);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step -= 1);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/cart');
    }
  }

  Future<void> _chooseAddress(List<Address> addresses) async {
    final selected = await showModalBottomSheet<Address>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Delivery Address',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                for (final address in addresses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(14),
                      onTap: () => Navigator.of(context).pop(address),
                      child: Row(
                        children: [
                          Icon(
                            address.isDefault
                                ? Icons.check_circle_rounded
                                : Icons.location_on_outlined,
                            size: 20,
                            color: context.palette.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.fullName,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  address.singleLine,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/addresses');
                  },
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                  label: const Text('Manage Addresses'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) setState(() => _addressId = selected.id);
  }

  Future<void> _placeOrder(
    CartState cart,
    Address address,
    String email,
  ) async {
    setState(() {
      _placing = true;
      _error = null;
    });
    try {
      final order = await ref
          .read(orderRepositoryProvider)
          .createOrder(
            CreateOrderRequest(
              lines: cart.lines,
              address: address,
              paymentMethod: _paymentMethod,
              contactEmail: email,
              promoCode: cart.promo?.code,
            ),
          );
      await ref.read(cartControllerProvider.notifier).clear();
      ref.invalidate(ordersProvider);
      ref.invalidate(notificationsProvider);
      if (!mounted) return;
      context.go('/order-confirmation/${order.id}');
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cart = ref.watch(cartControllerProvider).value ?? const CartState();
    final user = ref.watch(currentUserProvider);
    final addresses = ref.watch(addressesProvider);
    final isDemo = ref.watch(appConfigProvider).isDemo;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Sign In To Checkout',
          message: 'Your account keeps your addresses and order history in one place.',
          actionLabel: 'Sign In',
          onAction: () => context.push('/login?next=/checkout'),
        ),
      );
    }

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Your Bag Is Empty',
          message: 'Add something to your bag before checking out.',
          actionLabel: 'Browse Gear',
          onAction: () => context.go('/categories'),
        ),
      );
    }

    return addresses.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const AppLoading(label: 'Loading delivery details'),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: AppErrorState(
          message: 'We could not load your delivery addresses.',
          onRetry: () => ref.invalidate(addressesProvider),
        ),
      ),
      data: (addressList) {
        Address? address;
        if (_addressId != null) {
          for (final item in addressList) {
            if (item.id == _addressId) address = item;
          }
        }
        address ??= addressList.where((item) => item.isDefault).firstOrNull;
        address ??= addressList.firstOrNull;

        final email = user.email;

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.sizeOf(context).width >= 768 ? 32 : 20,
                    8,
                    MediaQuery.sizeOf(context).width >= 768 ? 32 : 20,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _back,
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
                            'Checkout',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          if (isDemo) const DemoModeChip(compact: true),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _StepIndicator(step: _step),
                      const SizedBox(height: 24),
                      if (_error != null) ...[
                        AuthlessError(message: _error!),
                        const SizedBox(height: 14),
                      ],
                      if (_step == 0) ...[
                        const _SectionTitle('Contact'),
                        _InfoTile(
                          icon: Icons.mail_outline_rounded,
                          title: email,
                          actionLabel: 'Edit',
                          onAction: () => context.push('/edit-profile'),
                        ),
                        const SizedBox(height: 22),
                        const _SectionTitle('Delivery Address'),
                        if (address == null)
                          SurfaceCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'No delivery address saved yet.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push('/addresses/edit'),
                                  icon: const Icon(
                                    Icons.add_location_alt_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Add Delivery Address'),
                                ),
                              ],
                            ),
                          )
                        else
                          _InfoTile(
                            icon: Icons.location_on_outlined,
                            title: address.fullName,
                            subtitle: address.multiLine
                                .split('\n')
                                .skip(1)
                                .join('\n'),
                            actionLabel: addressList.length > 1
                                ? 'Change'
                                : 'Edit',
                            onAction: () => addressList.length > 1
                                ? _chooseAddress(addressList)
                                : context.push('/addresses'),
                          ),
                        const SizedBox(height: 22),
                        const _SectionTitle('Delivery Option'),
                        _InfoTile(
                          icon: Icons.local_shipping_outlined,
                          title: 'Standard Delivery',
                          subtitle: '3–5 business days',
                          trailing: 'Free',
                        ),
                        const SizedBox(height: 22),
                        _OrderSummaryCard(cart: cart),
                        const SizedBox(height: 16),
                        const DemoNotice(
                          message: 'Demo checkout: no payment is taken. Orders are stored locally and are not fulfilled.',
                        ),
                      ],
                      if (_step == 1) ...[
                        const _SectionTitle('Payment Method'),
                        for (final option in _paymentOptions) ...[
                          _PaymentOption(
                            selected: _paymentMethod == option.label,
                            icon: option.icon,
                            label: option.label,
                            onTap: () =>
                                setState(() => _paymentMethod = option.label),
                          ),
                          const SizedBox(height: 10),
                        ],
                        InfoBanner(
                          message: 'Demo checkout: these payment methods are placeholders. No card details are collected, no e-wallet is charged, and no payment is captured. Your chosen method is recorded on the demo order only.',
                          icon: Icons.shield_outlined,
                          tone: InfoTone.warning,
                        ),
                        const SizedBox(height: 22),
                        const _SectionTitle('Billing Address'),
                        _InfoTile(
                          icon: Icons.receipt_long_outlined,
                          title: 'Same As Delivery Address',
                          subtitle:
                              address?.singleLine ?? 'Add an address first',
                        ),
                        const SizedBox(height: 22),
                        _OrderSummaryCard(cart: cart),
                      ],
                      if (_step == 2) ...[
                        const _SectionTitle('Review Your Order'),
                        SurfaceCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _ReviewRow(
                                label: 'Contact',
                                value: email,
                                onEdit: () => setState(() => _step = 0),
                              ),
                              Divider(color: palette.border, height: 20),
                              _ReviewRow(
                                label: 'Deliver To',
                                value: address == null
                                    ? 'No address selected'
                                    : address.multiLine,
                                onEdit: () => setState(() => _step = 0),
                              ),
                              Divider(color: palette.border, height: 20),
                              _ReviewRow(
                                label: 'Payment',
                                value: _paymentMethod,
                                onEdit: () => setState(() => _step = 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        _OrderSummaryCard(cart: cart),
                        const SizedBox(height: 16),
                        DemoNotice(
                          message: isDemo
                              ? 'This will create a demo order on this device. No payment is taken and no shipment will occur.'
                              : 'This will create an order row through Supabase. Payment capture and fulfillment are not implemented.',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border(top: BorderSide(color: palette.border)),
            ),
            child: SafeArea(
              top: false,
              child: FilledButton(
                onPressed: _placing
                    ? null
                    : () {
                        if (_step < 2) {
                          if (_step == 0 && address == null) {
                            context.push('/addresses/edit');
                            return;
                          }
                          _next();
                        } else if (address != null) {
                          _placeOrder(cart, address, email);
                        }
                      },
                child: _placing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _step == 0
                                ? 'Continue To Payment'
                                : _step == 1
                                ? 'Review Order'
                                : isDemo
                                ? 'Place Demo Order'
                                : 'Place Order',
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PaymentChoice {
  const _PaymentChoice(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Philippine payment options shown as demo selections only. Nothing here
/// integrates with a real payment provider.
const _paymentOptions = <_PaymentChoice>[
  _PaymentChoice('GCash', Icons.account_balance_wallet_rounded),
  _PaymentChoice('Maya', Icons.payments_rounded),
  _PaymentChoice('Cash On Delivery', Icons.local_shipping_outlined),
  _PaymentChoice('Bank Transfer', Icons.account_balance_outlined),
  _PaymentChoice('Credit Or Debit Card', Icons.credit_card_rounded),
];

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const labels = ['Delivery', 'Payment', 'Review'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          if (index > 0)
            Expanded(
              child: Container(
                height: 1.5,
                margin: const EdgeInsets.only(top: 15),
                color: index <= step ? palette.primary : palette.border,
              ),
            ),
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index <= step ? palette.primary : palette.surface,
                  border: Border.all(
                    color: index <= step ? palette.primary : palette.border,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: index < step
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: index == step
                                ? Colors.white
                                : palette.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[index],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: index == step
                      ? palette.primary
                      : palette.textSecondary,
                  fontWeight: index == step ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
          if (index < labels.length - 1)
            Expanded(
              child: Container(
                height: 1.5,
                margin: const EdgeInsets.only(top: 15),
                color: index < step ? palette.primary : palette.border,
              ),
            ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: palette.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: palette.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: 10),
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected
          ? palette.primarySoft.withValues(alpha: 0.5)
          : palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? palette.primary : palette.border,
          width: selected ? 1.3 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? palette.primary : palette.textSecondary,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: palette.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Icon(icon, size: 22, color: palette.textPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: palette.textPrimary, height: 1.5),
          ),
        ),
        TextButton(
          onPressed: onEdit,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8),
            minimumSize: const Size(0, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Edit'),
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.cart});

  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Order Summary'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            children: [
              for (final line in cart.lines) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ProductImage(
                        path: line.image,
                        padding: const EdgeInsets.all(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${line.productName} × ${line.quantity}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatMoney(line.lineTotalCents),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Divider(color: palette.border, height: 8),
              const SizedBox(height: 6),
              KeyValueRow(
                label: 'Subtotal',
                value: formatMoney(cart.subtotalCents),
              ),
              KeyValueRow(
                label: 'Delivery',
                value: cart.deliveryCents == 0
                    ? 'Free'
                    : formatMoney(cart.deliveryCents),
              ),
              if (cart.discountCents > 0)
                KeyValueRow(
                  label: 'Discount',
                  value: '−${formatMoney(cart.discountCents)}',
                ),
              Divider(color: palette.border, height: 18),
              KeyValueRow(
                label: 'Total',
                value: formatMoney(cart.totalCents),
                emphasized: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthlessError extends StatelessWidget {
  const AuthlessError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.dangerSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: palette.danger),
      ),
    );
  }
}
