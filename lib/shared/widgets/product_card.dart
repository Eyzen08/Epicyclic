import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../features/catalog/domain/product.dart';
import '../../features/wishlist/presentation/wishlist_controller.dart';
import 'product_image.dart';
import 'ui_helpers.dart';

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
    final categoryId = product.categoryIds.isEmpty
        ? null
        : product.categoryIds.first;

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
                    child: ProductImage.forProduct(
                      product,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                  if (categoryId != null)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: palette.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: palette.border),
                        ),
                        child: Text(
                          categoryLabel(categoryId).toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8.5,
                            letterSpacing: 0.7,
                            fontWeight: FontWeight.w600,
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: palette.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                      if (showRating && product.reviewCount > 0) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: palette.warning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: palette.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      height: 1.28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatMoney(price, showCents: false),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                      color: palette.textPrimary,
                    ),
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
          padding: const EdgeInsets.all(6),
          child: Icon(
            saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 19,
            color: saved ? palette.danger : palette.textPrimary,
          ),
        ),
      ),
    );
  }
}
