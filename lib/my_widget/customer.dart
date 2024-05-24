class Customer {
  String status;
  String message;
  String customerId;
  int wishlistCount;
  String sessionData;
  int cartCount;

  Customer({
    this.status,
    this.message,
    this.customerId,
    this.wishlistCount,
    this.sessionData,
    this.cartCount,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      status: json['status'],
      message: json['message'],
      customerId: json['customer_id'],
      wishlistCount: json['wishlist_count'],
      sessionData: json['session_data'],
      cartCount: json['cart_count'],
    );
  }
}

class LoginResponse {
  int code;
  String msg;
  Customer data;

  LoginResponse({
    this.code,
    this.msg,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['code'],
      msg: json['msg'],
      data: Customer.fromJson(json['data']['customer']),
    );
  }
}