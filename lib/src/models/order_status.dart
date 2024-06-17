import '../helpers/custom_trace.dart';

class OrderStatus {
  String id;
  String status;
  String priority;

  OrderStatus();

  OrderStatus.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      status = jsonMap['status'] != null ? jsonMap['status'] : '';
      priority = jsonMap['priority'] != null ? jsonMap['priority'] : '';
    } catch (e) {
      id = '';
      status = '';
      // print(CustomTrace(StackTrace.current, message: e));
    }
  }
}
