import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:food_delivery_app/my_widget/calander_widget.dart';
import 'package:food_delivery_app/src/models/home_model.dart';

import '../elements/GridItemWidget.dart';

import '../models/route_argument.dart';
import 'CardsCarouselLoaderWidget.dart';

class GridWidget extends StatelessWidget {
  final List<RestaurantModel> restaurantsList;
  final String heroTag;
  bool delivery;

  GridWidget({Key key, this.restaurantsList, this.heroTag,  this.delivery});

  @override
  Widget build(BuildContext context) {
    return  restaurantsList.isEmpty
        ? CardsCarouselLoaderWidget()
        : Container(
         // height: 400,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(
              left: 0, top: 0, bottom: 0, right: 8),
          decoration: BoxDecoration(

          ),
         child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,

        ),
        //n scrollDirection: Axis.horizontal,
        itemCount: restaurantsList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // print("DS>> print delivery"+delivery.toString());
              delivery!=true? showCalendarDialog(context, restaurantsList.elementAt(index).id, delivery,-1):
              Navigator.of(context).pushNamed('/Details',
                  arguments: RouteArgument(
                    id: '0',
                    param: restaurantsList.elementAt(index).id,
                    heroTag: heroTag,
                    isDelivery: true,
                    selectedDate: "",
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: GridItemWidget(
                restaurant: restaurantsList.elementAt(index),
                heroTag: heroTag,
              ),
            ),
          );
        },
      ),
    );

  }
}
