import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:food_delivery_app/src/controllers/category_controller.dart';
import 'package:food_delivery_app/src/controllers/homecontroller_provider.dart';
import 'package:food_delivery_app/src/pages/restaurant.dart';
import 'package:food_delivery_app/src/provider.dart';
import 'package:food_delivery_app/utils/CollectedData.dart';
import 'package:global_configuration/global_configuration.dart';
import 'generated/l10n.dart';
import 'route_generator.dart';
import 'src/helpers/app_config.dart' as config;
import 'src/helpers/custom_trace.dart';
import 'src/models/setting.dart';
import 'src/repository/firebase_api.dart';
import 'src/repository/settings_repository.dart' as settingRepo;
import 'src/repository/user_repository.dart' as userRepo;
import 'package:provider/provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A Background message just showed up: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configurations");
  HttpOverrides.global = new MyHttpOverrides();
  await Firebase.initializeApp();
//  await FirebaseApi().initNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Firebase local notification plugin
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Firebase messaging
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //Assign publishable key to flutter_stripe
  const stripePublishableKey = "pk_test_51O9PqlI87pCKWFaiB7GkHS9Tc1VJwLavISQhSIAvmX6fmjdB1hKhqPcTXHXycTqOzXRD96QT26HcKfShuU6NV2On00YRzMguqW";
  Stripe.publishableKey = stripePublishableKey;

  //Load our .env file that contains our Stripe Secret key
  await dotenv.load(fileName: "assets/.env");
// print(CustomTrace(StackTrace.current, message: "base_url: ${GlobalConfiguration().getValue('base_url')}"));
// print(CustomTrace(StackTrace.current, message: "api_base_url: ${GlobalConfiguration().getValue('api_base_url')}"));
  runApp(Phoenix(
    child: MultiProvider(
        providers: [
          ChangeNotifierProvider<CuisineProvider>(
            create: (_) => CuisineProvider(),
          ),
          ChangeNotifierProvider<LocationProvider>(
            create: (_) => LocationProvider(),
          ),
          ChangeNotifierProvider<LoaderProvider>(
            create: (_) => LoaderProvider(),
          ),
          ChangeNotifierProvider<favourite_item_provider>(
            create: (_) => favourite_item_provider(),
          ),
          ChangeNotifierProvider<tabIndexProvider>(
            create: (_) => tabIndexProvider(),
          ),
          ChangeNotifierProvider<FoodsProvider>(
            create: (_) => FoodsProvider(),
          ),
          ChangeNotifierProvider<QuantityProvider>(
            create: (_) => QuantityProvider(),
          ),
          ChangeNotifierProvider<Add_the_address>(
            create: (_) => Add_the_address(),
          ),
          ChangeNotifierProvider<OrderProvider>(
            create: (_) => OrderProvider(),
          ),
          ChangeNotifierProvider<RestaurantDataProvider>(
            create: (_) => RestaurantDataProvider(),
          ),
          ChangeNotifierProvider<CartProvider>(
            create: (_) => CartProvider(),
          ),ChangeNotifierProvider<OffersProvider>(
            create: (_) => OffersProvider(),
          ),
          ChangeNotifierProvider<location_enable_provider>(
            create: (_) => location_enable_provider(),
          ),
          ChangeNotifierProvider<HomeProvider>(
            create: (_) => HomeProvider(),
          ),

        ],
        child: MyApp()),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  //FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {

    settingRepo.initSettings();
    settingRepo.getCurrentLocation();
    userRepo.getCurrentUser();
    super.initState();

   // _showNotificationWithDefaultSound();




  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  /*// Method 2
  Future _showNotificationWithDefaultSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: settingRepo.setting,
        builder: (context, Setting _setting, _) {
          return ChangeNotifierProvider<CollectedData>(
            create: (_) => CollectedData(),
            child: Consumer<CollectedData>(
            builder: (context, collectedData, _) {
              return MaterialApp(

                  navigatorKey: settingRepo.navigatorKey,
                  title: _setting.appName,
                  initialRoute: '/Splash',
                  onGenerateRoute: RouteGenerator.generateRoute,
                  debugShowCheckedModeBanner: false,
                  locale: _setting.mobileLanguage.value,
                  localizationsDelegates: [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  theme: _setting.brightness.value == Brightness.light
                      ? ThemeData(
                    useMaterial3: false,
                    fontFamily: 'Poppins',
                    primaryColor: Colors.white,
                    floatingActionButtonTheme: FloatingActionButtonThemeData(
                        elevation: 0, foregroundColor: Colors.white),
                    brightness: Brightness.light,
                   // accentColor: config.Colors().mainColor(1),
                    dividerColor: config.Colors().accentColor(0.1),
                    focusColor: config.Colors().accentColor(1),
                    hintColor: config.Colors().secondColor(1),
                    textTheme: TextTheme(
                      headline5: TextStyle(fontSize: 20.0, color: config
                          .Colors().secondColor(1), height: 1.35),
                      headline4: TextStyle(fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: config.Colors().secondColor(1),
                          height: 1.35),
                      headline3: TextStyle(fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: config.Colors().secondColor(1),
                          height: 1.35),
                      headline2: TextStyle(fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          color: config.Colors().mainColor(1),
                          height: 1.35),
                      headline1: TextStyle(fontSize: 22.0,
                          fontWeight: FontWeight.w300,
                          color: config.Colors().secondColor(1),
                          height: 1.5),
                      subtitle1: TextStyle(fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: config.Colors().secondColor(1),
                          height: 1.35),
                      headline6: TextStyle(fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: config.Colors().mainColor(1),
                          height: 1.35),
                      bodyText2: TextStyle(fontSize: 12.0, color: config
                          .Colors().secondColor(1), height: 1.35),
                      bodyText1: TextStyle(fontSize: 14.0, color: config
                          .Colors().secondColor(1), height: 1.35),
                      caption: TextStyle(fontSize: 12.0, color: config.Colors()
                          .accentColor(1), height: 1.35),
                    ),
                  )
                      : ThemeData(
                    useMaterial3: false,
                    fontFamily: 'Poppins',
                    primaryColor: Color(0xFF252525),
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Color(0xFF2C2C2C),
                  //  accentColor: config.Colors().mainDarkColor(1),
                    dividerColor: config.Colors().accentColor(0.1),
                    hintColor: config.Colors().secondDarkColor(1),
                    focusColor: config.Colors().accentDarkColor(1),
                    textTheme: TextTheme(

                      headline5: TextStyle(fontSize: 20.0, color: config
                          .Colors().secondDarkColor(1), height: 1.35),
                      headline4: TextStyle(fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.35),
                      headline3: TextStyle(fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.35),
                      headline2: TextStyle(fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          color: config.Colors().mainDarkColor(1),
                          height: 1.35),
                      headline1: TextStyle(fontSize: 22.0,
                          fontWeight: FontWeight.w300,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.5),
                      subtitle1: TextStyle(fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.35),
                      headline6: TextStyle(fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: config.Colors().mainDarkColor(1),
                          height: 1.35),
                      bodyText2: TextStyle(fontSize: 12.0, color: config
                          .Colors().secondDarkColor(1), height: 1.35),
                      bodyText1: TextStyle(fontSize: 14.0, color: config
                          .Colors().secondDarkColor(1), height: 1.35),
                      caption: TextStyle(fontSize: 12.0, color: config.Colors()
                          .secondDarkColor(0.6), height: 1.35),
                    ),
                  ));
            }
            ),
          );
        });
  }
}

