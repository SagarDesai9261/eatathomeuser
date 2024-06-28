import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Gallery {
  String id;
  Media image;
  String description;

  Gallery({
    this.id = '',
    required this.image,
    this.description = '',
  });

  Gallery.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        image = jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty
            ? Media.fromJSON(jsonMap['media'][0])
            : Media(),
        description = jsonMap['description'] ?? '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'media': image.toMap(),
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Gallery{id: $id, image: $image, description: $description}';
  }

  @override
  bool operator ==(dynamic other) {
    if (other is Gallery) {
      return other.id == this.id &&
          other.image == this.image &&
          other.description == this.description;
    }
    return false;
  }

  @override
  int get hashCode => id.hashCode ^ image.hashCode ^ description.hashCode;
}
