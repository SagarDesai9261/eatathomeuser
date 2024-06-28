import 'package:flutter/foundation.dart';

import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Cuisine with ChangeNotifier {
  String id;
  String name;
  String description;
  Media? image;
  bool selected;

  Cuisine({
    this.id = '',
    this.name = '',
    this.description = '',
    this.image , // Assuming Media has a default constructor
    this.selected = false,
  });

  Cuisine.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        name = jsonMap['name'] ?? '',
        description = jsonMap['description'] ?? '',
        image = (jsonMap['media'] != null && jsonMap['media'].isNotEmpty)
            ? Media.fromJSON(jsonMap['media'][0])
            : Media(),
        selected = jsonMap['selected'] ?? false;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    // Add other fields if needed
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    return other is Cuisine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  void setSelected(bool value) {
    selected = value;
    notifyListeners();
  }
}
