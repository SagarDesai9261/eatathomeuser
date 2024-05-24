import '../helpers/custom_trace.dart';
import '../models/address.dart';
import '../models/food_order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/user.dart';

class Order {
  String id;
  List<FoodOrder> foodOrders;
  OrderStatus orderStatus;
  double tax;
  double deliveryFee;
  String hint;
  int delivery_dinein;
  bool active;
  DateTime dateTime;
  User user;
  Payment payment;
  Address deliveryAddress;
  String tracking_id;
  String tracking_order_id;
  String tracking_url;
  String driver_details;
  String coupon_code;
  String coupon_amount;
  String orderTrack; // New variable for order track
  String res_latitude;
  String res_longitude;

  Order();

  Order.fromJSON(Map<String, dynamic> jsonMap) {
    //try {
      print(jsonMap['latitude']);
      id = jsonMap['id'].toString();
      tax = jsonMap['tax'] != null ? jsonMap['tax'].toDouble() : 0.0;
      deliveryFee = jsonMap['delivery_fee'] != null ? jsonMap['delivery_fee'].toDouble() : 0.0;
      hint = jsonMap['hint'] != null ? jsonMap['hint'].toString() : '';
      delivery_dinein = jsonMap['delivery_dinein'] != null ? jsonMap['delivery_dinein'].toInt() : 0;
      tracking_id = jsonMap['tracking_id'].toString();
      tracking_order_id = jsonMap['tracking_order_id'].toString();
      tracking_url = jsonMap['tracking_url'].toString();
      driver_details = jsonMap['driver_details'].toString();

      orderTrack = jsonMap['order_status_track'] != null ? jsonMap['order_status_track'] : ''; // Parse order status track
      active = jsonMap['active'] ?? false;
      orderStatus = jsonMap['order_status'] != null ? OrderStatus.fromJSON(jsonMap['order_status']) : OrderStatus.fromJSON({});
      dateTime = DateTime.parse(jsonMap['updated_at']);
      user = jsonMap['user'] != null ? User.fromJSON(jsonMap['user']) : User.fromJSON({});
      deliveryAddress = jsonMap['delivery_address'] != null ? Address.fromJSON(jsonMap['delivery_address']) : Address.fromJSON({});
      payment = jsonMap['payment'] != null ? Payment.fromJSON(jsonMap['payment']) : Payment.fromJSON({});
      foodOrders = jsonMap['food_orders'] != null ? List.from(jsonMap['food_orders']).map((element) => FoodOrder.fromJSON(element)).toList() : [];
      res_latitude = jsonMap['latitude'];
      coupon_code = jsonMap['coupon_code'];
      coupon_amount = jsonMap['coupon_amount'];
      res_longitude = jsonMap['longitude'];
    // } catch (e) {
    //   id = '';
    //   tax = 0.0;
    //   deliveryFee = 0.0;
    //   hint = '';
    //   tracking_url = "";
    //   tracking_order_id = "";
    //   tracking_id = "";
    //   delivery_dinein = 1;
    //   active = false;
    //   orderTrack = '';
    //   orderStatus = OrderStatus.fromJSON({});
    //   dateTime = DateTime(0);
    //   user = User.fromJSON({});
    //   payment = Payment.fromJSON({});
    //   deliveryAddress = Address.fromJSON({});
    //   foodOrders = [];
    //   driver_details = "";
    // }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["user_id"] = user?.id;
    map["order_status_id"] = orderStatus?.id;
    map["tax"] = tax;
    map["tracking_id"] = tracking_id;
    map["tracking_order_id"] = tracking_order_id;
    map["tracking_url"] = tracking_url;
    map['hint'] = hint;
    map['delivery_dinein'] = delivery_dinein;
    map["delivery_fee"] = deliveryFee;
    map["foods"] = foodOrders?.map((element) => element.toMap())?.toList();
    map["payment"] = payment?.toMap();
    map["driver_details"] = driver_details;
    map["order_status_track"] = orderTrack; // Include order status track
    if (!deliveryAddress.isUnknown()) {
      map["delivery_address_id"] = deliveryAddress?.id;
    }
    return map;
  }

  Map cancelMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    if (orderStatus?.id != null && orderStatus?.id == '1') map["active"] = false;
    return map;
  }

  bool canCancelOrder() {
    return this.active == true && this.orderStatus.id == '1';
  }
}

