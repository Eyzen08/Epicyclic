import 'package:epicyclic/features/catalog/data/demo_catalog_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DemoCatalogRepository', () {
    late DemoCatalogRepository repository;

    setUp(() {
      repository = DemoCatalogRepository();
    });

    test('loads the bundled catalog', () async {
      final catalog = await repository.loadCatalog();

      expect(catalog.categories, hasLength(7));
      expect(catalog.products, hasLength(29));
      expect(
        catalog.categories.map((category) => category.name),
        containsAll(<String>[
          'Gaming',
          'Keyboards',
          'Mice',
          'Audio',
          'Mousepads',
          'Accessories',
          'Streaming',
        ]),
      );
    });

    test('uses unique ids and a category for every product', () async {
      final catalog = await repository.loadCatalog();

      final ids = catalog.products.map((product) => product.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(
        catalog.products.every((product) => product.categoryIds.isNotEmpty),
        isTrue,
      );
      final knownCategories = catalog.categories
          .map((category) => category.id)
          .toSet();
      expect(
        catalog.products.every(
          (product) => product.categoryIds.every(knownCategories.contains),
        ),
        isTrue,
      );
    });

    test('exposes only active products for browsing', () async {
      final catalog = await repository.loadCatalog();

      expect(catalog.products.every((product) => product.isActive), isTrue);
      expect(catalog.featured, isNotEmpty);
      expect(catalog.featured.every((product) => product.isFeatured), isTrue);
    });

    test('does not ship unverified review data', () async {
      final catalog = await repository.loadCatalog();

      expect(
        catalog.products.every((product) => product.reviewCount == 0),
        isTrue,
      );
      expect(catalog.products.every((product) => product.rating == 0), isTrue);
    });

    test('finds products by id and filters by category', () async {
      final catalog = await repository.loadCatalog();

      final keyboard = catalog.byId('aula-f75');
      expect(keyboard, isNotNull);
      expect(keyboard!.name, 'AULA F75');
      expect(keyboard.lowestPriceCents, 259500);
      expect(keyboard.inStock, isTrue);

      final audio = catalog.byCategory('audio');
      expect(audio, isNotEmpty);
      expect(
        audio.every((product) => product.categoryIds.contains('audio')),
        isTrue,
      );
    });

    test('caches the parsed catalog between calls', () async {
      final first = await repository.loadCatalog();
      final second = await repository.loadCatalog();

      expect(identical(first, second), isTrue);
    });

    test('parses variants with stock and pricing', () async {
      final catalog = await repository.loadCatalog();
      final keyboard = catalog.byId('aula-f75')!;

      expect(keyboard.variants, hasLength(1));
      final variant = keyboard.variantById('black-gradient-grey');
      expect(variant, isNotNull);
      expect(variant!.name, 'Black / Gradient Grey');
      expect(variant.inStock, isTrue);
      expect(variant.priceCents, 259500);
    });

    test(
      'ships one verified variant per product at a positive price',
      () async {
        final catalog = await repository.loadCatalog();

        for (final product in catalog.products) {
          expect(product.variants, hasLength(1), reason: product.id);
          expect(product.variants.single.priceCents, greaterThan(0));
          expect(product.variants.single.stock, greaterThan(0));
        }
      },
    );

    test('bundles a real image for every product', () async {
      final catalog = await repository.loadCatalog();

      for (final product in catalog.products) {
        expect(product.images, hasLength(1), reason: product.id);
        final bytes = await rootBundle.load(product.images.single);
        expect(bytes.lengthInBytes, greaterThan(1024), reason: product.id);
      }
    });
  });
}
