import 'dart:io';

import 'media.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  String apiToken;
  String deviceToken;
  String phone;
  String verifiedPhone = "123456";
  String verificationId;
  String address;
  String bio;
  String is_verified;
  Media image;
  double latitude;
  double longitude;
  String country;
  File identity; // Add identity file
  bool auth;
  String restoreid;
  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
          ? Media.fromJSON(jsonMap['media'][0])
          : new Media();
      id = jsonMap['id'].toString();
      is_verified = jsonMap['is_verified'].toString();
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      apiToken = jsonMap['api_token'] ?? "";
      deviceToken = jsonMap['device_token'] ?? "";
      country = jsonMap['country'] ?? "";
      restoreid = jsonMap['restoreid'] ?? "";
      address = jsonMap['custom_fields']['address']['value'] ?? "";
      phone = jsonMap['custom_fields']['phone']['value'] ?? "";
      bio = jsonMap['custom_fields']['bio']['value'] ?? "";
      longitude =  double.parse( jsonMap['longitude']) ?? 0.0;
      latitude =  double.parse(jsonMap['latitude']) ?? 0.0;
    //  latitude = 0.0;
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["password"] = password;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["phone"] = phone;
    map["country"] = country;
    map["longitude"] = longitude;
    map["latitude"] = latitude;
    map["verifiedPhone"] = verifiedPhone;
    map["address"] = address;
    map["bio"] = bio;
    map["media"] = image?.toMap();
    return map;
  }

  Map<String, dynamic> toRestrictMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["thumb"] = image?.thumb;
    map["device_token"] = deviceToken;
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }

  bool profileCompleted() {
    return address != null && address != '' && phone != null && phone != '' && verifiedPhone != null;
  }
}
