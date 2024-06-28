import '../helpers/custom_trace.dart';
import '../models/faq.dart';

class FaqCategory {
  String id;
  String name;
  List<Faq> faqs;

  FaqCategory({
    this.id = '',
    this.name = '',
    this.faqs = const [],
  });

  FaqCategory.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name'] ?? '',
        faqs = jsonMap['faqs'] != null
            ? List.from(jsonMap['faqs']).map((element) => Faq.fromJSON(element)).toList()
            : [];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'faqs': faqs.map((faq) => faq.toMap()).toList(),
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
    return other is FaqCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
