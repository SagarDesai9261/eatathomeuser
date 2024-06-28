import 'discountable.dart';

class Coupon {
  String id;
  String code;
  double discount;
  String discountType;
  List<Discountable> discountables;
  String discountableId;
  bool enabled;
  bool valid;

  Coupon({
    this.id = '',
    this.code = '',
    this.discount = 0.0,
    this.discountType = '',
    this.discountables = const [],
    this.discountableId = '',
    this.enabled = false,
    this.valid = false,
  });

  Coupon.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        code = jsonMap['code']?.toString() ?? '',
        discount = jsonMap['discount'] != null ? jsonMap['discount'].toDouble() : 0.0,
        discountType = jsonMap['discount_type']?.toString() ?? '',
        discountables = jsonMap['discountables'] != null
            ? List<Discountable>.from(jsonMap['discountables'].map((element) => Discountable.fromJSON(element)))
            : [],
        discountableId = jsonMap['discountable_id']?.toString() ?? '',
        enabled = jsonMap['enabled'] ?? false,
        valid = jsonMap['valid'] ?? false;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "code": code,
      "discount": discount,
      "discount_type": discountType,
      "discountables": discountables.map((element) => element.toMap()).toList(),
      "valid": valid,
    };
  }

  @override
  bool operator ==(dynamic other) {
    return other is Coupon && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
