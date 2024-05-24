import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../generated/l10n.dart';
import '../../my_widget/calander_widget.dart';
import '../../utils/color.dart';
import '../controllers/cart_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselLoaderWidget.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FoodsCarouselWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/HomeSliderWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../models/cuisine.dart';
import '../models/location.dart';
import '../models/route_argument.dart';
import '../provider.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart' as geolocator;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart';
import 'KitchenListDinein.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  final int currentTab;

  Widget currentPage;
  String directedFrom;
  bool showProress = true;
  GlobalKey<ScaffoldState> scaffoldKey;

  dynamic currentSelectedTab;

  HomeWidget(
      {Key key, this.parentScaffoldKey, this.currentTab, this.directedFrom})
      : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;
  CategoryController _controller = CategoryController();
  CartController _cart = CartController();
  var size, height, width;
  var args;
  int count = 0;
  LatLng SelectedLocation;
  String catId;
  bool isCurrentKitchen = true;
  bool isTrendingFoodLoaded = false,
      isTopKitchensLoaded = false,
      isPopularKitchenLoaded = false;
  bool isTrendingFoodDlvryLoaded = false,
      isTopKitchensDlvryLoaded = false,
      isPopularKitchenDlvryLoaded = false;
  int selectedCategoryindex = -1;
  int selectedCategoryDeliveryindex = -1;
  String defaultLanguage;
  List foodList = [];
  int selectedTabIndex = 0;
  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  String currentAddress = 'My Address';
  Position currentposition;

  bool isPositionDetermined = false;

  Future<void> _determinePosition() async {
    if (isPositionDetermined) {
      // Position has already been determined, no need to repeat.
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // print('Please enable your Location Service');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("permission", "LocationPermission.denied");
      // Fluttertoast.showToast(msg: 'Please enable Your Location Service');
      return;
    }

    permission = await Geolocator.checkPermission();
    //  print('Location permissions are $permission');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // print("permission is set ${permission.toString()}");
    prefs.setString("permission", permission.toString());

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // print('Requested location permission. New status: $permission');
      if (permission == LocationPermission.denied) {
        // Fluttertoast.showToast(msg: 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Fluttertoast.showToast(
      //     msg: 'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
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
      //   print("latitude: ${position.latitude}\nlongitude: ${position.longitude}");

      setState(() {
        currentposition = position;
        currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
        // print("DS>>> location: $currentAddress");
      });

      // Set the flag to true indicating that the position has been determined.
      isPositionDetermined = true;
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectTab(widget.currentTab);
    count = count++;
    //  print("count ==> $count ");
    args = RouteSettings().arguments;
    widget.scaffoldKey = new GlobalKey<ScaffoldState>();

    // _controller.listenForFoodsByCategory(id: '7');

    getCurrentDefaultLanguage();
    _determinePosition();
    getId();
    _con.refreshSubHome();
   /* Future.delayed(Duration(seconds: 1), () {

      //  setState(() { });
    });*/
  }

  getId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    catId = pref.getString('cat_id');
    //  await _con.refreshHome();
  }

  getCurrentDefaultLanguage() async {
    settingsRepo.getDefaultLanguageName().then((_langCode) {
      //   print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentSelectedTab = tabItem;
      switch (tabItem) {
        case 0:
          if (currentUser.value.apiToken != null) {
            Navigator.of(context).pushNamed('/orderPage', arguments: 0);
          } else {
            Navigator.of(context).pushNamed('/Login');
          }
          break;
        case 1:
          /*Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CalendarDialogWithoutRestaurant()),
          );*/
          break;
        case 1:
          isCurrentKitchen = true;
          widget.currentPage = HomeWidget(
            parentScaffoldKey: widget.scaffoldKey,
            currentTab: tabItem,
          );

          break;
        case 3:
          /*Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => KitchenListDeliveryWidget(
                      restaurantsList: _con.AllRestaurantsDelivery,
                      heroTag: "KitchenListDelivery",
                    )),
          );*/
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => KitchenListDeliveryWidget(
                      restaurantsList: _con.AllRestaurantsDelivery,
                      heroTag: "KitchenListDelivery",
                    )),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartWidget(
                parentScaffoldKey: widget.parentScaffoldKey,
              ),
            ),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<OffersProvider>(context);

    //_con.requestForCurrentLocation(context);
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    if (_con.categories.length > 0 &&
        _con.topKitchens.length > 0 &&
        _con.trendingFoodItems.length > 0 &&
        _con.popularKitchens.length > 0) {
      widget.showProress = false;
    } else {
      setState(() {
        widget.showProress = false;
        if (_con.isTopKitchensLoaded) {
          // print("DS>> home:top list ");
          isTopKitchensLoaded = true;
        }
        if (_con.isTrendingFoodLoaded) {
          // print("DS>> home:trending list ");
          isTrendingFoodLoaded = true;
        }
        if (_con.isPopularKitchenLoaded) {
          // print("DS>> home:pop list ");
          isPopularKitchenLoaded = true;
        }
      });
    }

    if (_con.categories.length > 0 &&
        _con.topKitchensDelivery.length > 0 &&
        _con.trendingFoodItemsDelivery.length > 0 &&
        _con.popularKitchensDelivery.length > 0) {
      widget.showProress = false;
    } else {
      setState(() {
        widget.showProress = false;
        if (_con.isTopKitchensDlvryLoaded) {
          isTopKitchensDlvryLoaded = true;
        }
        if (_con.isTrendingFoodDlvryLoaded) {
          isTrendingFoodDlvryLoaded = true;
        }
        if (_con.isPopularKitchenDlvryLoaded) {
          isPopularKitchenDlvryLoaded = true;
        }
      });
    }

    return isCurrentKitchen
        ? DefaultTabController(
            length: 2,
            child: WillPopScope(
              onWillPop: showExitPopup,
              child: Scaffold(
                drawer: DrawerWidget(),
                appBar: AppBar(
                  bottom: TabBar(
                    indicatorWeight: 14,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                      ),
                      border: Border.all(width: 50.0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    indicatorPadding: EdgeInsets.only(
                      top: 37,
                    ),
                    tabs: [
                      /*Text(
                      "Dine-In",
                      // S.of(context).pickup,
                      style: TextStyle(
                          color: settingsRepo.deliveryAddress.value?.address ==
                                  null
                              ? Theme.of(context).hintColor
                              : Theme.of(context).primaryColor,
                          fontSize: 20),
                    )*/
                      TranslationWidget(
                        message: S.of(context).delivery,
                        fromLanguage: "English",
                        toLanguage: defaultLanguage,
                        builder: (translatedMessage) => Text(translatedMessage,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                                color: settingsRepo
                                            .deliveryAddress.value?.address ==
                                        null
                                    ? Theme.of(context).hintColor
                                    : Theme.of(context).primaryColor,
                                fontSize: 20)),
                      ),
                      /*Text(
                      S.of(context).delivery,
                      style: TextStyle(
                          color: settingsRepo.deliveryAddress.value?.address ==
                                  null
                              ? Theme.of(context).hintColor
                              : Theme.of(context).primaryColor,
                          fontSize: 20),
                    )*/
                      TranslationWidget(
                        message: "Dine-In",
                        fromLanguage: "English",
                        toLanguage: defaultLanguage,
                        builder: (translatedMessage) => Text(translatedMessage,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                                color: settingsRepo
                                            .deliveryAddress.value?.address ==
                                        null
                                    ? Theme.of(context).hintColor
                                    : Theme.of(context).primaryColor,
                                fontSize: 20)),
                      ),
                    ],
                  ),
                  leading: Builder(builder: (context) {
                    return new IconButton(
                        icon: new Icon(Icons.sort,
                            color: Theme.of(context).hintColor),
                        onPressed: () => {
                              print("DS>>> clicked" +
                                  " " +
                                  widget.directedFrom +
                                  " " +
                                  widget.parentScaffoldKey.currentState
                                      .toString()),
                              widget.directedFrom == "forHome"
                                  ? Scaffold.of(context).openDrawer()
                                  : widget.parentScaffoldKey.currentState
                                      .openDrawer(),
                            });
                  }),
                  automaticallyImplyLeading: false,
                  iconTheme: IconThemeData(color: Colors.grey),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 30,
                        color: Colors.redAccent,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Consumer<Add_the_address>(
                                builder: (context, addressProvider, _) {
                                  String address = addressProvider.address1;
                                  if (address.length > 20) {
                                    address = address.substring(0, 20) + '...';
                                  }
                                  return Text(
                                    address,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  );
                                },
                              ),
                              Provider.of<Add_the_address>(context).address1 !=
                                      ""
                                  ? InkWell(
                                      onTap: () async {
                                        // await  _getCurrentLocation();
                                        // _address = await  _getAddressFromLocation(selectedLocation);
                                        //  print(_address);
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          // Wrap showModalBottomSheet with a Builder
                                          builder: (BuildContext context) {
                                            return Builder(
                                              builder: (BuildContext context) {
                                                return Container(
                                                    // color: Colors.red,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.95,
                                                    // Adjust height as needed
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                  width: 10),
                                                              InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .keyboard_arrow_down_sharp,
                                                                    size: 30,
                                                                  )),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                "Select a Location",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                              )
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            child:
                                                                TextFormField(
                                                              decoration:
                                                                  InputDecoration(
                                                                filled: true,
                                                                fillColor: Colors
                                                                        .grey[
                                                                    200], // Fill color
                                                                hintText:
                                                                    "Search for area, Street name",
                                                                prefixIcon: Icon(
                                                                    Icons
                                                                        .search,
                                                                    color: Colors
                                                                        .redAccent),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  // Border
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none, // No border
                                                                ),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            14.0,
                                                                        horizontal:
                                                                            16.0), // Padding
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Card(
                                                              color: Colors
                                                                  .grey[200],
                                                              elevation:
                                                                  0, // Set the elevation for the card
                                                              margin: EdgeInsets
                                                                  .all(
                                                                      15), // Set margin for the card
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      print(Provider.of<Add_the_address>(context, listen: false)
                                                                          .currentlocation);
                                                                      print( Provider.of<Add_the_address>(context, listen: false)
                                                                          .currentlocationLatlong);
                                                                      context.read<Add_the_address>().set_selected_location(
                                                                          Provider.of<Add_the_address>(context, listen: false)
                                                                              .currentlocation,
                                                                          Provider.of<Add_the_address>(context, listen: false)
                                                                              .currentlocationLatlong);
                                                                      context
                                                                          .read<
                                                                              Add_the_address>()
                                                                          .address_split();
                                                                      setState(
                                                                          () {});
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      // color:Colors.redAccent,
                                                                      height:
                                                                          70,
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              16.0,
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.my_location_outlined,
                                                                            color:
                                                                                Colors.redAccent,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                'Use Current Location',
                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                              ),
                                                                              SizedBox(
                                                                                width: MediaQuery.of(context).size.width * .7,
                                                                                child: Text(
                                                                                  Provider.of<Add_the_address>(context).currentlocation,
                                                                                  maxLines: 2,
                                                                                  softWrap: true,
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8.0),
                                                                    child:
                                                                        Container(
                                                                      height: 1,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                  //  Divider(), // Add a divider between list tiles
                                                                  GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      LatLng
                                                                          resultLocation =
                                                                          await _openAddressSelectionMap();
                                                                      if (resultLocation !=
                                                                          null) {
                                                                        String
                                                                            selectedAddress =
                                                                            await _getAddressFromLocation(resultLocation);
                                                                        SelectedLocation =
                                                                            resultLocation;
                                                                        print(
                                                                            selectedAddress);
                                                                        context
                                                                            .read<
                                                                                Add_the_address>()
                                                                            .add_to_address({
                                                                          "address":
                                                                              selectedAddress,
                                                                          "latlong":
                                                                              resultLocation
                                                                        });
                                                                        print(Provider.of<Add_the_address>(context,
                                                                                listen: false)
                                                                            .address
                                                                            .length);
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          50,
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              16.0,
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Icon(
                                                                              Icons.add,
                                                                              color: Colors.redAccent),
                                                                          SizedBox(
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          Text(
                                                                            'Add Address',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          if (Provider.of<
                                                                      Add_the_address>(
                                                                  context)
                                                              .address
                                                              .isNotEmpty)
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          if (Provider.of<
                                                                      Add_the_address>(
                                                                  context)
                                                              .address
                                                              .isNotEmpty)
                                                            Text(
                                                              '------  Save Address  ------',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          if (Provider.of<
                                                                      Add_the_address>(
                                                                  context)
                                                              .address
                                                              .isNotEmpty)
                                                            Column(
                                                              children: Provider
                                                                      .of<Add_the_address>(
                                                                          context)
                                                                  .address
                                                                  .map((addr) {
                                                                return Card(
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  elevation: 0,
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              5,
                                                                          horizontal:
                                                                              15),
                                                                  child:
                                                                      ListTile(
                                                                    onTap: () {
                                                                      print(addr["latlong"]
                                                                              .runtimeType
                                                                              .toString() ==
                                                                          "List<dynamic>");
                                                                      if (addr["latlong"]
                                                                              .runtimeType
                                                                              .toString() ==
                                                                          "List<dynamic>") {
                                                                        context.read<Add_the_address>().set_selected_location(
                                                                            addr[
                                                                                "address"],
                                                                            LatLng(addr["latlong"][0],
                                                                                addr["latlong"][1]));
                                                                        context
                                                                            .read<Add_the_address>()
                                                                            .address_split();
                                                                        _con.refreshHome();
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      } else {
                                                                        context.read<Add_the_address>().set_selected_location(
                                                                            addr["address"],
                                                                            addr["latlong"]);
                                                                        context
                                                                            .read<Add_the_address>()
                                                                            .address_split();
                                                                        _con.refreshHome();
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }
                                                                    },
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16,
                                                                        vertical:
                                                                            8),
                                                                    leading:
                                                                        Icon(
                                                                      Icons
                                                                          .location_on_rounded,
                                                                      color: Colors
                                                                          .redAccent,
                                                                      size: 40,
                                                                    ),
                                                                    title: Text(
                                                                      addr[
                                                                          "address"],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    trailing:
                                                                        IconButton(
                                                                      icon: Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Colors.red),
                                                                      onPressed:
                                                                          () {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return AlertDialog(
                                                                              content: Text("Are you sure you want to delete this address?"),
                                                                              actions: [
                                                                                TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop(); // Close the dialog
                                                                                  },
                                                                                  child: Text(
                                                                                    "Cancel",
                                                                                    style: TextStyle(color: Colors.redAccent),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                    gradient: LinearGradient(
                                                                                      colors: [
                                                                                        kPrimaryColororange,
                                                                                        kPrimaryColorLiteorange
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  child: MaterialButton(
                                                                                    onPressed: () {
                                                                                      //   _showAddressDialog();
                                                                                      Provider.of<Add_the_address>(context, listen: false).remove_address(addr);
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: Text(
                                                                                      'Delete',
                                                                                      style: TextStyle(color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                        ],
                                                      ),
                                                    ));
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Icon(
                                          Icons.keyboard_arrow_down_sharp,
                                          color: Colors.black45),
                                    )
                                  : Container()
                            ],
                          ),
                          Consumer<Add_the_address>(
                            builder: (context, addressProvider, _) {
                              String address = addressProvider.address2;
                              if (address.length > 30) {
                                address = address.substring(0, 30) + '...';
                              }
                              return Text(
                                address.trim(),
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                body: Stack(
                  children: [
                    TabBarView(
                      children: [
                        //Delivery
                        widget.showProress
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.deepOrangeAccent,
                                )))
                            : RefreshIndicator(
                                onRefresh: _con.refreshHome,
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                      left: 8, top: 10, bottom: 10, right: 0),
                                  child: Column(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: List.generate(
                                            settingsRepo.setting.value
                                                .homeSections.length, (index) {
                                          String _homeSection = settingsRepo
                                              .setting.value.homeSections
                                              .elementAt(index);
                                          switch (_homeSection) {
                                            case 'slider':
                                              return HomeSliderWidget(
                                                  slides: _con.slides);
                                            case 'search':
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            top: 0,
                                                            bottom: 0,
                                                            right: 18),
                                                    child: SearchBarWidget(
                                                        onClickFilter: (event) {
                                                          widget
                                                              .parentScaffoldKey
                                                              .currentState
                                                              .openEndDrawer();
                                                        },
                                                        isDinein: false),
                                                  ),
                                                  /* Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10,
                                                  top: 10.5,
                                                  bottom: 10.5,
                                                  right: 18),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          _openDialog(
                                                              context,
                                                              _con.cuisineList,
                                                              "delivery");
                                                        },
                                                        child: Container(
                                                          // width:237,

                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                              BorderRadius.only(
                                                                  topRight: Radius.circular(4),
                                                                  bottomRight: Radius.circular(4)),
                                                              color: Colors.white,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .grey,
                                                                    blurRadius:
                                                                    12,
                                                                    spreadRadius:
                                                                    -9)
                                                              ]),
                                                          child: TextButton(
                                                            onPressed: () {
                                                              _openDialog(
                                                                  context,
                                                                  _con.cuisineList,
                                                                  "delivery");
                                                            },
                                                            child:
                                                            GestureDetector(
                                                              onTap: () {
                                                                _openDialog(
                                                                    context,
                                                                    _con.cuisineList,
                                                                    "delivery");
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  // Icon(
                                                                  //   Icons.location_on_outlined,
                                                                  //   color: Theme.of(context)
                                                                  //       .hintColor,
                                                                  // ),
                                                                  Image.asset(
                                                                    "assets/img/cuisine.png",
                                                                    height:
                                                                    20,
                                                                    width: 20,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Text(
                                                                    "Cuisine",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        16,
                                                                        fontWeight: FontWeight
                                                                            .normal,
                                                                        color:
                                                                        Theme.of(context).hintColor),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    VerticalDivider(
                                                      color: Colors
                                                          .grey.shade100,
                                                      thickness: 1,
                                                      indent: 0,
                                                      width: 2,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        // width:237,

                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius.only(
                                                                topRight: Radius.circular(4),
                                                                bottomRight: Radius.circular(4)),
                                                            color: Colors.white,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  color: Colors
                                                                      .grey,
                                                                  blurRadius:
                                                                  12,
                                                                  spreadRadius:
                                                                  -9)
                                                            ]),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            _openDialogForLocation(
                                                                context,
                                                                _con.locationList,
                                                                "delivery");
                                                          },
                                                          child:
                                                          GestureDetector(
                                                            onTap: () {
                                                              _openDialogForLocation(
                                                                  context,
                                                                  _con.locationList,
                                                                  "delivery");
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              children: [
                                                                // Icon(
                                                                //   Icons.location_on_outlined,
                                                                //   color: Theme.of(context)
                                                                //       .hintColor,
                                                                // ),
                                                                Image.asset(
                                                                  "assets/img/location.png",
                                                                  height: 20,
                                                                  width: 20,
                                                                ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text(
                                                                  "Location",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      16,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                      color: Theme.of(context)
                                                                          .hintColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )*/
                                                ],
                                              );
                                            /*    case 'categories_heading':
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: ListTile(
                                            minLeadingWidth: 2,
                                            dense: true,
                                            contentPadding:
                                            EdgeInsets.symmetric(
                                                vertical: 0),
                                            leading: Icon(
                                              Icons.category,
                                              color:
                                              Theme.of(context).hintColor,
                                            ),
                                            title: */ /*Text(
                                                      S.of(context).food_categories,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.w500)
                                                      )*/ /*
                                            TranslationWidget(
                                              message: S
                                                  .of(context)
                                                  .food_categories,
                                              fromLanguage: "English",
                                              toLanguage: defaultLanguage,
                                              builder: (translatedMessage) =>
                                                  Text(translatedMessage,
                                                      overflow:
                                                      TextOverflow.fade,
                                                      softWrap: false,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                          FontWeight
                                                              .w500)),
                                            ),
                                          ),
                                        );*/
                                            // case 'categories':
                                            //   return CategoriesCarouselWidget(
                                            //     categories: _con.categories,
                                            //   );
                                            case 'categories':
                                              return _con.categories.isEmpty
                                                  ? Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300],
                                                      highlightColor:
                                                          Colors.grey[100],
                                                      child: Container(
                                                        height: 125,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 5,
                                                                horizontal: 8),
                                                        child: ListView.builder(
                                                          itemCount:
                                                              5, // Set a placeholder item count
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return ShimmerCategoryItem(); // Create a placeholder shimmer category item
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      height: 125,
                                                      // decoration: BoxDecoration(
                                                      //   boxShadow: [BoxShadow(color: kPrimaryColorLiteorange)]
                                                      // ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 8),
                                                      child: ListView.builder(
                                                        itemCount: _con
                                                            .categories.length,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, index) {
                                                          double _marginLeft =
                                                              0;
                                                          (index == 0)
                                                              ? _marginLeft = 20
                                                              : _marginLeft = 0;
                                                          return InkWell(
                                                            splashColor: Theme
                                                                    .of(context)
                                                                .accentColor
                                                                .withOpacity(
                                                                    0.08),
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              // SharedPreferences pref = await SharedPreferences.getInstance();
                                                              // pref.setString('food_list', widget.category.id);
                                                              setState(() {
                                                                selectedCategoryDeliveryindex =
                                                                    index;
                                                              });
                                                              catId = _con
                                                                  .categories[
                                                                      index]
                                                                  .id;
                                                              //   print(widget.category.id);

                                                              // await _controller.listenForFoodsByCategory(
                                                              //     id: _con
                                                              //         .categories[
                                                              //     index]
                                                              //         .id ==
                                                              //         null
                                                              //         ? '7'
                                                              //         : _con
                                                              //         .categories[
                                                              //     index]
                                                              //         .id);

                                                              setState(() {});

                                                              // Navigator.of(context)
                                                              //     .pushNamed('/Category', arguments: RouteArgument(id: _con.categories[index].id));
                                                            },
                                                            child: Container(
                                                              height: 200,
                                                              child: Column(
                                                                children: [
                                                                  Column(
                                                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: <
                                                                        Widget>[
                                                                      Hero(
                                                                        tag: _con
                                                                            .categories[index]
                                                                            .id,
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              EdgeInsets.all(5),
                                                                          // margin:
                                                                          //     EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.20,
                                                                          height:
                                                                              80,
                                                                          decoration: BoxDecoration(
                                                                              color: Theme.of(context).primaryColor,
                                                                              border: selectedCategoryDeliveryindex == index
                                                                                  ? Border.all(
                                                                                      color: kPrimaryColororange, // Set the border color
                                                                                      width: 1.0, // Set the border width
                                                                                    )
                                                                                  : null,
                                                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                    color: kPrimaryColororange,
                                                                                    // color: Theme.of(context).focusColor.withOpacity(0.2),
                                                                                    offset: Offset(
                                                                                      2,
                                                                                      2,
                                                                                    ),
                                                                                    spreadRadius: -8,
                                                                                    blurRadius: 10.0)
                                                                              ]),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(15),
                                                                            child: _con.categories[index].image.url.toLowerCase().endsWith('.svg')
                                                                                ? ShaderMask(
                                                                                    shaderCallback: (Rect bounds) {
                                                                                      return LinearGradient(
                                                                                        colors: [
                                                                                          kPrimaryColororange,
                                                                                          kPrimaryColorLiteorange
                                                                                        ],
                                                                                        stops: [0.3, 1.0], // Replace with your desired gradient colors
                                                                                        begin: Alignment.topLeft,
                                                                                        end: Alignment.bottomRight,
                                                                                      ).createShader(bounds);
                                                                                    },
                                                                                    blendMode: BlendMode.srcATop,
                                                                                    child: ColorFiltered(
                                                                                      colorFilter: ColorFilter.mode(kPrimaryColorLiteorange, BlendMode.srcIn),
                                                                                      child: SvgPicture.network(
                                                                                        _con.categories[index].image.url,
                                                                                        //color: kPrimaryColorLiteorange,
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : ShaderMask(
                                                                                    shaderCallback: (Rect bounds) {
                                                                                      return LinearGradient(
                                                                                        colors: [
                                                                                          kPrimaryColororange,
                                                                                          kPrimaryColorLiteorange
                                                                                        ],
                                                                                        stops: [0.3, 1.0], // Replace with your desired gradient colors
                                                                                        begin: Alignment.topLeft,
                                                                                        end: Alignment.bottomRight,
                                                                                      ).createShader(bounds);
                                                                                    },
                                                                                    child: CachedNetworkImage(
                                                                                      fit: BoxFit.cover,
                                                                                      imageUrl: _con.categories[index].image.icon,
                                                                                      placeholder: (context, url) => Image.asset(
                                                                                        'assets/img/loading.gif',
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                                                    ),
                                                                                  ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              5),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            left:
                                                                                8),

                                                                        // margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
                                                                        child: /*Text(
                          category.name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style:TextStyle(fontWeight: FontWeight.w600,),
                        )*/
                                                                            TranslationWidget(
                                                                          message: _con
                                                                              .categories[index]
                                                                              .name,
                                                                          fromLanguage:
                                                                              "English",
                                                                          toLanguage:
                                                                              defaultLanguage,
                                                                          builder: (translatedMessage) => Text(
                                                                              translatedMessage,
                                                                              overflow: TextOverflow.fade,
                                                                              softWrap: false,
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.w600,
                                                                              )),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ));
                                            // return CategoriesCarouselWidget(
                                            //   categories: _con.categories,
                                            // );
                                            case 'categories_foods':
                                              return Container(
                                                margin:EdgeInsets.only(bottom:10,top:10,left: 10),
                                                child: Consumer<OffersProvider>(
                                                  builder: (context,
                                                      offersProvider, _) {
                                                    if (offersProvider
                                                        .offers.isEmpty) {
                                                      // If offers list is empty, fetch offers
                                                      offersProvider
                                                          .fetchOffers();
                                                      return Shimmer.fromColors(
                                                        baseColor: Colors.grey[300],
                                                        highlightColor: Colors.grey[100],
                                                        child: Container(
                                                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                                                          child: Container(
                                                            height: 100,
                                                            width: MediaQuery.of(context).size.width * 0.8,
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return Container(
                                                        height: 100,
                                                        child: ListView.builder(
                                                          scrollDirection: Axis.horizontal,
                                                          itemCount: offersProvider.offers.length,
                                                          itemBuilder: (BuildContext context, int index) {
                                                            var offer = offersProvider.offers[index];
                                                            return Container(
                                                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                                                              width: MediaQuery.of(context).size.width * 0.8,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(10),
                                                                child: Image.network(
                                                                  offer.media.first.url,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );

                                                    }
                                                  },
                                                ),
                                              )

                                                  /*    Container(


                                         // color: Colors.green,
                                          margin:EdgeInsets.only(bottom: 20),
                                          height: 160,
                                          width:MediaQuery.of(context).size.width,
                                          child: Consumer<OffersProvider>(
                                            builder: (context, offersProvider, _) {
                                              if (offersProvider.offers.isEmpty) {
                                                // If offers list is empty, fetch offers
                                                offersProvider.fetchOffers();
                                                return Shimmer.fromColors(
                                                  baseColor:
                                                  Colors.grey[300],
                                                  highlightColor:
                                                  Colors.grey[100],
                                                  child: Container(
                                                    height: 160,
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                        vertical: 5,
                                                        horizontal: 8),
                                                    child: ListView.builder(
                                                      itemCount:
                                                      5, // Set a placeholder item count
                                                      scrollDirection:
                                                      Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap:
                                                              () {}, // Placeholder onTap function
                                                          child: Container(
                                                            height: 160,
                                                            margin:
                                                            EdgeInsets
                                                                .all(5),
                                                            width: MediaQuery.of(
                                                                context)
                                                                .size
                                                                .width *
                                                                0.8,
                                                            decoration:
                                                            BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      5)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                      0.5),
                                                                  spreadRadius:
                                                                  1,
                                                                  blurRadius:
                                                                  3,
                                                                  offset: Offset(
                                                                      0,
                                                                      2), // changes position of shadow
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                        ; // Create a placeholder shimmer category item
                                                      },
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return CustomCarouselSlider(
                                                  items: offersProvider.offers.map((offer) {
                                                    return Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                                                      child: Container(
                                                      //  padding: EdgeInsets.all(5),
                                                        child: Container(
                                                          height: 100,
                                                          width: MediaQuery.of(context).size.width * 0.7,
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              image: NetworkImage(offer.media.first.url),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            borderRadius: BorderRadius.circular(10)
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                );
                                              }
                                            },
                                          ),

                                        )*/
                                                  ;

                                              break;
                                            /*    return _controller.foodList.isEmpty
                                            ? CardsCarouselLoaderWidget()
                                            : Container(
                                          height: 185,
                                          child: ListView.builder(
                                              scrollDirection:
                                              Axis.horizontal,
                                              shrinkWrap: true,
                                              itemCount: _controller
                                                  .foodList.length,
                                              itemBuilder:
                                                  (context, index) {
                                                return Container(
                                                  padding:
                                                  EdgeInsets.all(
                                                      10),
                                                  child: InkWell(
                                                    highlightColor:
                                                    Colors
                                                        .transparent,
                                                    splashColor: Theme
                                                        .of(context)
                                                        .accentColor
                                                        .withOpacity(
                                                        0.08),
                                                    onTap: () {
                                                      */ /*Navigator.of(context).pushNamed('/Food',
                          arguments: new RouteArgument(
                              heroTag: this.widget.heroTag, id: this.widget.food.id));*/ /*
                                                      Navigator.of(
                                                          context)
                                                          .pushNamed(
                                                          '/Details',
                                                          arguments:
                                                          RouteArgument(
                                                            id: '0',
                                                            param: _controller
                                                                .foodList[index]
                                                                .restaurant
                                                                .id,
                                                            heroTag: _controller
                                                                .foodList[index]
                                                                .restaurant
                                                                .id,
                                                            isDelivery:
                                                            true,
                                                            selectedDate:
                                                            "",
                                                            parentScaffoldKey:
                                                            new GlobalKey(),
                                                          ));
                                                    },
                                                    child: Stack(
                                                      alignment:
                                                      AlignmentDirectional
                                                          .topEnd,
                                                      children: <
                                                          Widget>[
                                                        Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <
                                                              Widget>[
                                                            // Expanded(
                                                            //   child: Container(
                                                            //     decoration: BoxDecoration(
                                                            //       image: DecorationImage(
                                                            //           image: NetworkImage(_con.foodList[index].image.thumb),
                                                            //           fit: BoxFit.cover),
                                                            //       borderRadius: BorderRadius.circular(5),
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            Container(
                                                                child: Image
                                                                    .network(
                                                                  _controller
                                                                      .foodList[
                                                                  index]
                                                                      .image
                                                                      .thumb,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  height:
                                                                  120,
                                                                )),
                                                            SizedBox(
                                                                height:
                                                                5),
                                                            // Text(
                                                            //   _con.foodList[index].name.toString(),
                                                            //    style: Theme.of(context).textTheme.bodyText1,
                                                            //    overflow: TextOverflow.ellipsis,
                                                            //  ),
                                                            TranslationWidget(
                                                              message: _controller.foodList[index].name.toString(),
                                                              fromLanguage: "English",
                                                              toLanguage: defaultLanguage,
                                                              builder: (translatedMessage) {
                                                                // Get the first 15 characters of the translated message
                                                                String truncatedMessage="";
                                                                // Add ellipsis if the length of the translated message is greater than 15
                                                                if (translatedMessage.length > 16) {
                                                                  truncatedMessage = translatedMessage.substring(0, 16);
                                                                  truncatedMessage += '...';
                                                                }
                                                                else{
                                                                  truncatedMessage = translatedMessage;
                                                                }

                                                                return Text(
                                                                  truncatedMessage,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: Theme.of(context)
                                                                      .textTheme
                                                                      .bodyText1,
                                                                );
                                                              },
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                2),
                                                            */ /*Text(
                              widget.food.restaurant.name,
                              style: Theme.of(context).textTheme.caption,
                              overflow: TextOverflow.ellipsis,
                            )*/ /*
                                                            TranslationWidget(
                                                              message: _controller.foodList[index].restaurant.name.toString(),
                                                              fromLanguage: "English",
                                                              toLanguage: defaultLanguage,
                                                              builder: (translatedMessage) {
                                                                // Get the first 15 characters of the translated message
                                                                //String truncatedMessage = translatedMessage.substring(0, 15);
                                                                // Add ellipsis if the length of the translated message is greater than 15

                                                                return Text(
                                                                  translatedMessage,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: Theme.of(context).textTheme.caption,
                                                                );
                                                              },
                                                            )

                                                          ],
                                                        ),
                                                        // Container(
                                                        //   margin: EdgeInsets.all(10),
                                                        //   width: 35,
                                                        //   height: 35,
                                                        //   child: MaterialButton(
                                                        //     elevation: 0,
                                                        //     focusElevation: 0,
                                                        //     highlightElevation: 0,
                                                        //     padding: EdgeInsets.all(0),
                                                        //     onPressed: () {
                                                        //       print(currentUser.value.apiToken);
                                                        //       if (currentUser.value.apiToken == null) {
                                                        //
                                                        //         Navigator.of(context).pushNamed('/Login');
                                                        //       } else {
                                                        //         if (_controller.isSameRestaurants(_controller.foodList.elementAt(index))) {
                                                        //           _controller.addToCart(_controller.foodList.elementAt(index));
                                                        //         } else {
                                                        //           showDialog(
                                                        //             context: context,
                                                        //             builder: (BuildContext context) {
                                                        //               // return object of type Dialog
                                                        //               return AddToCartAlertDialogWidget(
                                                        //                   oldFood: _controller.carts.elementAt(0)?.food,
                                                        //                   newFood: _controller.foodList.elementAt(index),
                                                        //                   onPressed: (food, {reset: true}) {
                                                        //                     return _controller.addToCart(_controller.foodList.elementAt(index), reset: true);
                                                        //                   });
                                                        //             },
                                                        //           );
                                                        //         }
                                                        //       }
                                                        //
                                                        //       //widget.onPressed();
                                                        //     },
                                                        //     child: Icon(
                                                        //       Icons.shopping_cart,
                                                        //       color: Theme.of(context).primaryColor,
                                                        //       size: 21,
                                                        //     ),
                                                        //     color: Theme.of(context).accentColor.withOpacity(0.9),
                                                        //     shape: StadiumBorder(),
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        );*/
                                            case 'top_restaurants_headings':
                                              return _con.isTopKitchensDlvryLoaded &&
                                                      _con.topKitchensDelivery
                                                          .isNotEmpty
                                                  ? ListTile(
                                                      dense: true,
                                                      minLeadingWidth: 2,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20),
                                                      leading:
                                                          // SvgPicture.asset("assets/img/locationarrow.svg"),
                                                          Image.asset(
                                                        "assets/img/top-home-kitchen.png",
                                                        height: 27,
                                                        width: 27,
                                                      ),
                                                      title: /*Text(
                                                  S.of(context).top_home_kitchens,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w500),
                                                )*/
                                                          TranslationWidget(
                                                        message: "Top Home Kitchen",
                                                        fromLanguage: "English",
                                                        toLanguage:
                                                            defaultLanguage,
                                                        builder: (translatedMessage) => Text(
                                                            translatedMessage,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            softWrap: false,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ),
                                                      subtitle: Text(
                                                        S
                                                            .of(context)
                                                            .clickOnTheFoodToGetMoreDetailsAboutIt,
                                                        maxLines: 2,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption,
                                                      ),
                                                    )
                                                  : SizedBox();
                                            case 'top_restaurantss':
                                              return _con
                                                      .isTopKitchensDlvryLoaded
                                                  ? _con.topKitchensDelivery
                                                          .isEmpty
                                                      ? Container()
                                                      : CardsCarouselWidget(
                                                          delivery: true,
                                                          restaurantsList: _con
                                                              .topKitchensDelivery,
                                                          heroTag:
                                                              'home_top_restaurants',
                                                          parentScaffoldKey: widget
                                                              .parentScaffoldKey,
                                                        )
                                                  : Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300],
                                                      highlightColor:
                                                          Colors.grey[100],
                                                      child: Container(
                                                        height: 200,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 5,
                                                                horizontal: 8),
                                                        child: ListView.builder(
                                                          itemCount:
                                                              5, // Set a placeholder item count
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return InkWell(
                                                              onTap:
                                                                  () {}, // Placeholder onTap function
                                                              child: Container(
                                                                height: 200,
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.8,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              5)),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5),
                                                                      spreadRadius:
                                                                          1,
                                                                      blurRadius:
                                                                          3,
                                                                      offset: Offset(
                                                                          0,
                                                                          2), // changes position of shadow
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                            ; // Create a placeholder shimmer category item
                                                          },
                                                        ),
                                                      ),
                                                    );
                                            case 'trending_week_heading':
                                              return _con.trendingFoodItemsDelivery
                                                          .isNotEmpty &&
                                                      _con.isTrendingFoodDlvryLoaded
                                                  ? ListTile(
                                                      dense: true,
                                                      minLeadingWidth: 2,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20),
                                                      leading: Icon(
                                                        Icons.trending_up,
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                      ),
                                                      title: /*Text(
                                                  S.of(context).trending_this_week,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w500),
                                                )*/
                                                          TranslationWidget(
                                                        message: S
                                                            .of(context)
                                                            .trending_this_week,
                                                        fromLanguage: "English",
                                                        toLanguage:
                                                            defaultLanguage,
                                                        builder:
                                                            (translatedMessage) =>
                                                                Text(
                                                          translatedMessage,
                                                          overflow:
                                                              TextOverflow.fade,
                                                          softWrap: false,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                      subtitle: /*Text(
                                                  S.of(context)
                                                      .clickOnTheFoodToGetMoreDetailsAboutIt,
                                                  maxLines: 2,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption,
                                                )*/
                                                          TranslationWidget(
                                                        message: S
                                                            .of(context)
                                                            .clickOnTheFoodToGetMoreDetailsAboutIt,
                                                        fromLanguage: "English",
                                                        toLanguage:
                                                            defaultLanguage,
                                                        builder:
                                                            (translatedMessage) =>
                                                                Text(
                                                          translatedMessage,
                                                          overflow:
                                                              TextOverflow.fade,
                                                          softWrap: false,
                                                          maxLines: 2,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption,
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox();
                                            case 'trending_week':
                                              return _con
                                                      .isTrendingFoodDlvryLoaded
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 0.0),
                                                      child: StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                          if (_con
                                                              .trendingFoodItemsDelivery
                                                              .isEmpty) {
                                                            // Show a loading indicator or placeholder while data is being fetched
                                                            return Shimmer
                                                                .fromColors(
                                                              baseColor: Colors
                                                                  .grey[300],
                                                              highlightColor:
                                                                  Colors.grey[
                                                                      100],
                                                              child: Container(
                                                                height: 125,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            5,
                                                                        horizontal:
                                                                            8),
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount:
                                                                      5, // Set a placeholder item count
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Container(); // Create a placeholder shimmer category item
                                                                  },
                                                                ),
                                                              ),
                                                            );
                                                            /* return Center(
                                                                child:
                                                                    CircularProgressIndicator(color: Colors.deepOrangeAccent,));*/
                                                          } else {
                                                            return FoodsCarouselWidget(
                                                              delivery: true,
                                                              foodsList: _con
                                                                  .trendingFoodItemsDelivery,
                                                              heroTag:
                                                                  'home_food_carousel',
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    )
                                                  : Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300],
                                                      highlightColor:
                                                          Colors.grey[100],
                                                      child: Container(
                                                        height: 200,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 5,
                                                                horizontal: 8),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                vertical: 14),
                                                        child: ListView.builder(
                                                          itemCount:
                                                              5, // Set a placeholder item count
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return InkWell(
                                                              onTap:
                                                                  () {}, // Placeholder onTap function
                                                              child: Container(
                                                                height: 200,
                                                                width: 120,
                                                                //height: 150,
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                //width: MediaQuery.of(context).size.width * 0.20,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              5)),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5),
                                                                      spreadRadius:
                                                                          1,
                                                                      blurRadius:
                                                                          3,
                                                                      offset: Offset(
                                                                          0,
                                                                          2), // changes position of shadow
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                            ; // Create a placeholder shimmer category item
                                                          },
                                                        ),
                                                      ),
                                                    );
                                            case 'popular_heading':
                                              return _con.isPopularKitchenDlvryLoaded &&
                                                      _con.popularKitchensDelivery
                                                          .isNotEmpty
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 20,
                                                              bottom: 5,
                                                              top: 5),
                                                      child: ListTile(
                                                        dense: true,
                                                        minLeadingWidth: 2,
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        0),
                                                        leading: Icon(
                                                          Icons.trending_up,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor,
                                                        ),
                                                        title: /*Text(
                                                      S.of(context).most_popular,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500))*/
                                                            TranslationWidget(
                                                          message: S
                                                              .of(context)
                                                              .most_popular,
                                                          fromLanguage:
                                                              "English",
                                                          toLanguage:
                                                              defaultLanguage,
                                                          builder:
                                                              (translatedMessage) =>
                                                                  Text(
                                                            translatedMessage,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            softWrap: false,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                        trailing: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          KitchenListDeliveryWidget(
                                                                            restaurantsList:
                                                                                _con.AllRestaurantsDelivery,
                                                                            heroTag:
                                                                                "KitchenListDelivery",
                                                                          )),
                                                            );
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                                "View all"),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox();
                                            case 'popular':
                                              return _con
                                                      .isPopularKitchenDlvryLoaded
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 12.0),
                                                      child: GridWidget(
                                                        delivery: true,
                                                        restaurantsList: _con
                                                            .popularKitchensDelivery,
                                                        heroTag:
                                                            'home_restaurants',
                                                      ),
                                                    )
                                                  : Center(
                                                      child:
                                                          /*Text("No Data available")*/
                                                          TranslationWidget(
                                                      message: "",
                                                      fromLanguage: "English",
                                                      toLanguage:
                                                          defaultLanguage,
                                                      builder:
                                                          (translatedMessage) =>
                                                              Text(
                                                        translatedMessage,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        softWrap: false,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle1,
                                                      ),
                                                    ));
                                            case 'recent_reviews_heading':
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: ListTile(
                                                  dense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 20),
                                                  leading: Icon(
                                                    Icons.recent_actors,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                                  title: Text(
                                                    S
                                                        .of(context)
                                                        .recent_reviews,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4,
                                                  ),
                                                ),
                                              );
                                            case 'recent_reviews':
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: ReviewsListWidget(
                                                    reviewsList:
                                                        _con.recentReviews),
                                              );
                                            default:
                                              return SizedBox(height: 0);
                                          }
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        //Dine In
                        widget.showProress
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.deepOrangeAccent,
                                )))
                            : RefreshIndicator(
                                onRefresh: _con.refreshHome,
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                      left: 8, top: 10, bottom: 10, right: 0),
                                  child: Column(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: List.generate(
                                            settingsRepo.setting.value
                                                .homeSections.length, (index) {
                                          String _homeSection = settingsRepo
                                              .setting.value.homeSections
                                              .elementAt(index);

                                          switch (_homeSection) {
                                            case 'slider':
                                              return HomeSliderWidget(
                                                  slides: _con.slides);
                                            case 'search':
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            top: 0,
                                                            bottom: 0,
                                                            right: 18),
                                                    child: SearchBarWidget(
                                                        onClickFilter: (event) {
                                                          widget
                                                              .parentScaffoldKey
                                                              .currentState
                                                              .openEndDrawer();
                                                        },
                                                        isDinein: true),
                                                  ),
                                                /*  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            top: 10.5,
                                                            bottom: 10.5,
                                                            right: 18),
                                                    child: IntrinsicHeight(
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              // width:235,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.only(
                                                                          topLeft: Radius.circular(4),
                                                                          bottomLeft: Radius.circular(4)),
                                                                  color: Colors.white,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors
                                                                            .grey,
                                                                        blurRadius:
                                                                            12,
                                                                        spreadRadius:
                                                                            -9)
                                                                  ]),
                                                              child: TextButton(
                                                                onPressed: () {
                                                                  _openDialog(
                                                                      context,
                                                                      _con.cuisineList,
                                                                      "dine-in");
                                                                },
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    _openDialog(
                                                                        context,
                                                                        _con.cuisineList,
                                                                        "dine-in");
                                                                  },
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        "assets/img/cuisine.png",
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      *//*Text(
                                                                        "Cuisine",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .normal,
                                                                            color: Theme.of(
                                                                                    context)
                                                                                .hintColor),
                                                                      )*//*
                                                                      TranslationWidget(
                                                                        message:
                                                                            "Cuisine",
                                                                        fromLanguage:
                                                                            "English",
                                                                        toLanguage:
                                                                            defaultLanguage,
                                                                        builder: (translatedMessage) => Text(
                                                                            translatedMessage,
                                                                            overflow: TextOverflow
                                                                                .fade,
                                                                            softWrap:
                                                                                false,
                                                                            style: TextStyle(
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.normal,
                                                                                color: Theme.of(context).hintColor)),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          VerticalDivider(
                                                            color: Colors
                                                                .grey.shade100,
                                                            thickness: 1,
                                                            indent: 0,
                                                            width: 2,
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              // width:237,

                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.only(
                                                                          topRight: Radius.circular(4),
                                                                          bottomRight: Radius.circular(4)),
                                                                  color: Colors.white,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors
                                                                            .grey,
                                                                        blurRadius:
                                                                            12,
                                                                        spreadRadius:
                                                                            -9)
                                                                  ]),
                                                              child: TextButton(
                                                                onPressed: () {
                                                                  _openDialogForLocation(
                                                                      context,
                                                                      _con.locationList,
                                                                      "dine-in");
                                                                },
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    _openDialogForLocation(
                                                                        context,
                                                                        _con.locationList,
                                                                        "dine-in");
                                                                  },
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        "assets/img/location.png",
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      *//*Text(
                                                                        "Location",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .normal,
                                                                            color: Theme.of(
                                                                                    context)
                                                                                .hintColor),
                                                                      )*//*
                                                                      TranslationWidget(
                                                                        message:
                                                                            "Location",
                                                                        fromLanguage:
                                                                            "English",
                                                                        toLanguage:
                                                                            defaultLanguage,
                                                                        builder: (translatedMessage) => Text(
                                                                            translatedMessage,
                                                                            overflow: TextOverflow
                                                                                .fade,
                                                                            softWrap:
                                                                                false,
                                                                            style: TextStyle(
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.normal,
                                                                                color: Theme.of(context).hintColor)),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )*/
                                                ],
                                              );
                                            /*   case 'categories_heading':
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: ListTile(
                                                  minLeadingWidth: 2,
                                                  dense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 0),
                                                  leading: Icon(
                                                    Icons.category,
                                                    color:
                                                        Theme.of(context).hintColor,
                                                  ),
                                                  title: */ /*Text(
                                                      S.of(context).food_categories,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.w500)
                                                      // style: Theme.of(context).textTheme.headline4,
                                                      )*/ /*
                                                      TranslationWidget(
                                                    message: S
                                                        .of(context)
                                                        .food_categories,
                                                    fromLanguage: "English",
                                                    toLanguage: defaultLanguage,
                                                    builder: (translatedMessage) =>
                                                        Text(translatedMessage,
                                                            overflow:
                                                                TextOverflow.fade,
                                                            softWrap: false,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                  ),
                                                ),
                                              );*/
                                            case 'categories':
                                              return _con.categories.isEmpty
                                                  ? Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300],
                                                      highlightColor:
                                                          Colors.grey[100],
                                                      child: Container(
                                                        height: 125,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 5,
                                                                horizontal: 8),
                                                        child: ListView.builder(
                                                          itemCount:
                                                              5, // Set a placeholder item count
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return ShimmerCategoryItem(); // Create a placeholder shimmer category item
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      height: 125,
                                                      // decoration: BoxDecoration(
                                                      //   boxShadow: [BoxShadow(color: kPrimaryColorLiteorange)]
                                                      // ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 8),
                                                      child: ListView.builder(
                                                        itemCount: _con
                                                            .categories.length,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, index) {
                                                          double _marginLeft =
                                                              0;
                                                          (index == 0)
                                                              ? _marginLeft = 20
                                                              : _marginLeft = 0;
                                                          return InkWell(
                                                            splashColor: Theme
                                                                    .of(context)
                                                                .accentColor
                                                                .withOpacity(
                                                                    0.08),
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              // SharedPreferences pref = await SharedPreferences.getInstance();
                                                              // pref.setString('food_list', widget.category.id);
                                                              setState(() {
                                                                selectedCategoryindex =
                                                                    index;
                                                              });

                                                              catId = _con
                                                                  .categories[
                                                                      index]
                                                                  .id;
                                                              //   print(widget.category.id);

                                                              // await _controller.listenForFoodsByCategory(
                                                              //     id: _con
                                                              //                 .categories[
                                                              //                     index]
                                                              //                 .id ==
                                                              //             null
                                                              //         ? '7'
                                                              //         : _con
                                                              //             .categories[
                                                              //                 index]
                                                              //             .id);

                                                              setState(() {
                                                                //    selectedCategoryindex = index;
                                                              });

                                                              // Navigator.of(context)
                                                              //     .pushNamed('/Category', arguments: RouteArgument(id: _con.categories[index].id));
                                                            },
                                                            child: Container(
                                                              height: 200,
                                                              //color: Colors.green,
                                                              child: Column(
                                                                children: [
                                                                  Column(
                                                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: <
                                                                        Widget>[
                                                                      Hero(
                                                                        tag: _con
                                                                            .categories[index]
                                                                            .id,
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              EdgeInsets.all(5),
                                                                          // margin:
                                                                          //     EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.20,
                                                                          height:
                                                                              80,
                                                                          decoration: BoxDecoration(
                                                                              color: Theme.of(context).primaryColor,
                                                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                              border: selectedCategoryindex == index
                                                                                  ? Border.all(
                                                                                      color: kPrimaryColororange, // Set the border color
                                                                                      width: 1.0, // Set the border width
                                                                                    )
                                                                                  : null,
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                    color: kPrimaryColororange,
                                                                                    // color: Theme.of(context).focusColor.withOpacity(0.2),
                                                                                    offset: Offset(
                                                                                      2,
                                                                                      2,
                                                                                    ),
                                                                                    spreadRadius: -8,
                                                                                    blurRadius: 10.0)
                                                                              ]),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(15),
                                                                            child: _con.categories[index].image.url.toLowerCase().endsWith('.svg')
                                                                                ? ShaderMask(
                                                                                    shaderCallback: (Rect bounds) {
                                                                                      return LinearGradient(
                                                                                        colors: [
                                                                                          kPrimaryColororange,
                                                                                          kPrimaryColorLiteorange
                                                                                        ],
                                                                                        stops: [0.3, 1.0], // Replace with your desired gradient colors
                                                                                        begin: Alignment.topLeft,
                                                                                        end: Alignment.bottomRight,
                                                                                      ).createShader(bounds);
                                                                                    },
                                                                                    blendMode: BlendMode.srcATop,
                                                                                    child: ColorFiltered(
                                                                                      colorFilter: ColorFilter.mode(kPrimaryColorLiteorange, BlendMode.srcIn),
                                                                                      child: SvgPicture.network(
                                                                                        _con.categories[index].image.url,
                                                                                        //color: kPrimaryColorLiteorange,
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : ShaderMask(
                                                                                    shaderCallback: (Rect bounds) {
                                                                                      return LinearGradient(
                                                                                        colors: [
                                                                                          kPrimaryColororange,
                                                                                          kPrimaryColorLiteorange
                                                                                        ],
                                                                                        stops: [0.3, 1.0], // Replace with your desired gradient colors
                                                                                        begin: Alignment.topLeft,
                                                                                        end: Alignment.bottomRight,
                                                                                      ).createShader(bounds);
                                                                                    },
                                                                                    child: CachedNetworkImage(
                                                                                      fit: BoxFit.cover,
                                                                                      imageUrl: _con.categories[index].image.icon,
                                                                                      placeholder: (context, url) => Image.asset(
                                                                                        'assets/img/loading.gif',
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                                                    ),
                                                                                  ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              5),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            left:
                                                                                8),

                                                                        // margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
                                                                        child: /*Text(
                          category.name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style:TextStyle(fontWeight: FontWeight.w600,),
                        )*/
                                                                            TranslationWidget(
                                                                          message: _con
                                                                              .categories[index]
                                                                              .name,
                                                                          fromLanguage:
                                                                              "English",
                                                                          toLanguage:
                                                                              defaultLanguage,
                                                                          builder: (translatedMessage) => Text(
                                                                              translatedMessage,
                                                                              overflow: TextOverflow.fade,
                                                                              softWrap: false,
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.w600,
                                                                              )),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ));
                                            // return CategoriesCarouselWidget(
                                            //   categories: _con.categories,
                                            // );
                                            case 'categories_foods':
                                              return
                                                Container(
                                                  margin:EdgeInsets.only(bottom:10,top:10),
                                                  child: Consumer<OffersProvider>(
                                                    builder: (context,
                                                        offersProvider, _) {
                                                      if (offersProvider
                                                          .offers.isEmpty) {
                                                        // If offers list is empty, fetch offers
                                                        offersProvider
                                                            .fetchOffers();
                                                        return Shimmer.fromColors(
                                                          baseColor: Colors.grey[300],
                                                          highlightColor: Colors.grey[100],
                                                          child: Container(
                                                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                                                            child: Container(
                                                              height: 100,
                                                              width: MediaQuery.of(context).size.width * 0.8,
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return Container(
                                                          height: 100,
                                                          child: ListView.builder(
                                                            scrollDirection: Axis.horizontal,
                                                            itemCount: offersProvider.offers.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              var offer = offersProvider.offers[index];
                                                              return Container(
                                                                margin: EdgeInsets.symmetric(horizontal: 10.0),
                                                                width: MediaQuery.of(context).size.width * 0.8,
                                                                child: ClipRRect(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  child: Image.network(
                                                                    offer.media.first.url,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                );
                                              /* Container(


                                                // color: Colors.green,
                                                margin:
                                                    EdgeInsets.only(bottom: 20),
                                                height: 160,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Consumer<OffersProvider>(
                                                  builder: (context,
                                                      offersProvider, _) {
                                                    if (offersProvider
                                                        .offers.isEmpty) {
                                                      // If offers list is empty, fetch offers
                                                      offersProvider
                                                          .fetchOffers();
                                                      return Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    } else {
                                                      return CustomCarouselSlider(
                                                        items: offersProvider
                                                            .offers
                                                            .map((offer) {
                                                          return Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        20.0),
                                                            child: Container(
                                                              //  padding: EdgeInsets.all(5),
                                                              child: Container(
                                                                height: 100,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.7,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        image:
                                                                            DecorationImage(
                                                                          image: NetworkImage(offer
                                                                              .media
                                                                              .first
                                                                              .url),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      );
                                                    }
                                                  },
                                                ),
                                              );*/

                                              break;
                                            /*        return _controller.foodList.isEmpty
                                                  ? CardsCarouselLoaderWidget()
                                                  : NotificationListener<ScrollNotification>(
                                                onNotification: (ScrollNotification scrollInfo) {
                                                  if (
                                                      scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                                                    // User has reached the end of the list
                                                    _controller.debounceLoadMore(context, catId == null ? '7' : catId);

                                                    setState(() {
                                                      //    selectedCategoryindex = index;
                                                    });
                                                  }
                                                  return false;
                                                },
                                                    child: Container(
                                              //  color: Colors.amber,
                                                        height: 185,
                                                       // margin: EdgeInsets.symmetric(vertical: 10),
                                                        child: ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            itemCount: _controller
                                                                .foodList.length,
                                                            itemBuilder:
                                                                (context, index) {
                                                              return Container(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        10),
                                                                child: InkWell(
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  splashColor: Theme
                                                                          .of(context)
                                                                      .accentColor
                                                                      .withOpacity(
                                                                          0.08),
                                                                  onTap: () {
                                                                    */
                                          /*Navigator.of(context).pushNamed('/Food',
                          arguments: new RouteArgument(
                              heroTag: this.widget.heroTag, id: this.widget.food.id));*/
                                          /*
                                                                    int selected_index = selectedCategoryindex > -1 ? selectedCategoryindex : -1;
                                                                    showCalendarDialog(context, _controller
                                                                        .foodList[index]
                                                                        .restaurant
                                                                        .id, false,selected_index);
                                                                  */ /*  Navigator.of(
                                                                            context)
                                                                        .pushNamed(
                                                                            '/Details',
                                                                            arguments:
                                                                                RouteArgument(
                                                                              id: '0',
                                                                              param: _controller
                                                                                  .foodList[index]
                                                                                  .restaurant
                                                                                  .id,
                                                                              heroTag: _controller
                                                                                  .foodList[index]
                                                                                  .restaurant
                                                                                  .id,
                                                                              isDelivery:
                                                                                  false,
                                                                              selectedDate:
                                                                                  "",
                                                                              parentScaffoldKey:
                                                                                  new GlobalKey(),
                                                                            ));*/
                                          /*
                                                                  },
                                                                  child: Stack(
                                                                    alignment:
                                                                        AlignmentDirectional
                                                                            .topEnd,
                                                                    children: <
                                                                        Widget>[
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .start,
                                                                        children: <
                                                                            Widget>[
                                                                          // Expanded(
                                                                          //   child: Container(
                                                                          //     decoration: BoxDecoration(
                                                                          //       image: DecorationImage(
                                                                          //           image: NetworkImage(_con.foodList[index].image.thumb),
                                                                          //           fit: BoxFit.cover),
                                                                          //       borderRadius: BorderRadius.circular(5),
                                                                          //     ),
                                                                          //   ),
                                                                          // ),
                                                                          Container(
                                                                              child: Image
                                                                                  .network(
                                                                            _controller
                                                                                .foodList[
                                                                                    index]
                                                                                .image
                                                                                .thumb,
                                                                            fit: BoxFit
                                                                                .cover,
                                                                            height:
                                                                                120,
                                                                          )),
                                                                          SizedBox(
                                                                              height:
                                                                                  5),
                                                                          // Text(
                                                                          //   _con.foodList[index].name.toString(),
                                                                          //    style: Theme.of(context).textTheme.bodyText1,
                                                                          //    overflow: TextOverflow.ellipsis,
                                                                          //  ),
                                                                          TranslationWidget(
                                                                            message: _controller.foodList[index].name.toString(),
                                                                            fromLanguage: "English",
                                                                            toLanguage: defaultLanguage,
                                                                            builder: (translatedMessage) {
                                                                              // Get the first 15 characters of the translated message
                                                                              String truncatedMessage="";
                                                                              // Add ellipsis if the length of the translated message is greater than 15
                                                                              if (translatedMessage.length > 16) {
                                                                                truncatedMessage = translatedMessage.substring(0, 16);
                                                                                truncatedMessage += '...';
                                                                              }
                                                                              else{
                                                                                truncatedMessage = translatedMessage;
                                                                              }

                                                                              return Text(
                                                                                truncatedMessage,
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: Theme.of(context)
                                                                                    .textTheme
                                                                                    .bodyText1,
                                                                              );
                                                                            },
                                                                          ),
                                                                          */
                                          /*Text(
                              widget.food.restaurant.name,
                              style: Theme.of(context).textTheme.caption,
                              overflow: TextOverflow.ellipsis,
                            )*/ /*
                                                                          TranslationWidget(
                                                                            message: _controller
                                                                                .foodList[
                                                                                    index]
                                                                                .restaurant
                                                                                .name
                                                                                .toString(),
                                                                            fromLanguage:
                                                                                "English",
                                                                            toLanguage:
                                                                                defaultLanguage,
                                                                            builder:
                                                                                (translatedMessage) =>
                                                                                    Text(
                                                                              translatedMessage,
                                                                              maxLines:
                                                                                  1,
                                                                              overflow:
                                                                                  TextOverflow.ellipsis,
                                                                              style: Theme.of(context)
                                                                                  .textTheme
                                                                                  .caption,
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      // Container(
                                                                      //   margin: EdgeInsets.all(10),
                                                                      //   width: 35,
                                                                      //   height: 35,
                                                                      //   child: MaterialButton(
                                                                      //     elevation: 0,
                                                                      //     focusElevation: 0,
                                                                      //     highlightElevation: 0,
                                                                      //     padding: EdgeInsets.all(0),
                                                                      //     onPressed: () {
                                                                      //       print(currentUser.value.apiToken);
                                                                      //       if (currentUser.value.apiToken == null) {
                                                                      //
                                                                      //         Navigator.of(context).pushNamed('/Login');
                                                                      //       } else {
                                                                      //         if (_controller.isSameRestaurants(_controller.foodList.elementAt(index))) {
                                                                      //           _controller.addToCart(_controller.foodList.elementAt(index));
                                                                      //         } else {
                                                                      //           showDialog(
                                                                      //             context: context,
                                                                      //             builder: (BuildContext context) {
                                                                      //               // return object of type Dialog
                                                                      //               return AddToCartAlertDialogWidget(
                                                                      //                   oldFood: _controller.carts.elementAt(0)?.food,
                                                                      //                   newFood: _controller.foodList.elementAt(index),
                                                                      //                   onPressed: (food, {reset: true}) {
                                                                      //                     return _controller.addToCart(_controller.foodList.elementAt(index), reset: true);
                                                                      //                   });
                                                                      //             },
                                                                      //           );
                                                                      //         }
                                                                      //       }
                                                                      //
                                                                      //       //widget.onPressed();
                                                                      //     },
                                                                      //     child: Icon(
                                                                      //       Icons.shopping_cart,
                                                                      //       color: Theme.of(context).primaryColor,
                                                                      //       size: 21,
                                                                      //     ),
                                                                      //     color: Theme.of(context).accentColor.withOpacity(0.9),
                                                                      //     shape: StadiumBorder(),
                                                                      //   ),
                                                                      // ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                      ),
                                                  );*/
                                            //    return GridWidgetCategoryFoods(id: catId==null?'7':catId,
                                            //
                                            // );
                                            //                 return  Container(
                                            //                   decoration: BoxDecoration(
                                            //                     color: .white,
                                            //                     borderRadius: BorderRadius.circular(10),
                                            //                     boxShadow: [
                                            //                       BoxShadow(
                                            //                         color: Theme.of(context).focusColor.withOpacity(0.1),
                                            //                         blurRadius: 15,
                                            //                         offset: Offset(0, 5),
                                            //                       ),
                                            //                     ],
                                            //                   ),
                                            //                   child: Container(
                                            //                     padding: EdgeInsets.all(11),
                                            //                     height: 200,
                                            //                     width: 170,
                                            //                     decoration: BoxDecoration(
                                            //                       color:Colors.transparent,
                                            //                       // borderRadius: BorderRadius.all(Radius.circular(10)),
                                            //                       boxShadow: [
                                            //                         BoxShadow(
                                            //                             color: Theme
                                            //                                 .of(context)
                                            //                                 .focusColor
                                            //                                 .withOpacity(0.1),
                                            //                             blurRadius: 15,
                                            //                             offset: Offset(0, 5)),
                                            //                       ],
                                            //                     ),
                                            //                     child: Column(
                                            //
                                            //                       children: <Widget>[
                                            //                         // Image of the card
                                            //                         ClipRRect(
                                            //                           borderRadius: BorderRadius.all(
                                            //                               Radius.circular(10)),
                                            //                           child: CachedNetworkImage(
                                            //                             height: 80,
                                            //                             width: 180,
                                            //                             fit: BoxFit.cover,
                                            //                             imageUrl: "https://www.pexels.com/photo/close-up-photograph-of-flowers-931177/",
                                            //                             placeholder: (context, url) =>
                                            //                                 Image.asset(
                                            //                                   'assets/img/loading.gif',
                                            //                                   fit: BoxFit.cover,
                                            //                                   //width: double.infinity,
                                            //                                   //height: 150,
                                            //                                 ),
                                            //                             errorWidget: (context, url, error) => Icon(Icons.error),
                                            //                           ),
                                            //                         ),
                                            //                         Row(
                                            //                           children: [
                                            //                             Expanded(
                                            //                               child: Column(
                                            //                                 crossAxisAlignment: CrossAxisAlignment.start,
                                            //                                 children: [
                                            //                                   SizedBox(
                                            //                                     width:130,
                                            //                                     height: 17,
                                            //                                     child: /*Text(
                                            //   restaurant.name,
                                            //   overflow: TextOverflow.fade,
                                            //   softWrap: false,
                                            //   style: Theme
                                            //       .of(context)
                                            //       .textTheme
                                            //       .titleSmall.merge(TextStyle(fontWeight: FontWeight.w400)),
                                            // )*/
                                            //                                     TranslationWidget(
                                            //                                       message:  "widget.restaurant.name",
                                            //                                       fromLanguage: "English",
                                            //                                       toLanguage: defaultLanguage,
                                            //                                       builder: (translatedMessage) => Text(
                                            //                                         translatedMessage,
                                            //                                         overflow: TextOverflow.fade,
                                            //                                         softWrap: false,
                                            //                                         style: Theme.of(context).textTheme.subtitle1,
                                            //                                       ),
                                            //                                     ),
                                            //                                   ),
                                            //                                   SizedBox(
                                            //                                     width:110,
                                            //                                     height: 17,
                                            //                                     child: Text(
                                            //                                       "Helper.skipHtml(widget.restaurant.address)",
                                            //                                       overflow: TextOverflow.fade,
                                            //                                       softWrap: false,
                                            //                                       style: Theme
                                            //                                           .of(context)
                                            //                                           .textTheme
                                            //                                           .caption.merge(TextStyle(
                                            //                                           fontSize: 12
                                            //                                       )),
                                            //                                     ),
                                            //                                   ),
                                            //                                 ],
                                            //                               ),
                                            //                             ),
                                            //                             Spacer(),
                                            //                             //SizedBox(width: 8,),
                                            //                             Row(
                                            //                               children: [
                                            //                                 Text("20 km"),
                                            //                                 SizedBox(
                                            //                                   width: 5,
                                            //                                 ),
                                            //                                 Container(
                                            //                                   margin: EdgeInsets.all(0),
                                            //                                   padding: EdgeInsets.all(4),
                                            //                                   decoration: BoxDecoration(
                                            //                                       gradient: LinearGradient(
                                            //                                         colors: [
                                            //                                           kPrimaryColororange,
                                            //                                           kPrimaryColorLiteorange
                                            //                                         ],
                                            //                                       ),
                                            //                                       borderRadius: BorderRadius.circular(100)),
                                            //                                   child: Icon(
                                            //                                     Icons.arrow_right_alt,
                                            //                                     color: Colors.white,
                                            //                                     size: 10,
                                            //                                   ),
                                            //                                 ),
                                            //                               ],
                                            //                             ),
                                            //                           ],
                                            //                         ),
                                            //                         SizedBox(height: 5,),
                                            //                         Row(
                                            //                           mainAxisAlignment: MainAxisAlignment.start,
                                            //                           crossAxisAlignment: CrossAxisAlignment.start,
                                            //                           children: [
                                            //                             RatingBar.builder(
                                            //                               itemSize: 15,
                                            //                               initialRating: 3,
                                            //                               minRating: 1,
                                            //                               direction: Axis.horizontal,
                                            //                               allowHalfRating: true,
                                            //                               itemCount: 5,
                                            //                               // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                            //                               itemBuilder: (context, _) =>
                                            //                                   ShaderMask(
                                            //                                     shaderCallback: (Rect bounds) {
                                            //                                       return LinearGradient(
                                            //                                         colors: [
                                            //                                           kPrimaryColororange,
                                            //                                           kPrimaryColorLiteorange
                                            //                                         ],
                                            //                                       ).createShader(bounds);
                                            //                                     },
                                            //                                     child: Icon(
                                            //                                       Icons.star,
                                            //                                       color: Colors.white,
                                            //                                       size: 20.0,
                                            //                                     ),
                                            //                                   ),
                                            //                               onRatingUpdate: (rating) {
                                            //                                 print(rating);
                                            //                               },
                                            //                             ),
                                            //                             Spacer(),
                                            //                             Column(
                                            //                               mainAxisAlignment: MainAxisAlignment.start,
                                            //                               crossAxisAlignment: CrossAxisAlignment.center,
                                            //                               children: <Widget>[
                                            //                                 RichText(
                                            //                                   text: TextSpan(
                                            //                                       text: "AED",
                                            //                                       style: TextStyle(
                                            //                                         fontWeight: FontWeight.bold,
                                            //                                         color: Theme
                                            //                                             .of(context)
                                            //                                             .hintColor,
                                            //                                         fontSize: 5,
                                            //                                       ),
                                            //                                       children: [
                                            //                                         TextSpan(
                                            //                                           text: '15-25',
                                            //                                           style: TextStyle(
                                            //                                             fontSize: 15,
                                            //                                           ),
                                            //                                         ),
                                            //                                       ]),
                                            //                                 ),
                                            //                                 Text(
                                            //                                   "Avg.for one",
                                            //                                   style: TextStyle(
                                            //                                     fontSize: 5,
                                            //                                   ),
                                            //                                 ),
                                            //
                                            //                                 //  Text("hi",
                                            //                                 //   overflow: TextOverflow.fade,
                                            //                                 //   maxLines: 1,
                                            //                                 //   softWrap: false,
                                            //                                 // )
                                            //
                                            //                               ],
                                            //                             ),
                                            //                             // Row(
                                            //                             //   children: Helper.getStarsList(
                                            //                             //     double.parse(restaurant.rate),
                                            //                             //   ),
                                            //                             // ),
                                            //                           ],
                                            //                         ),
                                            //                       ],
                                            //
                                            //
                                            //                     ),
                                            //                   ),
                                            //                 );

                                            case 'top_restaurants_headings':
                                              return _con.isTopKitchensLoaded &&
                                                      _con.topKitchens
                                                          .isNotEmpty
                                                  ? ListTile(
                                                      dense: true,
                                                      minLeadingWidth: 2,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20),
                                                      leading: Image.asset(
                                                        "assets/img/top-home-kitchen.png",
                                                        height: 27,
                                                        width: 27,
                                                      ),
                                                      title: /*Text(
                                                  S.of(context).top_home_kitchens,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w500),
                                                )*/
                                                          TranslationWidget(
                                                        message:"Top Home Kitchen",
                                                        fromLanguage: "English",
                                                        toLanguage:
                                                            defaultLanguage,
                                                        builder: (translatedMessage) => Text(
                                                            translatedMessage,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            softWrap: false,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ),
                                                      subtitle: /*Text(
                                                  S.of(context)
                                                      .ordered_by_nearby_first,
                                                  maxLines: 2,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption,
                                                )*/
                                                          TranslationWidget(
                                                        message: S
                                                            .of(context)
                                                            .ordered_by_nearby_first,
                                                        fromLanguage: "English",
                                                        toLanguage:
                                                            defaultLanguage,
                                                        builder: (translatedMessage) =>
                                                            Text(
                                                                translatedMessage,
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                softWrap: false,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .caption),
                                                      ),
                                                    )
                                                  : SizedBox();
                                            case 'top_restaurantss':
                                              return _con.isTopKitchensLoaded
                                                  ? _con.topKitchens.isEmpty
                                                      ? Center(
                                                          child:
                                                              /*Text("No Data available")*/
                                                              TranslationWidget(
                                                          message: "",
                                                          fromLanguage:
                                                              "English",
                                                          toLanguage:
                                                              defaultLanguage,
                                                          builder:
                                                              (translatedMessage) =>
                                                                  Text(
                                                            translatedMessage,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            softWrap: false,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .subtitle1,
                                                          ),
                                                        ))
                                                      : CardsCarouselWidget(
                                                          delivery: false,
                                                          restaurantsList:
                                                              _con.topKitchens,
                                                          heroTag:
                                                              'home_top_restaurants',
                                                          parentScaffoldKey: widget
                                                              .parentScaffoldKey,
                                                        )
                                                  : Center(
                                                      child:
                                                          /*Text("No Data available")*/
                                                          TranslationWidget(
                                                      message: "",
                                                      fromLanguage: "English",
                                                      toLanguage:
                                                          defaultLanguage,
                                                      builder:
                                                          (translatedMessage) =>
                                                              Text(
                                                        translatedMessage,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        softWrap: false,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle1,
                                                      ),
                                                    ));

                                            case 'trending_week_heading':
                                              return _con.trendingFoodItems
                                                          .isNotEmpty &&
                                                      _con.isTrendingFoodLoaded
                                                  ? ListTile(
                                                      dense: true,
                                                      minLeadingWidth: 2,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20),
                                                      leading: Icon(
                                                        Icons.trending_up,
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                      ),
                                                      title: /*Text(
                                                  S.of(context).trending_this_week,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w500),
                                                )*/
                                                          TranslationWidget(
                                                        message: S
                                                            .of(context)
                                                            .trending_this_week,
                                                        fromLanguage: "English",
                                                        toLanguage:
                                                            defaultLanguage,
                                                        builder:
                                                            (translatedMessage) =>
                                                                Text(
                                                          translatedMessage,
                                                          overflow:
                                                              TextOverflow.fade,
                                                          softWrap: false,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                      subtitle: /*Text(
                                                  S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
                                                  maxLines: 2,
                                                  style: Theme.of(context).textTheme.caption,
                                                )*/
                                                          TranslationWidget(
                                                        message: S
                                                            .of(context)
                                                            .clickOnTheFoodToGetMoreDetailsAboutIt,
                                                        fromLanguage: "English",
                                                        toLanguage:
                                                            defaultLanguage,
                                                        builder:
                                                            (translatedMessage) =>
                                                                Text(
                                                          translatedMessage,
                                                          overflow:
                                                              TextOverflow.fade,
                                                          softWrap: false,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption,
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox();
                                            case 'trending_week':
                                              //print("DS>> "+_con.trendingFoods[0].name.toString());
                                              return _con.isTrendingFoodLoaded
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 0.0),
                                                      child: StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                          if (_con
                                                              .trendingFoodItems
                                                              .isEmpty) {
                                                            // Show a loading indicator or placeholder while data is being fetched
                                                            return Center(
                                                                child:
                                                                    /*Text("No Data available")*/
                                                                    TranslationWidget(
                                                              message: "",
                                                              fromLanguage:
                                                                  "English",
                                                              toLanguage:
                                                                  defaultLanguage,
                                                              builder:
                                                                  (translatedMessage) =>
                                                                      Text(
                                                                translatedMessage,
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                softWrap: false,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .subtitle1,
                                                              ),
                                                            ));
                                                          } else {
                                                            return FoodsCarouselWidget(
                                                              delivery: false,
                                                              foodsList: _con
                                                                  .trendingFoodItems,
                                                              heroTag:
                                                                  'home_food_carousel',
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    )
                                                  : Center(
                                                      child:
                                                          /*Text("No Data available")*/
                                                          TranslationWidget(
                                                      message: "",
                                                      fromLanguage: "English",
                                                      toLanguage:
                                                          defaultLanguage,
                                                      builder:
                                                          (translatedMessage) =>
                                                              Text(
                                                        translatedMessage,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        softWrap: false,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle1,
                                                      ),
                                                    ));
                                            case 'popular_heading':
                                              return _con.popularKitchens
                                                          .isNotEmpty &&
                                                      _con.isPopularKitchenLoaded
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 20,
                                                              bottom: 0,
                                                              top: 10),
                                                      child: ListTile(
                                                        dense: true,
                                                        minLeadingWidth: 2,
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        0),
                                                        leading: Icon(
                                                          Icons.trending_up,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor,
                                                        ),
                                                        trailing: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          KitchenListDineinWidget(
                                                                            restaurantsList:
                                                                                _con.AllRestaurantsDelivery,
                                                                            heroTag:
                                                                                "KitchenListDelivery",
                                                                          )),
                                                            );
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                                "View all"),
                                                          ),
                                                        ),
                                                        title: /*Text(
                                                      S.of(context).most_popular,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500))*/
                                                            TranslationWidget(
                                                          message: S
                                                              .of(context)
                                                              .most_popular,
                                                          fromLanguage:
                                                              "English",
                                                          toLanguage:
                                                              defaultLanguage,
                                                          builder:
                                                              (translatedMessage) =>
                                                                  Text(
                                                            translatedMessage,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            softWrap: false,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox();
                                            case 'popular':
                                              return _con.isPopularKitchenLoaded
                                                  ? _con.popularKitchens.isEmpty
                                                      ? Center(
                                                          child:
                                                              /*Text("No Data available")*/
                                                              TranslationWidget(
                                                          message: "",
                                                          fromLanguage:
                                                              "English",
                                                          toLanguage:
                                                              defaultLanguage,
                                                          builder:
                                                              (translatedMessage) =>
                                                                  Text(
                                                            translatedMessage,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            softWrap: false,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .subtitle1,
                                                          ),
                                                        ))
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      12.0),
                                                          child: GridWidget(
                                                            delivery: false,
                                                            restaurantsList: _con
                                                                .popularKitchens,
                                                            heroTag:
                                                                'home_restaurants',
                                                          ),
                                                        )
                                                  : Center(
                                                      child:
                                                          /*Text("No Data available")*/
                                                          TranslationWidget(
                                                      message: "",
                                                      fromLanguage: "English",
                                                      toLanguage:
                                                          defaultLanguage,
                                                      builder:
                                                          (translatedMessage) =>
                                                              Text(
                                                        translatedMessage,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        softWrap: false,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle1,
                                                      ),
                                                    ));
                                            case 'recent_reviews_heading':
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: ListTile(
                                                  dense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 20),
                                                  leading: Icon(
                                                    Icons.recent_actors,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                                  title: Text(
                                                    S
                                                        .of(context)
                                                        .recent_reviews,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4,
                                                  ),
                                                ),
                                              );
                                            case 'recent_reviews':
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: ReviewsListWidget(
                                                    reviewsList:
                                                        _con.recentReviews),
                                              );
                                            default:
                                              return SizedBox(height: 0);
                                          }
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                    Visibility(
                      visible: true,
                      child: Consumer<CartProvider>(
                        builder: (context, cartProvider, _) {
                       //   print(cartProvider.cartItems.first.food.restaurant.name);
                          // Use the cartProvider here to access cart items or listen for changes
                          if (cartProvider.cartItems.isNotEmpty) {
                            return Container(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 55,
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.only(left: 10, bottom: 5),
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),

                                      child: Image.network(
                                        cartProvider.cartItems.first.food
                                            .restaurant.image.url,
                                        height: 30,
                                        width: 30,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                            "${cartProvider.cartItems.first.food.restaurant.name}"),
                                        Text("${cartProvider.cartCount} Items"),
                                      ],
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CartWidget(
                                                    parentScaffoldKey:
                                                        widget.parentScaffoldKey,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: Colors.redAccent,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      text: "₹",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: (cartProvider
                                                                  .subTotal)
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                                Text(
                                                  "View Cart",
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              cartProvider
                                                  .removeAllItemsFromCart();
                                            },
                                            icon: Icon(Icons.close),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                    Visibility(
                      visible: true,
                      child: Consumer<OrderProvider>(
                        builder: (context, orderProvider, _) {
                          // Check if there is an ongoing order
                          if (orderProvider.orders.isNotEmpty) {
                            // Get the latest order status
                            final latestOrderStatus = orderProvider.orders.first;
                            String status  =  orderProvider.getStatusNameById(latestOrderStatus["order_status_id"].toString());
                            return Container(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 55,
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.only(left: 10, bottom: 5),
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(237, 236, 237, 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    // Display an icon or image indicating order status
                                //    Icon(Icons.shopping_bag, color: Colors.blue),
                                    SizedBox(width: 10),
                                    Text("Your order #${latestOrderStatus["id"]} is $status"),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Add button or action to view order details
                                          IconButton(
                                            onPressed: ()async {
                                              if(latestOrderStatus["delivery_dinein"] == 1)
                                                await settingRepo.navigatorKey.currentState.pushNamed('/Tracking',
                                                  arguments: RouteArgument(
                                                      id:latestOrderStatus["id"].toString(),
                                                      heroTag:
                                                      "1"));
                                              else if(latestOrderStatus["delivery_dinein"] == 2){
                                              await settingRepo.navigatorKey.currentState.pushNamed('/TrackingForDinein',
                                              arguments: RouteArgument(
                                              id: latestOrderStatus["id"].toString(),
                                              // latitude:widget.order.res_latitude,
                                              //longitude:widget.order.res_longitude,
                                              heroTag:
                                              "2"));
                                              }
                                              // Implement action to close the popup
                                            },
                                            icon: Icon(Icons.visibility,size: 20, color: Colors.redAccent,),
                                          ),
                                          // Add button or action to close the popup
                                          IconButton(
                                            onPressed: () {
                                              orderProvider.closeorder();
                                              // Implement action to close the popup
                                            },
                                            icon: Icon(Icons.close,size: 20,),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            // If there are no ongoing orders, return an empty container
                            return Container();
                          }
                        },
                      ),
                    ),

                    /* ListTile(

        leading: Icon(Icons.timer, color: Colors.green),
        title: Row(
          children: [
            Text('35 mins • 2.5 km', style: TextStyle(color: Colors.grey)),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('₹400', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('30% OFF up to ₹75'),
            Row(
              children: [
                Image.network(
                  'URL_of_the_food_image', // Replace with the actual image URL
                  width: 50,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Food Bazaar'),
                    Text('2 items', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      )*/
                  ],
                ),
                bottomNavigationBar: widget.directedFrom == "forHome"
                    ? BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: Colors.grey,
                        selectedFontSize: 0,
                        unselectedFontSize: 0,
                        iconSize: 28,
                        elevation: 0,
                        unselectedItemColor: Colors.grey,
                        backgroundColor: Colors.grey[100],
                        //selectedIconTheme: IconThemeData(size: 28),
                        unselectedLabelStyle: TextStyle(color: Colors.grey),
                        //   unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
                        currentIndex: 1,
                        onTap: (int i) {
                          this._selectTab(i);
                        },
                        // this will be set when a new tab is tapped
                        items: [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.assignment),
                            label: 'Orders',
                          ),
                          /* BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/img/dinein.svg',color: Colors.grey,height: 17,),
              label: '',
            ),*/
                          BottomNavigationBarItem(
                              label: '',
                              icon: new SvgPicture.asset(
                                'assets/img/home.svg',
                                height: 80,
                              )),
                          /* BottomNavigationBarItem(
              icon: new SvgPicture.asset('assets/img/delivery.svg',color: Colors.grey,height: 17,),
              label: '',
            ),*/
                          BottomNavigationBarItem(
                            icon: Icon(Icons.shopping_bag_outlined),
                            label: 'Carts',
                          ),
                        ],
                      )
                    : SizedBox(),
              ),
            ),
          )
        : widget.currentPage;
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit an App?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: Text(
                  'No',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              InkWell(
                onTap: () {
                  SystemNavigator.pop();
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
                        Text("Yes",
                            style: Theme.of(context).textTheme.bodyText1.merge(
                                TextStyle(
                                    color: Theme.of(context).primaryColor)))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }

  List checkListItems = [
    {
      "id": 0,
      "value": false,
      "title": "Sunday",
    },
    {
      "id": 1,
      "value": false,
      "title": "Monday",
    },
    {
      "id": 2,
      "value": false,
      "title": "Tuesday",
    },
    {
      "id": 3,
      "value": false,
      "title": "Wednesday",
    },
    {
      "id": 4,
      "value": false,
      "title": "Thursday",
    },
    {
      "id": 5,
      "value": false,
      "title": "Friday",
    },
    {
      "id": 6,
      "value": false,
      "title": "Saturday",
    },
  ];

  List<int> selectedCuisines = [];
  List<String> selectedLocation = [];

  void toggleCuisine(int cuisineId) {
    if (selectedCuisines.contains(cuisineId)) {
      setState(() {
        selectedCuisines.remove(cuisineId);
      });
    } else {
      setState(() {
        selectedCuisines.add(cuisineId);
      });
    }
  }

  void toggleLocation(String location) {
    if (selectedLocation.contains(location)) {
      setState(() {
        selectedLocation.remove(location);
      });
    } else {
      setState(() {
        selectedLocation.add(location);
      });
    }
  }

  _openDialog(BuildContext context, List<Cuisine> cuisineList,
      String fromDineInorDelivery) {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        TextEditingController searchController = TextEditingController();
        return StatefulBuilder(builder: (context, setState) {
          List<Cuisine> filteredCuisineList;
          if (searchController.text.isNotEmpty) {
            filteredCuisineList = cuisineList
                .where((cuisine) => cuisine.name.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    ))
                .toList();
          } else {
            filteredCuisineList = cuisineList;
          }
          //    print(filteredCuisineList.length);
          //  print(searchController.text);
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
                              .toggleCuisine(
                                  filteredCuisineList[index].id.toString());
                          setState(() {
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
                  filterWithCuisine(fromDineInorDelivery, selectedCuisines);

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
                          builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .merge(TextStyle(
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
        });
      },
    );
  }

  filterWithCuisine(
      String fromDineInorDelivery, List<String> selectedCuisines) {
    //  print("tap");
    for (int i = 0; i < selectedCuisines.length; i++) {
      // print("" + selectedCuisines[i].toString());
    }
    List<String> selectedLocations =
        Provider.of<LocationProvider>(context, listen: false).selectedLocations;

    // Construct the query parameter string for selected cuisines
    String cuisinesQueryParam =
        selectedCuisines.map((cuisineId) => 'cuisines[]=$cuisineId').join('&');
    //  print("cuisineParam " + cuisinesQueryParam);
    String locationQueryParam;
    if (selectedLocations.length > 0) {
      locationQueryParam = selectedLocations
          .map((locationValues) => 'location[]=$locationValues')
          .join('&');
    }
    if (selectedCuisines.length > 0 && selectedLocation.length > 0) {
      cuisinesQueryParam = cuisinesQueryParam + "&" + locationQueryParam;
    } else if (selectedCuisines.length == 0 && selectedLocation.length > 0) {
      cuisinesQueryParam = locationQueryParam;
    }

    _con.fetchKitchensWithCuisine(cuisinesQueryParam, fromDineInorDelivery);
    _con.listenForCategories();
    //_con.refreshHome();
    // _con.refreshSubHome();
    //  print("length kitchen" + _con.topKitchens.length.toString());
  }

  filterWithLocation(
      String fromDineInorDelivery, List<String> selectedLocations) {
    // print(selectedLocations.length);
    for (int i = 0; i < selectedLocations.length; i++) {
      //   print("" + selectedLocations[i].toString());
    }
    List<String> selectedCusions =
        Provider.of<CuisineProvider>(context, listen: false).selectedCuisines;
    String cuisinesQueryParam;
    if (selectedCusions.length > 0) {
      cuisinesQueryParam =
          selectedCusions.map((cuisineId) => 'cuisines[]=$cuisineId').join('&');
    }
    //   print(cuisinesQueryParam);
    // Construct the query parameter string for selected locations
    String locationQueryParam = selectedLocations
        .map((locationValues) => 'location[]=$locationValues')
        .join('&');
    //  print("locationParam " + locationQueryParam);

    if (selectedCusions.length > 0 && selectedLocations.length > 0) {
      locationQueryParam = cuisinesQueryParam + "&" + locationQueryParam;
    } else if (selectedCusions.length > 0 && selectedLocations.length == 0) {
      locationQueryParam = cuisinesQueryParam;
    }
    //   print("locationParam " + locationQueryParam);
    _con.fetchKitchensWithLocation(locationQueryParam, fromDineInorDelivery);
    _con.listenForCategories();

    // _con.refreshHome();
  }

  _openDialogForLocation(BuildContext context, List<LocationModel> locationList,
      String fromDineInorDelivery) {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        TextEditingController searchController = TextEditingController();
        return StatefulBuilder(builder: (context, setState) {
          List<LocationModel> filteredLocationList;
          if (searchController.text.isNotEmpty) {
            filteredLocationList = locationList
                .where((cuisine) => cuisine.address.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    ))
                .toList();
          } else {
            filteredLocationList = locationList;
          }
          //print(filteredLocationList.length);

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
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10),
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
                          filteredLocationList[index].selected =
                              value; // Update the state of the selected cuisine
                          toggleLocation(
                              filteredLocationList[index].address.toString());
                          Provider.of<LocationProvider>(context, listen: false)
                              .toggleLocation(filteredLocationList[index]
                                  .address
                                  .toString());
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
                      Provider.of<LocationProvider>(context, listen: false)
                          .selectedLocations;
                  filterWithLocation(fromDineInorDelivery, selectedLocations);
                  Navigator.of(context).pop(); // Close the dialog
                  /*  List<String> selectedCuisines =
                        Provider.of<CuisineProvider>(context, listen: false)
                            .selectedCuisines;
                    filterWithCuisine(fromDineInorDelivery, selectedCuisines);
                    Provider.of<CuisineProvider>(context, listen: false)
                        .clearSelectedCuisines();
                    Navigator.of(context).pop();*/
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
                          builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .merge(TextStyle(
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
        });
      },
    );
  }

  Future<String> _getAddressFromLocation(LatLng location) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        return '${placemarks.first.street} ${placemarks.first.thoroughfare} ,   ${placemarks.first.subLocality} ${placemarks.first.locality}  - ${placemarks.first.postalCode}, ${placemarks.first.administrativeArea}';
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error getting address';
    }
  }

  Future<LatLng> _openAddressSelectionMap() async {
    LatLng resultLocation;
    String resultAddress;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapScreen(
          initialLocation: SelectedLocation,
          onLocationSelected: (location, address) {
            resultLocation = location;
            resultAddress = address;
          },
        );
      },
    );

    return resultLocation;
  }
}

class ShimmerCategoryItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {}, // Placeholder onTap function
      child: Container(
        height: 200,
        margin: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width * 0.20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng, String) onLocationSelected;

  MapScreen({this.onLocationSelected, this.initialLocation});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  LatLng selectedLocation;
  LatLng selectedLocationrecheck;
  Marker selectedMarker;
  String address;
  bool isLoading = true;
  String seletedlocationmarker;
  String selectedlocationcity;

  @override
  void initState() {
    super.initState();
    //  selectedLocation = LatLng(0.0, 0.0);

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    geolocator.Position position;

    try {
      position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );
    } catch (e) {
      print("Error getting current location: $e");
    }

    if (position != null && selectedLocation== null) {
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_outlined,
              color: Colors.black,
            )),
        title: Text(
          "Confirm delivery location",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
        width: MediaQuery.of(context).size.width * .9,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [kPrimaryColororange, kPrimaryColorLiteorange],
            ),
          ),
          child: MaterialButton(
            onPressed: () {
              //   _showAddressDialog();
              print(selectedLocationrecheck);
              print(address);
              widget.onLocationSelected(selectedLocationrecheck, "selectedAddress");
              Navigator.pop(context);
            },
            child: Text(
              'Select the Address',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: FutureBuilder(
              future: _getCurrentLocation(),
              builder: (context, snapshot) {
                if (isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepOrangeAccent,
                    ),
                  );
                } else {
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.initialLocation ?? selectedLocation,
                      zoom: 15.0,
                    ),
                    onMapCreated: (controller) {
                      setState(() {
                        mapController = controller;
                      });
                    },
                    myLocationEnabled: true,
                    onTap: (latLng) {
                      _updateSelectedLocation(latLng);
                    },
                    markers: Set<Marker>.from(
                        selectedMarker != null ? [selectedMarker] : []),
                  );
                }
              },
            ),
          ),
          if (address != null)
            ListTile(
              leading: Icon(
                Icons.location_on_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
              title: Text(seletedlocationmarker ?? ""),
              subtitle: Text(selectedlocationcity ?? ""),
            )
        ],
      ),
    );
  }

  void _updateSelectedLocation(LatLng latLng) {
    final Marker marker = Marker(
      markerId: MarkerId('selected-location'),
      position: latLng,
      infoWindow: InfoWindow(title: 'Selected Location'),
    );

    mapController?.animateCamera(CameraUpdate.newLatLng(latLng));

    setState(() {
      selectedLocation = latLng;
      selectedMarker = marker;

      print(selectedLocation.latitude);
      _showAddressDialog();
    });
  }

  Future<void> _showAddressDialog() async {
    if (selectedLocation == null) {
      return;
    }

    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        selectedLocation.latitude,
        selectedLocation.longitude,
      );

      if (placemarks.isNotEmpty) {
        String selectedAddress =
            '${placemarks.first.name} ${placemarks.first.subLocality} , ${placemarks.first.locality}, ${placemarks.first.administrativeArea}';

        //  widget.onLocationSelected(selectedLocation, selectedAddress);
        print(placemarks.first);
        print(selectedAddress);
        setState(() {
          selectedLocationrecheck = selectedLocation;
          seletedlocationmarker =
              '${placemarks.first.street} ${placemarks.first.thoroughfare} ';
          selectedlocationcity =
              ' ${placemarks.first.subLocality} \n ${placemarks.first.locality} - ${placemarks.first.postalCode}, ${placemarks.first.administrativeArea}';
          address = selectedAddress;

        });
        // Navigator.of(context).pop();
      } else {
        setState(() {
          address = 'No address found';
        });
      }
    } catch (e) {
      setState(() {
        address = 'Error getting address';
      });
    }
  }
}

class CustomCarouselSlider extends StatefulWidget {
  final List<Widget> items;

  const CustomCarouselSlider({Key key, this.items}) : super(key: key);

  @override
  _CustomCarouselSliderState createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Adjust the height as needed
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          return widget.items[index];
        },
      ),
    );
  }
}
