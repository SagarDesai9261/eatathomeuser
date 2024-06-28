import '../helpers/custom_trace.dart';

class Notification {
  String id;
  String type;
  Map<String, dynamic> data;
  bool read;
  DateTime? createdAt;
  String bodyMessage;

  Notification({
    this.id = '',
    this.type = '',
    this.data = const {},
    this.read = false,
    this.createdAt,
    this.bodyMessage = '',
  });

  Notification.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        bodyMessage = jsonMap['body'].toString() ?? "",
        type = jsonMap['type'] != null ? jsonMap['type'].toString() : '',
        data = jsonMap['data'] ?? {},
        read = jsonMap['read_at'] != null,
        createdAt = DateTime.tryParse(jsonMap['created_at']) ?? DateTime(0);

  Map<String, dynamic> markReadMap() {
    return {
      "id": id,
      "read_at": !read,
    };
  }
}
