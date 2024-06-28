import '../helpers/custom_trace.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/user.dart';

class Review {
  late String id;
  late String review;
  late String rate;
  late User user;

  Review();

  Review.init(this.rate);

  Review.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id']?.toString() ?? '';
      review = jsonMap['review'] ?? '';
      rate = jsonMap['rate']?.toString() ?? '0';
      user = jsonMap['user'] != null ? User.fromJSON(jsonMap['user']) : User.fromJSON({});
    } catch (e) {
      id = '';
      review = '';
      rate = '0';
      user = User.fromJSON({});
      // print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "review": review,
      "rate": rate,
      "user_id": user.id,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> ofRestaurantToMap(Restaurant restaurant) {
    var map = toMap();
    map["restaurant_id"] = restaurant.id;
    return map;
  }

  Map<String, dynamic> ofFoodToMap(Food food) {
    var map = toMap();
    map["food_id"] = food.id;
    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Review) return false;
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
