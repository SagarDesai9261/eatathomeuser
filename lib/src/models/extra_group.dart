import '../helpers/custom_trace.dart';

class ExtraGroup {
  String id;
  String name;

  ExtraGroup({
    this.id = '',
    this.name = '',
  });

  ExtraGroup.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name'] ?? '';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
    };
    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    return other is ExtraGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
