import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/controllers/home_controller.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/pages.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shimmer/shimmer.dart';
import '../provider.dart';
import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../controllers/cart_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/CartItemWidget.dart';
import '../elements/DrawerWidget.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart' as settingRepo;
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import '../provider.dart';
import '../repository/user_repository.dart';
import 'package:provider/provider.dart';



class CartWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  dynamic currentTab;
  Widget currentPage = HomeWidget();
  bool isCurrentKitchen = true;
  String directedFrom;
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  CartWidget({Key key, this.routeArgument, this.parentScaffoldKey, this.directedFrom}) : super(key: key);

  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends StateMVC<CartWidget> {

  bool isLoading = false; // Add a boolean to control loader visibility
  CartController _con;
  HomeController _homeCon = HomeController();
  String defaultLanguage;

  _CartWidgetState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    getCurrentDefaultLanguage();
   // _con.listenForCarts();
    _selectTab(widget.currentTab);
    print("DS>> arguments "+ widget.parentScaffoldKey.toString());
    _showLoader();

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

  Future<void> _showLoader() async {
    setState(() {
      isLoading = true;
      _con.refreshCarts();
    });
    // Delay for 3 seconds
    await Future.delayed(Duration(seconds: 3));
      setState(() {
        isLoading = false;
      });
    // Close the dialog after 3 seconds

  }


  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }
  final Shader linearGradient = LinearGradient(
    colors: <Color>[kPrimaryColororange, kPrimaryColorLiteorange],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 70.0));

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //onWillPop: Helper.of(context).onWillPop,
      onWillPop: (){
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        drawer: DrawerWidget(),
        bottomNavigationBar:  BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor:  Colors.grey,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 28,
          elevation: 0,
          unselectedItemColor:  Colors.grey,
          backgroundColor: Colors.grey[100],
          selectedIconTheme: IconThemeData(size: 28),
          unselectedLabelStyle: TextStyle(
              color: Colors.grey
          ),
          onTap: (int i) {
            print("DS>>> "+ i.toString());
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
            // BottomNavigationBarItem(
            //   icon: SvgPicture.asset('assets/img/dinein.svg',color: Colors.grey,height: 17,),
            //   label: '',
            // ),
            // BottomNavigationBarItem(
            //     label: '',
            //     icon: new SvgPicture.asset('assets/img/home.svg',height: 70,)),
            // BottomNavigationBarItem(
            //   icon: new SvgPicture.asset('assets/img/delivery.svg',color: Colors.grey,height: 17,),
            //   label: '',
            // ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.shopping_bag_outlined),
            //   label: 'Carts',
            // ),
          ],
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(
              builder: (context) {
                return new IconButton(
                    icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
                    onPressed: () =>  Scaffold.of(context).openDrawer()
                );
              }
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: /*Text(
            S.of(context).delivery,
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
          )*/
          TranslationWidget(
            message:  S.of(context).cart,
            fromLanguage: "English",
            toLanguage: defaultLanguage,
            builder: (translatedMessage) => Text(
              translatedMessage,
                style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
            ),
          ),
        ),
        body: _con.isloading ?ShimmerList() :  widget.isCurrentKitchen ? RefreshIndicator(
          onRefresh: _con.refreshCarts,
          child: _con.carts.isEmpty
              ?Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/img/cart_empty.png",height: 200,width: 200,),
                  Center(child:  TranslationWidget(
            message: "Your cart is empty",
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
          ),),
                ],
              )
              : Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    ListView(
                      primary: true,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            leading: Icon(
                              Icons.shopping_cart,
                              color: Theme.of(context).hintColor,
                            ),
                            title: /*Text(
                              S.of(context).order_review,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline4,
                            )*/
                            TranslationWidget(
                              message:  "Order Review",
                              fromLanguage: "English",
                              toLanguage: defaultLanguage,
                              builder: (translatedMessage) => Text(
                                translatedMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                            subtitle: /*Text(
                              S.of(context).verify_your_quantity_and_click_checkout,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.caption,
                            )*/
                            TranslationWidget(
                              message:  S.of(context).verify_your_quantity_and_click_checkout,
                              fromLanguage: "English",
                              toLanguage: defaultLanguage,
                              builder: (translatedMessage) => Text(
                                translatedMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height -350,
                          child: SingleChildScrollView(
                            child: ListView.separated(
                              padding: EdgeInsets.only(top: 15, bottom: 120),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              primary: false,
                              itemCount: _con.carts.length,
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 8);
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                                  child: CartItemWidget(
                                    cart: _con.carts.elementAt(index),
                                    heroTag: 'cart',
                                    increment: () {

                                   //   Provider.of<CartProvider>(context,listen: false).listenForCartsCount();

                                      _con.incrementQuantity(_con.carts.elementAt(index));
                                      setState(() { });
                                      Provider.of<CartProvider>(context,listen: false).cartassign(_con.carts);
                                    },
                                    decrement: () {
                                      if(_con.carts.elementAt(index).quantity ==1){

                                        _con.removeFromCart(_con.carts.elementAt(index));
                                        print("carts lengthSL:- ${_con.carts}");
                                       setState(() { });
                                      }
                                      else{
                                        _con.decrementQuantity(_con.carts.elementAt(index));
                                      }

                                      //Provider.of<CartProvider>(context,listen: false).listenForCartsCount();
                                      setState(() { });
                                      Provider.of<CartProvider>(context,listen: false).cartassign(_con.carts);

                                    },
                                    onDismissed: () {
                                      _con.removeFromCart(_con.carts.elementAt(index));

                                     // Provider.of<CartProvider>(context,listen: false).listenForCartsCount();
                                      setState(() { });
                                      Provider.of<CartProvider>(context,listen: false).cartassign(_con.carts);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    CartBottomDetailsWidget(con: _con, parentScaffoldKey: new GlobalKey(),),
                  ],
                ),
        ) : widget.currentPage,
      ),
    );
  }

  void _selectTab(int tabItem) {
    setState(() {
      print("DS>> am i here?? "+tabItem.toString());
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

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeWidget(parentScaffoldKey: widget.parentScaffoldKey,
                  currentTab: 1, directedFrom: "forHome",)
            ),
          );
          break;
        case 5:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => KitchenListDeliveryWidget(restaurantsList: _homeCon.AllRestaurantsDelivery,
                  heroTag: "KitchenListDelivery",)
            ),
          );
          break;
        case 4:
         /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartWidget(
                parentScaffoldKey: widget.parentScaffoldKey,
              ),
            ),
          );*/
          break;
      }
    });
  }
}
class ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int offset = 0;
    int time = 1000;

    return SafeArea(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          offset += 5;
          time = 800 + offset;

         // print(time);

          return Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Shimmer.fromColors(
                highlightColor: Colors.white,
                baseColor: Colors.grey[350],
                child: ShimmerLayout(),
                period: Duration(milliseconds: time),
              ));
        },
      ),
    );
  }
}

class ShimmerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - 150;
    double containerHeight = 15;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 7.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 100,
            width: 100,
            color: Colors.grey,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: containerHeight,
                width: containerWidth,
                color: Colors.grey,
              ),
              SizedBox(height: 5),
              Container(
                height: containerHeight,
                width: containerWidth,
                color: Colors.grey,
              ),
              SizedBox(height: 5),
              Container(
                height: containerHeight,
                width: containerWidth * 0.75,
                color: Colors.grey,
              )
            ],
          )
        ],
      ),
    );
  }
}
