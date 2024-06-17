import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/color.dart';
import '../controllers/category_controller.dart';
import '../models/category.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import 'GridWidgetCategoryFoods.dart';

// ignore: must_be_immutable
class CategoriesCarouselItemWidget extends StatefulWidget {
  double marginLeft;
  Category category;

  CategoriesCarouselItemWidget({Key key, this.marginLeft, this.category})
      : super(key: key);

  @override
  State<CategoriesCarouselItemWidget> createState() => _CategoriesCarouselItemWidgetState();
}

class _CategoriesCarouselItemWidgetState extends State<CategoriesCarouselItemWidget> {
  String defaultLanguage;
  CategoryController _con = CategoryController();
  bool visible = false;

  @override
  void initState() {
    getCurrentDefaultLanguage();
    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingsRepo.getDefaultLanguageName().then((_langCode) {
      // print("DS>> DefaultLanguageret "+_langCode);
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
      onTap: () async
      {

        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('food_list', widget.category.id);
        print("tap");
        print(widget.category.id);
        _con.listenForFoodsByCategory(id:widget.category.id);

        print("length    :"+_con.foods.length.toString());


        //
        //
        // Navigator.of(context)
        //     .pushNamed('/Category', arguments: RouteArgument(id: widget.category.id));
      },
      child: Container(
        height: 200,
        child: Column(
          children: [
            Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: widget.category.id,
                  child: Container(
                    margin: EdgeInsets.all(5),
                    // margin:
                    //     EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
                    width: MediaQuery.of(context).size.width*0.20,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColororange,
                              // color: Theme.of(context).focusColor.withOpacity(0.2),
                              offset: Offset(2, 2,),
                              spreadRadius: -8,
                              blurRadius: 10.0)
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: widget.category.image.url.toLowerCase().endsWith('.svg')
                          ? ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                            stops: [0.3, 1.0],// Replace with your desired gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(kPrimaryColorLiteorange, BlendMode.srcIn),
                              child: SvgPicture.network(
                                  widget.category.image.url,
                                  //color: kPrimaryColorLiteorange,
                                ),
                            ),
                          )
                          : ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                            stops: [0.3, 1.0],// Replace with your desired gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                            child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: widget.category.image.icon,
                                placeholder: (context, url) => Image.asset(
                                  'assets/img/loading.gif',
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                          ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  margin: EdgeInsets.only(left: 8),

                  // margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
                  child: /*Text(
                    category.name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style:TextStyle(fontWeight: FontWeight.w600,),
                  )*/
                  TranslationWidget(
                    message: widget.category.name,
                    fromLanguage:"English",
                    toLanguage:defaultLanguage,
                    builder: (translatedMessage) => Text(
                        translatedMessage,
                        overflow:TextOverflow.fade,
                        softWrap:false,
                        style: TextStyle(fontWeight: FontWeight.w600,)),
                  ),
                ),


              ],
            ),


          ],
        ),
      ),
    );
  }
}


