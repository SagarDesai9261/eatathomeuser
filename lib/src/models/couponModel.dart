import 'package:intl/intl.dart';

class CouponModel {
  final int id;
  final String code;
  final int discount;
  final String discountType;
  final String description;
  final DateTime  expiresAt;
  final bool enabled;
  final String createdAt;
  final String updatedAt;

  CouponModel({
     this.id,
     this.code,
     this.discount,
     this.discountType,
     this.description,
     this.expiresAt,
     this.enabled,
     this.createdAt,
     this.updatedAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    final expiresAt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(json['expires_at']);
    return CouponModel(
      id: json['id'],
      code: json['code'],
      discount: json['discount'],
      discountType: json['discount_type'],
      description: json['description'],
      expiresAt: expiresAt,
      enabled: json['enabled'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}