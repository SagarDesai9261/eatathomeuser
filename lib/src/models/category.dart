import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Category {
  late String id;
  late String name;
  late String start_slot;
  late String end_slot;
  late Media image;

  Category({
    required this.id,
    required this.name,
    required this.start_slot,
    required this.end_slot,
    required this.image,
  });

  Category.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        name = jsonMap['name'] ?? '',
        start_slot = jsonMap['start_slot'] ?? '',
        end_slot = jsonMap['end_slot'] ?? '',
        image = jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty
            ? Media.fromJSON(jsonMap['media'][0])
            : Media();

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "start_slot": start_slot,
      "end_slot": end_slot,
      "media": [image.toMap()],
    };
  }
}
