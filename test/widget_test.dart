import 'package:epicyclic/core/storage/local_store.dart';
import 'package:epicyclic/core/theme/app_theme.dart';
import 'package:epicyclic/features/catalog/domain/product.dart';
import 'package:epicyclic/shared/providers/app_providers.dart';
import 'package:epicyclic/shared/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const product = Product(
  id: 'keychron-k2-pro',
  slug: 'keychron-k2-pro',
  name: 'Keychron K2 Pro',
  brand: 'Keychron',
  tagline: 'Wireless Mechanical Keyboard',
  description: 'A compact wireless mechanical keyboard.',
  categoryIds: ['keyboards'],
  rating: 4.8,
  reviewCount: 126,
  images: [],
  features: [],
  specs: [],
  variants: [
    ProductVariant(
      id: 'graphite',
      name: 'Graphite',
      colorHex: '#3A3A3C',
      priceCents: 599000,
      stock: 8,
    ),
  ],
  isFeatured: true,
  isActive: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStore store;
  var tapped = false;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = LocalStore(await SharedPreferences.getInstance());
    tapped = false;
  });

  Widget harness() {
    return ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(store)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 300,
              child: ProductCard(product: product, onTap: () => tapped = true),
            ),
          ),
        ),
      ),
    );
  }

  group('ProductCard', () {
    testWidgets('renders brand, name, rating, and peso price', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('Keychron'), findsOneWidget);
      expect(find.text('Keychron K2 Pro'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('₱5,990'), findsOneWidget);
    });

    testWidgets('invokes onTap when the card is pressed', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keychron K2 Pro'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('toggles the wishlist and persists the product id', (
      tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(store.wishlistJson, contains('keychron-k2-pro'));

      await tester.tap(find.byIcon(Icons.favorite_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(store.wishlistJson, isNot(contains('keychron-k2-pro')));
    });
  });
}
