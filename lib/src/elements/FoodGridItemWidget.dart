import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';

import '../models/food.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart' as settingRepo;

class FoodGridItemWidget extends StatefulWidget {
  final String heroTag;
  final String catid;
  final Food food;
  final VoidCallback onPressed;

  FoodGridItemWidget({Key key, this.heroTag, this.food, this.onPressed,this.catid})
      : super(key: key);

  @override
  _FoodGridItemWidgetState createState() => _FoodGridItemWidgetState();
}

class _FoodGridItemWidgetState extends State<FoodGridItemWidget> {
  String defaultLanguage;

  @override
  void initState() {
    getCurrentDefaultLanguage();
    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode) {
      print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      onTap: () {
        /*Navigator.of(context).pushNamed('/Food',
            arguments: new RouteArgument(
                heroTag: this.widget.heroTag, id: this.widget.food.id));*/

        Navigator.of(context).pushNamed('/Details',
            arguments: RouteArgument(
              id: '0',
              param: widget.food.restaurant.id,
              heroTag: widget.heroTag,
              isDelivery: true,
              selectedDate: "",
              parentScaffoldKey: new GlobalKey(),
            ));
      },
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Hero(
                  tag: widget.heroTag + widget.food.id,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(this.widget.food.image.thumb),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              /*Text(
                widget.food.name,
                style: Theme.of(context).textTheme.bodyText1,
                overflow: TextOverflow.ellipsis,
              )*/
              TranslationWidget(
                message: widget.food.name,
                fromLanguage: "English",
                toLanguage: defaultLanguage,
                builder: (translatedMessage) => Text(
                  translatedMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              SizedBox(height: 2),
              /*Text(
                widget.food.restaurant.name,
                style: Theme.of(context).textTheme.caption,
                overflow: TextOverflow.ellipsis,
              )*/
              TranslationWidget(
                message: widget.food.restaurant.name,
                fromLanguage: "English",
                toLanguage: defaultLanguage,
                builder: (translatedMessage) => Text(
                  translatedMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: 40,
            height: 40,
            child: MaterialButton(
              elevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              padding: EdgeInsets.all(0),
              onPressed: () {
                widget.onPressed();
              },
              child: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              color: Theme.of(context).accentColor.withOpacity(0.9),
              shape: StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
