import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/home_model.dart';
import '../../my_widget/calander_widget.dart';
import '../elements/CardsCarouselLoaderWidget.dart';

import '../models/route_argument.dart';
import 'CardWidget.dart';

// ignore: must_be_immutable
class CardsCarouselWidget extends StatefulWidget {
  List<RestaurantModel> restaurantsList;
  String heroTag;
  bool delivery;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  CardsCarouselWidget({Key key, this.restaurantsList, this.heroTag, this.delivery, this.parentScaffoldKey})
      : super(key: key);

  @override
  _CardsCarouselWidgetState createState() => _CardsCarouselWidgetState();
}

class _CardsCarouselWidgetState extends State<CardsCarouselWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("kitchen list length:"+widget.restaurantsList.length.toString());
    return widget.restaurantsList.isEmpty
        ? CardsCarouselLoaderWidget()
        : Container(
            height: 255,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.restaurantsList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    print("DS>> print delivery"+widget.delivery.toString());
                   widget.delivery!=true? showCalendarDialog(context, widget.restaurantsList.elementAt(index).id, widget.delivery,-1):
                    Navigator.of(context).pushNamed('/Details',
                        arguments: RouteArgument(
                          id: '0',
                          param: widget.restaurantsList.elementAt(index).id,
                          heroTag: widget.heroTag,
                          isDelivery: true,
                          selectedDate: "",
                          parentScaffoldKey: widget.parentScaffoldKey,
                        ));
                  },
                  child: CardWidget(
                    restaurant: widget.restaurantsList.elementAt(index),
                    heroTag: widget.heroTag,
                  ),
                );
              },
            ),
          );
  }
}
