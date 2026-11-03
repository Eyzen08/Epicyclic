import 'package:flutter/foundation.dart';

@immutable
class Category {
  const Category({required this.id, required this.name, required this.icon});

  final String id;
  final String name;
  final String icon;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: (json['icon'] as String?) ?? 'gaming',
    );
  }
}
