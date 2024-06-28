import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/l10n.dart';
import 'package:food_delivery_app/src/controllers/category_controller.dart';
import 'package:food_delivery_app/src/elements/FoodListItemWidget.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class CategoryFoodById extends StatefulWidget {
   RouteArgument? routeArgument;

  CategoryFoodById({Key? key, this.routeArgument}) : super(key: key);
  @override
  _CategoryFoodByIdState createState() => _CategoryFoodByIdState();
}

class _CategoryFoodByIdState extends StateMVC<CategoryFoodById> {

  CategoryController? _con;

  _CategoryFoodByIdState() : super(CategoryController()) {
    _con = controller as CategoryController?;
  }

  @override
  void initState() {
  //  _con.listenForFoodsByCategory(id: widget.routeArgument.id);
  //  _con.listenForCategory(id: widget.routeArgument.id);
   // _con.listenForCart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minLeadingWidth: 2,
      contentPadding:
      EdgeInsets.symmetric(horizontal: 20),
      leading:
      // SvgPicture.asset("assets/img/locationarrow.svg"),
      Image.asset("assets/img/top-home-kitchen.png",height: 27,width: 27,),
      title: Text(
        "Top Home Kitchen",
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        S.of(context)
            .clickOnTheFoodToGetMoreDetailsAboutIt,
        maxLines: 2,
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }
}
