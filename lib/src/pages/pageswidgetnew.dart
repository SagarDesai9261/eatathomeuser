import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/src/controllers/home_controller.dart';
import 'package:food_delivery_app/src/elements/DrawerWidget.dart';
import 'package:food_delivery_app/src/elements/FilterWidget.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/pages/CardsCarouselWidgetHome.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';

import '../controllers/homr_test.dart';

class PagesWidgetNew extends StatefulWidget {
  dynamic currentTab;
  RouteArgument routeArgument;
  Widget currentPage = HomePage();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  HomeController _con = HomeController();

  @override
  _PagesWidgetNewState createState() {
    return _PagesWidgetNewState();
  }
}

class _PagesWidgetNewState extends State<PagesWidgetNew> {

  initState() {
    super.initState();
    _selectTab(widget.currentTab);
    DateTime now = DateTime.now();
    String todayDate = "${now.day}-${now.month}-${now.year}";
  }

  @override
  void didUpdateWidget(PagesWidgetNew oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }


  void _updateCurrentTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
    });
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          if(currentUser.value.apiToken != null){
            widget.currentPage = SettingsWidget(parentScaffoldKey: widget.scaffoldKey, updateCurrentTab: _updateCurrentTab,);
          }
          else{
            Navigator.of(context).pushNamed('/Login');

          }
          break;
        case 1:
          widget.currentPage = KitchenList( heroTag: "KitchenList",);
          break;
        case 2:
          widget.currentPage = HomePage(parentScaffoldKey: widget.scaffoldKey, currentTab: tabItem,);
          break;
        case 3:
          widget.currentPage = KitchenListDeliveryWidget(restaurantsList: widget._con.AllRestaurantsDelivery,
            heroTag: "KitchenListDelivery",);
          break;
        case 4:
          widget.currentPage = CartWidget(parentScaffoldKey: widget.scaffoldKey); //FavoritesWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        endDrawer: FilterWidget(onFilter: (filter) {
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: widget.currentTab);
        }),
        body: widget.currentPage,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).accentColor,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 22,
          elevation: 0,
          backgroundColor: Colors.grey[100],
          selectedIconTheme: IconThemeData(size: 28),
          unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
          currentIndex: widget.currentTab,
          onTap: (int i) {
            this._selectTab(i);
          },
          // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/img/profile.svg',color: Colors.grey,height: 17,),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/img/dinein.svg',color: Colors.grey,height: 17,),
              label: '',
            ),
            BottomNavigationBarItem(
                label: '',
                icon: new SvgPicture.asset('assets/img/home.svg',height: 70,)),
            BottomNavigationBarItem(
              icon: new SvgPicture.asset('assets/img/delivery.svg',color: Colors.grey,height: 17,),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: new SvgPicture.asset('assets/img/cart.svg',color: Colors.grey,height: 17,),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
