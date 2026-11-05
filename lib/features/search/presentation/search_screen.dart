import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/product_card.dart';
import '../../catalog/domain/product.dart';
import '../../search/presentation/recent_searches_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _query = TextEditingController(
    text: widget.initialQuery ?? '',
  );
  final FocusNode _focus = FocusNode();
  String? _categoryId;
  bool _inStockOnly = false;

  @override
  void initState() {
    super.initState();
    if ((widget.initialQuery ?? '').isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(recentSearchesProvider.notifier).add(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _runSearch(String term) {
    _query.text = term;
    _query.selection = TextSelection.collapsed(offset: term.length);
    ref.read(recentSearchesProvider.notifier).add(term);
    setState(() {});
    _focus.unfocus();
  }

  void _submit() {
    final term = _query.text.trim();
    if (term.isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).add(term);
    }
    setState(() {});
    _focus.unfocus();
  }

  List<Product> _results(List<Product> products) {
    final term = _query.text.trim().toLowerCase();
    var filtered = products.where((product) {
      if (_categoryId != null && !product.categoryIds.contains(_categoryId)) {
        return false;
      }
      if (_inStockOnly && !product.inStock) return false;
      if (term.isEmpty) return true;
      final haystack = [
        product.name,
        product.brand,
        product.tagline,
        product.description,
        ...product.features,
      ].join(' ').toLowerCase();
      return haystack.contains(term);
    }).toList();
    if (term.isNotEmpty) {
      filtered.sort((a, b) {
        final aName = a.name.toLowerCase();
        final bName = b.name.toLowerCase();
        final aStarts = aName.startsWith(term) ? 0 : 1;
        final bStarts = bName.startsWith(term) ? 0 : 1;
        if (aStarts != bStarts) return aStarts.compareTo(bStarts);
        return b.rating.compareTo(a.rating);
      });
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final palette = context.palette;
    final hasQuery = _query.text.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: catalog.when(
          loading: () => const AppLoading(label: 'Loading products'),
          error: (error, stackTrace) => AppErrorState(
            message: 'Search needs the catalog. Check your connection.',
            onRetry: () => ref.invalidate(catalogProvider),
          ),
          data: (data) {
            final results = _results(data.products);
            final suggestions = data.featured.isEmpty
                ? data.products.take(4).toList()
                : data.featured.take(4).toList();

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.sizeOf(context).width >= 768 ? 32 : 20,
                12,
                MediaQuery.sizeOf(context).width >= 768 ? 32 : 20,
                30,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              width: 36,
                              height: 44,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _query,
                              focusNode: _focus,
                              autofocus: widget.initialQuery == null,
                              textInputAction: TextInputAction.search,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                hintText: 'Search gear and accessories',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  size: 21,
                                ),
                                suffixIcon: _query.text.isEmpty
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          _query.clear();
                                          setState(() {});
                                          _focus.requestFocus();
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 19,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _SearchChip(
                              label: 'Filters',
                              icon: Icons.tune_rounded,
                              active: _inStockOnly,
                              onTap: () =>
                                  setState(() => _inStockOnly = !_inStockOnly),
                            ),
                            const SizedBox(width: 8),
                            _SearchChip(
                              label: 'All',
                              active: _categoryId == null,
                              onTap: () => setState(() => _categoryId = null),
                            ),
                            for (final category in data.categories) ...[
                              const SizedBox(width: 8),
                              _SearchChip(
                                label: category.name,
                                active: _categoryId == category.id,
                                onTap: () =>
                                    setState(() => _categoryId = category.id),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!hasQuery) ...[
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Text(
                              'Recent Searches',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const Spacer(),
                            if (ref.watch(recentSearchesProvider).isNotEmpty)
                              TextButton(
                                onPressed: () => ref
                                    .read(recentSearchesProvider.notifier)
                                    .clear(),
                                child: const Text('Clear All'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (ref.watch(recentSearchesProvider).isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Your recent searches will appear here.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: palette.textSecondary),
                            ),
                          )
                        else
                          for (final term in ref.watch(recentSearchesProvider))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: Material(
                                color: palette.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: palette.border),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _runSearch(term),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.history_rounded,
                                          size: 20,
                                          color: palette.textSecondary,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            term,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 19,
                                          color: palette.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(height: 20),
                      ],
                      Row(
                        children: [
                          Text(
                            hasQuery
                                ? '${results.length} results'
                                : 'Suggested Products',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Spacer(),
                          if (!hasQuery)
                            TextButton(
                              onPressed: () => context.push('/catalog'),
                              child: const Text('See All'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (results.isEmpty)
                        EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No Matching Gear',
                          message: 'Try a broader term, another category, or turn off filters.',
                          actionLabel: 'Reset Search',
                          onAction: () {
                            _query.clear();
                            setState(() {
                              _categoryId = null;
                              _inStockOnly = false;
                            });
                            _focus.requestFocus();
                          },
                        )
                      else
                        for (final product
                            in (hasQuery ? results : suggestions))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SearchResultCard(
                              product: product,
                              onTap: () =>
                                  context.push('/product/${product.id}'),
                            ),
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

class _SearchChip extends StatelessWidget {
  const _SearchChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: active ? palette.primarySoft : palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: active
              ? palette.primary.withValues(alpha: 0.45)
              : palette.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 17,
                  color: active ? palette.primary : palette.textPrimary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: active ? palette.primary : palette.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultCard extends ConsumerWidget {
  const _SearchResultCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final saved = ref.watch(wishlistIdsProvider).contains(product.id);
    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ProductImage(
                  path: product.primaryImage,
                  padding: const EdgeInsets.all(4),
                  brand: product.brand,
                  categoryId: product.categoryIds.isEmpty
                      ? null
                      : product.categoryIds.first,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: palette.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontSize: 14.5, height: 1.3),
                    ),
                    if (product.reviewCount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: palette.warning,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${product.rating.toStringAsFixed(1)}  (${formatCompactCount(product.reviewCount)})',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontSize: 10.5),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        for (final feature in product.features.take(2))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: palette.surfaceAlt,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              feature,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontSize: 9.5),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatMoney(product.lowestPriceCents, showCents: false),
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              WishlistButton(
                saved: saved,
                light: false,
                onPressed: () => ref
                    .read(wishlistControllerProvider.notifier)
                    .toggle(product.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
