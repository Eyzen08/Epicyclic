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
  id: 'aula-f75',
  slug: 'aula-f75',
  name: 'AULA F75',
  brand: 'AULA',
  tagline: '75% Tri-Mode Mechanical Keyboard',
  description: 'A 75% gasket-mounted mechanical keyboard.',
  categoryIds: ['keyboards'],
  rating: 0,
  reviewCount: 0,
  images: [],
  features: [],
  specs: [],
  variants: [
    ProductVariant(
      id: 'black-gradient-grey',
      name: 'Black / Gradient Grey',
      colorHex: '#3B4049',
      priceCents: 259500,
      stock: 10,
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
    testWidgets('renders brand, name, and peso price without ratings', (
      tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('AULA'), findsWidgets);
      expect(find.text('AULA F75'), findsOneWidget);
      expect(find.text('₱2,595'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('invokes onTap when the card is pressed', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('AULA F75'));
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
      expect(store.wishlistJson, contains('aula-f75'));

      await tester.tap(find.byIcon(Icons.favorite_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(store.wishlistJson, isNot(contains('aula-f75')));
    });
  });
}
