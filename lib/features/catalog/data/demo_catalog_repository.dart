import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/catalog_data.dart';
import '../domain/category.dart';
import '../domain/product.dart';
import 'catalog_repository.dart';

class DemoCatalogRepository implements CatalogRepository {
  DemoCatalogRepository({this.bundle});

  final AssetBundle? bundle;
  CatalogData? _cache;

  @override
  Future<CatalogData> loadCatalog() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await (bundle ?? rootBundle).loadString(
      'assets/data/catalog.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final categories = [
      for (final item in (json['categories'] as List<dynamic>))
        Category.fromJson(item as Map<String, dynamic>),
    ];
    final products = [
      for (final item in (json['products'] as List<dynamic>))
        Product.fromJson(item as Map<String, dynamic>),
    ];
    final data = CatalogData(categories: categories, products: products);
    _cache = data;
    return data;
  }
}
