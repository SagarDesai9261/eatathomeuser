import 'package:flutter/material.dart';

import '../../my_widget/people_count_dailog.dart';

class RouteArgument {
  String? id;
  String? heroTag;
  dynamic param;
  bool? isDelivery;
  String? selectedDate;
  String? selectedPeople;
  String? selectedTime;
  String? latitude;
  String? longitude;
  List<ProductItem>? products;
  final GlobalKey<ScaffoldState>? parentScaffoldKey;


  RouteArgument({this.id, this.heroTag, this.param, this.isDelivery,
    this.selectedDate, this.selectedPeople, this.parentScaffoldKey, this.selectedTime,this.latitude,this
  .longitude,this.products});

  @override
  String toString() {
    return '{id: $id, heroTag:${heroTag.toString()}}';
  }
}
