/*class Trending {
  final bool success;
  final List<FoodItem> data;
  final String message;

  Trending({
     this.success,
     this.data,
     this.message,
  });

  factory Trending.fromJson(Map<String, dynamic> json) {
    return Trending(
      success: json['success'],
      data: List<FoodItem>.from(json['data'].map((item) => FoodItem.fromJson(item))),
      message: json['message'],
    );
  }
}

class FoodItem {
  final int id;
  final String name;
  final String price;
  final String description;
  final List<String> foodType;
  final Restaurant restaurant;
  final List<Media> media;

  FoodItem({
     this.id,
     this.name,
     this.price,
     this.description,
     this.foodType,
     this.restaurant,
     this.media,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: int.parse(json['id']),
      name: json['name'],
      price: json['price'],
      description: json['description'],
      foodType: List<String>.from(json['food_type'].map((type) => type.toString())),
      restaurant: Restaurant.fromJson(json['restaurant']),
      media: List<Media>.from(json['media'].map((item) => Media.fromJson(item))),
    );
  }
}

class Restaurant {
  final int id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String mobile;
  final String slots;
  final int rate;
  final List<Media> media;

  Restaurant({
     this.id,
     this.name,
     this.description,
     this.address,
     this.phone,
     this.mobile,
     this.slots,
     this.rate,
     this.media,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: int.parse(json['id']),
      name: json['name'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      mobile: json['mobile'],
      slots: json['slots'],
      rate: int.parse(json['rate']),
      media: List<Media>.from(json['media'].map((item) => Media.fromJson(item))),
    );
  }
}

class Media {
  final int id;
  final String url;
  final String thumb;
  final String icon;

  Media({
     this.id,
     this.url,
     this.thumb,
     this.icon,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: int.parse(json['id']),
      url: json['url'],
      thumb: json['thumb'],
      icon: json['icon'],
    );
  }
}*/

class ApiResponse {
  final Trending trending;
  final List<RestaurantModel> topKitchens;
  final List<RestaurantModel> popularKitchens;

  ApiResponse({
    this.trending,
    this.topKitchens,
    this.popularKitchens,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      trending: Trending.fromJson(json['trending']),
      topKitchens: List<RestaurantModel>.from(json['topkitchens']['data'].map((item) => RestaurantModel.fromJson(item))),
      popularKitchens: List<RestaurantModel>.from(json['popular']['data'].map((item) => RestaurantModel.fromJson(item))),
    );
  }
}

class Trending {
  final bool success;
  final List<FoodItem> data;
  final String message;

  Trending({
    this.success,
    this.data,
    this.message,
  });

  factory Trending.fromJson(Map<String, dynamic> json) {
    return Trending(
      success: json['success'],
      data: List<FoodItem>.from(json['data'].map((item) => FoodItem.fromJson(item))),
      message: json['message'],
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final num price;
  final String description;
  final List<String> foodType;
  final RestaurantModel restaurant;
  final List<Media> media;

  FoodItem({
    this.id,
    this.name,
    this.price,
    this.description,
    this.foodType,
    this.restaurant,
    this.media,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'].toString(),
      name: json['name'],
      price: json['price'],
      description: json['description'],
      foodType: List<String>.from(json['food_type'].map((type) => type.toString())),
      restaurant: RestaurantModel.fromJson(json['restaurant']),
      media: List<Media>.from(json['media'].map((item) => Media.fromJson(item))),
    );
  }
}

class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String mobile;
  final String slots;
  final String rate;
  final String is_open;
  final String closed;
  final String distance;
  final List<Media> media;
  final Price price;

  RestaurantModel({
    this.id,
    this.name,
    this.description,
    this.address,
    this.phone,
    this.mobile,
    this.slots,
    this.rate,
    this.distance,
    this.is_open,
    this.closed,
    this.media,
    this.price
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      mobile: json['mobile'],
      slots: json['slots'],
      rate: json['rate'].toString() ?? "",
      is_open: json['is_open'].toString() ?? "",
      closed: json['closed'].toString() ?? "",
      distance: json['distance'].toString(),
      media: List<Media>.from(json['media'].map((item) => Media.fromJson(item))),
      price:Price.fromJson(json['price_range']),
    );
  }
}


class Media {
  final String id;
  final String url;
  final String thumb;
  final String icon;

  Media({
    this.id,
    this.url,
    this.thumb,
    this.icon,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'].toString(),
      url: json['url'],
      thumb: json['thumb'],
      icon: json['icon'],
    );
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