import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/food_controller.dart';
import 'package:food_delivery_app/src/models/kitchen_detail_response.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';

import '../helpers/helper.dart';
import '../models/favorite.dart';
import '../models/favourite_model.dart';
import '../models/food.dart';
import '../models/route_argument.dart';

import '../repository/settings_repository.dart' as settingRepo;
import '../../src/helpers/app_config.dart' as config;
// ignore: must_be_immutable
class DineInIndividualFoodItemWidget extends StatefulWidget {
  String heroTag;
  SeparateItem food;
  Function(Food) updateFoodList;

  DineInIndividualFoodItemWidget({

   required this.heroTag,
   required this.food,
   required this.updateFoodList,
  }) ;

  @override
  State<DineInIndividualFoodItemWidget> createState() =>
      _DineInIndividualFoodItemWidgetState();
}

class _DineInIndividualFoodItemWidgetState extends State<DineInIndividualFoodItemWidget> {
  FoodController _foodcon = FoodController();
  String updatedQuantity = "1.0";
  List<Food> foodList = [];
  String defaultLanguage = "";

  @override
  void initState() {
    getCurrentDefaultLanguage();
    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode){
      // print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });

    });
  }
  @override
  Widget build(BuildContext context) {
    print("DS>>>> "+widget.food.image);
    return InkWell(
        // splashColor: Theme.of(context).accentColor,
        // focusColor: Theme.of(context).accentColor,
       // highlightColor: Theme.of(context).primaryColor,
        onTap: () {
          /* Navigator.of(context).pushNamed('/Food',
              arguments: new RouteArgument(
                  heroTag: this.widget.heroTag,
                  id: this.widget.food.id.toString()));*/
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Hero(
                  tag: widget.heroTag + widget.food.name.toString(),

                  child: Container(

                    height: 60,
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.food.image.toString(),
                        placeholder: (context, url) => Image.asset(
                          'assets/img/loading.gif',
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) =>
                            Image.asset(
                              'assets/img/image-Ae.png',
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),

                  ),
                ),
                SizedBox(width: 15),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /*Text(
                                widget.food.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.subtitle1,
                              )*/
                              TranslationWidget(
                                message:  updatedQuantity,
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Row(
                                children: [
                                  /*Text(
                                    widget.food.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Theme.of(context).textTheme.subtitle1,
                                  ),*/
                                  //Text("AED "),
                                  Helper.getPrice(
                                      double.parse(
                                          widget.food.price.toString()),
                                      context,
                                      style: TextStyle(fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                          color: config.Colors().secondColor(1),
                                          height: 1.35))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),

                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
