import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class Cart {
  String id;
  Food food;
  double quantity;
  List<Extra> extras;
  String userId;
  String Couponid;
  String average_preparation_time;
  String is_hrs;


  Cart();

  Cart.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      print("cart model calling");
      id = jsonMap['id'].toString();
      Couponid = jsonMap['coupon_id'].toString();
      average_preparation_time = jsonMap['average_preparation_time'].toString();
      is_hrs = jsonMap['is_hrs'].toString();
      quantity = jsonMap['quantity'] != null ? jsonMap['quantity'].toDouble() : 0.0;
      food = jsonMap['food'] != null ? Food.fromJSON(jsonMap['food']) : Food.fromJSON({});

      extras = jsonMap['extras'] != null ? List.from(jsonMap['extras']).map((element) => Extra.fromJSON(element)).toList() : [];
    } catch (e) {
      print("error in cart model");
      id = '';
      quantity = 0.0;
      food = Food.fromJSON({});
      extras = [];
      // print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["quantity"] = quantity;
    map["food_id"] = food.id;
    map["user_id"] = userId;
    map["coupon_id"] = Couponid;
    map["extras"] = extras.map((element) => element.id).toList();
    return map;
  }

  double getFoodPrice() {
    double result = food.price;
    if (extras.isNotEmpty) {
      extras.forEach((Extra extra) {
        result += extra.price != null ? extra.price : 0;
      });
    }
    return result;
  }

  bool isSame(Cart cart) {
    bool _same = true;
    _same &= this.food == cart.food;
    _same &= this.extras.length == cart.extras.length;
    if (_same) {
      this.extras.forEach((Extra _extra) {
        _same &= cart.extras.contains(_extra);
      });
    }
    return _same;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }

  @override
  int get hashCode => this.id.hashCode;
}
