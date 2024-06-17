import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../controllers/tracking_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/FoodOrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';

class TrackingOrderDelivery extends StatefulWidget {


  @override
  State<TrackingOrderDelivery> createState() => _TrackingOrderDeliveryState();
}

class _TrackingOrderDeliveryState extends State<TrackingOrderDelivery> {
  TrackingController _con;
  TabController _tabController;
  int _tabIndex = 0;
  Map<String, dynamic> driverDetails = {} ;
  String driverName = "";
  String vehicleNumber = "";
  String mobile = "";

  final Shader linearGradient = LinearGradient(
    colors: <Color>[kPrimaryColororange, kPrimaryColorLiteorange],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 70.0));

  @override
  Widget build(BuildContext context) {
    /*  driverDetails = json.decode(_con.order.driver_details);
    if (driverDetails != null && driverDetails.isNotEmpty) {
      driverName = driverDetails['driver_name'];
      vehicleNumber = driverDetails['vehicle_number'];
      mobile = driverDetails['mobile'];
    }*/


    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          snap: true,
          floating: true,
          centerTitle: true,
          title: Text(
            "Order Tracking",
            style: Theme.of(context)
                .textTheme
                .headline6
                .merge(TextStyle(letterSpacing: 1.3)),
          ),
          /*actions: <Widget>[
                    new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
                  ],*/
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,

        ),
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20,),


              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4, // Add elevation for a shadow effect
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Driver Name: $driverName'),
                        Text('Vehicle Number: $vehicleNumber'),
                        Text('Mobile: $mobile'),
                      ],
                    ),
                  ),
                ),
              ),
/*
              Container(
                height: MediaQuery.of(context).size.height * .7,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: WebView(
                    initialUrl: '${widget.con.order.tracking_url}',  // Replace with your desired URL
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController controller) {
                      // You can interact with the WebView here
                      // For example, evaluate JavaScript to hide specific elements
                      controller.evaluateJavascript(
                          "document.getElementById('header').style.display = 'none';" +
                              "document.getElementById('menu').style.display = 'none';" +
                              "document.getElementById('footer').style.display = 'none';"
                      );
                    },
                  ),
                ),
              ),*/

              SizedBox(height: 30)
            ],
          ),
        ),
      ]),
    );

  }
}



/*
class TrackingOrderDelivery extends StatefulWidget {
  final TrackingController con;

  TrackingOrderDelivery({Key key, this.con}) : super(key: key);

  @override
  _TrackingOrderDeliveryState createState() => _TrackingOrderDeliveryState();
}

class _TrackingOrderDeliveryState extends StateMVC<TrackingOrderDelivery>
  {
  TrackingController _con;
  TabController _tabController;
  int _tabIndex = 0;
  Map<String, dynamic> driverDetails = {} ;
  String driverName = "";
  String vehicleNumber = "";
  String mobile = "";

  @override
  void initState() {

    super.initState();
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  final Shader linearGradient = LinearGradient(
    colors: <Color>[kPrimaryColororange, kPrimaryColorLiteorange],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 70.0));

  @override
  Widget build(BuildContext context) {
    */
/*  driverDetails = json.decode(_con.order.driver_details);
    if (driverDetails != null && driverDetails.isNotEmpty) {
      driverName = driverDetails['driver_name'];
      vehicleNumber = driverDetails['vehicle_number'];
      mobile = driverDetails['mobile'];
    }*/
/*



    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            snap: true,
            floating: true,
            centerTitle: true,
            title: Text(
              "Order Tracking",
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .merge(TextStyle(letterSpacing: 1.3)),
            ),
            */
/*actions: <Widget>[
                    new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
                  ],*/
/*

            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,

          ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20,),


                     Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 4, // Add elevation for a shadow effect
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Driver Details',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text('Driver Name: $driverName'),
                                  Text('Vehicle Number: $vehicleNumber'),
                                  Text('Mobile: $mobile'),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Container(
                          height: MediaQuery.of(context).size.height * .7,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: WebView(
                              initialUrl: '${widget.con.order.tracking_url}',  // Replace with your desired URL
                              javascriptMode: JavascriptMode.unrestricted,
                              onWebViewCreated: (WebViewController controller) {
                                // You can interact with the WebView here
                                // For example, evaluate JavaScript to hide specific elements
                                controller.evaluateJavascript(
                                    "document.getElementById('header').style.display = 'none';" +
                                        "document.getElementById('menu').style.display = 'none';" +
                                        "document.getElementById('footer').style.display = 'none';"
                                );
                              },
                            ),
                          ),
                        ),

                    SizedBox(height: 30)
                  ],
                ),
              ),
            ]),
          );

  }
}
*/
