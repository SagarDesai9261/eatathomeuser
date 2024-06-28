import 'package:intl/intl.dart';

class CouponModel {
  final int id;
  final String code;
  final int discount;
  final String discountType;
  final String description;
  final DateTime expiresAt;
  final bool enabled;
  final String createdAt;
  final String updatedAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.discount,
    required this.discountType,
    required this.description,
    required this.expiresAt,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    final expiresAt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(json['expires_at'] as String);
    return CouponModel(
      id: json['id'] as int,
      code: json['code'] as String,
      discount: json['discount'] as int,
      discountType: json['discount_type'] as String,
      description: json['description'] as String,
      expiresAt: expiresAt,
      enabled: json['enabled'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount': discount,
      'discount_type': discountType,
      'description': description,
      'expires_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(expiresAt),
      'enabled': enabled,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
