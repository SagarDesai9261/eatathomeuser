import 'package:flutter/foundation.dart';

import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class Favorite {
  String id;
  Food? food;
  List<Extra>? extras;
  String? userId;

  Favorite({
    this.id = '',
    this.food,
    this.extras = const [],
    this.userId,
  });

  Favorite.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        food = jsonMap['food'] != null ? Food.fromJSON(jsonMap['food']) : Food(),
        extras = jsonMap['extras'] != null
            ? List.from(jsonMap['extras']).map((element) => Extra.fromJSON(element)).toList()
            : [],
        userId = jsonMap['user_id']?.toString() ?? '';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'food_id': food!.id,
      'user_id': userId,
      'extras': extras!.map((extra) => extra.id).toList(),
    };
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    return other is Favorite &&
        other.id == id &&
        other.food == food &&
        listEquals(other.extras, extras) &&
        other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ food.hashCode ^ extras.hashCode ^ userId.hashCode;
}
