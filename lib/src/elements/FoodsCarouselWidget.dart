import 'package:flutter/material.dart';
import 'package:food_delivery_app/my_widget/calander_widget.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';

import '../elements/FoodsCarouselItemWidget.dart';
import '../elements/FoodsCarouselLoaderWidget.dart';
import '../models/food.dart';
import '../models/home_model.dart';

class FoodsCarouselWidget extends StatefulWidget {
  final List<FoodItem> foodsList;
  final String heroTag;
  bool delivery;
  int enjoy;
  FoodsCarouselWidget({Key? key,required  this.foodsList,required this.heroTag,required this.delivery,required this.enjoy})
      : super(key: key);

  @override
  State<FoodsCarouselWidget> createState() => _FoodsCarouselWidgetState();
}

class _FoodsCarouselWidgetState extends State<FoodsCarouselWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.foodsList != null && widget.foodsList.isNotEmpty) {
      // print("DS>> foodlist length: ${widget.foodsList[0].name}");
    }
    print("enjoy in foodcarousl ==> ${widget.enjoy}");

    return widget.foodsList.isEmpty
        ? FoodsCarouselLoaderWidget()
        : Container(
            height: 220,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              itemCount: widget.foodsList.length,
              itemBuilder: (context, index) {
                double _marginLeft = 0;
                (index == 0) ? _marginLeft = 20 : _marginLeft = 0;
                return GestureDetector(
                  onTap: (){
                    // print("DS>> print delivery"+widget.delivery.toString());
                    widget.delivery!=true? showCalendarDialog(context, widget.foodsList.elementAt(index).restaurant!.id, widget.delivery,-1):
                    Navigator.of(context).pushNamed('/Details',
                        arguments: RouteArgument(
                          id: '0',
                          param: widget.foodsList.elementAt(index).restaurant!.id,
                          heroTag: widget.heroTag,
                          isDelivery: true,
                          selectedDate: widget.enjoy.toString(),
                        ));
                  },
                  child: FoodsCarouselItemWidget(
                    heroTag: widget.heroTag,
                    marginLeft: _marginLeft,
                    food: widget.foodsList[index],
                  ),
                );
              },
              scrollDirection: Axis.horizontal,
            ));
  }
}
