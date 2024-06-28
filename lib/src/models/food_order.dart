import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class FoodOrder {
  String id;
  String numberOfPersons;
  double price;
  double quantity;
  List<Extra>? extras;
  Food? food;
  DateTime? dateTime;

  FoodOrder({
    this.id = '',
    this.numberOfPersons = '',
    this.price = 0.0,
    this.quantity = 0.0,
     this.food,
     this.dateTime,
    this.extras = const [],
  });

  FoodOrder.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        numberOfPersons = jsonMap['number_of_persons'].toString(),
        price = jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0,
        quantity = jsonMap['quantity'] != null ? jsonMap['quantity'].toDouble() : 0.0,
        food = jsonMap['food'] != null ? Food.fromJSON(jsonMap['food']) : Food.fromJSON({}),
        dateTime = DateTime.tryParse(jsonMap['order_date']) ?? DateTime(0),
        extras = jsonMap['extras'] != null
            ? List.from(jsonMap['extras']).map((element) => Extra.fromJSON(element)).toList()
            : [];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'number_of_persons': numberOfPersons,
      'price': price,
      'quantity': quantity,
      'food_id': food!.id,
      'extras': extras!.map((element) => element.id).toList(),
    };
    return map;
  }
}
