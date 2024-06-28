class DeleteFromFavouriteModel {
  final bool success;
  final Data data;
  final String message;

  DeleteFromFavouriteModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory DeleteFromFavouriteModel.fromJson(Map<String, dynamic> json) {
    return DeleteFromFavouriteModel(
      success: json['success'],
      data: Data.fromJson(json['data']),
      message: json['message'],
    );
  }
}

class Data {
  final int id;
  final int restaurantId;
  //final int foodId;
  final int userId;
  final String createdAt;
  final String updatedAt;
  //final List<dynamic> customFields;
  //final List<dynamic> extras;

  Data({
    required this.id,
    required this.restaurantId,
    //required this.foodId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    //required this.customFields,
    //required this.extras,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      //foodId: json['food_id'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      //customFields: json['custom_fields'],
      //extras: json['extras'],
    );
  }
}
