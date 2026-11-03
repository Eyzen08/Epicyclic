import 'package:epicyclic/app.dart';
import 'package:epicyclic/core/config/app_config.dart';
import 'package:epicyclic/core/router/app_router.dart';
import 'package:epicyclic/core/storage/local_store.dart';
import 'package:epicyclic/features/catalog/domain/catalog_data.dart';
import 'package:epicyclic/features/catalog/domain/category.dart';
import 'package:epicyclic/features/catalog/domain/product.dart';
import 'package:epicyclic/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Product _navProduct = Product(
  id: 'keychron-k2-pro',
  slug: 'keychron-k2-pro',
  name: 'Keychron K2 Pro',
  brand: 'Keychron',
  tagline: 'Wireless Mechanical Keyboard',
  description: 'A compact wireless mechanical keyboard.',
  categoryIds: const <String>[],
  rating: 4.8,
  reviewCount: 126,
  images: const <String>[],
  features: const <String>[],
  specs: const <String>[],
  variants: const <ProductVariant>[],
  isFeatured: true,
  isActive: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('router resolves the initial splash location', (tester) async {
    final router = createAppRouter();

    expect(router.routeInformationProvider.value.uri.path, '/splash');
    addTearDown(router.dispose);
  });

  testWidgets('home route renders the app shell content', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = LocalStore(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(mode: AppMode.demo),
          ),
          localStoreProvider.overrideWithValue(store),
          catalogProvider.overrideWith((ref) {
            return Future.value(
              CatalogData(
                categories: const <Category>[],
                products: <Product>[_navProduct],
              ),
            );
          }),
        ],
        child: const EpicyclicApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(Scaffold), findsWidgets);
  });
}
