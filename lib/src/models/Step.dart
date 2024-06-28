import 'package:google_maps_flutter/google_maps_flutter.dart';

class Step {
  LatLng startLatLng;

  Step({required this.startLatLng});

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      startLatLng: LatLng(json["end_location"]["lat"] as double, json["end_location"]["lng"] as double),
    );
  }
}
