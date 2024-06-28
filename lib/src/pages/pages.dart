import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/controllers/home_controller.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import '../../utils/color.dart';
import '../controllers/homr_test.dart';
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
  RouteArgument? routeArgument;
  Widget currentPage = HomePage();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  HomeController _con = HomeController();

   PagesWidget({
    Key? key,
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
          if (currentUser.value.apiToken != "") {
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
          widget.currentPage = HomePage(parentScaffoldKey: widget.scaffoldKey, currentTab: tabItem,
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
          if(currentUser.value.apiToken != ""){
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
                        style: Theme.of(context).textTheme.bodyText1!.merge(
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton:   FloatingActionButton(
          onPressed: () {
            widget.currentPage = HomePage(parentScaffoldKey: widget.scaffoldKey, currentTab: 1,
              directedFrom: "",);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 56.0,
            height: 56.0,
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:Colors.white,

            ),
            child: Image.asset("assets/img/logo_bottom.png"),
          ),
        ),


        bottomNavigationBar:

        BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 5.0,
          height: 65,
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 70),
                  child: IconButton(
                    icon: const Icon(
                      Icons.assignment,
                      size: 30,
                    ),
                    onPressed: () {
                      if (currentUser.value.apiToken != "") {
                        Navigator.of(context).pushNamed('/orderPage', arguments: 0);
                      } else {
                        Navigator.of(context).pushNamed('/Login');
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 30,
                  ),
                  onPressed: () {
                    if(currentUser.value.apiToken != ""){
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
                  },
                ),
              ],
            ),
          ),
        )
           ,
      ),
    );
  }

  void _updateCurrentTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
    });
  }
}
