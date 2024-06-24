import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';

import '../../utils/color.dart';
import '../models/home_model.dart';
import '../repository/settings_repository.dart' as settingRepo;

class FoodsCarouselItemWidget extends StatefulWidget {
  final double marginLeft;
  final FoodItem food;
  final String heroTag;

  FoodsCarouselItemWidget({Key key, this.heroTag, this.marginLeft, this.food})
      : super(key: key);

  @override
  State<FoodsCarouselItemWidget> createState() => _FoodsCarouselItemWidgetState();
}

class _FoodsCarouselItemWidgetState extends State<FoodsCarouselItemWidget> {
  String defaultLanguage;

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
      splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      highlightColor: Colors.transparent,
     /* onTap: () {
        Navigator.of(context).pushNamed('/Food',
            arguments: RouteArgument(id: widget.food.id, heroTag: widget.heroTag));
      },*/
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: <Widget>[
              Hero(
                tag: widget.heroTag + widget.food.id,
                child: Container(
                  margin: EdgeInsets.only(left: 12),
                  width: 120,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.food.media[0].thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.only(end: 10, top: 5),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    gradient: LinearGradient(colors: [
                      kPrimaryColororange,
                      kPrimaryColorLiteorange,
                    ])
                    // color: food.discountPrice > 0
                    //     ? Colors.red
                    //     : Theme.of(context).accentColor,
                    ),
                alignment: AlignmentDirectional.topEnd,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    RichText(
                      text: TextSpan(
                          text: "₹",
                          style: TextStyle(
                            // color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: widget.food.price.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ]),
                    ),
                    /*Text(
                      "Avg.for one",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    )*/
                    TranslationWidget(
                      message: "Avg.for one",
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(
                        translatedMessage,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style:  TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),

              ),
            ],
          ),
          SizedBox(height: 5),
          Container(
              width: 100,

              margin:
                  EdgeInsetsDirectional.only(start: 12, end: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /*Text(
                    widget.food.restaurant.name.isEmpty ? "" : widget.food.restaurant.name,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  )*/
                  TranslationWidget(
                    message: widget.food.restaurant.name.isEmpty ? "" : widget.food.restaurant.name,
                    fromLanguage: "English",
                    toLanguage: defaultLanguage,
                    builder: (translatedMessage) => Text(
                      translatedMessage,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  /*Text(
                    widget.food.restaurant.address.isEmpty ? "" : widget.food.restaurant.address,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  )*/
                /*  TranslationWidget(
                    message:  widget.food.restaurant.address.isEmpty ? "" : widget.food.restaurant.address,
                    fromLanguage: "English",
                    toLanguage: defaultLanguage,
                    builder: (translatedMessage) => Text(
                      translatedMessage,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),*/
                ],
              )),
        ],
      ),
    );
  }
}
