import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';

import '../../utils/color.dart';

import '../helpers/helper.dart';
import '../models/home_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../repository/settings_repository.dart' as settingRepo;
import '../repository/settings_repository.dart';

// ignore: must_be_immutable
class CardWidget extends StatefulWidget {
  RestaurantModel restaurant;
  String heroTag;

  CardWidget({Key key, this.restaurant, this.heroTag}) : super(key: key);

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  String defaultLanguage;

  //final String apiKey = "AIzaSyBQt-bwom5Z3fnNee4eLwca7RZWtkzi_SM";

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode){
     // print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });

    });
  }

  @override
  void initState() {
    getCurrentDefaultLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  //  print(widget.restaurant.price.min);
 //   print(widget.restaurant.price.max);
    //heroTag = "Restaurant";
 //   print("DS>> from cardwidget "+widget.restaurant.name);
  //  print("rate:-\n"+ widget.restaurant.rate == "null".toString()  );
if(widget.restaurant.rate == "null"|| widget.restaurant.rate == null){
  //print("3.0");
}else{
 // print(widget.restaurant.rate);
}
ColorFilter colorFilter = widget.restaurant.closed == "0" ? ColorFilter.mode(Colors.transparent, BlendMode.saturation) : ColorFilter.mode(Colors.grey, BlendMode.saturation);

    return Container(
      width: MediaQuery.of(context).size.width * 4 / 5,
      margin: EdgeInsets.symmetric(horizontal: 13),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ColorFiltered(
          colorFilter: colorFilter,
          child: Container(

              // margin: EdgeInsets.only(left: 20, right: 4, top: 15, bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(10)),
            //    backgroundBlendMode: BlendMode.color,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Image of the card
                  Expanded(
                    child: Stack(
                      fit: StackFit.loose,
                      alignment: AlignmentDirectional.bottomStart,
                      children: <Widget>[
                        Hero(
                          tag: widget.heroTag,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            child: CachedNetworkImage(
                              height: 170,
                              width: double.infinity,
                              fit: BoxFit.fill,
                              imageUrl: widget.restaurant.media[0].url,
                              placeholder: (context, url) => Image.asset(
                                'assets/img/loading.gif',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150,
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /*Text(
                                Helper.skipHtml(widget.restaurant.description),
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.caption,
                              )*/
                          TranslationWidget(
                          message: widget.restaurant.name.toString(),
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),

                              /*Text(
                                restaurant.name.toString(),
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),*/

                              TranslationWidget(
                                message: widget.restaurant.description.toString(),
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                              SizedBox(height: 10),
                            widget.restaurant.closed =="1" ? Text("Currently not accepting order") :  RatingBar.builder(
                                itemSize: 18,
                                initialRating: (widget.restaurant.rate == "null"|| widget.restaurant.rate == null)? 0.0 : double.parse(widget.restaurant.rate),
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      colors: [
                                        kPrimaryColororange,
                                        kPrimaryColorLiteorange
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 50.0,
                                  ),
                                ),
                                onRatingUpdate: (rating) {
                               //   print(rating);
                                },
                              ),
                              // Row(
                              //   children: Helper.getStarsList(
                              //     double.parse(restaurant.rate),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /*Text(
                                    widget.restaurant.distance.toString(),
                                    style: TextStyle(fontSize: 12),
                                  )*/
                                  TranslationWidget(
                                    message: Helper.getDistance(
                                        double.parse( widget.restaurant.distance),
                                        Helper.of(context)
                                            .trans(setting.value.distanceUnit)),
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(0),
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            kPrimaryColororange,
                                            kPrimaryColorLiteorange
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(100)),
                                    child:
                                        // Image.asset("assets/img/")
                                        Icon(
                                      Icons.turn_right_sharp,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              RichText(
                                text: TextSpan(
                                    text: "₹",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).hintColor,
                                      fontSize: 10,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${widget.restaurant.price.min}-₹${widget.restaurant.price.max}',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ]),
                              ),
                              /*Text(
                                "Avg. for one",
                                style: TextStyle(
                                  fontSize: 8,
                                ),
                              )*/ TranslationWidget(
                                message: "Avg. for one",
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
        ),
      ),
    );

  }
}
