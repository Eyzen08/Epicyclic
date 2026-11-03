import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../../../shared/widgets/section_header.dart';
import '../../cart/domain/cart_models.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return catalog.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (error, stackTrace) => Scaffold(
        body: AppErrorState(
          message: 'We could not load this product.',
          onRetry: () => ref.invalidate(catalogProvider),
        ),
      ),
      data: (data) {
        final product = data.byId(productId);
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Product unavailable',
              message: 'This item may have been removed from the catalog.',
              actionLabel: 'Browse gear',
              onAction: () => context.go('/categories'),
            ),
          );
        }
        return _ProductDetailBody(product: product, data: data);
      },
    );
  }
}

class _ProductDetailBody extends ConsumerStatefulWidget {
  const _ProductDetailBody({required this.product, required this.data});

  final dynamic product;
  final dynamic data;

  @override
  ConsumerState<_ProductDetailBody> createState() => _ProductDetailBodyState();
}

class _ProductDetailBodyState extends ConsumerState<_ProductDetailBody> {
  final PageController _images = PageController();
  late final variants = widget.product.variants as List;
  late int _variantIndex = variants.indexWhere((variant) => variant.inStock);
  int _quantity = 1;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (_variantIndex < 0) _variantIndex = 0;
  }

  @override
  void dispose() {
    _images.dispose();
    super.dispose();
  }

  dynamic get _variant => variants[_variantIndex];
  dynamic get _product => widget.product;

  Future<void> _addToCart() async {
    final variant = _variant;
    if (!variant.inStock) return;
    await ref
        .read(cartControllerProvider.notifier)
        .addLine(
          CartLine(
            productId: _product.id as String,
            variantId: variant.id as String,
            productName: _product.name as String,
            variantName: variant.name as String,
            tagline: _product.tagline as String,
            image: _product.primaryImage as String,
            unitPriceCents: variant.priceCents as int,
            quantity: _quantity,
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_product.name} added to your bag'),
        action: SnackBarAction(
          label: 'View bag',
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final saved = ref
        .watch(wishlistIdsProvider)
        .contains(_product.id as String);
    final cartCount = ref.watch(cartCountProvider);
    final images = _product.images as List<String>;
    final variant = _variant;
    final maxQty = (variant.stock as int).clamp(1, 20);
    final inStock = variant.inStock as bool;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.canPop()
                              ? context.pop()
                              : context.go('/home'),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                          tooltip: 'Back',
                        ),
                        Expanded(
                          child: Text(
                            'Product details',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref
                              .read(wishlistControllerProvider.notifier)
                              .toggle(_product.id as String),
                          icon: Icon(
                            saved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: saved ? palette.danger : palette.textPrimary,
                          ),
                          tooltip: 'Wishlist',
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () => context.push('/cart'),
                              icon: const Icon(Icons.shopping_bag_outlined),
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
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 330,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ColoredBox(
                                  color: palette.surfaceAlt,
                                  child: PageView.builder(
                                    controller: _images,
                                    itemCount: images.isEmpty
                                        ? 1
                                        : images.length,
                                    onPageChanged: (value) =>
                                        setState(() => _imageIndex = value),
                                    itemBuilder: (context, index) =>
                                        ProductImage(
                                          path: images.isEmpty
                                              ? ''
                                              : images[index],
                                          padding: const EdgeInsets.all(10),
                                        ),
                                  ),
                                ),
                                if (images.length > 1)
                                  Positioned(
                                    bottom: 12,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (var i = 0; i < images.length; i++)
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 220,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                            ),
                                            width: i == _imageIndex ? 8 : 7,
                                            height: i == _imageIndex ? 8 : 7,
                                            decoration: BoxDecoration(
                                              color: i == _imageIndex
                                                  ? palette.primary
                                                  : palette.textSecondary
                                                        .withValues(
                                                          alpha: 0.35,
                                                        ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _product.name as String,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontSize: 25),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            for (var i = 0; i < 5; i++)
                              Icon(
                                i < (_product.rating as double).round()
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 17,
                                color: palette.warning,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              '${(_product.rating as double).toStringAsFixed(1)} (${_product.reviewCount} reviews)',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatMoney(variant.priceCents as int),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontSize: 26),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: inStock
                                    ? palette.successSoft
                                    : palette.dangerSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: inStock
                                          ? palette.success
                                          : palette.danger,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    inStock ? 'In stock' : 'Sold out',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: inStock
                                              ? palette.success
                                              : palette.danger,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _product.tagline as String,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: palette.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _product.description as String,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: palette.textSecondary,
                                height: 1.6,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final feature
                                in (_product.features as List<String>))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: palette.border),
                                ),
                                child: Text(
                                  feature,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: palette.textPrimary,
                                        fontSize: 11.5,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Divider(color: palette.border),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Color',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (
                                        var index = 0;
                                        index < variants.length;
                                        index++
                                      )
                                        _VariantDot(
                                          color: _hexColor(
                                            variants[index].colorHex as String,
                                          ),
                                          selected: index == _variantIndex,
                                          soldOut:
                                              !(variants[index].inStock
                                                  as bool),
                                          onTap: () => setState(() {
                                            _variantIndex = index;
                                            final stock =
                                                variants[index].stock as int;
                                            _quantity = _quantity.clamp(
                                              1,
                                              stock.clamp(1, 20),
                                            );
                                          }),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    variant.name as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quantity',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  const SizedBox(height: 10),
                                  QuantityStepper(
                                    quantity: _quantity,
                                    min: 1,
                                    max: maxQty,
                                    onChanged: (value) =>
                                        setState(() => _quantity = value),
                                  ),
                                  if (inStock)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        '${variant.stock} left',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Specifications',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: palette.border),
                          ),
                          child: Column(
                            children: [
                              for (
                                var index = 0;
                                index < (_product.specs as List<String>).length;
                                index++
                              )
                                Column(
                                  children: [
                                    if (index > 0)
                                      Divider(color: palette.border, height: 1),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _specLabel(
                                                _product.specs[index] as String,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                          Text(
                                            _product.specs[index] as String,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: palette.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RelatedProducts(
                    data: widget.data,
                    currentId: _product.id as String,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
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
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatMoney(variant.priceCents as int),
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    inStock ? 'In stock' : 'Sold out',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: inStock ? palette.success : palette.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FilledButton.icon(
                  onPressed: inStock ? _addToCart : null,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 19),
                  label: Text(inStock ? 'Add to cart' : 'Sold out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16) ?? 0x3A3A3C;
    return Color(0xFF000000 | value);
  }

  String _specLabel(String spec) {
    final lower = spec.toLowerCase();
    if (lower.contains('layout')) return 'Layout';
    if (lower.contains('battery')) return 'Battery';
    if (lower.contains('bluetooth') || lower.contains('usb')) {
      return 'Connection';
    }
    if (lower.contains('sensor')) return 'Sensor';
    if (lower.contains('dpi')) return 'Resolution';
    if (lower.contains('weight') || lower.contains(' g')) return 'Weight';
    if (lower.contains('driver')) return 'Drivers';
    if (lower.contains('khz')) return 'Audio';
    if (lower.contains('pattern')) return 'Patterns';
    return 'Detail';
  }
}

class _VariantDot extends StatelessWidget {
  const _VariantDot({
    required this.color,
    required this.selected,
    required this.soldOut,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final bool soldOut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? palette.primary : palette.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (soldOut)
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.surface.withValues(alpha: 0.55),
                ),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 1.5,
                    color: palette.textSecondary,
                    transform: Matrix4.rotationZ(-0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RelatedProducts extends StatelessWidget {
  const _RelatedProducts({required this.data, required this.currentId});

  final dynamic data;
  final String currentId;

  @override
  Widget build(BuildContext context) {
    final current = data.byId(currentId);
    if (current == null) return const SizedBox.shrink();
    final related = (data.products as List)
        .where(
          (product) =>
              product.id != currentId &&
              (product.categoryIds as List).any(
                (id) => (current.categoryIds as List).contains(id),
              ),
        )
        .take(6)
        .toList();
    if (related.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'You might also like'),
          const SizedBox(height: 12),
          SizedBox(
            height: 294,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 24),
              itemCount: related.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = related[index];
                return SizedBox(
                  width: 176,
                  child: ProductCard(
                    product: product,
                    onTap: () =>
                        context.pushReplacement('/product/${product.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
