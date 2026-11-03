import 'package:flutter/foundation.dart';

@immutable
class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.priceCents,
    required this.stock,
    this.sku,
  });

  final String id;
  final String name;
  final String colorHex;
  final int priceCents;
  final int stock;
  final String? sku;

  bool get inStock => stock > 0;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: (json['colorHex'] ?? json['color_hex'] ?? '#3A3A3C') as String,
      priceCents: (json['priceCents'] ?? json['price_cents'] ?? 0) as int,
      stock: (json['stock'] ?? 0) as int,
      sku: json['sku'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'colorHex': colorHex,
    'priceCents': priceCents,
    'stock': stock,
    'sku': sku,
  };
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.brand,
    required this.tagline,
    required this.description,
    required this.categoryIds,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.features,
    required this.specs,
    required this.variants,
    required this.isFeatured,
    required this.isActive,
  });

  final String id;
  final String slug;
  final String name;
  final String brand;
  final String tagline;
  final String description;
  final List<String> categoryIds;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> features;
  final List<String> specs;
  final List<ProductVariant> variants;
  final bool isFeatured;
  final bool isActive;

  ProductVariant? get firstVariant => variants.isEmpty ? null : variants.first;

  int get lowestPriceCents => variants.isEmpty
      ? 0
      : variants
            .map((variant) => variant.priceCents)
            .reduce((a, b) => a < b ? a : b);

  bool get inStock => variants.any((variant) => variant.inStock);

  String get primaryImage => images.isEmpty ? '' : images.first;

  ProductVariant? variantById(String? id) {
    if (id == null) return firstVariant;
    for (final variant in variants) {
      if (variant.id == id) return variant;
    }
    return null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = <String>[
      for (final image in (json['images'] as List<dynamic>? ?? const []))
        if (image is String && image.trim().isNotEmpty) image.trim(),
    ];
    final variants = <ProductVariant>[
      for (final variant
          in (json['variants'] as List<dynamic>? ?? const <dynamic>[]))
        ProductVariant.fromJson(variant as Map<String, dynamic>),
    ];
    final categories = <String>[
      for (final id in (json['categoryIds'] as List<dynamic>? ?? const []))
        id as String,
    ];
    return Product(
      id: json['id'] as String,
      slug: (json['slug'] as String?) ?? json['id'] as String,
      name: json['name'] as String,
      brand: (json['brand'] as String?) ?? 'Epicyclic',
      tagline: (json['tagline'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      categoryIds: categories,
      rating: ((json['rating'] ?? 0) as num).toDouble(),
      reviewCount: (json['reviewCount'] ?? json['review_count'] ?? 0) as int,
      images: images,
      features: [
        for (final feature in (json['features'] as List<dynamic>? ?? const []))
          feature as String,
      ],
      specs: [
        for (final spec in (json['specs'] as List<dynamic>? ?? const []))
          spec as String,
      ],
      variants: variants,
      isFeatured: (json['isFeatured'] ?? json['is_featured'] ?? false) as bool,
      isActive: (json['isActive'] ?? json['is_active'] ?? true) as bool,
    );
  }

  factory Product.fromSupabase({
    required Map<String, dynamic> row,
    required List<Map<String, dynamic>> variantRows,
    required List<Map<String, dynamic>> imageRows,
    required List<String> categoryIds,
  }) {
    final sortedImages = [...imageRows]
      ..sort(
        (a, b) => ((a['sort_order'] ?? 0) as num).compareTo(
          (b['sort_order'] ?? 0) as num,
        ),
      );
    final images = sortedImages
        .map((image) => (image['url'] ?? image['storage_path'] ?? '') as String)
        .where((image) => image.trim().isNotEmpty)
        .toList();

    return Product(
      id: row['id'] as String,
      slug: (row['slug'] as String?) ?? row['id'] as String,
      name: row['name'] as String,
      brand: (row['brand'] as String?) ?? 'Epicyclic',
      tagline: (row['tagline'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      categoryIds: categoryIds,
      rating: ((row['rating'] ?? 0) as num).toDouble(),
      reviewCount: (row['review_count'] ?? 0) as int,
      images: images,
      features: [
        for (final feature in (row['features'] as List<dynamic>? ?? const []))
          feature as String,
      ],
      specs: [
        for (final spec in (row['specs'] as List<dynamic>? ?? const []))
          spec as String,
      ],
      variants: variantRows
          .map(
            (variant) => ProductVariant(
              id: variant['id'] as String,
              name: (variant['name'] as String?) ?? 'Default',
              colorHex: (variant['color_hex'] as String?) ?? '#3A3A3C',
              priceCents: (variant['price_cents'] as int?) ?? 0,
              stock: (variant['stock'] as int?) ?? 0,
              sku: variant['sku'] as String?,
            ),
          )
          .toList(),
      isFeatured: (row['is_featured'] as bool?) ?? false,
      isActive: (row['is_active'] as bool?) ?? true,
    );
  }
}
