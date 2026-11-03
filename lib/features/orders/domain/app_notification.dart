import 'package:flutter/foundation.dart';

enum AppNotificationType { order, welcome, promo, account }

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    this.read = false,
    this.orderId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final AppNotificationType type;
  final bool read;
  final String? orderId;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    title: title,
    body: body,
    createdAt: createdAt,
    type: type,
    read: read ?? this.read,
    orderId: orderId,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'type': type.name,
    'read': read,
    'orderId': orderId,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      type: AppNotificationType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AppNotificationType.account,
      ),
      read: (json['read'] as bool?) ?? false,
      orderId: json['orderId'] as String?,
    );
  }
}
