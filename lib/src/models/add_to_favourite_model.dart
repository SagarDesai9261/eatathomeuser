class AddToFavouriteModel {
  final bool success;
  // final List<AddToFavouriteModelData> data;
  AddToFavouriteModelData data;
  final String message;

  AddToFavouriteModel({
    required this.success,
    required this.data,
    required this.message,
  });

  /*factory AddToFavouriteModel.fromJson(Map<String, dynamic> json) {
    return AddToFavouriteModel(
      success: json['success'] as bool,
      //data: AddToFavouriteModelData.fromJson(json['data'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>).map((item) => AddToFavouriteModelData.fromJson(item as Map<String, dynamic>)).toList(),
      message: json['message'] as String,
    );
  }*/
  factory AddToFavouriteModel.fromJson(Map<String, dynamic> json) {
    return AddToFavouriteModel(
      success: json['success'],
      data: AddToFavouriteModelData.fromJson(json['data']),
      message: json['message'],
    );
  }
}

class AddToFavouriteModelData {
  final int restaurantId;
  final int userId;
  //final dynamic foodId;
  final String updatedAt;
  final String createdAt;
  final int id;
  //final List<dynamic> customFields;
  //final List<dynamic> extras;

  AddToFavouriteModelData({
    required this.restaurantId,
    required this.userId,
    //this.foodId,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
   // required this.customFields,
   // required this.extras,
  });

  /*factory AddToFavouriteModelData.fromJson(Map<String, dynamic> json) {
    return AddToFavouriteModelData(
      restaurantId: json['restaurant_id'] as int,
      userId: json['user_id'] as int,
      //foodId: json['food_id'],
      updatedAt: json['updated_at'] as String,
      createdAt: json['created_at'] as String,
      id: json['id'] as int,
      //customFields: json['custom_fields'] as List<dynamic>,
      //extras: json['extras'] as List<dynamic>,
    );
  }*/
  factory AddToFavouriteModelData.fromJson(Map<String, dynamic> json) {
    return AddToFavouriteModelData(
      restaurantId: json['restaurant_id'],
      userId: json['user_id'],
      // foodId: json['food_id'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
      //customFields: json['custom_fields'],
      //extras: json['extras'],
    );
  }
}