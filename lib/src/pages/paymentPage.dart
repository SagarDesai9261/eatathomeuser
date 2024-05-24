import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/delivery_pickup.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/profile.dart';
import 'package:food_delivery_app/src/pages/restaurant.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../models/route_argument.dart';

class PaymentPage extends StatefulWidget {


  String total;
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey = new GlobalKey<ScaffoldState>();
  dynamic currentTab;
  Widget currentPage = HomeWidget();
  bool isCurrentKitchen = true;

  PaymentPage({Key key, this.routeArgument,this.total}) : super(key: key);

 /* @override
  State<PaymentPage> createState() => _PaymentPageState();*/

  @override
  _PaymentPageState createState() {
    return _PaymentPageState();
  }
}

class _PaymentPageState extends StateMVC<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).hintColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).checkout,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: widget.isCurrentKitchen ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              leading: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).hintColor,
              ),
              title: Text(
                S.of(context).payment_mode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headline4,
              ),
              subtitle: Text(
                S.of(context).select_your_preferred_payment_mode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.05,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 35,vertical: 10),
            child: Image.asset('assets/img/payment-mode.png'),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.05,),
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/OrderSuccess');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 48,
              width: MediaQuery.of(context).size.width*0.8,
              decoration: BoxDecoration(
                  gradient:  LinearGradient(
                  colors: [
                    kPrimaryColororange,
                    kPrimaryColorLiteorange
                  ],
                ),borderRadius: BorderRadius.circular(30)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text('Confirm Payment',style: Theme.of(context).textTheme.labelLarge.merge(
                      TextStyle(color: Colors.white)
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('AED',style: Theme.of(context).textTheme.titleSmall.merge(
                          TextStyle(color: Colors.white)
                        ),),
                        Text(widget.total.toString(),style: Theme.of(context).textTheme.titleLarge.merge(
                          TextStyle(color: Colors.white))),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          )

        ],
      ) : widget.currentPage,
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
          widget.isCurrentKitchen = false;
          widget.currentPage = SettingsWidget(); //ProfileWidget(parentScaffoldKey: widget.parentScaffoldKey);
          break;
        case 1:
          widget.isCurrentKitchen = false;
          widget.currentPage = RestaurantWidget(parentScaffoldKey: widget.parentScaffoldKey );
          break;
        case 2:
          widget.isCurrentKitchen = false;
          //widget.currentPage = HomeWidget(parentScaffoldKey: widget.parentScaffoldKey, currentTab: tabItem,);
          break;
        case 3:
          widget.isCurrentKitchen = false;
          widget.currentPage = DeliveryPickupWidget();
          break;
        case 4:
          widget.isCurrentKitchen = false;
          widget.currentPage = CartWidget(key: widget.parentScaffoldKey); //FavoritesWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }
}
