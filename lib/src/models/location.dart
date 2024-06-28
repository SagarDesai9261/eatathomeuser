import 'package:flutter/material.dart';

class LocationModel with ChangeNotifier {
  final String address;
  final String latitude;
  final String longitude;
  final List<dynamic>? customFields;
  final bool? hasMedia;
  final dynamic rate;
  final List<dynamic>? media;
  bool selected;

  LocationModel({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.customFields,
    this.hasMedia,
    required this.rate,
    this.media,
    this.selected = false,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      customFields: json['custom_fields'],
      hasMedia: json['has_media'],
      rate: json['rate'],
      media: json['media'],
      selected: json['selected'] ?? false,
    );
  }
}
