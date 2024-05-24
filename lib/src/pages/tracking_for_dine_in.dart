import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../controllers/tracking_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/FoodOrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../../src/helpers/app_config.dart' as config;
class TrackingWidgetForDinein extends StatefulWidget {
  final RouteArgument routeArgument;

  TrackingWidgetForDinein({Key key, this.routeArgument}) : super(key: key);

  @override
  _TrackingWidgetForDineinState createState() => _TrackingWidgetForDineinState();
}

class _TrackingWidgetForDineinState extends StateMVC<TrackingWidgetForDinein>
    with SingleTickerProviderStateMixin {
  TrackingController _con;
  TabController _tabController;
  int _tabIndex = 0;
  Map<String, dynamic> driverDetails = {} ;

  _TrackingWidgetForDineinState() : super(TrackingController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForOrder(orderId: widget.routeArgument.id);
    _tabController = TabController(
        length: widget.routeArgument.heroTag == "2" ? 2 : 1,
        initialIndex: _tabIndex,
        vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[kPrimaryColororange, kPrimaryColorLiteorange],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 70.0));
  Set<Marker> _createMarkers() {
    return <Marker>[
      Marker(
        markerId: MarkerId('Your Marker ID'), // A unique ID for the marker
        position: LatLng(double.parse( _con.order.foodOrders[0].food.restaurant.latitude), double.parse(_con.order.foodOrders[0].food.restaurant.longitude)), // Marker position
        infoWindow: InfoWindow(
          title: 'Your Marker Title',
          snippet: 'Your Marker Description',
        ),
        // You can also customize the marker icon if needed
        // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    ].toSet();
  }
  Future<void> _openGoogleMaps(BuildContext context) async {

    final String url = 'http://maps.google.com/maps?daddr=${_con.order.foodOrders[0].food.restaurant.latitude},${_con.order.foodOrders[0].food.restaurant.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  void click_on_map(LatLng latLng){

  }
  void _onMapTap(LatLng latLng) {
    // Handle the tap event here (e.g., navigate to a new page)
    // You can also add a new marker to the map if needed
    print('Map tapped at: $latLng');

    _openGoogleMaps(context);
  }

  @override
  Widget build(BuildContext context) {
   // driverDetails = json.decode(_con.order.driver_details);
  //  String driverName = driverDetails['driver_name'];
    //String vehicleNumber = driverDetails['vehicle_number'];
   // String mobile =  driverDetails['mobile'];
    //final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent, accentColor: Theme.of(context).accentColor);
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    //print(_con.order.res_longitude.toString() + "====> asfafafassasasa");
    // print("dineindelivery type: " + widget.routeArgument.heroTag);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          key: _con.scaffoldKey,
          bottomNavigationBar: Container(
            width: MediaQuery.of(context).size.width,
            height: 135,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.15),
                      offset: Offset(0, -2),
                      blurRadius: 5.0)
                ]),
            child: _con.order == null || _con.orderStatus.isEmpty
                ? CircularLoadingWidget(height: 120)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text("How would you rate this Kitchen?",
                    style: Theme.of(context).textTheme.subtitle1),
                Text(
                    S.of(context)
                        .click_on_the_stars_below_to_leave_comments,
                    style: Theme.of(context).textTheme.caption),
                SizedBox(height: 5),
                MaterialButton(
                  elevation: 0,
                  focusElevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/Reviews',
                        arguments: RouteArgument(
                            id: _con.order.id,
                            heroTag: "restaurant_reviews"));
                  },
                  padding: EdgeInsets.symmetric(vertical: 5),
                  shape: StadiumBorder(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: Helper.getStarsList(
                        double.parse(
                            _con.order.foodOrders[0].food.restaurant.rate),
                        size: 35),
                  ),
                ),
              ],
            ),
          ),
          body: _con.order == null || _con.orderStatus.isEmpty
              ? CircularLoadingWidget(height: 400)
              : RefreshIndicator(
            onRefresh: ()async{
              _con.listenForOrder(orderId: widget.routeArgument.id,message: "refresh");
              _con.isRefresh = true;
            },
                child: CustomScrollView(slivers: <Widget>[
            SliverAppBar(
                snap: true,
                floating: true,
                centerTitle: true,
                title: Text(
                  S.of(context).orderDetails,
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
                bottom: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelPadding: EdgeInsets.symmetric(horizontal: 15),
                    labelColor: Colors.white,
                    unselectedLabelColor: kPrimaryColororange,
                    //labelColor: Theme.of(context).primaryColor,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      //color: kPrimaryColororange,
                      gradient: LinearGradient(
                        colors: [
                          kPrimaryColororange,
                          // Replace with your desired start color
                          kPrimaryColorLiteorange,
                          // Replace with your desired end color
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    tabs: widget.routeArgument.heroTag == "2"
                        ? [
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(S.of(context).details),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(S.of(context).tracking_order),
                          ),
                        ),
                      ),
                    ]
                        : [
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(S.of(context).details),
                          ),
                        ),
                      ),
                    ]),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
                  Offstage(
                    offstage: 0 != _tabIndex,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Stack(
                        alignment: AlignmentDirectional.topCenter,
                        children: <Widget>[
                          Opacity(
                            opacity: _con.order.active ? 1 : 0.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 14),
                                  padding:
                                  EdgeInsets.only(top: 20, bottom: 5),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.9),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context)
                                              .focusColor
                                              .withOpacity(0.1),
                                          blurRadius: 5,
                                          offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: Theme(
                                    data: theme,
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      title: Column(
                                        children: <Widget>[
                                          Text(
                                            '${S.of(context).order_id}: #${_con.order.id}',
                                            style: TextStyle(
                                                foreground: Paint()
                                                  ..shader = linearGradient),
                                          ),
                                          Text(
                                            DateFormat('dd-MM-yyyy | HH:mm')
                                                .format(_con.order.dateTime),
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption,
                                          ),
                                        ],
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                      ),
                                      trailing: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Helper.getPrice(
                                              Helper.getTotalOrdersPrice(
                                                  _con.order),
                                              context,
                                              style:TextStyle(fontSize: 18.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: config.Colors().secondColor(1),
                                                  height: 1.35)),
                                          Text(
                                            '${_con.order.payment.method}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption,
                                          )
                                        ],
                                      ),
                                      children: <Widget>[
                                        Column(
                                            children: List.generate(
                                              _con.order.foodOrders.length,
                                                  (indexFood) {
                                                return FoodOrderItemWidget(
                                                    heroTag: 'my_order',
                                                    order: _con.order,
                                                    foodOrder: _con
                                                        .order.foodOrders
                                                        .elementAt(indexFood));
                                              },
                                            )),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      "Number of persons",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${_con.order.foodOrders.first.number_of_persons}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      "Dine-in Date",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    ),
                                                  ),
                                                  Text(
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(_con.order.foodOrders.first.dateTime),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ],
                                              ),

                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 20),
                                          child: Column(
                                            children: <Widget>[
                                              if(_con.order.coupon_code != "")
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(
                                                        "Applied Coupon(${_con.order.coupon_code})",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                      ),
                                                    ),
                                                    RichText(
                                                        softWrap: false,
                                                        overflow: TextOverflow.fade,
                                                        maxLines: 1,
                                                        text: TextSpan(
                                                          text: "-₹",
                                                          style:
                                                          TextStyle(fontWeight: FontWeight.w400, fontSize: Theme.of(context).textTheme.subtitle1.fontSize,color: kFBBlue),

                                                          children: <TextSpan>[
                                                            TextSpan(text: _con.order.coupon_amount ?? '', style:  Theme.of(context).textTheme.subtitle1),
                                                          ],
                                                        )


                                                    )
                                                  ],
                                                ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      "Delivery fees",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    ),
                                                  ),
                                                  Helper.getPrice(
                                                      _con.order.deliveryFee,
                                                      context,
                                                      style:  TextStyle(fontSize: 18.0,
                                                          fontWeight: FontWeight.w600,
                                                          color: config.Colors().secondColor(1),
                                                          height: 1.35))
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      'GST',
                                                      style: TextStyle(fontSize: 14.0, color: config
                                                          .Colors().secondColor(1), height: 1.35)
                                                    ),
                                                  ),
                                                  Helper.getPrice(
                                                      Helper.getTaxOrder(
                                                          _con.order),
                                                      context,
                                                      style: TextStyle(fontSize: 18.0,
                                                          fontWeight: FontWeight.w600,
                                                          color: config.Colors().secondColor(1),
                                                          height: 1.35))
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      S.of(context).total,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    ),
                                                  ),
                                                  Helper.getPrice(
                                                      Helper
                                                          .getTotalOrdersPrice(
                                                          _con.order),
                                                      context,
                                                      style: TextStyle(fontSize: 18.0,
                                                          fontWeight: FontWeight.w600,
                                                          color: config.Colors().secondColor(1),
                                                          height: 1.35))
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Wrap(
                                    alignment: WrapAlignment.end,
                                    children: <Widget>[
                                      if (_con.order.canCancelOrder() && _con.order.orderStatus.status == "" )
                                        MaterialButton(
                                          elevation: 0,
                                          focusElevation: 0,
                                          highlightElevation: 0,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext context) {
                                                // return object of type Dialog
                                                return AlertDialog(
                                                  title: Wrap(
                                                    spacing: 10,
                                                    children: <Widget>[
                                                      Icon(Icons.report,
                                                          color:
                                                          Colors.orange),
                                                      Text(
                                                        S
                                                            .of(context)
                                                            .confirmation,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .orange),
                                                      ),
                                                    ],
                                                  ),
                                                  content: Text(S
                                                      .of(context)
                                                      .areYouSureYouWantToCancelThisOrder),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 25),
                                                  actions: <Widget>[
                                                    MaterialButton(
                                                      elevation: 0,
                                                      focusElevation: 0,
                                                      highlightElevation: 0,
                                                      child: new Text(
                                                        S.of(context).yes,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                context)
                                                                .hintColor),
                                                      ),
                                                      onPressed: () {
                                                        _con.doCancelOrder();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    MaterialButton(
                                                      elevation: 0,
                                                      focusElevation: 0,
                                                      highlightElevation: 0,
                                                      child: new Text(
                                                        S.of(context).close,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .orange),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          textColor:
                                          Theme.of(context).hintColor,
                                          child: Wrap(
                                            children: <Widget>[
                                              Text(
                                                  S.of(context).cancelOrder +
                                                      " ",
                                                  style:
                                                  TextStyle(height: 1.3)),
                                              Icon(Icons.clear)
                                            ],
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 28,
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(100)),
                              gradient: LinearGradient(
                                colors: [
                                  kPrimaryColororange,
                                  // Replace with your desired start color
                                  kPrimaryColorLiteorange,
                                  // Replace with your desired end color
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            //color: _con.order.active ? Theme.of(context).accentColor : Colors.redAccent),
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              _con.order.active
                                  ? '${_con.order.orderStatus.status}'
                                  : S.of(context).canceled,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .merge(TextStyle(
                                  height: 1,
                                  color: Theme.of(context).primaryColor)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: 1 != _tabIndex,
                    child:  Column(
                      children: <Widget>[
                        SizedBox(height: 20,),
                        GestureDetector(
                          onTap: () => _openGoogleMaps(context),
                          child: Container(
                            height: 150,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(double.parse(_con.order.foodOrders[0].food.restaurant.latitude), double.parse(_con.order.foodOrders[0].food.restaurant.longitude)), // Initial position (San Francisco)
                                zoom: 12.0, // Zoom level
                              ),
                              onTap: _onMapTap,
                              markers: _createMarkers(), // Set of markers (if needed)
                              onMapCreated: (GoogleMapController controller) {
                                // Do something with the controller if needed
                              },
                            ),
                          ),
                        ),

                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Theme(
                              data: ThemeData(
                                primaryColor: Theme.of(context).accentColor,
                              ),
                              child: Stepper(
                                physics: ClampingScrollPhysics(),
                                controlsBuilder: (BuildContext context,
                                    ControlsDetails details) {
                                  return SizedBox(height: 0);
                                },
                                steps: _con.getTrackingSteps(context),
                                currentStep:_con.getCurrentStepIndex(_con.orderStatus),
                              ),
                            ),
                          ),
                        _con.order.deliveryAddress?.address != null
                            ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(5)),
                                    color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                        ? Colors.black38
                                        : Theme.of(context)
                                        .backgroundColor),
                                child: Icon(
                                  Icons.place,
                                  color: Theme.of(context).primaryColor,
                                  size: 38,
                                ),
                              ),
                              SizedBox(width: 15),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _con.order.deliveryAddress
                                          ?.description ??
                                          "",
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1,
                                    ),
                                    Text(
                                      _con.order.deliveryAddress
                                          ?.address ??
                                          S.of(context).unknown,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                            : SizedBox(height: 0),
                        SizedBox(height: 30)
                      ],
                    ),
                  ),
                ]),
            )
          ]),
              )),
    );
  }

}
