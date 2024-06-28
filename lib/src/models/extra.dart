import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Extra {
  String id;
  String extraGroupId;
  String name;
  double price;
  Media? image;
  String description;
  bool checked;

  Extra({
    this.id = '',
    this.extraGroupId = '0',
    this.name = '',
    this.price = 0.0,
    this.description = '',
    this.checked = false,
    this.image ,
  });

  Extra.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        extraGroupId = jsonMap['extra_group_id']?.toString() ?? '0',
        name = jsonMap['name'].toString(),
        price = jsonMap['price']?.toDouble() ?? 0.0,
        description = jsonMap['description'] ?? '',
        checked = false,
        image = jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty
            ? Media.fromJSON(jsonMap['media'][0])
            : Media();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'extra_group_id': extraGroupId,
      'name': name,
      'price': price,
      'description': description,
    };
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    return other is Extra && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
