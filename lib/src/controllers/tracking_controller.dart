import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../pages/orderStatus.dart';
import '../repository/order_repository.dart';

class TrackingController extends ControllerMVC {
  Order? order;
  List<OrderStatus> orderStatus = <OrderStatus>[];
  bool isRefresh = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<OrderStatus> orderDeclinedstatus = [];
  List<Step>? _cachedSteps;
  //
  TrackingController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForOrder({String? orderId, String? message}) async {
    if(message == "refresh"){
      setState(() {
        isRefresh = false;
      });
    }
    //_orderStatusSteps.clear();
    final Stream<Order> stream = await getOrder(orderId);
    stream.listen((Order _order) {
      setState(() {
        order = _order;
      });
    }, onError: (a) {
      // print(a);
      ScaffoldMessenger.of(scaffoldKey!.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if(message != "refresh"){
        listenForOrderStatus();
        // setState(() {
        //   isRefresh = true;
        // });
      }
      if(message == "refresh"){

        setState(() {
          isRefresh = true;
        });
      }
     /* if (message != null) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }*/
    });
  }

  void listenForOrderStatus() async {
    final Stream<OrderStatus> stream = await getOrderStatus();
    stream.listen((OrderStatus _orderStatus) {
      setState(() {

        orderStatus.add(_orderStatus);
      //  orderStatus.removeAt(2);
      });
    }, onError: (a) {}, onDone: () {});
  }
  int getCurrentStepIndex(List<OrderStatus> orderStatusList) {
    // Iterate through the orderStatusList to find the index of the current order status
    for (int i = 0; i < orderStatusList.length; i++) {
      if (orderStatusList[i].priority == order!.orderStatus!.id) {
        return i;
      }
    }
    return 0; // Return 0 if not found or handle it based on your requirements
  }
  int getStepIndex(List<OrderStatus> orderStatusList,String status) {
    // Iterate through the orderStatusList to find the index of the current order status
    for (int i = 0; i < orderStatusList.length; i++) {
      if (orderStatusList[i].status == status) {
        return i;
      }
    }
    return 0; // Return 0 if not found or handle it based on your requirements
  }
  List<Step> getTrackingDeclinedSteps(BuildContext context) {

    List orderTrackList = [];
    orderTrackList = jsonDecode(order!.orderTrack!);
    List<Step> _orderStatusSteps = [];
    int count = 0;
    List<OrderStatus> orderstatus = [];




    this.orderStatus.forEach((element) {

      if(order!.delivery_dinein == 2){
        if(element.status != "Pickup" && element.status != "Order Declined" && element.status != "On the Way" ){
          orderstatus.add(element);
        }
      }
      else{
        // print("addd");
        if(element.status != "Order Declined")
          orderstatus.add(element);
        if(element.status == "Order Received" || element.status == "Order Declined"){
          orderDeclinedstatus.add(element);
        }
      }
    });
    print(orderDeclinedstatus.length);
    print(order!.delivery_dinein.toString() + order!.delivery_dinein.runtimeType.toString());
    print(orderstatus.length);

      orderDeclinedstatus.forEach((OrderStatus _orderStatus) {

        _orderStatusSteps.add(Step(
          state: StepState.complete,
          title: Text(
            _orderStatus.status,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          /* subtitle: order_track_value["status"] == _orderStatus.id && order_track_value.isNotEmpty
                ? Text(
              '${order_track_value["status_time"]}',
              style: Theme.of(context).textTheme.caption,
              overflow: TextOverflow.ellipsis,
            )
                : SizedBox(height: 0),*/
          content: SizedBox(
            width: double.infinity, // Maintain full width
            child: Padding(
              padding: EdgeInsets.zero, // Remove padding here
              child: Text(
                '${Helper.skipHtml(order!.hint!)}',
              ),
            ),
          ),
          isActive: true,
        ));

        count = count + 1;

      });

    print("Helllo =====> " + _orderStatusSteps.length.toString());
    return _orderStatusSteps;
  }
  List<Step> getTrackingSteps(BuildContext context) {
    // if (_cachedSteps != null ) {
    //   return _cachedSteps;
    // }

    print("Get Tracking Steps calls");
    List<Step> _orderStatusSteps = [];
    List orderTrackList = [];
    orderTrackList = jsonDecode(order!.orderTrack!);

    int count = 0;
    List<OrderStatus> orderstatus = [];
    List<OrderStatus> orderDeclinedstatus = [];



    this.orderStatus.forEach((element) {

      if(order!.delivery_dinein == 2){
        if(element.status != "Pickup" && element.status != "Order Declined" && element.status != "On the Way" ){
            orderstatus.add(element);
        }
      }
      else{
       // print("addd");
        if(element.status != "Order Declined")
        orderstatus.add(element);
        if(element.status == "Order Received" || element.status == "Order Declined"){
          orderDeclinedstatus.add(element);
        }
      }
    });
    print(orderDeclinedstatus.length);
    print(order!.delivery_dinein.toString() + order!.delivery_dinein.runtimeType.toString());
    print(orderstatus.length);
    if(order!.orderStatus!.status != "Order Declined") {
      orderstatus.forEach((OrderStatus _orderStatus) {
        print(orderTrackList[0]);
        // print(orderTrackList[count -1]["status"] == _orderStatus.id);
        Map<String, dynamic> order_track_value = {};
        if (orderTrackList.length - 1 >= count) {
          order_track_value = orderTrackList[count];
        }
        //  print(orderTrackList[2]["status"].runtimeType);
        // print(order_track_value["status"].runtimeType);
//print(int.parse(order_track_value["status"]) == int.parse( _orderStatus.id));
        // print(order_track_value["status"]);

        _orderStatusSteps.add(Step(
          state: StepState.complete,
          title: Text(
            _orderStatus.status,
            style: Theme
                .of(context)
                .textTheme
                .subtitle1,
          ),
          subtitle: order_track_value["status"] == _orderStatus.id &&
              order_track_value.isNotEmpty
              ? Text(
            '${order_track_value["status_time"]}',
            style: Theme
                .of(context)
                .textTheme
                .caption,
            overflow: TextOverflow.ellipsis,
          )
              : SizedBox(height: 0),
          content: SizedBox(
            width: double.infinity, // Maintain full width
            child: Padding(
              padding: EdgeInsets.zero, // Remove padding here
              child: Text(
                '${Helper.skipHtml(order!.hint!)}',
              ),
            ),
          ),
          isActive: (int.tryParse(order!.orderStatus!.priority))! - 1 >=
              getStepIndex(orderstatus, _orderStatus.status),
        ));

        count = count + 1;
      });
    }
    if(order!.orderStatus!.status  == "Order Declined")
      {
        orderDeclinedstatus.forEach((OrderStatus _orderStatus) {
         // print(orderTrackList[0]);
          // print(orderTrackList[count -1]["status"] == _orderStatus.id);
          // Map<String,dynamic> order_track_value = {};
          // if(orderTrackList.length-1 >= count){
          //   order_track_value = orderTrackList[count];
          // }
          //  print(orderTrackList[2]["status"].runtimeType);
          // print(order_track_value["status"].runtimeType);
//print(int.parse(order_track_value["status"]) == int.parse( _orderStatus.id));
          // print(order_track_value["status"]);

          _orderStatusSteps.add(Step(
            state: StepState.complete,
            title: Text(
              _orderStatus.status,
              style: Theme.of(context).textTheme.subtitle1,
            ),
           /* subtitle: order_track_value["status"] == _orderStatus.id && order_track_value.isNotEmpty
                ? Text(
              '${order_track_value["status_time"]}',
              style: Theme.of(context).textTheme.caption,
              overflow: TextOverflow.ellipsis,
            )
                : SizedBox(height: 0),*/
            content: SizedBox(
              width: double.infinity, // Maintain full width
              child: Padding(
                padding: EdgeInsets.zero, // Remove padding here
                child: Text(
                  '${Helper.skipHtml(order!.hint!)}',
                ),
              ),
            ),
            isActive: true,
          ));

          count = count + 1;

        });
      }
    print("Helllo =====> " + _orderStatusSteps.length.toString());
    _cachedSteps = _orderStatusSteps;
    return _cachedSteps!;
   // return _orderStatusSteps;
  }

  Future<void> refreshOrder() async {
    order = new Order();
    listenForOrder(message: S.of(state!.context).tracking_refreshed_successfuly);
  }

  void doCancelOrder() {
    cancelOrder(this.order!).then((value) {
      setState(() {
        this.order!.active = false;
      });
    }).catchError((e) {
      ScaffoldMessenger.of(scaffoldKey!.currentContext!).showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      orderStatus = [];
      listenForOrderStatus();
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).orderThisorderidHasBeenCanceled(this.order!.id!)),
      ));
    });
  }

  bool canCancelOrder(Order order) {
    return order.active == true && order.orderStatus!.id == 1;
  }
}
