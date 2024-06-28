import '../helpers/custom_trace.dart';

class Payment {
  String id;
  String status;
  String method;

  Payment({
    this.id = '',
    this.status = '',
    this.method = '',
  });

  Payment.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        status = jsonMap['status'] ?? '',
        method = jsonMap['method'] ?? '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'method': method,
    };
  }

  @override
  String toString() {
    return 'Payment{id: $id, status: $status, method: $method}';
  }
}
