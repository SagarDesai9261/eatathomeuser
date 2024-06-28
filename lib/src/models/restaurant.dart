import '../helpers/custom_trace.dart';
import '../models/media.dart';
import 'user.dart';

class Restaurant {
   String? id;
   String? name;
   Media? image;
   String? rate;
   String? address;
   String? description;
   String? phone;
   String? mobile;
   String? information;
   double? deliveryFee;
   double? adminCommission;
   double? defaultTax;
   String? latitude;
   String? longitude;
   String? closed;
   bool? availableForDelivery;
   bool? availableForDineIn;
   double? deliveryRange;
   String? distance;
   List<User>? users;
   String? banner_image;
   Price? price;
   String? is_open;
   String? is_hrs;
   String? average_price;
   String? average_preparation_time;
   String? restaurant_distance;
   String? fssai_number;

  Restaurant();

  Restaurant.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      // Handling 'price_range' or defaulting if absent
      if (jsonMap.containsKey('price_range')) {
        price = Price.fromJson(jsonMap['price_range']);
      } else {
        price = Price(min: "0", max: "0");
      }

      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      is_open = jsonMap['is_open'] ?? '';
      image = jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty
          ? Media.fromJSON(jsonMap['media'][0])
          : Media();
      rate = jsonMap['rate'] ?? '0';
      deliveryFee = jsonMap['delivery_fee']?.toDouble() ?? 0.0;
      adminCommission = jsonMap['admin_commission']?.toDouble() ?? 0.0;
      deliveryRange = jsonMap['delivery_range']?.toDouble() ?? 0.0;
      address = jsonMap['address'] ?? '';
      description = jsonMap['description'] ?? '';
      restaurant_distance = jsonMap['restaurant_distance'] ?? '';
      average_preparation_time = jsonMap['average_preparation_time']?.toString() ?? '';
      phone = jsonMap['phone'] ?? '';
      mobile = jsonMap['mobile'] ?? '';
      fssai_number = jsonMap['fssai_number'] ?? '';
      defaultTax = jsonMap['default_tax']?.toDouble() ?? 0.0;
      information = jsonMap['information'] ?? '';
      latitude = jsonMap['latitude'] ?? '0';
      longitude = jsonMap['longitude'] ?? '0';
      closed = jsonMap['closed'] ?? '';
      is_hrs = jsonMap['is_hrs']?.toString() ?? '';
      average_price = jsonMap['average_price']?.toString() ?? '';
      banner_image = jsonMap["banners"] != null && (jsonMap["banners"] as List).isNotEmpty
          ? jsonMap["banners"][0] ?? ''
          : '';
      availableForDelivery = jsonMap['available_for_delivery'] ?? false;
      availableForDineIn = jsonMap['available_for_dinein'] ?? false;
      distance = jsonMap['distance'] ?? "0.0";
      users = jsonMap['users'] != null && (jsonMap['users'] as List).isNotEmpty
          ? List.from(jsonMap['users']).map((element) => User.fromJSON(element)).toList()
          : [];
    } catch (e) {
      print(e);
      id = '';
      name = '';
      image = Media();
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
      closed = '';
      is_hrs = '';
      average_price = '';
      banner_image = '';
      restaurant_distance = '';
      average_preparation_time = '';
      fssai_number = '';
      availableForDelivery = false;
      availableForDineIn = false;
      distance = "";
      users = [];
      price = Price(min: "0", max: "0");
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

class Price {
  final String min;
  final String max;

  Price({
    required this.min,
    required this.max,
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
    required this.success,
    required this.data,
    required this.message,
  });

  factory DeliveryKitchenListModel.fromJson(Map<String, dynamic> json) {
    List<Restaurant> restaurantList = [];
    if (json['data'] != null) {
      restaurantList = List<Map<String, dynamic>>.from(json['data'])
          .map((dataJson) => Restaurant.fromJSON(dataJson))
          .toList();
    }

    return DeliveryKitchenListModel(
      success: json['success'] ?? false,
      data: restaurantList,
      message: json['message'] ?? '',
    );
  }
}
