import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'E';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  AppUser copyWith({String? fullName, String? phone, String? avatarUrl}) {
    return AppUser(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'email': email,
    'fullName': fullName,
    'phone': phone,
    'avatarUrl': avatarUrl,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      fullName: (json['fullName'] as String?) ?? 'Epicyclic Customer',
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
