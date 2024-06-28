import 'dart:io';

import 'media.dart';

class User {
  String id;
  String name;
  String email;
  String? password;
  String apiToken;
  String deviceToken;
  String phone;
  String verifiedPhone = "123456";
  String? verificationId;
  String address;
  String bio;
  String is_verified;
  Media? image;
  double latitude;
  double longitude;
  String country;
  File? identity; // Add identity file
  bool? auth;
  String restoreid;

  User({
    this.id = '',
    this.name = '',
    this.email = '',
    this.password = '',
    this.apiToken = '',
    this.deviceToken = '',
    this.phone = '',
    this.verifiedPhone = '123456',
    this.verificationId = '',
    this.address = '',
    this.bio = '',
    this.is_verified = '',
    this.image,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.country = '',
    this.identity,
    this.auth = false,
    this.restoreid = '',
  });

  User.fromJSON(Map<String, dynamic> jsonMap)

      : image = jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty
      ? Media.fromJSON(jsonMap['media'][0])
      : Media(),
        id = jsonMap['id'].toString(),
        is_verified = jsonMap['is_verified'].toString(),
        name = jsonMap['name'] ?? '',
        email = jsonMap['email'] ?? '',
        apiToken = jsonMap['api_token'] ?? '',
        deviceToken = jsonMap['device_token'] ?? '',
        country = jsonMap['country'] ?? '',
        restoreid = jsonMap['restoreid'] ?? '',
        address = jsonMap['custom_fields']?['address']?['value'] ?? '',
        phone = jsonMap['custom_fields']?['phone']?['value'] ?? '',
        bio = jsonMap['custom_fields']?['bio']?['value'] ?? '',
        longitude = jsonMap['longitude'] != null ? double.parse(jsonMap['longitude'].toString()) : 0.0,
        latitude = jsonMap['latitude'] != null ? double.parse(jsonMap['latitude'].toString()) : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'password': password,
      'api_token': apiToken,
      if (deviceToken != null) 'device_token': deviceToken,
      'phone': phone,
      'country': country,
      'longitude': longitude,
      'latitude': latitude,
      'verifiedPhone': verifiedPhone,
      'address': address,
      'bio': bio,
      'media': image?.toMap(),
    };
  }

  Map<String, dynamic> toRestrictMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'thumb': image?.thumb,
      'device_token': deviceToken,
    };
  }

  @override
  String toString() {
    var map = this.toMap();
    map['auth'] = this.auth;
    return map.toString();
  }

  bool profileCompleted() {
    return address != null && address.isNotEmpty && phone != null && phone.isNotEmpty && verifiedPhone != null;
  }
}
