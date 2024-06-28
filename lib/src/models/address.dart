import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Address {
  String? id;
  String? description;
  String? address;
  double? latitude;
  double? longitude;
  bool? isDefault;
  String? userId;

  Address({
     this.id,
     this.description,
     this.address,
     this.latitude,
     this.longitude,
     this.isDefault,
     this.userId,
  });

  Address.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        description = jsonMap['description'] != null ? jsonMap['description'].toString() : "",
        address = jsonMap['address'] != null ? jsonMap['address'] : "",
        latitude = jsonMap['latitude'] != null ? jsonMap['latitude'].toDouble() : 0.0,
        longitude = jsonMap['longitude'] != null ? jsonMap['longitude'].toDouble() : 0.0,
        isDefault = jsonMap['is_default'] ?? false,
        userId = jsonMap['user_id'] != null ? jsonMap['user_id'].toString() : "";

  bool isUnknown() {
    return id!.isEmpty || id == 'null' || latitude == 0.0 || longitude == 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "description": description,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "is_default": isDefault,
      "user_id": userId,
    };
  }

  LocationData toLocationData() {
    return LocationData.fromMap({
      "latitude": latitude,
      "longitude": longitude,
    });
  }

  LatLng getLatLng() {
    if (isUnknown()) {
      return LatLng(38.806103, 52.4964453);
    } else {
      return LatLng(latitude!, longitude!);
    }
  }
}
