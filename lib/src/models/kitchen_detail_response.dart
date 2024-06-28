
import 'restaurant.dart';
import 'food.dart';


class KitchenDetailResponse {
  bool success;
  final Map<String, FoodItem> data;
  String message;

  KitchenDetailResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory KitchenDetailResponse.fromJson(Map<String, dynamic> json) {
    Map<String, FoodItem> foodItems = {};
    if (json['data'] != null) {
      json['data'].forEach((key, value) {
        foodItems[key] = FoodItem.fromJson(value);
      });
    }
    return KitchenDetailResponse(
      success: json['success'] ?? false,
      data: foodItems,
      message: json['message'] ?? '',
    );
  }
}

class FoodItem {
  int id;
  String type;
  String dates;
  String name;
  double price;
  double discountPrice;
  String description;
  String standards;
  String ingredients;
  String? is_signature_food; // Changed to nullable
  int packageItemsCount;
  List<SeparateItem>? separateItems; // Changed to nullable
  Restaurant? restaurant; // Changed to nullable
  final List<ComboMedia> comboMedia;
  TimeSlots timeSlots;

  FoodItem({
    required this.id,
    required this.type,
    required this.dates,
    required this.name,
    required this.price,
    required this.comboMedia,
    required this.timeSlots,
    this.is_signature_food,
    this.discountPrice = 0.0,
    this.description = '',
    this.standards = '',
    this.ingredients = '',
    this.packageItemsCount = 0,
    this.separateItems,
    this.restaurant,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    List<SeparateItem>? separateItems = json['separate_item'] != null
        ? List<SeparateItem>.from(json['separate_item'].map((item) => SeparateItem.fromJson(item)))
        : null;
    Restaurant? restaurant =
    json['restaurant'] != null ? Restaurant.fromJSON(json['restaurant']) : null;
    final List<dynamic> mediaJsonList = json['media'] ?? [];
    List<ComboMedia> mediaList = mediaJsonList.map((mediaJson) => ComboMedia.fromJson(mediaJson)).toList();
    return FoodItem(
      id: json['id'],
      type: json['type']??"",
      dates: json['dates']??"",
      name: json['name']??"",
      price: json['price'].toDouble(),
      is_signature_food: json['is_signature_food']??"",
      discountPrice: json['discount_price'] != null ? double.parse(json['discount_price'].toString()) : 0.0,
      description: json['description']??"",
      standards: json['standards']??"",
      ingredients: json['ingredients']??"",
      packageItemsCount: json['package_items_count']??"",
      separateItems: separateItems,
      restaurant: restaurant,
      comboMedia: mediaList,
      timeSlots: TimeSlots(), // Replace with appropriate initialization
    );
  }
}

class ComboMedia {
  final int id;
  final String url;

  ComboMedia({
    required this.id,
    required this.url,
  });

  factory ComboMedia.fromJson(Map<String, dynamic> json) {
    return ComboMedia(
      id: json['id'],
      url: json['url'],
    );
  }
}

class SeparateItem {
  String name;
  String image;
  int price;

  SeparateItem({
    required this.name,
    required this.image,
    required this.price,
  });

  factory SeparateItem.fromJson(Map<String, dynamic> json) {
    return SeparateItem(
      name: json['name'],
      image: json['image'],
      price: json['price'],
    );
  }
}

class KitchenDetails {
  int id;
  String name;
  double deliveryFee;
  String address;
  String phone;
  String rate;
  List<RestaurantMedia> media;

  KitchenDetails({
    required this.id,
    required this.name,
    required this.deliveryFee,
    required this.address,
    required this.phone,
    required this.rate,
    required this.media,
  });

  factory KitchenDetails.fromJson(Map<String, dynamic> json) {
    List<RestaurantMedia> media = json['media'] != null
        ? List<RestaurantMedia>.from(json['media'].map((item) => RestaurantMedia.fromJson(item)))
        : [];
    return KitchenDetails(
      id: json['id'],
      name: json['name'],
      deliveryFee: json['delivery_fee'].toDouble(),
      address: json['address'],
      phone: json['phone'],
      rate: json['rate'].toString(),
      media: media,
    );
  }
}

class RestaurantMedia {
  int id;
  String name;
  String fileName;
  String mimeType;
  String disk;
  String size;
  String url;

  RestaurantMedia({
    required this.id,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.disk,
    required this.size,
    required this.url,
  });

  factory RestaurantMedia.fromJson(Map<String, dynamic> json) {
    return RestaurantMedia(
      id: json['id'],
      name: json['name'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      disk: json['disk'],
      size: json['size'],
      url: json['url'],
    );
  }
}
