import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../src/helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';

class FoodItemWidget extends StatelessWidget {
  final String heroTag;
  final Food food;
  final VoidCallback onTap;
  final bool fieldenable;

  const FoodItemWidget({required this.food,required this.heroTag,required this.onTap,required this.fieldenable}) ;

  @override
  Widget build(BuildContext context) {
    return InkWell(

      highlightColor: Theme.of(context).primaryColor,
      /*onTap: () {
        Navigator.of(context).pushNamed('/Food',
            arguments: RouteArgument(id: food.id, heroTag: this.heroTag));
      },*/
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical:5),
              child: Text("${food.restaurant.name}",style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),),
            ),*/

            Container(
              padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
             // margin: EdgeInsets.only(top:5,left:10,right:10,bottom:5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: CachedNetworkImage(
                      height: 120,
                      width: 100,
                      fit: BoxFit.cover,
                      imageUrl: food.image!.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        height: 60,
                        width: 60,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  SizedBox(width: 15),
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${food.restaurant!.name}",style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                food.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Row(
                                children: Helper.getStarsList(food.getRate()),
                              ),
                            /*  Text(
                                food.extras.map((e) => e.name).toList().join(', '),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.caption,
                              ),*/
                              SizedBox(height: 10,),
                            if(fieldenable)
                            food.restaurant!.closed == "1"?  Text(
                              "Currently not accepting order",
                              style: TextStyle(color: Colors.redAccent),
                            ) :  Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 30,
                                    decoration: BoxDecoration(
                                     // shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Theme.of(context).hintColor),
                                      color: Colors.white,
                                    ),
                                    child: GestureDetector(
                                      onTap: onTap,
                                     /* onTap: () {
                                        if (_con.restaurant.closed == "1") {
                                          _showClosedDialog(context);
                                        } else {
                                          print("DS>> GD decrement");
                                          _foodcon.decrementQuantity();
                                          setState(() {
                                            print("hello");
                                            if (quantity > 0) {
                                              quantity--;
                                              itemQuantities[breakfastFoodItem
                                                  .id
                                                  .toString()] = quantity;
                                            }
                                            updatedQuantity = _foodcon
                                                .quantity
                                                .toInt()
                                                .toString();
                                            removeFoodFromList(Food.withId(
                                                id: breakfastFoodItem.id
                                                    .toString(),
                                                foodImg: breakfastFoodItem
                                                    .comboMedia
                                                    .length ==
                                                    0
                                                    ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                    : breakfastFoodItem
                                                    .comboMedia[0].url,
                                                name: breakfastFoodItem.name,
                                                price: double.parse(
                                                    breakfastFoodItem.price
                                                        .toString())));
                                            *//*updateFoodList(new Food.withId(
                                                id: breakfastFoodItem.id
                                                    .toString(),
                                                foodImg: breakfastFoodItem
                                                    .comboMedia[0].url,
                                                name: breakfastFoodItem.name,
                                                price: double.parse(
                                                    breakfastFoodItem.price
                                                        .toString())));*//*
                                          });
                                        } //provider.decrementQuantity(index);
                                      },*/
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("Add "),
                                          Icon(
                                            Icons.add,
                                            size: 15,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                 /* Container(
                                    width: 35,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          "0".toString(),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Theme.of(context).hintColor),
                                      color: Colors.white,
                                    ),
                                    child: InkWell(
                                      child: GestureDetector(
                                        onTap: onTap,
                                        *//*onTap: () {
                                          if (_con.restaurant.closed == "1") {
                                            _showClosedDialog(context);
                                          } else {
                                            print("DS>> GD increment" +
                                                _foodcon.quantity.toString());
                                            _foodcon.incrementQuantity();
                                            setState(() {
                                              //  print("hello");
                                              updatedQuantity = _foodcon
                                                  .quantity
                                                  .toInt()
                                                  .toString();
                                              updateFoodList(new Food.withId(
                                                  id: breakfastFoodItem.id
                                                      .toString(),
                                                  foodImg: breakfastFoodItem
                                                      .comboMedia
                                                      .length ==
                                                      0
                                                      ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                      : breakfastFoodItem
                                                      .comboMedia[0].url,
                                                  name: breakfastFoodItem.name,
                                                  restaurant: breakfastFoodItem
                                                      .restaurant,
                                                  price: double.parse(
                                                      breakfastFoodItem.price
                                                          .toString())));
                                              quantity++;
                                              itemQuantities[breakfastFoodItem
                                                  .id
                                                  .toString()] = quantity;
                                            });
                                            setState(() {});
                                          } //    provider.incrementQuantity(index);
                                        },*//*
                                        child: Icon(
                                          Icons.add,
                                          size: 15,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ),
                                  ),*/
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Helper.getPrice(
                              food.price,
                              context,
                              style: TextStyle(fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: config.Colors().secondColor(1),
                                height: 1.35),
                            ),
                            food.discountPrice > 0
                                ? Helper.getPrice(food.discountPrice, context,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        !.merge(TextStyle(
                                            decoration: TextDecoration.lineThrough)))
                                : SizedBox(height: 0),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
           /* Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("View full menu"),
                Icon(Icons.arrow_forward)
              ],
            )*/
          ],
        ),
      ),
    );
  }
}
