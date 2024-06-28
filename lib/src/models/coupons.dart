import '../repository/settings_repository.dart' as settingRepo;

class Coupon {
  final String? id;
  final String? name;
  final String? code; // Coupon code
  final double? discount; // Discount percentage
  final double? maxDiscount; // Maximum discount amount
  final double? minOrder; // Minimum order to apply the discount
  final DateTime? validUntil;
  final String? discounttype;
  final bool? enabled;

  Coupon({
     this.id,
     this.name,
     this.code,
     this.discount,
     this.maxDiscount,
     this.minOrder,
     this.validUntil,
     this.discounttype,
     this.enabled,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    print(json['code'].runtimeType);
    print(json['discount'].runtimeType);
    print(json['max_discount'].runtimeType);
    print(json['min_order'].runtimeType);
    print(json['expires_at'].runtimeType);
    print(json['discount_type'].runtimeType);

    return Coupon(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      code: json['code'],
      discount: (json['discount'] as num).toDouble(),
      maxDiscount: (json['max_discount'] as num).toDouble(),
      minOrder: (json['min_order'] as num).toDouble(),
      validUntil: DateTime.parse(json['expires_at']),
      discounttype: json['discount_type'],
      enabled: json['enabled'],
    );
  }

  // Method to generate a custom description for the coupon
  String getCustomDescription(String discounttype) {
    String currency = settingRepo.setting.value.defaultCurrency;

    if (discounttype == "percent") {
      return "Use code '$code' and get $discount% off up to $currency$maxDiscount on orders above $currency$minOrder.";
    } else {
      return "Use code '$code' and get flat $currency$discount off on orders above $currency$minOrder.";
    }
  }
}
