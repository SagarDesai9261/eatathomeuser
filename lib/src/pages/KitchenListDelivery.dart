import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/controllers/home_controller.dart';
import 'package:food_delivery_app/src/elements/CardsCarouselLoaderWidget.dart';
import 'package:food_delivery_app/src/elements/DrawerWidget.dart';
import 'package:food_delivery_app/src/elements/KitchenListItem.dart';
import 'package:food_delivery_app/src/models/cuisine.dart';
import 'package:food_delivery_app/src/models/location.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
//import 'package:food_delivery_app/src/pages/CardsCarouselWidgetHome.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/color.dart';
import 'package:http/http.dart' as http;
import '../helpers/helper.dart';
import '../models/filter.dart';
import '../provider.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart' as settingRepo;
import 'package:provider/provider.dart';
class KitchenListDeliveryWidget extends StatefulWidget {
  List<Restaurant> restaurantsList;
  String heroTag;
  bool delivery;
  HomeController _con = HomeController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  dynamic currentTab;
  RouteArgument routeArgument;
  Widget currentPage = HomeWidget();

  KitchenListDeliveryWidget({Key key, this.heroTag, this.delivery, this.restaurantsList})
      : super(key: key);

  @override
  _KitchenListDeliveryState createState() => _KitchenListDeliveryState();
}

