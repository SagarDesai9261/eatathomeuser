import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FoodsCarouselWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../models/route_argument.dart';
import '../pages/KitchenListDelivery.dart';
import '../pages/KitchenListDinein.dart';
import '../pages/cart.dart';
import '../pages/home.dart';
import '../pages/restaurant.dart';
import '../provider.dart';
import '../repository/translation_widget.dart';
import '../repository/user_repository.dart';
import 'home_controller.dart';
import 'homecontroller_provider.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../repository/settings_repository.dart' as settingRepo;
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart' as geolocator;

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final int currentTab;
  Widget currentPage;
  String directedFrom;
  bool showProress = true;
  GlobalKey<ScaffoldState> scaffoldKey;

  dynamic currentSelectedTab;
  HomePage(
      {Key key, this.parentScaffoldKey, this.currentTab, this.directedFrom});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // dataAssign(){
  //   Provider.of<CartProvider>(context,listen: false).loadCartItems();
  //     Provider.of<QuantityProvider>(context, listen: false)
  //         .setQuantitiesFromCart(Provider.of<CartProvider>(context,listen: false).cartItems.first.food.restaurant.id, Provider.of<CartProvider>(context,listen: false).cartItems);
  // }
  Position currentposition;
  bool isEnjoyNowSelected = true;
  bool isPositionDetermined = false;
  String catId;
  int selectedCategoryDeliveryindex = -1;

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
    // final homeController = Provider.of<HomeController>(context, listen: false);
    // // Call methods from HomeController to fetch data
    // homeController.listenForCategories();
    // homeController.listenForCuisine();
    // homeController.listenForLocation();
    // homeController.listenForSlides();
    // homeController.listenForRecentReviews();
    widget.scaffoldKey = new GlobalKey<ScaffoldState>();

    _determinePosition();
  }

  LatLng SelectedLocation;
  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeProvider>(context);

    // Example UI to display fetched data
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                toLanguage: "en",
                builder: (translatedMessage) => Text(translatedMessage,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                        color:
                            settingRepo.deliveryAddress.value?.address == null
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
                toLanguage: "en",
                builder: (translatedMessage) => Text(translatedMessage,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                        color:
                            settingRepo.deliveryAddress.value?.address == null
                                ? Theme.of(context).hintColor
                                : Theme.of(context).primaryColor,
                        fontSize: 20)),
              ),
            ],
          ),
          leading: Builder(builder: (context) {
            return new IconButton(
                icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
                onPressed: () => {
                      print("DS>>> clicked" +
                          " " +
                          widget.directedFrom +
                          " " +
                          widget.parentScaffoldKey.currentState.toString()),
                      widget.directedFrom == "forHome"
                          ? Scaffold.of(context).openDrawer()
                          : widget.parentScaffoldKey.currentState.openDrawer(),
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
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          );
                        },
                      ),
                      Provider.of<Add_the_address>(context).address1 != ""
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
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.95,
                                            // Adjust height as needed
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      SizedBox(width: 10),
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
                                                      SizedBox(width: 10),
                                                      Text(
                                                        "Select a Location",
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      )
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: TextFormField(
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.grey[
                                                            200], // Fill color
                                                        hintText:
                                                            "Search for area, Street name",
                                                        prefixIcon: Icon(
                                                            Icons.search,
                                                            color: Colors
                                                                .redAccent),
                                                        border:
                                                            OutlineInputBorder(
                                                          // Border
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          borderSide: BorderSide
                                                              .none, // No border
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                                vertical: 14.0,
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
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Card(
                                                      color: Colors.grey[200],
                                                      elevation:
                                                          0, // Set the elevation for the card
                                                      margin: EdgeInsets.all(
                                                          15), // Set margin for the card
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              print(Provider.of<
                                                                          Add_the_address>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .currentlocation);
                                                              print(Provider.of<
                                                                          Add_the_address>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .currentlocationLatlong);
                                                              context.read<Add_the_address>().set_selected_location(
                                                                  Provider.of<Add_the_address>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .currentlocation,
                                                                  Provider.of<Add_the_address>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .currentlocationLatlong);
                                                              context
                                                                  .read<
                                                                      Add_the_address>()
                                                                  .address_split();
                                                              setState(() {});
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Container(
                                                              // color:Colors.redAccent,
                                                              height: 70,
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16.0,
                                                                  vertical: 8),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .my_location_outlined,
                                                                    color: Colors
                                                                        .redAccent,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Use Current Location',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .7,
                                                                        child:
                                                                            Text(
                                                                          Provider.of<Add_the_address>(context)
                                                                              .currentlocation,
                                                                          maxLines:
                                                                              2,
                                                                          softWrap:
                                                                              true,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                            child: Container(
                                                              height: 1,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                          //  Divider(), // Add a divider between list tiles
                                                          GestureDetector(
                                                            onTap: () async {
                                                              LatLng
                                                                  resultLocation =
                                                                  await _openAddressSelectionMap();
                                                              if (resultLocation !=
                                                                  null) {
                                                                String
                                                                    selectedAddress =
                                                                    await _getAddressFromLocation(
                                                                        resultLocation);
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
                                                                print(Provider.of<
                                                                            Add_the_address>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .address
                                                                    .length);
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 50,
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16.0,
                                                                  vertical: 8),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Icon(
                                                                      Icons.add,
                                                                      color: Colors
                                                                          .redAccent),
                                                                  SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Text(
                                                                    'Add Address',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
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
                                                            FontWeight.bold,
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
                                                      children: Provider.of<
                                                                  Add_the_address>(
                                                              context)
                                                          .address
                                                          .map((addr) {
                                                        return Card(
                                                          color:
                                                              Colors.grey[200],
                                                          elevation: 0,
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      15),
                                                          child: ListTile(
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
                                                                    LatLng(
                                                                        addr["latlong"]
                                                                            [0],
                                                                        addr["latlong"]
                                                                            [
                                                                            1]));
                                                                context
                                                                    .read<
                                                                        Add_the_address>()
                                                                    .address_split();
                                                                homeController
                                                                    .refreshHome();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              } else {
                                                                context
                                                                    .read<
                                                                        Add_the_address>()
                                                                    .set_selected_location(
                                                                        addr[
                                                                            "address"],
                                                                        addr[
                                                                            "latlong"]);
                                                                context
                                                                    .read<
                                                                        Add_the_address>()
                                                                    .address_split();
                                                                homeController
                                                                    .refreshHome();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            },
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            16,
                                                                        vertical:
                                                                            8),
                                                            leading: Icon(
                                                              Icons
                                                                  .location_on_rounded,
                                                              color: Colors
                                                                  .redAccent,
                                                              size: 40,
                                                            ),
                                                            title: Text(
                                                              addr["address"],
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            trailing:
                                                                IconButton(
                                                              icon: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red),
                                                              onPressed: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      content: Text(
                                                                          "Are you sure you want to delete this address?"),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop(); // Close the dialog
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            "Cancel",
                                                                            style:
                                                                                TextStyle(color: Colors.redAccent),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            gradient:
                                                                                LinearGradient(
                                                                              colors: [
                                                                                kPrimaryColororange,
                                                                                kPrimaryColorLiteorange
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              MaterialButton(
                                                                            onPressed:
                                                                                () {
                                                                              //   _showAddressDialog();
                                                                              Provider.of<Add_the_address>(context, listen: false).remove_address(addr);
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                Text(
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
                              child: Icon(Icons.keyboard_arrow_down_sharp,
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
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        drawer: DrawerWidget(),
        body: Stack(
          children: [
            TabBarView(
              children: [
                RefreshIndicator(
                  color: Colors.deepOrange,
                  onRefresh: () async {
                    await homeController.refreshHome();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, top: 0, bottom: 0, right: 18),
                          child: SearchBarWidget(
                              onClickFilter: (event) {
                                widget.parentScaffoldKey.currentState
                                    .openEndDrawer();
                              },
                              parentScaffoldKey: widget.parentScaffoldKey,
                              isDinein: false),
                        ),
                        // Display categories
                        // Display trending foods carousel widget
                        Container(
                          height: 40,
                          margin: EdgeInsets.only(
                              bottom: 10, top: 10, left: 15, right: 15),
                          // padding: const EdgeInsets.all(8.0),
                          child: /* Row(
                            children: [
                              Expanded(child: Container(

                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      kPrimaryColororange,
                                      kPrimaryColorLiteorange
                                    ],
                                  ),
                                ),
                                child: MaterialButton(
                                  onPressed: (){},

                                  child: Text("Enjoy Now",style: TextStyle(color:Colors.white),),
                                ),
                              )),



                              SizedBox(width: 10,),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: LinearGradient(
                                      colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                                    ),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.all(2), // Adjust the margin to control the thickness of the border
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Background color
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: MaterialButton(
                                      onPressed: () {},
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                                          ).createShader(bounds);
                                        },
                                        child: Text(
                                          "Enjoy Later",
                                          style: TextStyle(
                                            color: Colors.white, // This color is applied only if the gradient fails
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )*/ //,
                              Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        isEnjoyNowSelected = true;
                                      });
                                      await homeController
                                          .refreshSubHomeforenjoynow();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: isEnjoyNowSelected != false
                                            ? null
                                            : Border.all(
                                                color: Colors.deepOrange,
                                                width: 1),
                                        gradient: isEnjoyNowSelected
                                            ? LinearGradient(
                                                colors: [
                                                  kPrimaryColororange,
                                                  kPrimaryColorLiteorange
                                                ],
                                              )
                                            : null,
                                        //   color: isEnjoyNowSelected ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          bottomLeft: Radius.circular(4),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: isEnjoyNowSelected
                                          ? Text(
                                              "Enjoy Now",
                                              style: TextStyle(
                                                color: !isEnjoyNowSelected
                                                    ? Colors.transparent
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : ShaderMask(
                                              shaderCallback: (bounds) {
                                                return LinearGradient(
                                                  colors: [
                                                    kPrimaryColororange,
                                                    kPrimaryColorLiteorange
                                                  ],
                                                ).createShader(bounds);
                                              },
                                              child: Text(
                                                "Enjoy Now",
                                                style: TextStyle(
                                                  color: isEnjoyNowSelected
                                                      ? Colors.transparent
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        isEnjoyNowSelected = false;
                                      });
                                      await homeController
                                          .refreshSubHomeforenjoylater();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: isEnjoyNowSelected == false
                                            ? null
                                            : Border.all(
                                                color: Colors.deepOrange,
                                                width: 1),
                                        gradient: isEnjoyNowSelected == false
                                            ? LinearGradient(
                                                colors: [
                                                  kPrimaryColororange,
                                                  kPrimaryColorLiteorange
                                                ],
                                              )
                                            : null,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(4),
                                          bottomRight: Radius.circular(4),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: !isEnjoyNowSelected
                                          ? Text(
                                              "Enjoy Later",
                                              style: TextStyle(
                                                color: isEnjoyNowSelected
                                                    ? Colors.transparent
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : ShaderMask(
                                              shaderCallback: (bounds) {
                                                return LinearGradient(
                                                  colors: [
                                                    kPrimaryColororange,
                                                    kPrimaryColorLiteorange
                                                  ],
                                                ).createShader(bounds);
                                              },
                                              child: Text(
                                                "Enjoy Later",
                                                style: TextStyle(
                                                  color: !isEnjoyNowSelected
                                                      ? Colors.transparent
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(bottom: 10, top: 10, left: 10),
                          child: Consumer<OffersProvider>(
                            builder: (context, offersProvider, _) {
                              if (offersProvider.offers.isEmpty) {
                                // If offers list is empty, fetch offers
                                offersProvider.fetchOffers();
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300],
                                  highlightColor: Colors.grey[100],
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Container(
                                      height: 100,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
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
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var offer = offersProvider.offers[index];
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                        ),
                        FoodsCarouselWidget(
                          delivery: true,
                          foodsList: homeController.trendingFoodItemsDelivery,
                          heroTag: 'home_food_carousel',
                          enjoy: isEnjoyNowSelected == false ? 2 : 1,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 5, top: 5),
                          child: ListTile(
                            dense: true,
                            minLeadingWidth: 2,
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            leading: Icon(
                              Icons.trending_up,
                              color: Theme.of(context).hintColor,
                            ),
                            title: /*Text(
                                                            S.of(context).most_popular,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight.w500))*/
                                TranslationWidget(
                              message: S.of(context).most_popular,
                              fromLanguage: "English",
                              toLanguage: "en",
                              builder: (translatedMessage) => Text(
                                translatedMessage,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          KitchenListDeliveryWidget(
                                            restaurantsList: homeController
                                                .allRestaurantsDelivery,
                                            heroTag: "KitchenListDelivery",
                                            enjoy_now:
                                                isEnjoyNowSelected == false
                                                    ? 2
                                                    : 1,
                                          )),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("View all"),
                              ),
                            ),
                          ),
                        ),
                        // Display popular kitchens grid widget
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: GridWidget(
                            delivery: true,
                            restaurantsList:
                                homeController.popularKitchensDelivery,
                            heroTag: 'home_restaurants',
                            enjoy: isEnjoyNowSelected == false ? 2 : 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                RefreshIndicator(
                  color: Colors.deepOrange,
                  onRefresh: () async {
                    await homeController.refreshHome();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 0, bottom: 0, right: 18),
                          child: SearchBarWidget(
                              onClickFilter: (event) {
                                widget.parentScaffoldKey.currentState
                                    .openEndDrawer();
                              },
                              parentScaffoldKey: widget.parentScaffoldKey,
                              isDinein: true),
                        ),
                        homeController.categories.isEmpty
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300],
                                highlightColor: Colors.grey[100],
                                child: Container(
                                  height: 125,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 8),
                                  child: ListView.builder(
                                    itemCount:
                                        5, // Set a placeholder item count
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 8),
                                child: ListView.builder(
                                  itemCount: homeController.categories.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    double _marginLeft = 0;
                                    (index == 0)
                                        ? _marginLeft = 20
                                        : _marginLeft = 0;
                                    return InkWell(
                                      splashColor: Theme.of(context)
                                          .accentColor
                                          .withOpacity(0.08),
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        // SharedPreferences pref = await SharedPreferences.getInstance();
                                        // pref.setString('food_list', widget.category.id);
                                        setState(() {
                                          selectedCategoryDeliveryindex = index;
                                        });
                                        catId =
                                            homeController.categories[index].id;
                                        //   print(widget.category.id);
                                        homeController
                                            .refreshDatawithCategaroies(catId);
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

//                                        setState(() {});

                                        // Navigator.of(context)
                                        //     .pushNamed('/Category', arguments: RouteArgument(id: _con.categories[index].id));
                                      },
                                      child: Container(
                                        height: 200,
                                        child: Column(
                                          children: [
                                            Column(
                                              // crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Hero(
                                                  tag: homeController
                                                      .categories[index].id,
                                                  child: Container(
                                                    margin: EdgeInsets.all(5),
                                                    // margin:
                                                    //     EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.21,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        border:
                                                            selectedCategoryDeliveryindex ==
                                                                    index
                                                                ? Border.all(
                                                                    color:
                                                                        kPrimaryColororange, // Set the border color
                                                                    width:
                                                                        1.0, // Set the border width
                                                                  )
                                                                : null,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  kPrimaryColororange,
                                                              // color: Theme.of(context).focusColor.withOpacity(0.2),
                                                              offset: Offset(
                                                                2,
                                                                2,
                                                              ),
                                                              spreadRadius: -8,
                                                              blurRadius: 10.0)
                                                        ]),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      child: homeController
                                                              .categories[index]
                                                              .image
                                                              .url
                                                              .toLowerCase()
                                                              .endsWith('.svg')
                                                          ? ShaderMask(
                                                              shaderCallback:
                                                                  (Rect
                                                                      bounds) {
                                                                return LinearGradient(
                                                                  colors: [
                                                                    kPrimaryColororange,
                                                                    kPrimaryColorLiteorange
                                                                  ],
                                                                  stops: [
                                                                    0.3,
                                                                    1.0
                                                                  ], // Replace with your desired gradient colors
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                ).createShader(
                                                                    bounds);
                                                              },
                                                              blendMode:
                                                                  BlendMode
                                                                      .srcATop,
                                                              child:
                                                                  ColorFiltered(
                                                                colorFilter: ColorFilter.mode(
                                                                    kPrimaryColorLiteorange,
                                                                    BlendMode
                                                                        .srcIn),
                                                                child: SvgPicture
                                                                    .network(
                                                                  homeController
                                                                      .categories[
                                                                          index]
                                                                      .image
                                                                      .url,
                                                                  //color: kPrimaryColorLiteorange,
                                                                ),
                                                              ),
                                                            )
                                                          : ShaderMask(
                                                              shaderCallback:
                                                                  (Rect
                                                                      bounds) {
                                                                return LinearGradient(
                                                                  colors: [
                                                                    kPrimaryColororange,
                                                                    kPrimaryColorLiteorange
                                                                  ],
                                                                  stops: [
                                                                    0.3,
                                                                    1.0
                                                                  ], // Replace with your desired gradient colors
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                ).createShader(
                                                                    bounds);
                                                              },
                                                              child:
                                                                  CachedNetworkImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                imageUrl: homeController
                                                                    .categories[
                                                                        index]
                                                                    .image
                                                                    .icon,
                                                                placeholder: (context,
                                                                        url) =>
                                                                    Image.asset(
                                                                  'assets/img/loading.gif',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 8),

                                                  // margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
                                                  child: /*Text(
                            category.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style:TextStyle(fontWeight: FontWeight.w600,),
                          )*/
                                                      TranslationWidget(
                                                    message: homeController
                                                        .categories[index].name,
                                                    fromLanguage: "English",
                                                    toLanguage: "en",
                                                    builder:
                                                        (translatedMessage) =>
                                                            Text(
                                                                translatedMessage,
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                softWrap: false,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
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
                                )),
                        // Display categories
                        // Display trending foods carousel widget
                        Container(
                          margin:
                              EdgeInsets.only(bottom: 10, top: 10, left: 10),
                          child: Consumer<OffersProvider>(
                            builder: (context, offersProvider, _) {
                              if (offersProvider.offers.isEmpty) {
                                // If offers list is empty, fetch offers
                                offersProvider.fetchOffers();
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300],
                                  highlightColor: Colors.grey[100],
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Container(
                                      height: 100,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
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
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var offer = offersProvider.offers[index];
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                        ),
                        FoodsCarouselWidget(
                          delivery: false,
                          foodsList: homeController.trendingFoodItems,
                          heroTag: 'home_food_carousel',
                          enjoy: 1,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 5, top: 5),
                          child: ListTile(
                            dense: true,
                            minLeadingWidth: 2,
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            leading: Icon(
                              Icons.trending_up,
                              color: Theme.of(context).hintColor,
                            ),
                            title: /*Text(
                                                            S.of(context).most_popular,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight.w500))*/
                                TranslationWidget(
                              message: S.of(context).most_popular,
                              fromLanguage: "English",
                              toLanguage: "en",
                              builder: (translatedMessage) => Text(
                                translatedMessage,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () {
                                print(catId);
                                print(selectedCategoryDeliveryindex);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          KitchenListDineinWidget(
                                            restaurantsList: [],
                                            heroTag: "KitchenListDelivery",
                                            category_id: catId != null
                                                ? int.parse(catId)
                                                : null,
                                          )),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("View all"),
                              ),
                            ),
                          ),
                        ),
                        // Display popular kitchens grid widget
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: GridWidget(
                              delivery: false,
                              restaurantsList: homeController.popularKitchens,
                              heroTag: 'home_restaurants',
                              enjoy: 1),
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
                    if(!cartProvider.quantitiesSet){
                      Provider.of<QuantityProvider>(context, listen: false)
                          .setQuantitiesFromCart(cartProvider.cartItems.first.food.restaurant.id, cartProvider.cartItems);
                       cartProvider.setQuantitiesSet(true);
                    }
                    print("abc calling");

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
                                cartProvider
                                    .cartItems.first.food.restaurant.image.url,
                                height: 30,
                                width: 30,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      "${cartProvider.cartItems.first.food.restaurant.name}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text("${cartProvider.cartItems.length} Items"),
                                ],
                              ),
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
                                          builder: (context) => CartWidget(
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
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: (cartProvider.subTotal)
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
                                      cartProvider.removeAllItemsFromCart();
                                      Provider.of<QuantityProvider>(context, listen: false).clearQuantity();
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
                    String status = orderProvider.getStatusNameById(
                        latestOrderStatus["order_status_id"].toString());
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
                            Text(
                                "Your order #${latestOrderStatus["id"]} is $status"),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Add button or action to view order details
                                  IconButton(
                                    onPressed: () async {
                                      if (latestOrderStatus[
                                              "delivery_dinein"] ==
                                          1)
                                        await settingRepo
                                            .navigatorKey.currentState
                                            .pushNamed('/Tracking',
                                                arguments: RouteArgument(
                                                    id: latestOrderStatus["id"]
                                                        .toString(),
                                                    heroTag: "1"));
                                      else if (latestOrderStatus[
                                              "delivery_dinein"] ==
                                          2) {
                                        await settingRepo
                                            .navigatorKey.currentState
                                            .pushNamed('/TrackingForDinein',
                                                arguments: RouteArgument(
                                                    id: latestOrderStatus["id"]
                                                        .toString(),
                                                    // latitude:widget.order.res_latitude,
                                                    //longitude:widget.order.res_longitude,
                                                    heroTag: "2"));
                                      }
                                      // Implement action to close the popup
                                    },
                                    icon: Icon(
                                      Icons.visibility,
                                      size: 20,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  // Add button or action to close the popup
                                  IconButton(
                                    onPressed: () {
                                      orderProvider.closeorder();
                                      // Implement action to close the popup
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: 20,
                                    ),
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
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton:  widget.directedFrom == "forHome" ?  FloatingActionButton(
          onPressed: () {
            widget.currentPage = HomePage(
              parentScaffoldKey: widget.scaffoldKey,
              currentTab: 1,
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 56.0,
            height: 56.0,
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:Colors.white,
              
            ),
            child: Image.asset("assets/img/logo_bottom.png"),
          ),
        ):Container(),


        bottomNavigationBar: widget.directedFrom == "forHome"
            ?
            BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 5.0,
                height: 65,
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: kBottomNavigationBarHeight,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 70),
                        child: IconButton(
                          icon: const Icon(
                            Icons.assignment,
                            size: 30,
                          ),
                          onPressed: () {
                            if (currentUser.value.apiToken != null) {
                              Navigator.of(context)
                                  .pushNamed('/orderPage', arguments: 0);
                            } else {
                              Navigator.of(context).pushNamed('/Login');
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 30,
                        ),
                        onPressed: () {
                          if (currentUser.value.apiToken == null) {
                            Navigator.of(context).pushNamed('/Login');
                          }
                          else
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartWidget(
                                parentScaffoldKey: widget.parentScaffoldKey,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(),
      ),
    );
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
          //  isCurrentKitchen = true;
          widget.currentPage = HomePage(
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
                      restaurantsList: [],
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
}
/*  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 56.0,
            height: 56.0,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(

              shape: BoxShape.circle,
              color:Colors.white,
             */
/* image: DecorationImage(
                fit: BoxFit.fill,
                scale: 3,
                image: AssetImage("assets/img/logo_bottom.png"), // Replace with your image URL
              ),*/
/*

            ),
            child: Image.asset("assets/img/logo_bottom.png"),
          ),
        ),
*/
/* BottomNavigationBar(
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
                  */
/* BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/img/dinein.svg',color: Colors.grey,height: 17,),
              label: '',
            ),*/
/*
                  BottomNavigationBarItem(
                      label: '',
                      icon: new SvgPicture.asset(
                        'assets/img/home.svg',
                        height: 80,
                      )),
                  */
/* BottomNavigationBarItem(
              icon: new SvgPicture.asset('assets/img/delivery.svg',color: Colors.grey,height: 17,),
              label: '',
            ),*/
/*
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_bag_outlined),
                    label: 'Carts',
                  ),
                ],
              )*/