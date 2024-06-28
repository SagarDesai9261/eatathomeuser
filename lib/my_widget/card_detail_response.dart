import 'dart:convert';
import 'package:http/http.dart' as http;

class CartDetailResponse {
  int? code;
  String? msg;
  CartDetailData? data;

  CartDetailResponse({
    this.code,
    this.msg,
    this.data,
  });

  factory CartDetailResponse.fromJson(Map<String, dynamic> json) {
    return CartDetailResponse(
      code: json['code'],
      msg: json['msg'],
      data: CartDetailData.fromJson(json['data']),
    );
  }
}

class CartDetailData {
  String? status;
  String? message;
  String? sessionData;
  int? totalCartItems;
  int? totalCartCount;

  CartDetailData({
    this.status,
    this.message,
    this.sessionData,
    this.totalCartItems,
    this.totalCartCount,
  });

  factory CartDetailData.fromJson(Map<String, dynamic> json) {
    return CartDetailData(
      status: json['status'],
      message: json['message'],
      sessionData: json['session_data'],
      totalCartItems: json['total_cart_items'],
      totalCartCount: json['total_cart_count'],
    );
  }
}

