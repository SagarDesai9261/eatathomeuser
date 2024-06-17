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
import '../elements/track_order_delivery.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../../src/helpers/app_config.dart' as config;

class TrackingWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  TrackingWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _TrackingWidgetState createState() => _TrackingWidgetState();
}

class _TrackingWidgetState extends StateMVC<TrackingWidget>
    with SingleTickerProviderStateMixin {
  TrackingController _con;
  TabController _tabController;
  int _tabIndex = 0;
  Map<String, dynamic> driverDetails = {} ;
  String driverName = "";
  String vehicleNumber = "";
  String mobile = "";
  _TrackingWidgetState() : super(TrackingController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForOrder(orderId: widget.routeArgument.id);
    _tabController = TabController(
        length: widget.routeArgument.heroTag == "1" ? 2 : 1,
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

  @override
  Widget build(BuildContext context) {
  /*  driverDetails = json.decode(_con.order.driver_details);
    if (driverDetails != null && driverDetails.isNotEmpty) {
      driverName = driverDetails['driver_name'];
      vehicleNumber = driverDetails['vehicle_number'];
      mobile = driverDetails['mobile'];
    }*/



    //final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent, accentColor: Theme.of(context).accentColor);
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    // print("dineindelivery type: " + widget.routeArgument.heroTag);
    return DefaultTabController(
      length: widget.routeArgument.heroTag == "1" ? 2 : 1,
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
                          tabs: widget.routeArgument.heroTag == "1"
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
                                                    style:  TextStyle(fontSize: 18.0,
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
                                                  children: <Widget>[
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
                                                            style: TextStyle(fontSize: 15.0,
                                                                fontWeight: FontWeight.w500,
                                                                color: config.Colors().secondColor(1),
                                                                height: 1.35))
                                                      ],
                                                    ),
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
                                                            'GST',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodyText1,
                                                          ),
                                                        ),
                                                        Helper.getPrice(
                                                            Helper.getTaxOrder(
                                                                _con.order),
                                                            context,
                                                            style: TextStyle(fontSize: 15.0,
                                                                fontWeight: FontWeight.w500,
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
                                            if (_con.order.canCancelOrder() && _con.order.orderStatus.status == "")
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
                          child: SingleChildScrollView(
                            child: Column(

                              children: <Widget>[
                                SizedBox(height: 20,),
                              _con.order.orderStatus.status == "Pickup" ? InkWell(

                                  onTap: (){

                                    if(_con.order.driver_details != "null"){
                                      Map<String,dynamic> driver_details = json.decode(_con.order.driver_details);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return FullScreenDialog(driver_details: driver_details,traking_path: _con.order.tracking_url,);
                                        },
                                      );

                                    }
                                    else{
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return FullScreenDialog(driver_details:{},traking_path: "",);
                                        },
                                      );
                                    }
                                    // showDialog(
                                    //   context: context,
                                    //   builder: (BuildContext context) {
                                    //     return FullScreenDialog(con: _con,);
                                    //   },
                                    // );
                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>TrackingOrderDelivery(con: _con,)));
                                  },
                                  child: Container(
                                    alignment: Alignment.topRight,
                                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                      //color: Colors.deepOrange,
                                      child: Text("Track your Order -->",style: Theme.of(context)
                                          .textTheme
                                          .bodyText1,)),
                                ):Container(),
                                if(_con.order.orderStatus.status == "Order Declined")
                                  Container(
                                    //   color: Colors.lightGreen,
                                    padding: EdgeInsets.zero,
                                    child: Theme(
                                      data: ThemeData(
                                        primaryColor: Theme.of(context).accentColor,
                                      ),
                                      child: Stepper(
                                        margin: EdgeInsets.zero,
                                        //  padding: EdgeInsets.zero,
                                        physics: ClampingScrollPhysics(),
                                        controlsBuilder: (BuildContext context, ControlsDetails details) {
                                          return SizedBox(height: 0);
                                        },
                                        steps: _con.getTrackingDeclinedSteps(context),
                                        currentStep: 1,
                                      ),
                                    ),
                                  ),
                                  if(_con.order.orderStatus.status != "Order Declined")
                                Container(
                               //   color: Colors.lightGreen,
                                  padding: EdgeInsets.zero,
                                  child: Stepper(
                                    margin: EdgeInsets.zero,
                                  //  padding: EdgeInsets.zero,
                                    physics: ClampingScrollPhysics(),
                                    controlsBuilder: (BuildContext context, ControlsDetails details) {
                                      return SizedBox(height: 0);
                                    },
                                    steps: _con.getTrackingSteps(context),
                                    currentStep: _con.getCurrentStepIndex(_con.orderStatus),
                                  ),
                                ),

                                /* Padding(
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
                                  height: MediaQuery.of(context).size.height * .6,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: WebView(
                                      initialUrl: '${_con.order.tracking_url}',  // Replace with your desired URL
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
                          )
                        ),
                      ]),
                    )
                  ]),
              )),
    );
  }
  order_track(){

  }

}
class FullScreenDialog extends StatefulWidget {
  Map<String,dynamic> driver_details;
  String traking_path;
  FullScreenDialog({this.driver_details,this.traking_path});
  @override
  State<FullScreenDialog> createState() => _FullScreenDialogState();
}

class _FullScreenDialogState extends State<FullScreenDialog> {
  Map<String, dynamic> driverDetails = {} ;
  String driverName = "";
  String vehicleNumber = "";
  String mobile = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        title: Text("Order Tracking"),
      ),
      body:   Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white, // You can customize the color here
        child: widget.driver_details.isEmpty ? Center(
          child: Container(
            child: Text(
                "Delivery Api is not Connected",style: Theme.of(context)
                .textTheme
                .bodyText1,
            ),
          ),
        ) : SingleChildScrollView(
          child: Column(
            children: <Widget>[

              Card(
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
                      Text('Driver Name: ${widget.driver_details["driver_name"]}'),
                      Text('Vehicle Number: ${widget.driver_details["vehicle_number"]}'),
                      Text('Mobile: ${widget.driver_details["mobile"]}'),
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * .7,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: WebView(
                    initialUrl: widget.traking_path,  // Replace with your desired URL
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
      ),
    );
  }
}
