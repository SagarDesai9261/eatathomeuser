import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../provider.dart';
import 'settings_repository.dart' as settingRepo;
import 'package:provider/provider.dart';
import '../models/route_argument.dart';

class FirebaseApi {
  FirebaseMessaging messaging = FirebaseMessaging.instance ;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();
  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(BuildContext context, RemoteMessage message)async{


    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings ,
        iOS: iosInitializationSettings
    );

    await _flutterLocalNotificationsPlugin.initialize(
        initializationSetting,
        onDidReceiveNotificationResponse: (payload) async {
          // handle interaction when app is active for android
          handlemessage(context, message);


        }
    );
  }

  void firebaseInit(BuildContext context){

    FirebaseMessaging.onMessage.listen((message) {

      RemoteNotification notification = message.notification ;
      AndroidNotification android = message.notification.android ;

      if (kDebugMode) {
        print(notification);
        print("notifications title:${notification.title}");
        print("notifications body:${notification.body}");
        //   print('count:${android!.count}');
        print('data:${message.data.toString()}');
      }

      if(Platform.isIOS){
        forgroundMessage();
      }

      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotification(message);

        //storeNotificationInSharedPreferences(message);
      }
    });
  }
  Future<void> setupInteractMessage(BuildContext context) async
  {
    RemoteMessage initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      handlemessage(context, initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {

     // await Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
      handlemessage(context, event);
    });
  }


  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true ,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      //appsetting.AppSettings.openNotificationSettings();
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message)async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification.android.channelId.toString(),
      message.notification.android.channelId.toString() ,
      importance: Importance.max  ,
      showBadge: true ,
      playSound: true,

    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString() ,
        channelDescription: 'your channel description',
        importance: Importance.high,
        priority: Priority.high ,
        playSound: true,
        ticker: 'ticker' ,

    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true ,
        presentBadge: true ,
        presentSound: true
    ) ;

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero , (){
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification.title.toString(),
        message.notification.body.toString(),
        notificationDetails ,
      );
    });
   // print("hello");
  //  print(message.notification.body.split("is ").last=="Preparing" || message.notification.body.split("is ").last=="Ready" || message.notification.body.split("is ").last=="Pickup" || message.notification.body.split("is ").last=="On the Way" || message.notification.body.split("is ").last=="Delivered");
    if(message.notification.body.split("is ").last=="Preparing" || message.notification.body.split("is ").last=="Ready" || message.notification.body.split("is ").last=="Pickup" || message.notification.body.split("is ").last=="On the Way" || message.notification.body.split("is ").last=="Delivered" )
    {
     // print("hello111");
      await Provider.of<OrderProvider>(
          settingRepo.navigatorKey.currentState.context, listen: false)
          .fetchOrders();
    }
  }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {
    String token = await messaging.getToken();
    print(token);
    return token;
  }

  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }
  Future forgroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  void handlemessage(BuildContext context, RemoteMessage message) async {
    print("when click on notification is tapped");
  print( message.data.values);
  String data = message.data.values.toString();
    String jsonString = "{"+ data.split(RegExp(r'\{|\}'))[1] +"}";
    print(jsonString);
    String orderid = json.decode(jsonString)["order_id"].toString();
    print(orderid);


    if(json.decode(jsonString)["delivery_dinein"] == 1)
   await settingRepo.navigatorKey.currentState.pushNamed('/Tracking',
       arguments: RouteArgument(
           id:orderid,
           heroTag:
           "1"));
    else if(json.decode(jsonString)["delivery_dinein"] == 2){
      await settingRepo.navigatorKey.currentState.pushNamed('/TrackingForDinein',
          arguments: RouteArgument(
              id: orderid,
             // latitude:widget.order.res_latitude,
              //longitude:widget.order.res_longitude,
              heroTag:
              "2"));
    }



    // Navigator.of(context).pushNamed('/Tracking',
    //     arguments: RouteArgument(
    //         id: widget.order.id,
    //         heroTag:
    //         widget.order.delivery_dinein.toString()));
  }

}
// Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);