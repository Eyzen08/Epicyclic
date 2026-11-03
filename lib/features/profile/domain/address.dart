import 'package:flutter/foundation.dart';

@immutable
class Address {
  const Address({
    required this.id,
    required this.fullName,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
    this.isDefault = false,
  });

  final String id;
  final String fullName;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;
  final bool isDefault;

  String get singleLine {
    final parts = [
      line1,
      if (line2 != null && line2!.trim().isNotEmpty) line2!,
      city,
      '$state $postalCode',
      country,
    ];
    return parts.join(', ');
  }

  String get multiLine {
    final parts = [
      fullName,
      line1,
      if (line2 != null && line2!.trim().isNotEmpty) line2!,
      '$city, $state $postalCode',
      country,
    ];
    return parts.join('\n');
  }

  Address copyWith({
    String? fullName,
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      fullName: fullName ?? this.fullName,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'fullName': fullName,
    'line1': line1,
    'line2': line2,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
    'phone': phone,
    'isDefault': isDefault,
  };

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      fullName: (json['fullName'] as String?) ?? '',
      line1: (json['line1'] as String?) ?? '',
      line2: json['line2'] as String?,
      city: (json['city'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      postalCode: (json['postalCode'] as String?) ?? '',
      country: (json['country'] as String?) ?? 'Philippines',
      phone: (json['phone'] as String?) ?? '',
      isDefault: (json['isDefault'] as bool?) ?? false,
    );
  }
}
