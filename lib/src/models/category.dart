import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Category {
  String id;
  String name;
  String start_slot;
  String end_slot;
  Media image;

  Category();

  Category.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      start_slot = jsonMap['start_slot'];
      end_slot = jsonMap['end_slot'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();

    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      // print(CustomTrace(StackTrace.current, message: e));
    }
  }
}
