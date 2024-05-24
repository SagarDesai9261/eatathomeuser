class DeleteFromFavouriteModel {
  bool success;
  Data data;
  String message;

  DeleteFromFavouriteModel({
     this.success,
     this.data,
     this.message,
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
  int id;
  int restaurantId;
  //int foodId;
  int userId;
  String createdAt;
  String updatedAt;
  //List<dynamic> customFields;
  //List<dynamic> extras;

  Data({
     this.id,
     this.restaurantId,
     //this.foodId,
     this.userId,
     this.createdAt,
     this.updatedAt,
     //this.customFields,
     //this.extras,
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