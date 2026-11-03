import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/bottom_bar.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import '../domain/cart_models.dart';
import 'cart_controller.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _promo = TextEditingController();
  bool _applying = false;
  String? _promoError;

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    setState(() {
      _applying = true;
      _promoError = null;
    });
    try {
      await ref.read(cartControllerProvider.notifier).applyPromo(_promo.text);
      if (!mounted) return;
      _promo.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Promo code applied')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _promoError = error.toString());
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  Future<void> _checkout() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      await context.push('/login?next=/checkout');
      return;
    }
    if (!mounted) return;
    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: cart.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorState(
            message: 'Your bag could not be loaded.',
            onRetry: () => ref.invalidate(cartControllerProvider),
          ),
          data: (state) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              MediaQuery.sizeOf(context).width >= 768 ? 32 : 20,
              8,
              MediaQuery.sizeOf(context).width >= 768 ? 32 : 20,
              28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.canPop()
                              ? context.pop()
                              : context.go('/home'),
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
                          'Your Cart',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        if (!state.isEmpty)
                          Text(
                            '${state.itemCount} ${state.itemCount == 1 ? 'item' : 'items'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (state.isEmpty)
                      EmptyState(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Your Bag Is Empty',
                        message: 'Add a keyboard, mouse, or headset and it will show up here.',
                        actionLabel: 'Start Shopping',
                        onAction: () => context.go('/categories'),
                      )
                    else ...[
                      for (final line in state.lines)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CartLineCard(
                            line: line,
                            onQuantity: (value) => ref
                                .read(cartControllerProvider.notifier)
                                .setQuantity(
                                  line.productId,
                                  line.variantId,
                                  value,
                                ),
                            onRemove: () => ref
                                .read(cartControllerProvider.notifier)
                                .removeLine(line.productId, line.variantId),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: palette.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Promo Code',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            if (state.promo != null)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: palette.successSoft,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_offer_outlined,
                                          size: 14,
                                          color: palette.success,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${state.promo!.code} · ${state.promo!.percentOff}% off',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: palette.success,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => ref
                                        .read(cartControllerProvider.notifier)
                                        .removePromo(),
                                    child: const Text('Remove'),
                                  ),
                                ],
                              )
                            else ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _promo,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      onSubmitted: (_) => _applyPromo(),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter code',
                                        prefixIcon: Icon(
                                          Icons.local_offer_outlined,
                                          size: 19,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  FilledButton(
                                    onPressed: _applying ? null : _applyPromo,
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(90, 50),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                    ),
                                    child: _applying
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Apply'),
                                  ),
                                ],
                              ),
                              if (_promoError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _promoError!,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: palette.danger),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Demo promo: EPIC10 for 10% off.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const DemoNotice(
                        message: 'Demo checkout: orders are stored locally and no payment is taken. Supabase mode records orders only; card capture is not implemented.',
                      ),
                      const SizedBox(height: 14),
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
                              value: formatMoney(state.subtotalCents),
                            ),
                            KeyValueRow(
                              label: 'Delivery',
                              value: state.deliveryCents == 0
                                  ? 'Free'
                                  : formatMoney(state.deliveryCents),
                            ),
                            if (state.discountCents > 0)
                              KeyValueRow(
                                label: 'Discount',
                                value: '−${formatMoney(state.discountCents)}',
                              ),
                            Divider(color: palette.border, height: 20),
                            KeyValueRow(
                              label: 'Total',
                              value: formatMoney(state.totalCents),
                              emphasized: true,
                            ),
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: _checkout,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Continue To Checkout'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: EpicyclicBottomBar(
        destinations: const [
          homeDestination,
          categoriesDestination,
          wishlistDestination,
          profileDestination,
        ],
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/categories');
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

class _CartLineCard extends ConsumerWidget {
  const _CartLineCard({
    required this.line,
    required this.onQuantity,
    required this.onRemove,
  });

  final CartLine line;
  final ValueChanged<int> onQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final saved = ref.watch(wishlistIdsProvider).contains(line.productId);
    final product = ref.watch(catalogProvider).value?.byId(line.productId);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 112,
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ProductImage(
              path: line.image,
              padding: const EdgeInsets.all(4),
              brand: product?.brand,
              categoryId: product?.categoryIds.isNotEmpty == true
                  ? product!.categoryIds.first
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        line.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontSize: 14.5, height: 1.3),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => ref
                            .read(wishlistControllerProvider.notifier)
                            .toggle(line.productId),
                        icon: Icon(
                          saved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 19,
                          color: saved ? palette.danger : palette.textPrimary,
                        ),
                        tooltip: 'Wishlist',
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: onRemove,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: palette.textSecondary,
                        ),
                        tooltip: 'Remove',
                      ),
                    ),
                  ],
                ),
                Text(
                  line.tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (line.variantName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    line.variantName,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: palette.textSecondary),
                  ),
                ],
                const SizedBox(height: 7),
                Text(
                  formatMoney(line.unitPriceCents),
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700, fontSize: 16.5),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: QuantityStepper(
                    quantity: line.quantity,
                    compact: true,
                    onChanged: onQuantity,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
