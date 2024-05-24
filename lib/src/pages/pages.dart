import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/controllers/home_controller.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import '../../utils/color.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../models/route_argument.dart';
import '../pages/home.dart';
import '../repository/user_repository.dart';
import 'cart.dart';
import 'settings.dart';

// ignore: must_be_immutable
class PagesWidget extends StatefulWidget {
  dynamic currentTab;
  RouteArgument routeArgument;
  Widget currentPage = HomeWidget();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  HomeController _con = HomeController();

   PagesWidget({
    Key key,
    this.currentTab,
  }) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else {
      currentTab = 1;
    }
  }

  @override
  _PagesWidgetState createState() {
    return _PagesWidgetState();
  }
}

class _PagesWidgetState extends State<PagesWidget> {
  initState() {
    super.initState();
    _selectTab(widget.currentTab);
    DateTime now = DateTime.now();
    String todayDate = "${now.day}-${now.month}-${now.year}";
  // widget._con.listenForAllRestaurants("1", todayDate, "0","0");
    //widget._con.listenForAllRestaurantsDelivery("2", todayDate);
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          if (currentUser.value.apiToken != null) {
            Navigator.of(context).pushNamed('/orderPage', arguments: 0);
          } else {
            Navigator.of(context).pushNamed('/Login');
          }
          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CalendarDialogWithoutRestaurant()
            ),
          );
          break;
        case 1:
         /* Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeWidget(parentScaffoldKey: widget.scaffoldKey, currentTab: tabItem,)
            ),
          );*/
          widget.currentPage = HomeWidget(parentScaffoldKey: widget.scaffoldKey, currentTab: tabItem,
          directedFrom: "",);
          break;
        case 3:

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KitchenListDeliveryWidget(restaurantsList: widget._con.AllRestaurantsDelivery,
                heroTag: "KitchenListDelivery",)
            ),
          );
          break;
        case 2:
          if(currentUser.value.apiToken != null){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartWidget(
                parentScaffoldKey: widget.scaffoldKey,
              ),
            ),
          );}
          else{
            Navigator.of(context).pushNamed('/Login');
          }
          break;
      }
    });
  }
  Future<bool> showExitPopup() async {
    return await showDialog(
      //show confirm dialogue
      //the return value will be from "Yes" or "No" options
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Do you want to exit an App?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            //return false when click on "NO"
            child: Text(
              'No',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          InkWell(
            onTap: () {
              SystemNavigator.pop();
            },
            child: SizedBox(
              height: 40,
              width: 100,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Yes",
                        style: Theme.of(context).textTheme.bodyText1.merge(
                            TextStyle(
                                color: Theme.of(context).primaryColor)))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ) ??
        false; //if showDialouge had returned null, then return false
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // onWillPop: Helper.of(context).onWillPop,
      onWillPop: showExitPopup,
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        // endDrawer: FilterWidget(onFilter: (filter) {
        //   Navigator.of(context).pushReplacementNamed('/Pages', arguments: widget.currentTab);
        // }),
        body: widget.currentPage,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).accentColor,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 28,
          elevation: 0,
          backgroundColor: Colors.grey[100],
         // selectedIconTheme: IconThemeData(size: 28),
       unselectedLabelStyle: TextStyle(
         color: Colors.grey
       ),
       //   unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
          currentIndex: 1,
          onTap: (int i) {
            this._selectTab(i);
          },
          // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                  Icons.assignment
              ),
              label: 'Orders',
            ),
           /* BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/img/dinein.svg',color: Colors.grey,height: 17,),
              label: '',
            ),*/
            BottomNavigationBarItem(
                label: '',
                icon: new SvgPicture.asset('assets/img/home.svg',height: 80,)),
           /* BottomNavigationBarItem(
              icon: new SvgPicture.asset('assets/img/delivery.svg',color: Colors.grey,height: 17,),
              label: '',
            ),*/
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Carts',
            ),
          ],
        ),
      ),
    );
  }

  void _updateCurrentTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
    });
  }
}