class _KitchenListDeliveryState extends StateMVC<KitchenListDeliveryWidget> {
  ScrollController _scrollController = ScrollController();
  String defaultLanguage;
  HomeController _con;
  //_OverflowMenuDialogState overflowMenuDialog;
  bool isDataLoaded = false;
  bool isDatamoreLoaded = false;
  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // User has reached the end of the list
      fetchRestaurants(); // Fetch next page
    }
  }
  @override
  void initState() {
    getCurrentDefaultLanguage();
    if(widget.restaurantsList.length == 0){
      _con = HomeController();
      _con.refreshSubHome();

      fetchRestaurants_firsttime();
    }
    // Future.delayed(Duration(seconds: 3), () {
    //   setState(() {
    //     isDataLoaded = true; // Set isDataLoaded to true when data is loaded
    //   });
    // });
    _scrollController.addListener(_scrollListener);
    super.initState();
  }
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }
  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode){
      print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }

  Future<void> fetchRestaurants() async {


    String kitchenType = "2";
    String todayDate = DateTime.now().toString();
    String numberOfPerson = "0";
    String category = "0";
    int limit = 6;
    int offset = 8;

    if(!isDatamoreLoaded){
      try {
        List<Restaurant> allRestaurants = [];
        while (true) {
          Stream<Restaurant> restaurantsStream = await getAllRestaurants(kitchenType, todayDate, numberOfPerson, category, limit: limit, offset: offset);
          List<Restaurant> restaurants = await restaurantsStream.toList();

          if (restaurants.isEmpty) {
            setState(() {

              isDatamoreLoaded = true;
            });


            break; // No more restaurants available
          }

          allRestaurants.addAll(restaurants);
          offset += limit; // Increment offset for the next page
        }
        List<Restaurant> filteredRestaurants = allRestaurants.where((restaurant) => !widget.restaurantsList.any((existing) => existing.id == restaurant.id)).toList();


        setState(() {

          widget.restaurantsList.addAll(filteredRestaurants);
          // isDataLoaded = true;
        });
      } catch (e) {
        print("Error fetching restaurants: $e");
      }}
  }
  Future<void> fetchRestaurants_firsttime() async {

    if(widget.restaurantsList.isNotEmpty){
      setState(() {
        isDataLoaded = true;

      });
    }
    String kitchenType = "2";
    String todayDate = DateTime.now().toString();
    String numberOfPerson = "0";
    String category = "0";
    int limit = 8;
    int offset = 0;

    try {
      List<Restaurant> allRestaurants = [];

      Stream<Restaurant> restaurantsStream = await getAllRestaurants(kitchenType, todayDate, numberOfPerson, category, limit: limit, offset: offset);
      List<Restaurant> restaurants = await restaurantsStream.toList();

      allRestaurants.addAll(restaurants);
      offset += limit; // Increment offset for the next page


      setState(() {

        widget.restaurantsList = allRestaurants;
        isDataLoaded = true;
      });
    } catch (e) {
      print("Error fetching restaurants: $e");
    }
  }
  CusionWithrestaurant(String cuisinesQueryParam) async {
    String kitchenType = "2";
    String todayDate = DateTime.now().toString();
    String numberOfPerson = "0";
    String category = "0";
    Uri uri = Helper.getUri('api/restaurants');
    Map<String, dynamic> _queryParams = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

    String latitude = prefs.getString("latitude");
    String longitude = prefs.getString("longitude");
    String permission = prefs.getString("permission");
    // print("current permission  + ${permission} ");
    //_queryParams['limit'] = '6';
    _queryParams['kitchenList'] = 'true';
    _queryParams['kitchenType'] = kitchenType;
    _queryParams['DeliveryDate'] = todayDate;
    _queryParams['numberOfPerson'] = numberOfPerson;
    _queryParams['category'] = category;
    if(permission == "LocationPermission.always" || permission == "LocationPermission.whileInUse"){
      // print("$latitude ----- $longitude");
      _queryParams['myLat'] = latitude;
      _queryParams['myLon'] = longitude;
      _queryParams['areaLat'] = latitude;
      _queryParams['areaLon'] = longitude;
    }
    _queryParams.addAll(filter.toQuery());
    _queryParams.remove('searchJoin');
    List<Map<String, String>> params = [];
    List<String> pairs = cuisinesQueryParam.split('&');
    // print(pairs);
    for (String pair in pairs) {
      List<String> keyValue = pair.split('=');

      if (keyValue.length == 2) {
        String key = keyValue[0];
        String value = keyValue[1];

        // Remove any square brackets from the key or value
        params.add({key:value});
      }
    }
    // print(params);
    for (Map<String, String> param in params) {
      _queryParams.addAll(param);
    }
    uri = uri.replace(queryParameters: _queryParams);
    try {
      final client = new http.Client();
      final streamedRest = await client.send(http.Request('get', uri));
      //print("DS>>> Request delivery: "+uri.toString());
      return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
        return Restaurant.fromJSON(data);
      });
    } catch (e) {
      // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
      return new Stream.value(new Restaurant.fromJSON({}));
    }
  }
  final Shader linearGradient = LinearGradient(
    colors: <Color>[kPrimaryColororange, kPrimaryColorLiteorange],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 70.0));


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              drawer: DrawerWidget(),
              appBar: AppBar(
                foregroundColor: Colors.black,
                automaticallyImplyLeading: false,
                leading: Builder(
                    builder: (context) {
                      return new IconButton(
                          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
                          onPressed: () =>  Scaffold.of(context).openDrawer()
                      );
                    }
                ),
                actions: [
                 /* PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.fastfood_rounded),
                            title: Text('Cuisine'),
                            onTap: () {
                              print("click on cuisine" +
                                  widget._con.cuisineList2.length.toString());
                              Navigator.pop(context);
                              _openDialog(context, widget._con.cuisineList2);
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text('Location'),
                            onTap: () {
                              // Handle help action
                              Navigator.pop(context);
                            *//*  _openDialogForLocation(
                                context,
                                widget._con.locationList2,
                              );*//*
                              _openDialogForLocation(context,widget._con.locationList2);
                            },
                          ),
                        ),
                      ];
                    },
                  ),*/
                ],
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: TranslationWidget(
                  message:  'Delivery',
                  fromLanguage: "English",
                  toLanguage: defaultLanguage,
                  builder: (translatedMessage) => Text(
                    translatedMessage,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
                  ),
                ),
              ),
              body: isDataLoaded
                  ? RefreshIndicator(
                onRefresh: widget._con.refreshHome,
                child: widget.restaurantsList.isEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/img/No_data_found.png",height: 200,width: 200,),
                        SizedBox(height: 10,),
                        Center(child:  TranslationWidget(
                  message: "Oops! No Data Available",
                  fromLanguage: "English",
                  toLanguage: defaultLanguage,
                  builder: (translatedMessage) => Text(
                        translatedMessage,
                        style: TextStyle(
                            foreground: Paint()
                              ..shader = linearGradient,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                  ),
                ),),
                      ],
                    )
                    : Container(
                  padding: EdgeInsets.all(10),
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: .9
                    ),
                    scrollDirection: Axis.vertical,
                    itemCount: widget.restaurantsList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (widget.restaurantsList.elementAt(index).availableForDelivery ) {
                            Navigator.of(context).pushNamed('/Details',
                                arguments: RouteArgument(
                                  id: '0',
                                  param: widget.restaurantsList.elementAt(index).id,
                                  heroTag: widget.heroTag,
                                  isDelivery: true,
                                  selectedDate: "",
                                  parentScaffoldKey: new GlobalKey(),
                                ));
                          }
                          else {
                            print("DS>> Not available for delivery");
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: KitchenListItem(
                            restaurant: widget.restaurantsList.elementAt(index),
                            heroTag: widget.heroTag,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ) : Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .9,
                  ),
                  scrollDirection: Axis.vertical,
                  itemCount: 6, // Set an arbitrary number of shimmering items
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      height: 200.0, // Adjust height as per your need
                      color: Colors.white, // Optional: Set a color for the shimmer effect
                    ),
                  ),
                ),
              ),
             /* bottomNavigationBar:  BottomNavigationBar(
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
                  print("DS>>> "+ i.toString());
                  this._selectTab(i);
                },
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
              ),*/
            );
          }
      ),
    );
  }
  _openDialog(BuildContext context, List<Cuisine> cuisineList,
     ) {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        TextEditingController searchController = TextEditingController();
        return StatefulBuilder(builder: (context, setState) {
          List<Cuisine> filteredCuisineList;
          if(searchController.text.isNotEmpty) {
            filteredCuisineList = cuisineList
                .where((cuisine) =>
                cuisine.name.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ))
                .toList();
          }else
          {
            filteredCuisineList = cuisineList;
          }

          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(""),
                    TranslationWidget(
                      message: "Select Cuisine",
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(
                        translatedMessage,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.close))
                  ],
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    height: 34,
                    margin: EdgeInsets.only(right: 8, left: 8, top: 8),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: -8,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController, // Assign the controller
                      onChanged: (value) {
                        // Call setState to trigger a rebuild when the user types
                        setState(() {});
                      },
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  child: ListView.builder(
                    itemCount: filteredCuisineList.length,
                    itemBuilder: (context, index) => CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        title: TranslationWidget(
                          message: filteredCuisineList[index].name,
                          fromLanguage: "English",
                          toLanguage: defaultLanguage,
                          builder: (translatedMessage) => Text(
                            translatedMessage,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        value: filteredCuisineList[index].selected,
                        onChanged: (value) {
                          Provider.of<CuisineProvider>(context, listen: false)
                              .toggleCuisine(filteredCuisineList[index].id.toString());
                          setState(() {
                            print("DS>>> selected " +
                                value.toString() +
                                " index " +
                                filteredCuisineList[index].id.toString());
                            filteredCuisineList[index].selected = value;
                          });
                        }
                      /*onChanged: (value) {
                            */ /*setState(() {
                              print("DS>>> selected " +
                                  value.toString() +
                                  "index " +
                                  cuisineList[index].id.toString());
                              cuisineList[index].selected = value;
                              // toggleCuisine(int.parse(cuisineList[index].id));
                            });*/ /*

                          },*/
                    ),
                  ),
                )

              ],
            ),
            actions: [
              InkWell(
                onTap: () {
                  List<String> selectedCuisines =
                      Provider.of<CuisineProvider>(context, listen: false)
                          .selectedCuisines;
                  filterWithCuisine( selectedCuisines);
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                  height: 40,
                  width: 100,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TranslationWidget(
                          message: "Apply" ?? '',
                          fromLanguage: "English",
                          toLanguage: defaultLanguage,
                          builder: (translatedMessage) => Text(translatedMessage,
                              style: Theme.of(context).textTheme.bodyText1.merge(
                                  TextStyle(
                                      color: Theme.of(context).primaryColor))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              /*     ElevatedButton(
                  onPressed: () {
                    // filterWithCuisine(fromDineInorDelivery);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: TranslationWidget(
                    message: "Apply",
                    fromLanguage: "English",
                    toLanguage: defaultLanguage,
                    builder: (translatedMessage) => Text(
                      translatedMessage,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ),*/
            ],
          );
        }
        );
      },
    );
  }
  filterWithCuisine(
       List<String> selectedCuisines) async {
    print("tap");
    for (int i = 0; i < selectedCuisines.length; i++) {
      print("" + selectedCuisines[i].toString());
    }

    // Construct the query parameter string for selected cuisines
    String cuisinesQueryParam =
    selectedCuisines.map((cuisineId) => 'cuisines[]=$cuisineId').join('&');
    print("cuisineParam " + cuisinesQueryParam);

    try {
      Stream<Restaurant> restaurantsStream = await CusionWithrestaurant(cuisinesQueryParam);
      List<Restaurant> restaurants = await restaurantsStream.toList();

      setState(() {
        widget.restaurantsList = restaurants;
      });
    } catch (e) {
      print("Error fetching restaurants: $e");
    }

    //_con.refreshHome();
    // _con.refreshSubHome();
 //   print("length kitchen" + _con.topKitchens.length.toString());
  }
  filterWithLocation(
      List<String> selectedCuisines) async {
    print("tap");
    for (int i = 0; i < selectedCuisines.length; i++) {
      print("" + selectedCuisines[i].toString());
    }

    // Construct the query parameter string for selected cuisines
    String cuisinesQueryParam =
    selectedCuisines.map((cuisineId) => 'location[]=$cuisineId').join('&');
    print("cuisineParam " + cuisinesQueryParam);

    try {
      Stream<Restaurant> restaurantsStream = await CusionWithrestaurant(cuisinesQueryParam);
      List<Restaurant> restaurants = await restaurantsStream.toList();

      setState(() {
        widget.restaurantsList = restaurants;
      });
    } catch (e) {
      print("Error fetching restaurants: $e");
    }

    //_con.refreshHome();
    // _con.refreshSubHome();
    //   print("length kitchen" + _con.topKitchens.length.toString());
  }

  void _selectTab(int tabItem) {
    setState(() {
      print("DS>> am i here?? "+tabItem.toString());
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          if(currentUser.value.apiToken != null){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SettingsWidget()
              ),
            );
          }
          else{
            Navigator.of(context).pushNamed('/Login');
          }
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CalendarDialogWithoutRestaurant()
            ),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomeWidget(parentScaffoldKey: new GlobalKey(), directedFrom: "forHome",
                      currentTab: 2,)
            ),
          );
          break;
        case 3:
          fetchRestaurants();
          break;
        case 4:
          if(currentUser.value.apiToken != null){
            Navigator.pushReplacement(
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
  _openDialogForLocation(BuildContext context, List<LocationModel> locationList,
    ) {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        TextEditingController searchController = TextEditingController();
        return StatefulBuilder(builder: (context, setState) {
          List<LocationModel> filteredLocationList;
          if(searchController.text.isNotEmpty){
            filteredLocationList = locationList
                .where((cuisine) =>
                cuisine.address.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ))
                .toList();

          }else{
            filteredLocationList = locationList;
          }
          print(filteredLocationList.length);


          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(""),
                    /*Text('Select Cuisine')*/
                    TranslationWidget(
                      message: "Select Location",
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(
                        translatedMessage,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        //style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.close))
                  ],
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    height: 34,
                    margin: EdgeInsets.only(right: 8, left: 8, top: 8),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: -8,
                          blurRadius: 10,
                          // offset: Offset(0, 3), // changes the shadow position
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController, // Assign the controller
                      onChanged: (value) {
                        // Call setState to trigger a rebuild when the user types
                        setState(() {});
                      },
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                          prefixIcon: Icon(Icons.search)),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(0),
                  // padding: EdgeInsets.all(),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  child: ListView.builder(
                    itemCount: filteredLocationList.length,
                    itemBuilder: (context, index) => CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      title: /*Text(
                            locationList[index].address,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          )*/
                      TranslationWidget(
                        message: filteredLocationList[index].address,
                        fromLanguage: "English",
                        toLanguage: defaultLanguage,
                        builder: (translatedMessage) => Text(
                          translatedMessage,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      value: filteredLocationList[index].selected,
                      onChanged: (value) {
                        setState(() {
                          print("DS>>> selected location" +
                              value.toString() +
                              "index value" +
                              filteredLocationList[index].address.toString());
                          filteredLocationList[index].selected =
                              value; // Update the state of the selected cuisine

                          Provider.of<LocationProvider>(context, listen: false)
                              .toggleLocation(
                              filteredLocationList[index].address.toString());
                        });
                      },
                    ),
                  ),
                )

              ],
            ),
            actions: [
              InkWell(
                onTap: () {
                  List<String> selectedLocations =
                      Provider.of<LocationProvider>(context, listen: false).selectedLocations;
                  filterWithLocation(selectedLocations);
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                  height: 40,
                  width: 100,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TranslationWidget(
                          message: "Apply" ?? '',
                          fromLanguage: "English",
                          toLanguage: defaultLanguage,
                          builder: (translatedMessage) => Text(translatedMessage,
                              style: Theme.of(context).textTheme.bodyText1.merge(
                                  TextStyle(
                                      color: Theme.of(context).primaryColor))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              /* Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        filterWithLocation(fromDineInorDelivery);
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: */
              /*Text('Apply')*/ /*
                          TranslationWidget(
                        message: "Apply",
                        fromLanguage: "English",
                        toLanguage: defaultLanguage,
                        builder: (translatedMessage) => Text(
                          translatedMessage,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: */ /*Text('Close')*/ /*
                          TranslationWidget(
                        message: "Close",
                        fromLanguage: "English",
                        toLanguage: defaultLanguage,
                        builder: (translatedMessage) => Text(
                          translatedMessage,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                )*/
            ],
          );
        }
        );
      },
    );
  }
}
