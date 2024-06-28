import '../helpers/custom_trace.dart';

class Discountable {
  String id;
  String? discountableType;
  String? discountableId;

  Discountable({
    this.id = '',
    this.discountableType,
    this.discountableId,
  });

  Discountable.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        discountableType = jsonMap['discountable_type'] ?? '',
        discountableId = jsonMap['discountable_id'] ?? '';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['discountable_type'] = discountableType;
    map['discountable_id'] = discountableId;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    return other is Discountable && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
