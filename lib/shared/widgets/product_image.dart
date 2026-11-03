import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../features/catalog/domain/product.dart';
import 'ui_helpers.dart';

/// Renders a product image with a consistent, branded treatment.
///
/// Product photography is not bundled for every catalog entry, so when a
/// product has no image (or the file is missing) this widget draws a calm,
/// branded placeholder instead of a broken image or a random photo. The
/// placeholder always reflects the real product brand and category, so it can
/// never be mistaken for a different product.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.padding = const EdgeInsets.all(8),
    this.categoryId,
    this.brand,
    this.icon,
    this.showPlate = true,
  });

  /// Convenience constructor that pulls the brand, category, and first image
  /// straight from a [Product].
  factory ProductImage.forProduct(
    Product product, {
    Key? key,
    BoxFit fit = BoxFit.contain,
    EdgeInsets padding = const EdgeInsets.all(8),
    bool showPlate = true,
  }) {
    return ProductImage(
      key: key,
      path: product.primaryImage,
      fit: fit,
      padding: padding,
      categoryId: product.categoryIds.isEmpty
          ? null
          : product.categoryIds.first,
      brand: product.brand,
      showPlate: showPlate,
    );
  }

  final String path;
  final BoxFit fit;
  final EdgeInsets padding;

  /// Category id used to pick a representative icon for the placeholder.
  final String? categoryId;

  /// Brand name shown on the placeholder so the fallback stays honest.
  final String? brand;

  /// Explicit icon override for the placeholder.
  final IconData? icon;

  /// Whether to paint the soft image plate behind transparent cut-outs.
  final bool showPlate;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final placeholder = _Placeholder(
      padding: padding,
      palette: palette,
      icon: icon ?? categoryIcon(categoryId ?? ''),
      brand: brand,
    );

    final Widget content;
    if (path.isEmpty) {
      content = placeholder;
    } else {
      final isRemote =
          path.startsWith('http://') || path.startsWith('https://');
      content = Padding(
        padding: padding,
        child: isRemote
            ? Image.network(
                path,
                fit: fit,
                errorBuilder: (context, error, stackTrace) => placeholder,
              )
            : Image.asset(
                path,
                fit: fit,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      );
    }

    if (!showPlate) return content;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.imagePlate, palette.surfaceAlt],
        ),
      ),
      child: content,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.padding,
    required this.palette,
    required this.icon,
    required this.brand,
  });

  final EdgeInsets padding;
  final AppPalette palette;
  final IconData icon;
  final String? brand;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: palette.primary.withValues(alpha: 0.55),
                size: 40,
              ),
              if (brand != null && brand!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  brand!.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: palette.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
