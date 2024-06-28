import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/pages/CardsCarouselWidgetHome.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/delivery_pickup.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/pages.dart';
import 'package:food_delivery_app/src/pages/paymentPage.dart';
import 'package:food_delivery_app/src/pages/profile.dart';
import 'package:food_delivery_app/src/pages/restaurant.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:food_delivery_app/utils/color.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/cart_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/homr_test.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../models/route_argument.dart';
import '../../generated/l10n.dart';

class CheckoutPage extends StatefulWidget {

  String? total;
  final RouteArgument? routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey = new GlobalKey<ScaffoldState>();
  dynamic currentTab;
  Widget currentPage = HomePage();
  bool isCurrentKitchen = true;

  CheckoutPage({Key? key,  this.routeArgument, this.total}) : super(key: key);

 /* @override
  State<CheckoutPage> createState() => _CheckoutPageState();*/

  @override
  _CheckoutPageState createState() {
    return _CheckoutPageState();
  }
}

class _CheckoutPageState extends StateMVC<CheckoutPage> {

  CartController? _con;
  HomeController _homeCon = HomeController();

  @override
  void initState() {
    // TODO: implement initState
    _selectTab(widget.currentTab);
    super.initState();
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {
    
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey,
      // bottomNavigationBar: CartBottomDetailsWidget(con: null),
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text( S.of(context).checkout,
          style: Theme.of(context).textTheme.headline5!.merge(TextStyle( color: Colors.red,letterSpacing: 1.3), ),
        ),
      ),
      body: widget.isCurrentKitchen ? SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 70,),
            Container(
              padding: EdgeInsets.all(10),
              height: 380,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                  color: Colors.white
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 15,),
                    Row(
                      children: [
                        Icon(Icons.person,size: 22),
                        SizedBox(width: 10,),
                        Text('Payment Setting',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600
                          ),)
                      ],
                    ),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Number',  labelStyle: TextStyle(
                            color: Colors.grey
                        )


                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                            labelText: 'Exp. Date',
                            labelStyle: TextStyle(
                                color: Colors.grey
                            )
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'CVV',
                            labelStyle: TextStyle(
                                color: Colors.grey
                            )
                        ),
                      ),
                    ),
                    SizedBox(height: 25,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(onPressed: () {
                            Navigator.pop(context);
                          }, child: Text('Cancel',style: TextStyle(
                              color: Colors.black,
                              fontSize: 20
                          ),)),
                          Spacer(),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              gradient: LinearGradient(
                                colors: [
                                  kPrimaryColororange,
                                  kPrimaryColorLiteorange
                                ],
                              ),
                            ),
                            child: MaterialButton(
                              elevation: 0,
                              focusElevation: 0,
                              highlightElevation: 0,
                              onPressed: () {
                                //Navigator.of(context).pushReplacementNamed('/paymentPage');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(total:widget.total!),
                                  ),
                                );
                              },
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 8),
                              shape: StadiumBorder(),
                              //color: Theme.of(context).accentColor,
                              child: Wrap(
                                spacing: 10,
                                children: [
                                  Text(
                                    "Save",
                                    style: TextStyle(
                                        color: Theme
                                            .of(context)
                                            .primaryColor,
                                        fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text('Or check out with'),
            ),

          ],
        ),
      ) : widget.currentPage,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //selectedItemColor: Theme.of(context).accentColor,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: 22,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        selectedIconTheme: IconThemeData(size: 28),
        unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
        currentIndex: 2,
        onTap: (int i) {
          // print("DS>>> "+ i.toString());
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
    );
  }



  void _selectTab(int tabItem) {
    setState(() {
      // print("DS>> am i here?? "+tabItem.toString());
      widget.currentTab = tabItem;
      switch (tabItem) {

        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SettingsWidget()
            ),
          );

          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CalendarDialogWithoutRestaurant()
            ),
          );
          break;
        case 2:

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(parentScaffoldKey: widget.parentScaffoldKey,
                  currentTab: tabItem, directedFrom: "forHome",)
            ),
          );
          break;
        case 3:

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => KitchenListDeliveryWidget(restaurantsList: _homeCon.AllRestaurantsDelivery,
                  heroTag: "KitchenListDelivery",)
            ),
          );
          break;
        case 4:

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
