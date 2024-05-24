import 'package:flutter/material.dart';

import '../../my_widget/calander_widget.dart';
import '../controllers/category_controller.dart';
import '../models/food.dart';
import '../models/route_argument.dart';
import '../repository/translation_widget.dart';
import 'CardsCarouselLoaderWidget.dart';
import 'GridItemWidget.dart';
import '../repository/settings_repository.dart' as settingRepo;


class GridWidgetCategoryFoods extends StatefulWidget {
  String id;
  // final String heroTag;
  // bool delivery;

  GridWidgetCategoryFoods({Key key,this.id});

  @override
  State<GridWidgetCategoryFoods> createState() => _GridWidgetCategoryFoodsState();
}

class _GridWidgetCategoryFoodsState extends State<GridWidgetCategoryFoods> {

  CategoryController _con = CategoryController();
  String defaultLanguage;
  //final categoryFoodProvider = Provider.of<CollectedData>(context);



  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode) {
      print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _con.listenForFoodsByCategory(id: widget.id);

    });
    getCurrentDefaultLanguage();
    print("--->widget:"+widget.id);
    print("--->list:"+_con.foods.length.toString());
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return _con.foodList.isEmpty?
    CardsCarouselLoaderWidget():
      Container(
       height: 200,
       child: ListView.builder(
           scrollDirection: Axis.horizontal,
           shrinkWrap : true,
         itemCount: 4,
         itemBuilder: (context,index) {
           return Container(
             padding: EdgeInsets.all(10),


             child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Theme.of(context).accentColor.withOpacity(0.08),
              onTap: () {



                /*Navigator.of(context).pushNamed('/Food',
                    arguments: new RouteArgument(
                        heroTag: this.widget.heroTag, id: this.widget.food.id));*/

                // Navigator.of(context).pushNamed('/Details',
                //     arguments: RouteArgument(
                //       id: '0',
                //       param: widget.food.restaurant.id,
                //       heroTag: widget.heroTag,
                //       isDelivery: true,
                //       selectedDate: "",
                //       parentScaffoldKey: new GlobalKey(),
                //     ));
              },
              child: Stack(
                alignment: AlignmentDirectional.topEnd,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Expanded(
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       image: DecorationImage(
                      //           image: NetworkImage(_con.foodList[index].image.thumb),
                      //           fit: BoxFit.cover),
                      //       borderRadius: BorderRadius.circular(5),
                      //     ),
                      //   ),
                      // ),
                      Container(child: Image.network(_con.foodList[index].image.thumb,
                      fit: BoxFit.cover,height: 120,)),
                      SizedBox(height: 5),
                     // Text(
                     //   _con.foodList[index].name.toString(),
                     //    style: Theme.of(context).textTheme.bodyText1,
                     //    overflow: TextOverflow.ellipsis,
                     //  ),
                      TranslationWidget(
                        message: _con.foodList[index].name.toString(),
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
                        message: _con.foodList[index].restaurant.name.toString(),
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
                    width: 35,
                    height: 35,
                    child: MaterialButton(
                      elevation: 0,
                      focusElevation: 0,
                      highlightElevation: 0,
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        //widget.onPressed();
                      },
                      child: Icon(
                        Icons.shopping_cart,
                        color: Theme.of(context).primaryColor,
                        size: 21,
                      ),
                      color: Theme.of(context).accentColor.withOpacity(0.9),
                      shape: StadiumBorder(),
                    ),
                  ),
                ],
              ),
    ),
           );
         }
       ),
     );


  }
}
