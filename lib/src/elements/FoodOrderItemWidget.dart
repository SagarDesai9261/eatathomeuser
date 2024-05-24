import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/food_order.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import '../../src/helpers/app_config.dart' as config;
class FoodOrderItemWidget extends StatefulWidget {
  final String heroTag;
  final FoodOrder foodOrder;
  final Order order;

  const FoodOrderItemWidget({Key key, this.foodOrder, this.order, this.heroTag})
      : super(key: key);

  @override
  State<FoodOrderItemWidget> createState() => _FoodOrderItemWidgetState();
}

class _FoodOrderItemWidgetState extends State<FoodOrderItemWidget> {

  String defaultLanguage;
  @override
  void initState() {
    getCurrentDefaultLanguage();
    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingsRepo.getDefaultLanguageName().then((_langCode) {
      print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    //print("DS>>> order image"+foodOrder.food.foodMedia[0].url.toString());
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
       /* Navigator.of(context).pushNamed('/Food',
            arguments: RouteArgument(id: this.foodOrder.food.id));*/
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: widget.heroTag + widget.foodOrder?.id,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CachedNetworkImage(
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  imageUrl: widget.foodOrder.food.image.url.toString(),
                  /*placeholder: (context, url) => Image.asset(
                    'assets/img/loading.gif',
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                  ),*/
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /*Text(
                          widget.foodOrder.food.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        )*/
                       /* TranslationWidget(
                          message:widget.foodOrder.food.name,
                          fromLanguage: "English",
                          toLanguage: defaultLanguage,
                          builder: (translatedMessage) => Text(
                            translatedMessage,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),*/
                        Wrap(
                          children:
                              List.generate(widget.foodOrder.extras.length, (index) {
                            return Text(
                              widget.foodOrder.extras.elementAt(index).name + ', ',
                              style: Theme.of(context).textTheme.caption,
                            );
                          }),
                        ),
                        /*Text(
                          widget.foodOrder.food.restaurant.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.caption,
                        )*/
                        TranslationWidget(
                          message:widget.foodOrder.food.name,
                          fromLanguage: "English",
                          toLanguage: defaultLanguage,
                          builder: (translatedMessage) => Text(
                            translatedMessage,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Helper.getPrice(Helper.getOrderPrice(widget.foodOrder), context,
                          style: TextStyle(fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: config.Colors().secondColor(1),
                              height: 1.35)),
                      /*Text(
                        " x " + widget.foodOrder.quantity.toString(),
                        style: Theme.of(context).textTheme.caption,
                      ),*/
                      TranslationWidget(
                        message:  " x " + widget.foodOrder.quantity.toString(),
                        fromLanguage: "English",
                        toLanguage: defaultLanguage,
                        builder: (translatedMessage) => Text(
                          translatedMessage,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
