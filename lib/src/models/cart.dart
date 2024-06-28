import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class Cart {
  late String? id;
  late Food? food;
  late double? quantity;
  late List<Extra>? extras;
  late String? userId;
  late String? couponId;
  late String? averagePreparationTime;
  late String? isHrs;

  Cart({
     this.id,
     this.food,
     this.quantity,
     this.extras,
     this.userId,
     this.couponId,
     this.averagePreparationTime,
     this.isHrs,
  });

  Cart.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        couponId = jsonMap['coupon_id']?.toString() ?? '',
        averagePreparationTime = jsonMap['average_preparation_time']?.toString() ?? '',
        isHrs = jsonMap['is_hrs']?.toString() ?? '',
        quantity = jsonMap['quantity']?.toDouble() ?? 0.0,
        food = jsonMap['food'] != null ? Food.fromJSON(jsonMap['food']) : Food.fromJSON({}),
        extras = jsonMap['extras'] != null ? List.from(jsonMap['extras']).map((element) => Extra.fromJSON(element)).toList() : [],
        userId = jsonMap['user_id']?.toString() ?? '';

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "quantity": quantity,
      "food_id": food!.id,
      "user_id": userId,
      "coupon_id": couponId,
      "extras": extras!.map((element) => element.id).toList(),
    };
  }

  double getFoodPrice() {
    double result = food!.price;
    for (var extra in extras!) {
      result += extra.price;
    }
    return result;
  }

  bool isSame(Cart cart) {
    bool same = true;
    same &= food == cart.food;
    same &= extras!.length == cart.extras!.length;
    if (same) {
      for (var extra in extras!) {
        same &= cart.extras!.contains(extra);
      }
    }
    return same;
  }

  @override
  bool operator ==(dynamic other) {
    return other is Cart && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
