import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/splash_screen_controller.dart';
import '../provider.dart';
import '../repository/firebase_api.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;
  Position currentposition;
  bool isPositionDetermined = false;

  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
  //  await _determinePosition();
    await Provider.of<location_enable_provider>(context, listen: false).initialize();

   //await Provider.of<Add_the_address>(context, listen: false).determinePosition();
    loadData();
    FirebaseApi().requestNotificationPermission();
    FirebaseApi().forgroundMessage();
    FirebaseApi().firebaseInit(context);
    FirebaseApi().setupInteractMessage(context);
    FirebaseApi().isTokenRefresh();
    print(await FirebaseApi().getDeviceToken());
  }

  Future<void> _determinePosition() async {
    if (isPositionDetermined) {
      // Position has already been determined, no need to repeat.
      return;
    }
    String currentAddress = 'My Address';
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("permission", "LocationPermission.denied");
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
      return;
    }

    permission = await Geolocator.checkPermission();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("permission", permission.toString());

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: 'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      SharedPreferences prefss = await SharedPreferences.getInstance();
      prefss.setString("longitude", position.longitude.toString());
      prefss.setString("latitude", position.latitude.toString());

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      setState(() {
        currentposition = position;
        currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });

      // Set the flag to true indicating that the position has been determined.
      isPositionDetermined = true;
    } catch (e) {
      print(e);
    }
  }

  void loadData() {
    _con.progress.addListener(() {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100) {
        try {
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
        } catch (e) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/img/HOME-FOOD-LOGO2.png',
                width: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
