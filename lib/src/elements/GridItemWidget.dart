import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import '../../utils/color.dart';
import '../helpers/helper.dart';

import '../models/home_model.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import '../repository/settings_repository.dart' as settingRepo;

class GridItemWidget extends StatefulWidget {
  final RestaurantModel restaurant;
  final String heroTag;

  GridItemWidget({Key? key, required this.restaurant, required this.heroTag}) : super(key: key);

  @override
  State<GridItemWidget> createState() => _GridItemWidgetState();
}

class _GridItemWidgetState extends State<GridItemWidget> {
  String defaultLanguage = "en";

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
    ColorFilter colorFilter = widget.restaurant.closed == "0" ? ColorFilter.mode(Colors.transparent, BlendMode.saturation) : ColorFilter.mode(Colors.grey, BlendMode.saturation);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).focusColor.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Container(
      //  padding: EdgeInsets.all(11),
        height: 320,
        width: 180,
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
        child: SingleChildScrollView(
          child: Column(

            children: <Widget>[
              // Image of the card
              Hero(
                tag: this.widget.heroTag + widget.restaurant.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                       Radius.circular(10)),
                  child: ColorFiltered(
                    colorFilter: colorFilter,
                    child: CachedNetworkImage(
                      height: 80,
                      width: 180,
                      fit: BoxFit.cover,
                      imageUrl: widget.restaurant.media!.length == 0 ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ14AJXokxXlQNidFd1P1rK_JuRjzRpaFC4DQ&usqp=CAU" : widget.restaurant.media![0].url!,
                      placeholder: (context, url) =>
                          Image.asset(
                            'assets/img/loading.gif',
                            fit: BoxFit.cover,
                            //width: double.infinity,
                            //height: 150,
                          ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                child: Row(

                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                          //  color: Colors.green,
                            width:140,
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
                              message:  widget.restaurant.name,
                              fromLanguage: "English",
                              toLanguage: defaultLanguage,
                              builder: (translatedMessage) => Text(
                                translatedMessage,
                                overflow: TextOverflow.fade,
                                softWrap: true,
                                style: Theme.of(context).textTheme.subtitle1!.merge(TextStyle(fontSize: 12)),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:110,
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
                //    Spacer(),
                    //SizedBox(width: 8,),
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
                              gradient: widget.restaurant.closed == "0" ? LinearGradient(
                                colors: [
                                  kPrimaryColororange,
                                  kPrimaryColorLiteorange
                                ],
                              ):LinearGradient(
                                colors: [
                                  Colors.grey,
                                  Colors.grey,
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
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.restaurant.closed == "0" ?   RatingBar.builder(
                      itemSize: 15,
                      initialRating: (widget.restaurant.rate == "null"|| widget.restaurant.rate == null)? 0.0 : double.parse(widget.restaurant.rate!),
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
                              size: 20.0,
                            ),
                          ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ):Text("Not accepting order",style: TextStyle(fontSize: 10),),
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
                                fontSize: 10,
                              ),
                              children: [
                                TextSpan(
                                  text: '${widget.restaurant.average_price}',
                                  style: TextStyle(
                                    fontSize: 10,
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

                        // widget.restaurant.distance != "0" && widget.restaurant.distance != null
                        //     ? Text(
                        //   Helper.getDistance(
                        //      double.parse( widget.restaurant.distance),
                        //       Helper.of(context)
                        //           .trans(setting.value.distanceUnit)),
                        //   overflow: TextOverflow.fade,
                        //   maxLines: 1,
                        //   softWrap: false,
                        // )
                        //     : SizedBox(height: 0)
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
      ),
    );
  }}
//