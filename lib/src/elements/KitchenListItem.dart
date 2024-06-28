import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';

import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../helpers/helper.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../repository/settings_repository.dart' as settingRepo;

// ignore: must_be_immutable
class KitchenListItem extends StatefulWidget {
  Restaurant restaurant;
  String heroTag;

  KitchenListItem({Key? key,required this.restaurant,required this.heroTag}) : super(key: key);

  @override
  State<KitchenListItem> createState() => _KitchenListItemState();
}

class _KitchenListItemState extends State<KitchenListItem> {
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
    //heroTag = "Restaurant";
    //print("DS>> from cardwidget "+restaurant.name);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).focusColor.
            withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Container(


        width: 170,
        decoration: BoxDecoration(
          color:Colors.transparent,
          // borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
                color: Theme
                    .of(context)
                    .focusColor
                    .withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 5)),
          ],
        ),
        child: Column(

          children: <Widget>[
            // Image of the card
            Hero(
              tag: widget.restaurant.id!,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                    Radius.circular(10)),
                child: CachedNetworkImage(
                  height: 120,
                  width: 300,
                  fit: BoxFit.fill,
                  imageUrl: widget.restaurant.image!.url,
                  placeholder: (context, url) =>
                      Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.fill,
                        //width: double.infinity,
                        //height: 150,
                      ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width:120,
                          height: 17,
                          child: /*Text(
                            restaurant.name,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleSmall.merge(TextStyle(fontWeight: FontWeight.w400)),
                          )*/
                          TranslationWidget(
                            message:  widget.restaurant.name!,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(

                              translatedMessage,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style:Theme
                                  .of(context)
                                  .textTheme
                                  .caption!.merge(TextStyle(
                                  fontSize: 12
                              )),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          height: 17,
                          child: Text(
                            Helper.skipHtml(widget.restaurant.address!),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Theme
                                .of(context)
                                .textTheme
                                .caption!.merge(TextStyle(
                                fontSize: 10
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Spacer(),
                  SizedBox(width: 8,),
                  Row(
                    children: [
                      Text(
                        Helper.getDistance(
                            double.parse( widget.restaurant.distance!),
                            Helper.of(context)
                                .trans(setting.value.distanceUnit)),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                            fontSize: 8
                        ),
                      ),
                      SizedBox(
                        width: 5,
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
                        child: Icon(
                          Icons.arrow_right_alt,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 3,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBar.builder(
                    itemSize: 10,
                    initialRating: double.parse( widget.restaurant.rate!),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) =>
                        ShaderMask(
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
                            size: 10.0,
                          ),
                        ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                            text: "₹",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme
                                  .of(context)
                                  .hintColor,
                              fontSize: 7,
                            ),
                            children: [
                              TextSpan(
                                text: '${widget.restaurant.average_price}',
                                style: TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ]),
                      ),
                      Text(
                        "Avg.for one",
                        style: TextStyle(
                          fontSize: 5,
                        ),
                      ),


                    ],
                  ),
                  // Row(
                  //   children: Helper.getStarsList(
                  //     double.parse(restaurant.rate),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],


        ),
      ),
    );
  }
}
