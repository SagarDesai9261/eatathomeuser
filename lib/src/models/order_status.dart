import '../helpers/custom_trace.dart';

class OrderStatus {
  String id;
  String status;
  String priority;

  OrderStatus({
    this.id = '',
    this.status = '',
    this.priority = '',
  });

  OrderStatus.fromJson(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        status = jsonMap['status'] ?? '',
        priority = jsonMap['priority'] ?? '';

  @override
  String toString() {
    return 'OrderStatus{id: $id, status: $status, priority: $priority}';
  }
}
