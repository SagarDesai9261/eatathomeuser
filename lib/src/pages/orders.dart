import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/controllers/home_controller.dart';
import 'package:food_delivery_app/src/elements/DrawerWidget.dart';
import 'package:food_delivery_app/src/models/order.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/pages.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:food_delivery_app/utils/color.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../../my_widget/dine_in_order_view.dart';
import '../controllers/homr_test.dart';
import '../controllers/order_controller.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../repository/order_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

import 'package:food_delivery_app/src/repository/translation_widget.dart';

void main() {
  runApp(MaterialApp(
    home: OrdersWidget(),
  ));
}

class OrdersWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final Function(int)? updateCurrentTab; // Callback function
  HomeController _con = HomeController();

  dynamic currentTab;
  Widget currentPage = HomePage();
  bool isCurrentKitchen = true;

  OrdersWidget({Key? key, this.parentScaffoldKey, this.updateCurrentTab})
      : super(key: key);

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends StateMVC<OrdersWidget> {
  OrderController? _con;
  bool isLoading = false; // Add a boolean to control loader visibility
  ScrollController _dineInScrollController = ScrollController();
  ScrollController _deliveryScrollController = ScrollController();
  List<Order> dineinOrdersList = [];
  List<Order> deliveryOrdersList = [];
  String defaultLanguage = "";
  int dineInLimit = 6; // Initial limit for dine-in orders
  int dineInOffset = 0; // Initial offset for dine-in orders
 // List<Order> dineinOrdersList = [];

  int deliveryLimit = 6; // Initial limit for delivery orders
  int deliveryOffset = 0; // Initial offset for delivery orders
  //List<Order> deliveryOrdersList = [];

  _OrdersWidgetState() : super(OrderController()) {
    _con = controller as OrderController?;
  }
  Future<void> fetchDineInOrders({bool refresh = false}) async {
    try {
      if (refresh) {
        // Reset offset when refreshing
        dineInOffset = 0;
      }
      Stream<Order> dineInOrdersStream = await getOrders(limit: dineInLimit, offset: dineInOffset, deliveryType: 2);
      List<Order> fetchedDineInOrders = await dineInOrdersStream.toList();

      setState(() {
        if (refresh) {
          dineinOrdersList = fetchedDineInOrders;
        } else {
          dineinOrdersList.addAll(fetchedDineInOrders);
        }
        dineInOffset += dineInLimit; // Increment offset for next page
      });
    } catch (e) {
      print("Error fetching dine-in orders: $e");
    }
  }
  Future<void> fetchDeliveryOrders({bool refresh = false}) async {
    try {
      if (refresh) {
        // Reset offset when refreshing
        deliveryOffset = 0;
      }
      Stream<Order> deliveryOrdersStream = await getOrders(limit: deliveryLimit, offset: deliveryOffset, deliveryType: 1);
      List<Order> fetchedDeliveryOrders = await deliveryOrdersStream.toList();

      setState(() {
        if (refresh) {
          deliveryOrdersList = fetchedDeliveryOrders;
        } else {
          deliveryOrdersList.addAll(fetchedDeliveryOrders);
        }
        deliveryOffset += deliveryLimit; // Increment offset for next page
      });
    } catch (e) {
      print("Error fetching delivery orders: $e");
    }
  }


  @override
  void initState() {
    _selectTab(widget.currentTab ?? 6);
    getCurrentDefaultLanguage();
    _dineInScrollController.addListener(_dineInScrollListener);
    _deliveryScrollController.addListener(_deliveryScrollListener);

    // Fetch initial data for dine-in and delivery tabs
    fetchDineInOrders();
    fetchDeliveryOrders();
    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingsRepo.getDefaultLanguageName().then((_langCode) {
      print("DS>> DefaultLanguageret " + _langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }

  void dispose() {
    // Remove listeners to avoid memory leaks
    _dineInScrollController.removeListener(_dineInScrollListener);
    _dineInScrollController.dispose();
    _deliveryScrollController.removeListener(_deliveryScrollListener);
    _deliveryScrollController.dispose();
    super.dispose();
  }
  void _dineInScrollListener() {
    if (_dineInScrollController.position.pixels ==
        _dineInScrollController.position.maxScrollExtent) {
      // User has scrolled to the end, fetch next page of dine-in orders
      fetchDineInOrders();
    }
  }

// Scroll listener for delivery tab
  void _deliveryScrollListener() {
    print("scroll down");
    if (_deliveryScrollController.position.pixels ==
        _deliveryScrollController.position.maxScrollExtent) {
      // User has scrolled to the end, fetch next page of delivery orders
      print("scroll down delivery");
      fetchDeliveryOrders();
    }
  }
  @override
  void didUpdateWidget(PagesWidget oldWidget) {
     _selectTab(oldWidget.currentTab ?? 6);
    super.didUpdateWidget(oldWidget);
    widget.updateCurrentTab!(oldWidget.currentTab);
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[kPrimaryColororange, kPrimaryColorLiteorange],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 70.0));

  @override
  Widget build(BuildContext context) {
    print("DS>> order length " + _con!.orders.length.toString());
    // if (_con.orders.length > 0) {
    //   for (int i = 0; i <= _con.orders.length - 1; i++) {
    //     String orderId = _con.orders[i]
    //         .id; // Assuming orderId is the property that uniquely identifies an order and it's a string
    //
    //     if (_con.orders[i].delivery_dinein == 1 &&
    //         !deliveryOrdersList.any((order) => order.id == orderId)) {
    //       deliveryOrdersList.add(_con.orders[i]);
    //     }
    //
    //     if (_con.orders[i].delivery_dinein == 2 &&
    //         !dineinOrdersList.any((order) => order.id == orderId)) {
    //       dineinOrdersList.add(_con.orders[i]);
    //       print(dineinOrdersList.length);
    //     }
    //   }
    // }

    return WillPopScope(
      onWillPop: ()async{
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomePage(parentScaffoldKey: new GlobalKey(), directedFrom: "forHome",
                    currentTab: 1,)
          ),
        );
        return false;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _con!.scaffoldKey,
          drawer: DrawerWidget(),
          appBar: widget.isCurrentKitchen
              ? AppBar(
                  leading: Builder(builder: (context) {
                    return new IconButton(
                        icon: new Icon(Icons.sort,
                            color: Theme.of(context).hintColor),
                        onPressed: () => Scaffold.of(context).openDrawer());
                  }),
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title:
                      TranslationWidget(
                    message: S.of(context).my_orders,
                    fromLanguage: "English",
                    toLanguage: defaultLanguage,
                    builder: (translatedMessage) => Text(
                      translatedMessage,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                         ! .merge(TextStyle(letterSpacing: 1.3)),
                    ),
                  ),
                  bottom: widget.isCurrentKitchen
                      ? TabBar(

                          indicatorWeight: 14,
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          indicator: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kPrimaryColororange,
                                kPrimaryColorLiteorange
                              ],
                            ),
                            border: Border.all(width: 50.0),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          indicatorPadding: EdgeInsets.only(
                            top: 37,
                          ),
                          tabs: [
                            TranslationWidget(
                              message: S.of(context).delivery,
                              fromLanguage: "English",
                              toLanguage: defaultLanguage,
                              builder: (translatedMessage) => Text(
                                translatedMessage,
                                style: TextStyle(
                                    color:secondColor(1),
                                    fontSize: 20),
                              ),
                            ),
                            TranslationWidget(
                              message: "Dine-in",
                              fromLanguage: "English",
                              toLanguage: defaultLanguage,
                              builder: (translatedMessage) => Text(
                                translatedMessage,
                                style: TextStyle(
                                    color: secondColor(1),
                                    fontSize: 20),
                              ),
                            ),
                            /*Text(
                              S.of(context).delivery,
                              style: TextStyle(
                                  color: settingsRepo
                                              .deliveryAddress.value?.address ==
                                          null
                                      ? Theme.of(context).hintColor
                                      : Theme.of(context).primaryColor,
                                  fontSize: 20),
                            )*/

                          ],
                        )
                      : PreferredSize(
                          preferredSize: Size.zero,
                          child: Container(),
                        ),
                )
              : PreferredSize(
                  preferredSize: Size.zero,
                  child: Container(),
                ),
          body: widget.isCurrentKitchen
              ? TabBarView(
                  children: [

                    currentUser.value.apiToken == null
                        ? PermissionDeniedWidget()
                        : isLoading
                            ?ShimmerList()
                            : deliveryOrdersList.isEmpty
                                ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/img/no-order-found.png",height: 200,width: 200,),
                                    Center(
                                      child: TranslationWidget(
                                        message: "Couldn't find any orders.",
                                        fromLanguage: "English",
                                        toLanguage: defaultLanguage,
                                        builder: (translatedMessage) => Text(
                                          translatedMessage,
                                          style: TextStyle(
                                              foreground: Paint()
                                                ..shader = linearGradient,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : RefreshIndicator(
                      onRefresh: () => fetchDeliveryOrders(refresh: true),
                                    child: deliveryOrdersList.length > 0
                                        ? ListView.builder(
                                        controller: _deliveryScrollController,
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                primary: false,
                                                itemCount:
                                                    deliveryOrdersList.length,
                                                itemBuilder: (context, index) {
                                                  print(deliveryOrdersList
                                                      .length);
                                                  var _order =
                                                      deliveryOrdersList[index];
                                                  print(
                                                      "Order data ${_order.foodOrders!.isEmpty}");
                                                  if (_order
                                                      .foodOrders!.isEmpty) {
                                                    return Container();
                                                  }
                                                  return Container(
                                                    margin: index == 0 ? EdgeInsets.only(top: 5) : null,
                                                    child: OrderItemWidget(
                                                      expanded: index == 0
                                                          ? true
                                                          : false,
                                                      order: _order,
                                                      onCanceled: (e) {
                                                        _con!.doCancelOrder(
                                                            _order);
                                                      },
                                                    ),
                                                  );
                                                },

                                              )
                                        : SizedBox(),
                                  ),

                    currentUser.value.apiToken == null
                        ? PermissionDeniedWidget()
                        : isLoading
                        ? ShimmerList()
                        : dineinOrdersList.isEmpty
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/img/no-order-found.png",height: 200,width: 200,),
                        Center(
                          child: TranslationWidget(
                            message: "Couldn't find any orders.",
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: TextStyle(
                                  foreground: Paint()
                                    ..shader = linearGradient,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    )
                        : RefreshIndicator(
                      onRefresh: () => fetchDineInOrders(refresh: true),
                      child: dineinOrdersList.length > 0
                          ? ListView.separated(
                        controller: _dineInScrollController,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount:
                        dineinOrdersList.length,
                        itemBuilder: (context, index) {
                          print(dineinOrdersList
                              .length);
                          var _order =
                          dineinOrdersList[index];
                          print(
                              "Order data ${_order.foodOrders!.isEmpty}");
                          if (_order
                              .foodOrders!.isEmpty) {
                            return Container();
                          }
                          return Container(
                            margin: index == 0 ? EdgeInsets.only(top: 5) : null,
                            child: OrderItemWidget(
                              expanded: index == 0
                                  ? true
                                  : false,
                              order: _order,
                              onCanceled: (e) {
                                _con!.doCancelOrder(
                                    _order);
                              },
                            ),
                          );
                        },
                        separatorBuilder:
                            (context, index) {
                          return SizedBox(height: 6);
                        },
                      )
                          : SizedBox(),
                    ),
                  ],
                )
              : widget.currentPage,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton:   FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                     // parentScaffoldKey: widget.parentScaffoldKey,
                      currentTab: 1,
                      directedFrom: "forHome",
                    )),
              );
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
                             // parentScaffoldKey: widget.parentScaffoldKey,
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
      ),
    );
  }

  void _selectTab(int tabItem) {
    setState(() {
      isLoading = true;

      // Delay execution for 3 seconds to simulate loading
      Future.delayed(Duration(seconds: 4), () {
        // Set isLoading to false to hide loader
        setState(() {
          isLoading = false;
        });

        // Your existing switch case logic here...
      });
    //  print("DS>> am i here?? " + tabItem.toString());
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          // if (currentUser.value.apiToken != "") {
          //   Navigator.of(context).pushNamed('/orderPage', arguments: 0);
          // } else {
          //   Navigator.of(context).pushNamed('/Login');
          // }

          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CalendarDialogWithoutRestaurant()),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      parentScaffoldKey: widget.parentScaffoldKey!,
                      currentTab: 1,
                      directedFrom: "forHome",
                    )),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => KitchenListDeliveryWidget(
                      restaurantsList: widget._con.AllRestaurantsDelivery,
                      heroTag: "KitchenListDelivery",
                    )),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartWidget(
                parentScaffoldKey: widget.parentScaffoldKey,
              ),
            ),
          );
          break;
      }
    });
  }
}
