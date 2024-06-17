import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/category_controller.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../elements/FoodGridItemWidget.dart';
import '../elements/FoodListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';
import '../repository/settings_repository.dart' as settingRepo;

class CategoryWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  CategoryWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends StateMVC<CategoryWidget> {
  // TODO add layout in configuration file
  String layout = 'grid';

  CategoryController _con;
  String defaultLanguage;

  _CategoryWidgetState() : super(CategoryController()) {
    _con = controller;
  }

  @override
  void initState() {
    getCurrentDefaultLanguage();
    _con.listenForFoodsByCategory(id: widget.routeArgument.id);
    _con.listenForCategory(id: widget.routeArgument.id);
    _con.listenForCart();
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
    print("DS>>> what is wrong "+_con.foods.length.toString());
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      endDrawer: FilterWidget(onFilter: (filter) {
        Navigator.of(context).pushReplacementNamed('/Category', arguments: RouteArgument(id: widget.routeArgument.id));
      }),
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => _con.scaffoldKey?.currentState?.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: /*Text(
          S.of(context).category,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 0)),
        )*/
        TranslationWidget(
          message:  S.of(context).category,
          fromLanguage: "English",
          toLanguage: defaultLanguage,
          builder: (translatedMessage) => Text(
            translatedMessage,
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 0)),
          ),
        ),

      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshCategory,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBarWidget(onClickFilter: (filter) {
                  _con.scaffoldKey?.currentState?.openEndDrawer();
                }),
              ),
              SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.category,
                    color: Theme.of(context).hintColor,
                  ),
                  title: /*Text(
                    _con.category?.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline4,
                  )*/
                  TranslationWidget(
                    message: _con.category?.name ?? '',
                    fromLanguage: "English",
                    toLanguage: defaultLanguage,
                    builder: (translatedMessage) => Text(
                      translatedMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                    ],
                  ),
                ),
              ),

              _con.foods.isEmpty
                  ? CircularLoadingWidget(height: 500)
             /* Center(child: Text("No data Available"))*/
                  : GridView.count(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this produces 2 rows.
                    crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
                    // Generate 100 widgets that display their index in the List.
                    children: List.generate(_con.foods.length, (index) {
                      print("--->"+_con.foods.length.toString());
                      return FoodGridItemWidget(
                          heroTag: 'category_grid',
                          food: _con.foods.elementAt(index),
                          onPressed: () {
                            if (currentUser.value.apiToken == null) {
                              Navigator.of(context).pushNamed('/Login');
                            } else {
                              if (_con.isSameRestaurants(_con.foods.elementAt(index))) {
                                _con.addToCart(_con.foods.elementAt(index));
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    // return object of type Dialog
                                    return AddToCartAlertDialogWidget(
                                        oldFood: _con.carts.elementAt(0)?.food,
                                        newFood: _con.foods.elementAt(index),
                                        onPressed: (food, {reset: true}) {
                                          return _con.addToCart(_con.foods.elementAt(index), reset: true);
                                        });
                                  },
                                );
                              }
                            }
                          });
                    }),
                  )
            ],
          ),
        ),
      ),
    );
  }
}
