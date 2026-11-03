import 'product.dart';
import 'category.dart';

class CatalogData {
  const CatalogData({required this.categories, required this.products});

  final List<Category> categories;
  final List<Product> products;

  List<Product> get featured =>
      products.where((product) => product.isFeatured).toList();

  Product? byId(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  List<Product> byCategory(String? categoryId) {
    if (categoryId == null) return products;
    return products
        .where((product) => product.categoryIds.contains(categoryId))
        .toList();
  }
}
