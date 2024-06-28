import '../helpers/custom_trace.dart';

class Faq {
  String id;
  String question;
  String answer;

  Faq({
    this.id = '',
    this.question = '',
    this.answer = '',
  });

  Faq.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        question = jsonMap['question'] ?? '',
        answer = jsonMap['answer'] ?? '';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'question': question,
      'answer': answer,
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
    return other is Faq && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
