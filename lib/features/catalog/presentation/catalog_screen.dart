import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/epicyclic_logo.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/responsive_product_grid.dart';
import '../../cart/presentation/cart_controller.dart';

enum ProductSort {
  featured('Featured'),
  priceLow('Price: Low To High'),
  priceHigh('Price: High To Low'),
  rating('Top Rated');

  const ProductSort(this.label);
  final String label;
}

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, this.initialCategory, this.showBack = true});

  final String? initialCategory;
  final bool showBack;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  late String? _categoryId = widget.initialCategory;
  ProductSort _sort = ProductSort.featured;
  bool _inStockOnly = false;

  /// Ceiling for the peso price slider, in whole pesos. The most expensive
  /// demo product sits well below this, so the default shows everything.
  static const double _priceCeiling = 40000;
  double _maxPrice = _priceCeiling;

  bool get _filtersActive => _inStockOnly || _maxPrice < _priceCeiling;

  @override
  void didUpdateWidget(covariant CatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      setState(() => _categoryId = widget.initialCategory);
    }
  }

  Future<void> _openFilter() async {
    var inStock = _inStockOnly;
    var maxPrice = _maxPrice;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final palette = context.palette;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Filter',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setSheetState(() {
                          inStock = false;
                          maxPrice = _priceCeiling;
                        }),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('In Stock Only'),
                    subtitle: const Text('Hide options that are sold out'),
                    value: inStock,
                    onChanged: (value) => setSheetState(() => inStock = value),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Maximum Price',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      Text(
                        formatMoney(maxPrice.round() * 100, showCents: false),
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(color: palette.primary),
                      ),
                    ],
                  ),
                  Slider(
                    value: maxPrice,
                    min: 0,
                    max: _priceCeiling,
                    divisions: 16,
                    label: formatMoney(
                      maxPrice.round() * 100,
                      showCents: false,
                    ),
                    onChanged: (value) => setSheetState(() => maxPrice = value),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (applied == true) {
      setState(() {
        _inStockOnly = inStock;
        _maxPrice = maxPrice;
      });
    }
  }

  Future<void> _openSort() async {
    final selected = await showModalBottomSheet<ProductSort>(
      context: context,
      builder: (context) {
        final palette = context.palette;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                  child: Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                for (final option in ProductSort.values)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Text(option.label),
                    trailing: option == _sort
                        ? Icon(Icons.check_rounded, color: palette.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) setState(() => _sort = selected);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final cartCount = ref.watch(cartCountProvider);
    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: catalog.when(
          loading: () => const AppLoading(label: 'Loading catalog'),
          error: (error, stackTrace) => AppErrorState(
            message: 'The catalog is unavailable right now.',
            onRetry: () => ref.invalidate(catalogProvider),
          ),
          data: (data) {
            final category = _categoryId == null
                ? null
                : data.categories
                      .where((item) => item.id == _categoryId)
                      .firstOrNull;
            var products = data.byCategory(_categoryId);
            if (_inStockOnly) {
              products = products.where((product) => product.inStock).toList();
            }
            products = products
                .where(
                  (product) =>
                      product.lowestPriceCents <= (_maxPrice.round() * 100),
                )
                .toList();
            switch (_sort) {
              case ProductSort.featured:
                products = [...products]
                  ..sort((a, b) {
                    if (a.isFeatured == b.isFeatured) return 0;
                    return a.isFeatured ? -1 : 1;
                  });
              case ProductSort.priceLow:
                products = [...products]
                  ..sort(
                    (a, b) => a.lowestPriceCents.compareTo(b.lowestPriceCents),
                  );
              case ProductSort.priceHigh:
                products = [...products]
                  ..sort(
                    (a, b) => b.lowestPriceCents.compareTo(a.lowestPriceCents),
                  );
              case ProductSort.rating:
                products = [...products]
                  ..sort((a, b) => b.rating.compareTo(a.rating));
            }

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.sizeOf(context).width >= 768 ? 32 : 20,
                8,
                MediaQuery.sizeOf(context).width >= 768 ? 32 : 20,
                28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.showBack)
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
                                height: 40,
                              ),
                            ),
                          const SizedBox(width: 6),
                          const EpicyclicLogo(markSize: 28, textSize: 21),
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
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        category == null ? 'All Gear' : '${category.name} Gear',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontSize: 31),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _subtitleFor(category?.name),
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: palette.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _CategoryChip(
                              label: 'All',
                              selected: _categoryId == null,
                              onTap: () => setState(() => _categoryId = null),
                            ),
                            for (final item in data.categories) ...[
                              const SizedBox(width: 8),
                              _CategoryChip(
                                label: item.name,
                                selected: _categoryId == item.id,
                                onTap: () =>
                                    setState(() => _categoryId = item.id),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _FilterButton(
                              icon: Icons.tune_rounded,
                              label: 'Filter',
                              active: _filtersActive,
                              onTap: _openFilter,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _FilterButton(
                              icon: Icons.swap_vert_rounded,
                              label: 'Sort: ${_sort.label}',
                              onTap: _openSort,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (products.isEmpty)
                        EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No Gear Matches',
                          message:
                              'Try a different category or clear your filters.',
                          actionLabel: 'Clear Filters',
                          onAction: () => setState(() {
                            _categoryId = null;
                            _inStockOnly = false;
                            _maxPrice = _priceCeiling;
                          }),
                        )
                      else
                        ResponsiveProductGrid(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              onTap: () =>
                                  context.push('/product/${product.id}'),
                            );
                          },
                        ),
                      if (products.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            '${products.length} ${products.length == 1 ? 'product' : 'products'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
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

  String _subtitleFor(String? category) {
    switch (category) {
      case 'Gaming':
        return 'Level up your play with high-performance gear.';
      case 'Keyboards':
        return 'Boards that feel as good as they sound.';
      case 'Mice':
        return 'Precision shapes for faster, cleaner movement.';
      case 'Audio':
        return 'Hear every cue with studio-ready sound.';
      case 'Mousepads':
        return 'Give every movement a consistent surface.';
      case 'Accessories':
        return 'The finishing touches that tidy up a setup.';
      case 'Streaming':
        return 'Look and sound clear on every stream.';
      default:
        return 'Everything you need for a setup that works as hard as you do.';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected ? palette.primarySoft : palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected
              ? palette.primary.withValues(alpha: 0.4)
              : palette.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? palette.primary : palette.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: active
              ? palette.primary.withValues(alpha: 0.5)
              : palette.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 19, color: palette.textPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: palette.textPrimary, fontSize: 12.5),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}
