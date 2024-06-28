import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/elements/KitchenListItem.dart';
import 'package:food_delivery_app/src/helpers/custom_trace.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/filter.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/color.dart';
import '../controllers/home_controller.dart';
import '../controllers/homr_test.dart';
import '../elements/DrawerWidget.dart';
import '../models/restaurant.dart';

class KitchenList extends StatefulWidget {
  String? heroTag, responseMessage;
  bool? delivery;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  dynamic currentTab;
  String? selectedDate, selectedTime, selectedPeople;

  HomeController _con = HomeController();

  KitchenList(
      {Key? key, this.heroTag, this.delivery, this.selectedDate, this.selectedTime, this.selectedPeople,}) : super(key: key);

  @override
  _KitchenListState createState() => _KitchenListState();
}

class _KitchenListState extends StateMVC<KitchenList> {
  bool _shouldShowFirstDialog = true;
  bool _isDataFetched = false, hasData = false;
  List<Restaurant> restaurantsList = [];


  callApi() async {
    if (widget.selectedDate != null) {
      // Do something with the collected data
     //print('Collected Data: $selectedDate $selectedSession $selectedPeople');

      List<String> parts =
      widget.selectedPeople!.split(','); // Split the string into individual parts

      int totalPeople = 0;
      int sessionId = 0;
      for (String part in parts) {
        List<String> words = part.trim().split(' ');
        if (words.length >= 2) {
          int number =
          int.tryParse(words[0])!; // Extract the number from the part
          if (number != null) {
            totalPeople += number; // Add the number to the total count
          }
        }
      }

      print('Total number of people: $totalPeople');
      switch (widget.selectedTime) {
        case "Breakfast":
          sessionId = 8;
          break;
        case "Snacks":
          sessionId = 7;
          break;
        case "Lunch":
          sessionId = 9;
          break;
        case "Dinner":
          sessionId = 10;
          break;
      }
      _shouldShowFirstDialog = false;

     /* print("DS>>> values" +
          selectedDate +
          " " +
          totalPeople.toString() +
          " " +
          sessionId.toString());*/
      await listenForAllRestaurantshere(
      "1", widget.selectedDate!, totalPeople.toString(), sessionId.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    callApi();
    _showLoader();
  }

  setDataValues(bool status) {
    setState(() {
      _isDataFetched = true;
    });
  }

  Future<void> listenForAllRestaurantshere(String kitchenType, String todayDate,
      String numberOfPerson, String category) async {
    print("DS>>*** method called");
    try {
      final DeliveryKitchenListModel DeliveryKitchenListModelResponse =
          await getAllRestaurants(
              kitchenType, todayDate, numberOfPerson, category);

      if (DeliveryKitchenListModelResponse.success) {
        setState(() {
          restaurantsList.addAll(DeliveryKitchenListModelResponse.data);
          setDataValues(DeliveryKitchenListModelResponse.success);
        });
      } else {
        print("Error: ${DeliveryKitchenListModelResponse.message}");
        // Handle error scenario here
        setDataValues(DeliveryKitchenListModelResponse.success);
      }
    } catch (e) {
      print("Error: $e");
      // Handle error scenario here
    }
  }

  Future<DeliveryKitchenListModel> getAllRestaurants(String kitchenType,
      String todayDate, String numberOfPerson, String category) async {
    //  print("DS>>*** again method called");
    Uri uri = Helper.getUri('api/restaurants');
    Map<String, dynamic> _queryParams = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Filter filter =
        Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
    String latitude = prefs.getString("latitude").toString();
    String longitude = prefs.getString("longitude").toString();
    String permission = prefs.getString("permission").toString();
    _queryParams['kitchenList'] = 'true';
    _queryParams['kitchenType'] = kitchenType;
    _queryParams['DineInDate'] = todayDate;
    _queryParams['numberOfPerson'] = numberOfPerson;
    _queryParams['category'] = category;
    _queryParams.addAll(filter.toQuery());
    _queryParams.remove('searchJoin');
    if(permission == "LocationPermission.always" || permission == "LocationPermission.whileInUse"){
      print("$latitude ----- $longitude");
      _queryParams['myLat'] = latitude;
      _queryParams['myLon'] = longitude;
      _queryParams['areaLat'] = latitude;
      _queryParams['areaLon'] = longitude;
    }
    uri = uri.replace(queryParameters: _queryParams);
    try {
      final client = http.Client();
      final response = await client.get(uri);
      print("DS>>>#### Request: " + uri.toString());

      if (response.statusCode == 200) {
        return DeliveryKitchenListModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch restaurants');
      }
    } catch (e) {
      print(
          CustomTrace(StackTrace.current, message: uri.toString()).toString());
      return DeliveryKitchenListModel(
          success: false, data: [], message: 'Failed to fetch restaurants');
    }
  }
  bool isLoading = false; // Add a boolean to control loader visibility
  Future<void> _showLoader() async {
    setState(() {
      isLoading = true;
    });
    // Delay for 3 seconds
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      isLoading = false;
    });
    // Close the dialog after 3 seconds

  }
  @override
  Widget build(BuildContext context) {
    //print("DS>> size: "+ " "+ restaurantsList.length.toString());
    print("DS>>> isdata fetched" +
        _isDataFetched.toString() +
        " " +
        restaurantsList.length.toString());

    /*return StatefulBuilder(
      builder: (context, setState) {*/
      //  delayAndCall();
        return Scaffold(
          backgroundColor: Colors.white,
          drawer: DrawerWidget(),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: Builder(builder: (context) {
              return new IconButton(
                  icon:
                      new Icon(Icons.sort, color: Theme.of(context).hintColor),
                  onPressed: () => Scaffold.of(context).openDrawer());
            }),
            actions: [
              Builder(
                  builder: (context) {
                    return new IconButton(
                        icon: new Icon(Icons.filter_alt_rounded, color: Theme.of(context).hintColor),
                        onPressed: () =>  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CalendarDialogWithoutRestaurant()
                          ),
                        ),
                    );
                  }
              ),
            ],
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Dine-in ',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  !.merge(TextStyle(letterSpacing: 1.3)),
            ),
          ),
          body:  isLoading ? Center(child: CircularProgressIndicator(color: Colors.deepOrangeAccent,)) : Container(
              padding: EdgeInsets.all(10),
              child: _isDataFetched && restaurantsList.length == 0
                  ? Center(
                      child: Center(child: Text("No data available")),
                    )
                  : ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: restaurantsList.length ~/ 2, // Display two cards per row
                itemBuilder: (context, index) {
                  final firstIndex = index * 2;
                  final secondIndex = firstIndex + 1;

                  return Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (restaurantsList.elementAt(firstIndex).availableForDineIn!) {
                              Navigator.of(context).pushNamed('/Details',
                                  arguments: RouteArgument(
                                    id: '0',
                                    param: restaurantsList.elementAt(firstIndex).id,
                                    heroTag: widget.heroTag,
                                    isDelivery: false,
                                    selectedDate: widget.selectedDate,
                                    parentScaffoldKey: GlobalKey(),
                                    selectedTime: widget.selectedTime,
                                    selectedPeople: widget.selectedPeople
                                  ));
                            }
                          },
                          child: KitchenListItem(
                            restaurant: restaurantsList[firstIndex],
                            heroTag: widget.heroTag!,
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Add spacing between cards
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (restaurantsList.elementAt(secondIndex).availableForDineIn!) {
                              Navigator.of(context).pushNamed('/Details',
                                  arguments: RouteArgument(
                                    id: '0',
                                    param: restaurantsList.elementAt(secondIndex).id,
                                    heroTag: widget.heroTag,
                                    isDelivery: false,
                                      selectedDate: widget.selectedDate,
                                      parentScaffoldKey: GlobalKey(),
                                      selectedTime: widget.selectedTime,
                                      selectedPeople: widget.selectedPeople
                                  ));
                            }
                          },
                          child: KitchenListItem(
                            restaurant: restaurantsList[secondIndex],
                            heroTag: widget.heroTag!,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: mainColor(1),
            selectedFontSize: 0,
            unselectedFontSize: 0,
            iconSize: 22,
            elevation: 0,
            backgroundColor: Colors.grey[100],
            selectedIconTheme: IconThemeData(size: 28),
            unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
            currentIndex: 2,
            onTap: (int i) {
              print("DS>>> " + i.toString());
              _selectTab(i);
            },
            // this will be set when a new tab is tapped
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/img/profile.svg',
                  color: Colors.grey,
                  height: 17,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/img/dinein.svg',
                  color: Colors.grey,
                  height: 17,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                  label: '',
                  icon: new SvgPicture.asset(
                    'assets/img/home.svg',
                    height: 70,
                  )),
              BottomNavigationBarItem(
                icon: new SvgPicture.asset(
                  'assets/img/delivery.svg',
                  color: Colors.grey,
                  height: 17,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: new SvgPicture.asset(
                  'assets/img/cart.svg',
                  color: Colors.grey,
                  height: 17,
                ),
                label: '',
              ),
            ],
          ),
        );
        // }
    /*  },
    );*/
  }

  void _selectTab(int tabItem) {
    setState(() {
      print("DS>> am i here?? " + tabItem.toString());
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          if(currentUser.value.apiToken != ""){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsWidget()),
          );
          }
          else{
            Navigator.of(context).pushNamed('/Login');
          }

          break;
        case 1:
          break;
        case 2:
          //widget.currentPage = HomeWidget(parentScaffoldKey: widget.scaffoldKey, currentTab: tabItem,);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      parentScaffoldKey: widget.scaffoldKey,
                      currentTab: tabItem,
                      directedFrom: "forHome",
                    )),
          );
          break;
        case 3:
          /* widget.currentPage = KitchenListDeliveryWidget(restaurantsList: widget._con.AllRestaurantsDelivery,
            heroTag: "KitchenListDelivery",);*/
             Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    KitchenListDeliveryWidget(
                      restaurantsList: widget._con.AllRestaurantsDelivery,
                      heroTag: "KitchenListDelivery",)
            ),
          );
          break;
        case 4:
          //widget.currentPage = CartWidget(parentScaffoldKey: widget.scaffoldKey);
          if(currentUser.value.apiToken != ""){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartWidget(
                parentScaffoldKey: widget.scaffoldKey,
              ),
            ),
          );
          }
          else{
            Navigator.of(context).pushNamed('/Login');
          }
          break;
      }
    });
  }

  void delayAndCall() {

    Future.delayed(Duration(seconds: 2), () {
      showCalendarDialoggWithoutRestaurant(context);
     /* WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_shouldShowFirstDialog) {

        }
      });*/
    });
  }
}

// 9429641564
