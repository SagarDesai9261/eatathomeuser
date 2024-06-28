import '../helpers/custom_trace.dart';
import '../models/media.dart';
import '../models/restaurant.dart';
import 'food.dart';

class Slide {
  late String id;
  late int order;
  late String text;
  late String button;
  late String textPosition;
  late String textColor;
  late String buttonColor;
  late String backgroundColor;
  late String indicatorColor;
  late Media image;
  late String imageFit;
  late Food food;
  late Restaurant restaurant;
  late bool enabled;

  Slide();

  Slide.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id']?.toString() ?? '';
      order = jsonMap['order'] ?? 0;
      text = jsonMap['text']?.toString() ?? '';
      button = jsonMap['button']?.toString() ?? '';
      textPosition = jsonMap['text_position']?.toString() ?? '';
      textColor = jsonMap['text_color']?.toString() ?? '';
      buttonColor = jsonMap['button_color']?.toString() ?? '';
      backgroundColor = jsonMap['background_color']?.toString() ?? '';
      indicatorColor = jsonMap['indicator_color']?.toString() ?? '';
      imageFit = jsonMap['image_fit']?.toString() ?? 'cover';
      enabled = jsonMap['enabled'] ?? false;
      restaurant = jsonMap['restaurant'] != null ? Restaurant.fromJSON(jsonMap['restaurant']) : Restaurant();
      food = jsonMap['food'] != null ? Food.fromJSON(jsonMap['food']) : Food();
      image = (jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty) ? Media.fromJSON(jsonMap['media'][0]) : Media();
    } catch (e) {
      id = '';
      order = 0;
      text = '';
      button = '';
      textPosition = '';
      textColor = '';
      buttonColor = '';
      backgroundColor = '';
      indicatorColor = '';
      imageFit = 'cover';
      enabled = false;
      restaurant = Restaurant();
      food = Food();
      image = Media();
      // print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "text": text,
      "order": order,
      "button": button,
      "text_position": textPosition,
      "text_color": textColor,
      "button_color": buttonColor,
      "background_color": backgroundColor,
      "indicator_color": indicatorColor,
      "image_fit": imageFit,
      "enabled": enabled,
      "restaurant": restaurant.toMap(),
      "food": food.toMap(),
      "media": [image.toMap()],
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Slide) return false;
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
