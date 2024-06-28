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

// ignore: must_be_immutable
class IndividualFoodItemWidget extends StatefulWidget {
  String heroTag;
  SeparateItem food;
  Function(Food) updateFoodList;

  IndividualFoodItemWidget({
    Key? key,
    required this.heroTag,
    required this.food,
    required this.updateFoodList,
  }) : super(key: key);

  @override
  State<IndividualFoodItemWidget> createState() =>
      _IndividualFoodItemWidgetState();
}

class _IndividualFoodItemWidgetState extends State<IndividualFoodItemWidget> {
  FoodController _foodcon = FoodController();
  String updatedQuantity = "0.0";
  List<Food> foodList = [];
  String defaultLanguage = "";

  @override
  void initState() {
    getCurrentDefaultLanguage();
    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode){
      print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        //splashColor: Theme.of(context).accentColor,
        //focusColor: Theme.of(context).accentColor,
        highlightColor: Theme.of(context).primaryColor,
        onTap: () {
         /* Navigator.of(context).pushNamed('/Food',
              arguments: new RouteArgument(
                  heroTag: this.widget.heroTag,
                  id: this.widget.food.id.toString()));*/
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 3,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2)),
                ],
              ),
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
                          imageUrl: widget.food.image,
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
                      /*decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        image: DecorationImage(
                            image: AssetImage(
                              "assets/img/image-Ae.png",
                            ),
                            fit: BoxFit.cover),
                      ),*/
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
                                  message:  widget.food.name,
                                  fromLanguage: "English",
                                  toLanguage: defaultLanguage,
                                  builder: (translatedMessage) => Text(
                                    translatedMessage,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                                Row(
                                  children: [
                                    /*Text("AED ")*/
                                    TranslationWidget(
                                      message:  "₹",
                                      fromLanguage: "English",
                                      toLanguage: defaultLanguage,
                                      builder: (translatedMessage) => Text(
                                        translatedMessage,
                                      ),
                                    ),
                                    Helper.getPrice(
                                        double.parse(
                                            widget.food.price.toString()),
                                        context,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Theme.of(context).hintColor),
                                color: Colors.white,
                              ),
                              child: InkWell(
                                child: GestureDetector(
                                  onTap: () {
                                    //print("DS>> GD decrement");
                                    _foodcon.incrementQuantity();
                                    setState(() {
                                      updatedQuantity =
                                          _foodcon.quantity.toString();
                                    });
                                    //widget.updateFoodList(widget.food);
                                    widget.updateFoodList(new Food.withId(name: widget.food.name,
                                        price: double.parse(widget.food.price.toString()),
                                        foodImg:widget.food.image, id: '' ));
                                  },
                                  child: Icon(
                                    Icons.add,
                                    color: Theme.of(context).hintColor,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 50,
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: /*Text(
                                    updatedQuantity,
                                    style: TextStyle(fontSize: 12),
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
                                ),
                              ),
                            ),
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Theme.of(context).hintColor),
                                color: Colors.white,
                              ),
                              child: InkWell(
                                child: GestureDetector(
                                  onTap: () {
                                    //print("DS>> GD decrement");
                                    _foodcon.decrementQuantity();
                                    setState(() {
                                      updatedQuantity =
                                          _foodcon.quantity.toString();
                                    });
                                  },
                                  child: Icon(
                                    Icons.remove,
                                    color: Theme.of(context).hintColor,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        /* Helper.getPrice(double.parse(widget.food.price.toString()), context,
                        style: Theme.of(context).textTheme.headline4),*/
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
