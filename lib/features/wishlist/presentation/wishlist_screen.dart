import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/epicyclic_logo.dart';
import '../../../shared/widgets/product_card.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final wishlist = ref.watch(wishlistIdsProvider);
    final cartCount = ref.watch(cartCountProvider);
    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: catalog.when(
          loading: () => const AppLoading(label: 'Loading your wishlist'),
          error: (error, stackTrace) => AppErrorState(
            message: 'We could not load your wishlist.',
            onRetry: () => ref.invalidate(catalogProvider),
          ),
          data: (data) {
            final saved = data.products
                .where((product) => wishlist.contains(product.id))
                .toList();
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const EpicyclicLogo(markSize: 32, textSize: 23),
                          const SizedBox(width: 8),
                          const DemoModeChip(compact: true),
                          const Spacer(),
                          IconButton(
                            onPressed: () => context.push('/search'),
                            icon: const Icon(Icons.search_rounded, size: 25),
                            tooltip: 'Search',
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: () => context.push('/cart'),
                                icon: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 24,
                                ),
                                tooltip: 'Bag',
                              ),
                              if (cartCount > 0)
                                Positioned(
                                  top: 3,
                                  right: 3,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 17,
                                      minHeight: 17,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: palette.primary,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: palette.background,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$cartCount',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Wishlist',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        saved.isEmpty
                            ? 'Save gear you love and come back to it.'
                            : '${saved.length} ${saved.length == 1 ? 'item' : 'items'} saved for later.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: palette.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      if (saved.isEmpty)
                        EmptyState(
                          icon: Icons.favorite_border_rounded,
                          title: 'Nothing saved yet',
                          message: 'Tap the heart on any product to keep it here for later.',
                          actionLabel: 'Explore gear',
                          onAction: () => context.go('/categories'),
                        )
                      else ...[
                        Text(
                          'Saved for later',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: saved.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                mainAxisExtent: 294,
                              ),
                          itemBuilder: (context, index) {
                            final product = saved[index];
                            return ProductCard(
                              product: product,
                              showRating: false,
                              onTap: () =>
                                  context.push('/product/${product.id}'),
                            );
                          },
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
    );
  }
}
