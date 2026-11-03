import 'package:epicyclic/features/catalog/data/demo_catalog_repository.dart';
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

      expect(catalog.categories, hasLength(4));
      expect(catalog.products, hasLength(8));
      expect(
        catalog.categories.map((category) => category.name),
        containsAll(<String>['Gaming', 'Keyboards', 'Mice', 'Audio']),
      );
    });

    test('exposes only active products for browsing', () async {
      final catalog = await repository.loadCatalog();

      expect(catalog.products.every((product) => product.isActive), isTrue);
      expect(catalog.featured, isNotEmpty);
      expect(catalog.featured.every((product) => product.isFeatured), isTrue);
    });

    test('finds products by id and filters by category', () async {
      final catalog = await repository.loadCatalog();

      final keyboard = catalog.byId('keychron-k2-pro');
      expect(keyboard, isNotNull);
      expect(keyboard!.name, 'Keychron K2 Pro');
      expect(keyboard.lowestPriceCents, 12900);
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
      final keyboard = catalog.byId('keychron-k2-pro')!;

      expect(keyboard.variants, hasLength(4));
      final soldOut = keyboard.variantById('pink');
      expect(soldOut, isNotNull);
      expect(soldOut!.inStock, isFalse);
      expect(soldOut.priceCents, 13400);
    });
  });
}
