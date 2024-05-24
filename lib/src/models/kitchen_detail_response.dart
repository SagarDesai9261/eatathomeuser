import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';

class KitchenDetailResponse {
  bool success;
  final Map<String, FoodItem>  data;
  String message;

  KitchenDetailResponse({ this.success,  this.data,  this.message});

  factory KitchenDetailResponse.fromJson(Map<String, dynamic> json) {
   // var data = json['data'] as List;
    //List<FoodItem> foodItems = data.map((item) => FoodItem.fromJson(item)).toList();
    int count=0;
    Map<String, FoodItem> foodItems = {};
    if (json['data'] != null) {
      json['data'].forEach((key, value) {
        // print("data{$key->${value}\n");
        count = count +1;
        foodItems[key] = FoodItem.fromJson(value);
      });
    }
    // print(count);
    return KitchenDetailResponse(
      success: json['success'],
      data: foodItems,
      message: json['message'],
    );
  }
}

class FoodItem {
  int id;
  String type;
  String dates;
  String name;
  double  price;
  double discountPrice;
  String description;
  String standards;
  String ingredients;
  String is_signature_food;
  int packageItemsCount;
  List<SeparateItem> separateItems;
  Restaurant restaurant;
  final List<ComboMedia> comboMedia;
  TimeSlots timeSlots;

  FoodItem({
     this.id,
     this.type,
     this.dates,
     this.name,
     this.price,
     this.is_signature_food,

    this.discountPrice,
     this.description,
     this.standards,
     this.ingredients,
     this.packageItemsCount,
    this.separateItems,
    this.restaurant,
     this.comboMedia,
    this.timeSlots
  });
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    List<SeparateItem> separateItems = json['separate_item'] != null
        ? List<SeparateItem>.from(json['separate_item'].map((item) => SeparateItem.fromJson(item)))
        : null;
    Restaurant restaurant = json['restaurant'] != null ? Restaurant.fromJSON(json['restaurant']) : null;
    final List<dynamic> mediaJsonList = json['media'] ?? [];
    List<ComboMedia> mediaList = mediaJsonList.map((mediaJson) => ComboMedia.fromJson(mediaJson)).toList();
    return FoodItem(
      id: json['id'],
      type: json['type'],
      dates: json['dates'],
     // foodType: List<String>.from(json['food_type']),
      name: json['name'],
      price: json['price'],
      is_signature_food: json['is_signature_food'],
      discountPrice: double.parse( json['discount_price']) ?? 0.0,
      description: json['description'],
      standards: json['standards'] ?? "",
      ingredients: json['ingredients'],
      packageItemsCount: json['package_items_count'],
      // Initialize other properties here
      separateItems: separateItems,
      restaurant: restaurant,
      comboMedia: mediaList,
      timeSlots:TimeSlots(),
    );
  }
}


class ComboMedia {
  final int id;
  final String url;

  ComboMedia({
     this.id,
     this.url,
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
     this.name,
     this.image,
     this.price,
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

  // Add other properties here based on the JSON response

  KitchenDetails({
    this.id,
    this.name,
    this.deliveryFee,
    this.address,
    this.phone,
    this.rate,
    this.media,
    // Initialize other properties here
  });

  factory KitchenDetails.fromJson(Map<String, dynamic> json) {
    List<RestaurantMedia> media = json['media'] != null
        ? List<RestaurantMedia>.from(
        json['media'].map((item) => RestaurantMedia.fromJson(item)))
        : [];
    return KitchenDetails(
      id: json['id'],
      name: json['name'],
      deliveryFee: json['delivery_fee'],
      address: json['address'],
      phone: json['phone'],
      rate: json['rate'],
      media: media,
      // Parse other properties here
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
  // Add other properties as needed

  RestaurantMedia({
   this.id,
   this.name,
   this.fileName,
   this.mimeType,
   this.disk,
   this.size,
    this.url
  // Initialize other properties here
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
  // Parse other properties as needed
  );
  }
  }
