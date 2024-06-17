import '../helpers/custom_trace.dart';
import '../models/media.dart';
import 'user.dart';

class Restaurant {
  String id;
  String name;
  Media image;
  String rate;
  String address;
  String description;
  String phone;
  String mobile;
  String information;
  double deliveryFee;
  double adminCommission;
  double defaultTax;
  String latitude;
  String longitude;
  String closed;
  bool availableForDelivery;
  bool availableForDineIn;
  double deliveryRange;
  double distance;
  List<User> users;
  String banner_image;
  Price price;
  String is_open;
  String is_hrs;
  String average_price;
  String average_preparation_time;
  String restaurant_distance;
  Restaurant();

  Restaurant.fromJSON(Map<String, dynamic> jsonMap) {
    try {

     // print("Price_range is ------------- ${jsonMap.containsKey('price_range')}");
      // Check if 'price_range' is present in the JSON response
      if (jsonMap.containsKey('price_range')) {
      //  // print("price_range calll");
        price = Price.fromJson(jsonMap['price_range']);
        // print(price.min);
      } else {
        // If 'price_range' is not present, set a default Price
        price = Price(min: "0", max: "0");
      }
      print(jsonMap['id']);
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      is_open = jsonMap['is_open'] ??"";
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      rate = jsonMap['rate'] ?? '0';
      deliveryFee = jsonMap['delivery_fee'] != null ? jsonMap['delivery_fee'].toDouble() : 0.0;
      adminCommission = jsonMap['admin_commission'] != null ? jsonMap['admin_commission'].toDouble() : 0.0;
      deliveryRange = jsonMap['delivery_range'] != null ? jsonMap['delivery_range'].toDouble() : 0.0;
      address = jsonMap['address'];
      description = jsonMap['description'];
      restaurant_distance = jsonMap['restaurant_distance'] ??"";
      average_preparation_time = jsonMap['average_preparation_time'].toString()??"";
      phone = jsonMap['phone'];
      mobile = jsonMap['mobile'];
      defaultTax = jsonMap['default_tax'] != null ? jsonMap['default_tax'].toDouble() : 0.0;
      information = jsonMap['information'];
      latitude = jsonMap['latitude'];
      longitude = jsonMap['longitude'];
      closed = jsonMap['closed'] ?? "";
      is_hrs = jsonMap['is_hrs'].toString() ?? "";
      average_price = jsonMap['average_price'].toString() ?? "";
      banner_image = jsonMap["banners"][0] ??"";
      //price = Price.fromJson(jsonMap['price_range']) ?? Price(min:"0",max: "0");
      availableForDelivery = jsonMap['available_for_delivery'] ?? false;
      availableForDineIn = jsonMap['available_for_dinein'] ?? false;
      distance = jsonMap['distance'] != null ? double.parse(jsonMap['distance'].toString()) : 0.0;
      users = jsonMap['users'] != null && (jsonMap['users'] as List).length > 0
          ? List.from(jsonMap['users']).map((element) => User.fromJSON(element)).toSet().toList()
          : [];
    } catch (e) {
      print(e);
      id = '';
      name = '';
      image = new Media();
      rate = '0';
      deliveryFee = 0.0;
      adminCommission = 0.0;
      deliveryRange = 0.0;
      address = '';
      description = '';
      phone = '';
      mobile = '';
      defaultTax = 0.0;
      information = '';
      latitude = '0';
      longitude = '0';
      closed = "";
      availableForDelivery = false;
      availableForDineIn = false;
      distance = 0.0;
      users = [];
      price = Price(max: "0",min: "0");
      // print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_fee': deliveryFee,
      'distance': distance,
    };
  }
}

class Price{
  final String min;
  final String max;
  Price({
    this.min,
    this.max

  });
  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      min: json['min'].toString(),
      max: json['max'].toString(),
    );
  }
}
class DeliveryKitchenListModel {
  final bool success;
  final List<Restaurant> data;
  final String message;

  DeliveryKitchenListModel({
     this.success,
     this.data,
     this.message,
  });

  factory DeliveryKitchenListModel.fromJson(Map<String, dynamic> json) {
    // Data list
    final dataList = List<Map<String, dynamic>>.from(json['data']);
    final restaurantList = dataList.map((dataJson) => Restaurant.fromJSON(dataJson)).toList();

    return DeliveryKitchenListModel(
      success: json['success'],
      data: restaurantList,
      message: json['message'],
    );
  }
}
