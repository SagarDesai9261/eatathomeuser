import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
class InternetConnectionService {
  final Connectivity _connectivity = Connectivity();
  StreamController<ConnectivityResult> connectionStatusController = StreamController<ConnectivityResult>();

  InternetConnectionService() {
    _initialize();
  }

  Future<void> _initialize() async {
    ConnectivityResult connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);

    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    connectionStatusController.add(result);
  }

  void dispose() {
    connectionStatusController.close();
  }
}
class InternetConnectionChecker extends StatefulWidget {
  final Widget? child;

  InternetConnectionChecker({ this.child});
  @override
  State<InternetConnectionChecker> createState() => _InternetConnectionCheckerState();
}
class _InternetConnectionCheckerState extends State<InternetConnectionChecker> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StreamBuilder<ConnectivityResult>(
          stream: InternetConnectionService().connectionStatusController.stream,
          builder: (context, snapshot) {
            final connectivityResult = snapshot.data;
            if (connectivityResult == ConnectivityResult.none || connectivityResult == null) return showNoInternetDialog(context);

            return widget.child!;
          },
        ),
      ),
    );
  }

  showNoInternetDialog(BuildContext context) {
    return  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
        );
      },
    );
  }
}