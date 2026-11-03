import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../features/catalog/domain/product.dart';
import '../../features/wishlist/presentation/wishlist_controller.dart';
import 'product_image.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showRating = true,
  });

  final Product product;
  final VoidCallback onTap;
  final bool showRating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final saved = ref.watch(wishlistIdsProvider).contains(product.id);
    final price = product.lowestPriceCents;

    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: palette.surfaceAlt,
                      child: ProductImage(
                        path: product.primaryImage,
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: WishlistButton(
                      saved: saved,
                      onPressed: () => ref
                          .read(wishlistControllerProvider.notifier)
                          .toggle(product.id),
                    ),
                  ),
                  if (!product.inStock)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: palette.navy,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'SOLD OUT',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showRating)
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: palette.warning,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: palette.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '(${formatCompactCount(product.reviewCount)})',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  if (showRating) const SizedBox(height: 5),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontSize: 13.5, height: 1.3),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(fontSize: 11.5),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    formatMoney(price, showCents: false),
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WishlistButton extends StatelessWidget {
  const WishlistButton({
    super.key,
    required this.saved,
    required this.onPressed,
    this.light = true,
  });

  final bool saved;
  final VoidCallback onPressed;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: light
          ? palette.surface.withValues(alpha: 0.92)
          : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 20,
            color: saved ? palette.danger : palette.textPrimary,
          ),
        ),
      ),
    );
  }
}
