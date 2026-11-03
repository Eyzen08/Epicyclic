import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/epicyclic_logo.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../catalog/domain/category.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: catalog.when(
          loading: () => const AppLoading(label: 'Loading your gear'),
          error: (error, stackTrace) => AppErrorState(
            message: 'We could not load the catalog. Check your connection and try again.',
            onRetry: () => ref.invalidate(catalogProvider),
          ),
          data: (data) {
            final featured = data.featured.isEmpty
                ? data.products.take(4).toList()
                : data.featured;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(cartCount: cartCount),
                      const SizedBox(height: 24),
                      Text(
                        'Find Your Next\nUpgrade.',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontSize: 31, height: 1.12),
                      ),
                      const SizedBox(height: 18),
                      _SearchBar(onTap: () => context.push('/search')),
                      const SizedBox(height: 20),
                      const HeroCarousel(),
                      const SizedBox(height: 28),
                      const SectionHeader(title: 'Shop by category'),
                      const SizedBox(height: 14),
                      _CategoryRow(categories: data.categories),
                      const SizedBox(height: 28),
                      SectionHeader(
                        title: 'Featured gear',
                        actionLabel: 'See all',
                        onAction: () => context.push('/catalog'),
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: featured.length > 4 ? 4 : featured.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              mainAxisExtent: 294,
                            ),
                        itemBuilder: (context, index) {
                          final product = featured[index];
                          return ProductCard(
                            product: product,
                            onTap: () => context.push('/product/${product.id}'),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _ServiceStrip(),
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

class _Header extends StatelessWidget {
  const _Header({required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        const EpicyclicLogo(markSize: 34, textSize: 24),
        const SizedBox(width: 8),
        const DemoModeChip(compact: true),
        const Spacer(),
        IconButton(
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search_rounded, size: 26),
          color: palette.textPrimary,
          tooltip: 'Search',
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => context.push('/cart'),
              icon: const Icon(Icons.shopping_bag_outlined, size: 25),
              color: palette.textPrimary,
              tooltip: 'Bag',
            ),
            if (cartCount > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 19,
                    minHeight: 19,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: palette.background, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      cartCount > 99 ? '99+' : '$cartCount',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9.5,
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
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 22,
                color: palette.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                'Search gear and accessories',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: palette.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.image,
    required this.eyebrow,
    required this.title,
    required this.category,
    required this.dark,
  });

  final String image;
  final String eyebrow;
  final String title;
  final String? category;
  final bool dark;
}

const _slides = [
  _Slide(
    image: 'assets/images/banners/hero_home_clean.png',
    eyebrow: 'TOP PICKS',
    title: 'Level up\nyour setup',
    category: null,
    dark: true,
  ),
  _Slide(
    image: 'assets/images/banners/banner_keys.png',
    eyebrow: 'KEYBOARDS',
    title: 'Keys built\nfor speed',
    category: 'keyboards',
    dark: false,
  ),
  _Slide(
    image: 'assets/images/banners/banner_audio.png',
    eyebrow: 'AUDIO',
    title: 'Hear every\ndetail',
    category: 'audio',
    dark: false,
  ),
];

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        SizedBox(
          height: 216,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    final textColor = slide.dark ? Colors.white : palette.navy;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          slide.image,
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: slide.dark
                                  ? [
                                      palette.navy.withValues(alpha: 0.88),
                                      palette.navy.withValues(alpha: 0.25),
                                      Colors.transparent,
                                    ]
                                  : [
                                      palette.surface.withValues(alpha: 0.92),
                                      palette.surface.withValues(alpha: 0.1),
                                      Colors.transparent,
                                    ],
                              stops: const [0, 0.55, 1],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 22, 130, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                slide.eyebrow,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.2,
                                  color: slide.dark
                                      ? const Color(0xFF9CCBFF)
                                      : palette.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                slide.title,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 27,
                                  height: 1.08,
                                  letterSpacing: -0.7,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () => context.push(
                                  slide.category == null
                                      ? '/catalog'
                                      : '/catalog?category=${slide.category}',
                                ),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  backgroundColor: palette.primary,
                                  textStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Explore'),
                                    SizedBox(width: 5),
                                    Icon(Icons.arrow_forward_rounded, size: 15),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _index ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? (_slides[_index].dark
                                      ? palette.primary
                                      : palette.navy)
                                : Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        for (var index = 0; index < categories.length; index++) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: palette.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: palette.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () =>
                    context.push('/catalog?category=${categories[index].id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        categoryIcon(categories[index].icon),
                        size: 27,
                        color: palette.textPrimary,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        categories[index].name,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: palette.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ServiceStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          _ServiceItem(
            icon: Icons.local_shipping_outlined,
            title: 'Free delivery',
            subtitle: 'On every order',
          ),
          Container(width: 1, height: 34, color: palette.border),
          _ServiceItem(
            icon: Icons.verified_user_outlined,
            title: '2-year cover',
            subtitle: 'On all gear',
          ),
          Container(width: 1, height: 34, color: palette.border),
          _ServiceItem(
            icon: Icons.replay_rounded,
            title: '30-day returns',
            subtitle: 'No fuss',
          ),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: palette.primary),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(fontSize: 9.5),
          ),
        ],
      ),
    );
  }
}
