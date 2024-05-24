import 'package:flutter/material.dart';

class FavouriteModel {
  int id;
  String name;
  String description;
  String image;
  double minPrice;
  double maxPrice;
  String currency;
  int restaurant_id;
  int favourite_id;

  FavouriteModel({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.image,
    @required this.minPrice,
    @required this.maxPrice,
    @required this.currency,
    @required this.favourite_id,
    @required this.restaurant_id
  });

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      minPrice: json['min_price'],
      maxPrice: json['max_price'],
      currency: json['currency'],
      restaurant_id: json['restaurant_id'],
      favourite_id: json['favorite_id'],
    );
  }
}

class RestaurantResponse {
  bool success;
  List<FavouriteModel> data;
  String message;

  RestaurantResponse({
    @required this.success,
    @required this.data,
    @required this.message,
  });

  factory RestaurantResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> restaurantData = json['data'];
    List<FavouriteModel> restaurants = restaurantData
        .map((restaurantJson) => FavouriteModel.fromJson(restaurantJson))
        .toList();

    return RestaurantResponse(
      success: json['success'],
      data: restaurants,
      message: json['message'],
    );
  }
}