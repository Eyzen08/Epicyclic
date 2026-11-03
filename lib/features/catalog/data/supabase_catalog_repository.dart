import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/catalog_data.dart';
import '../domain/category.dart';
import '../domain/product.dart';
import 'catalog_repository.dart';

class SupabaseCatalogRepository implements CatalogRepository {
  SupabaseCatalogRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<CatalogData> loadCatalog() async {
    final categoryRows = await _client
        .from('categories')
        .select()
        .order('sort_order', ascending: true);
    final productRows = await _client
        .from('products')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: true);
    final variantRows = await _client.from('product_variants').select();
    final imageRows = await _client.from('product_images').select();
    final linkRows = await _client.from('product_categories').select();

    final categories = <Category>[
      for (final row in categoryRows)
        Category(
          id: row['id'] as String,
          name: row['name'] as String,
          icon: (row['icon'] as String?) ?? 'gaming',
        ),
    ];

    final variantsByProduct = <String, List<Map<String, dynamic>>>{};
    for (final row in variantRows) {
      variantsByProduct
          .putIfAbsent(row['product_id'] as String, () => [])
          .add(row);
    }

    final imagesByProduct = <String, List<Map<String, dynamic>>>{};
    for (final row in imageRows) {
      imagesByProduct
          .putIfAbsent(row['product_id'] as String, () => [])
          .add(row);
    }

    final categoriesByProduct = <String, List<String>>{};
    for (final row in linkRows) {
      categoriesByProduct
          .putIfAbsent(row['product_id'] as String, () => [])
          .add(row['category_id'] as String);
    }

    final products = <Product>[
      for (final row in productRows)
        Product.fromSupabase(
          row: row,
          variantRows: variantsByProduct[row['id']] ?? const [],
          imageRows: imagesByProduct[row['id']] ?? const [],
          categoryIds: categoriesByProduct[row['id']] ?? const [],
        ),
    ];

    return CatalogData(categories: categories, products: products);
  }
}
