import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:food_delivery_app/src/repository/cart_repository.dart';
import 'package:food_delivery_app/src/repository/order_repository.dart';
import 'package:food_delivery_app/src/repository/restaurant_repository.dart';
import 'package:food_delivery_app/src/repository/search_repository.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:http/http.dart' as http;
import 'models/cart.dart';
import 'models/food.dart';
import 'models/home_model.dart';
import 'models/offers.dart';
import 'models/order_status.dart';
import 'models/user.dart';
import 'repository/user_repository.dart' as userRepo;
import 'repository/settings_repository.dart' as settingRepo;
import 'package:provider/provider.dart';
class dataProvider extends ChangeNotifier
{
  String category_id = "";

  set_category(cat_id){
    category_id = cat_id;
    notifyListeners();
  }

}


class CuisineProvider extends ChangeNotifier {
  List<String> _selectedCuisines = [];

  List<String> get selectedCuisines => _selectedCuisines;

  void toggleCuisine(String cuisineId) {
    if (_selectedCuisines.contains(cuisineId)) {
      _selectedCuisines.remove(cuisineId);
    } else {
      _selectedCuisines.add(cuisineId);
    }

    notifyListeners();
  }

  void clearSelectedCuisines() {
    _selectedCuisines.clear();
    notifyListeners();
  }
}

class LocationProvider extends ChangeNotifier {
  List<String> _selectedLocations = [];

  List<String> get selectedLocations => _selectedLocations;

  void toggleLocation(String location) {
    if (_selectedLocations.contains(location)) {
      _selectedLocations.remove(location);
    } else {
      _selectedLocations.add(location);
    }

    notifyListeners();
  }

  void clearSelectedCuisines() {
    _selectedLocations.clear();
    notifyListeners();
  }
}

class LoaderProvider extends ChangeNotifier {
bool _isLoading = true;

bool get isLoading => _isLoading;
void startLoading() {
  _isLoading = true;
  notifyListeners();
}

void stopLoading() {
  _isLoading = false;
  notifyListeners();
}
}

class favourite_item_provider  extends ChangeNotifier {
  List<String> restaurant_name = [];

  void add_to_favorite(String name){
    restaurant_name.add(name);
    notifyListeners();
  }
  void removeFromFavorite(String name) {
    restaurant_name.remove(name);
    notifyListeners();
  }

}
class tabIndexProvider extends ChangeNotifier{
  int index = 0;

  void change_index(int value){
    index = value;
    print("tab index change" + index.toString());
    notifyListeners();
  }
}
class location_enable_provider with ChangeNotifier{
  bool? isLocationEnabled;
  bool isLocationServiceDialogShown = false;
  location_enable_provider(){
    initialize();
  }
   initialize() async {
    print("object is calling");

    const Duration checkInterval = Duration(seconds: 5);
    Timer.periodic(checkInterval, (Timer timer) async {
      final bool locationEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
      if (!locationEnabled && !isLocationServiceDialogShown ) {
        // print("object calling ");
        isLocationServiceDialogShown = true;
        _showLocationServiceDialog(settingRepo.navigatorKey.currentState!.context);
      }
    });
    notifyListeners();

  }
  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("Location Services Disabled"),
            content: Text("Please enable location services to use this feature."),
            actions: [
              TextButton(
                onPressed: () {
                  isLocationServiceDialogShown = false;
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  // Redirect user to location settings
                  // await geolocator.Geolocator.openLocationSettings();
                  await geolocator.Geolocator.openLocationSettings();
                  await Future.delayed(Duration(seconds: 3));
                  // final position = await geolocator.Geolocator.getCurrentPosition(
                  //   desiredAccuracy: geolocator.LocationAccuracy.high,
                  // );

                  // if (position != null) {
                  //   // Get the address from the current location
                  //   final addrs = await _getAddressFromLocation(LatLng(position.latitude, position.longitude));
                  //   print(addrs);
                  //   context
                  //       .read<Add_the_address>()
                  //       .set_selected_location(
                  //       addrs,
                  //       LatLng(position.latitude, position.longitude));
                  //   context
                  //       .read<Add_the_address>()
                  //       .address_split();
                  //
                  //   Navigator.of(context).pop();
                  // } else {
                  //   // Handle case when unable to fetch location
                  //   // You can display a message or retry option here
                  // }

                  isLocationServiceDialogShown = false;
                  Phoenix.rebirth(context);
                  Navigator.of(context).pop();

                  },
                child: Text("Enable"),
              ),
            ],
          ),
        );
      },
    );
  }
}
class Add_the_address with ChangeNotifier {
  String? selectedlocation;
  String? currentlocation;
  LatLng? currentlocationLatlong;
  LatLng? selectedlocationLatlong;
  List<Map<String, dynamic>>? address;
  String? address1;
  String? address2;
  geolocator.LocationPermission? permission;
  bool? isLocationEnabled;
  Position? currentposition;
  bool isPositionDetermined = false;
  bool isLocationServiceDialogShown = false;
  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied) {
      throw Exception("User denied permissions to access the device's location.");
    }
  }
  Add_the_address() {
    selectedlocation = "";
    selectedlocationLatlong = LatLng(0, 0);
    address = [];
    initialize();
    address1 = "";
    address2 = "";
    SharedPreferences _prefs;
    // Initialize the address list
  }

  void add_to_address(Map<String, dynamic> addres) {
    print(addres);
    address!.add(addres);
    _saveAddresses();
    notifyListeners();
  }


  void _savecurrentaddress()async{
    print("save address calling");
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('selected_location', selectedlocation!);
    _prefs.setDouble('selected_lat', selectedlocationLatlong!.latitude);
    _prefs.setDouble('selected_lng', selectedlocationLatlong!.longitude);
  }
  void _saveAddresses() async {
    // Convert the List<Map<String, dynamic>> into a JSON string
    final String encodedAddresses = json.encode(address);
    // Save the JSON string to SharedPreferences
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs.setString('addresses', encodedAddresses);
    _prefs.setString('selected_location', selectedlocation!);
    _prefs.setDouble('selected_lat', selectedlocationLatlong!.latitude);
    _prefs.setDouble('selected_lng', selectedlocationLatlong!.longitude);
  }

  void set_selected_location(String locationaddress, LatLng locationLatlng) {
    selectedlocation = locationaddress;
    selectedlocationLatlong = locationLatlng;
    _saveAddresses();
    notifyListeners();
  }

  void remove_address(Map<String, dynamic> addressToRemove) {
    address!.remove(addressToRemove);
    _saveAddresses();
    notifyListeners();
  }

  void initialize() async {
   // isLocationEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
 //   print("object is calling");
   // const Duration checkInterval = Duration(seconds: 5);
   // await requestLocationPermission();
    // Timer.periodic(checkInterval, (Timer timer) async {
    //   final bool locationEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    //   if (!locationEnabled && !isLocationServiceDialogShown ) {
    //    // print("object calling ");
    //     isLocationServiceDialogShown = true;
    //     _showLocationServiceDialog(settingRepo.navigatorKey.currentState.context);
    //
    //   }
    // });
    // isLocationEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    // if (!isLocationEnabled) {
    //   _showLocationServiceDialog(
    //       settingRepo.navigatorKey.currentState.context
    //   );
    //   return;
    // }
    // Get the current location
    isLocationEnabled = await geolocator.Geolocator.isLocationServiceEnabled();

    // Continuously check for location until obtained
    while (!isLocationEnabled!) {
      await Future.delayed(Duration(seconds: 3)); // Wait for 10 seconds before retrying
      isLocationEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    }

    await Future.delayed(Duration(seconds:5 ));
    final position = await geolocator.Geolocator.getCurrentPosition(
      desiredAccuracy: geolocator.LocationAccuracy.high,
    );
 //   SharedPreferences _prefs = await SharedPreferences.getInstance();
    // Get the address from the current location
    final addrs =
    await _getAddressFromLocation(LatLng(position.latitude, position.longitude));

    // Set the selected location and address
    selectedlocation = addrs;
    currentlocation = addrs;
    currentlocationLatlong = LatLng(position.latitude, position.longitude);
    selectedlocationLatlong = LatLng(position.latitude, position.longitude);

    // Initialize the address list
    address_split();
    this.address = [];
    _savecurrentaddress();
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    // Retrieve and decode saved address list from SharedPreferences
    final String savedAddresses = _prefs.getString('addresses') ?? '[]';
    final List<dynamic> decodedAddresses = json.decode(savedAddresses);
    // Convert the decoded list of maps into List<Map<String, dynamic>>
    address = decodedAddresses.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();

    notifyListeners();


  }
  determinePosition() async {
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
      //Fluttertoast.showToast(msg: 'Please enable Your Location Service');
      return;
    }

    permission = await Geolocator.checkPermission();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("permission", permission.toString());

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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



      // Set the flag to true indicating that the position has been determined.
      isPositionDetermined = true;
    } catch (e) {
      print(e);
    }
  }
  void address_split() {
    List<String> addresssplit = selectedlocation!.split(",");
    address1 = addresssplit[0];
    address2 = addresssplit[1];
    print(addresssplit);

    notifyListeners();
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

  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("Location Services Disabled"),
            content: Text("Please enable location services to use this feature."),
            actions: [
              TextButton(
                onPressed: () {
                  isLocationServiceDialogShown = false;
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  // Redirect user to location settings
                  // await geolocator.Geolocator.openLocationSettings();
                  final position = await geolocator.Geolocator.getCurrentPosition(
                    desiredAccuracy: geolocator.LocationAccuracy.high,
                  );

                  if (position != null) {
                    // Get the address from the current location
                    final addrs = await _getAddressFromLocation(LatLng(position.latitude, position.longitude));
                    print(addrs);
                    context
                        .read<Add_the_address>()
                        .set_selected_location(
                        addrs,
                        LatLng(position.latitude, position.longitude));
                    context
                        .read<Add_the_address>()
                        .address_split();

                    Navigator.of(context).pop();
                  } else {
                    // Handle case when unable to fetch location
                    // You can display a message or retry option here
                  }
                  isLocationServiceDialogShown = false;
                },
                child: Text("Enable"),
              ),
            ],
          ),
        );
      },
    );
  }
}
class CartProvider extends ChangeNotifier {
  List<Cart> _cartItems = [];
  int cartCount = 0;
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  //int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  double deliveryCharges = 0.0;
  bool _quantitiesSet = false;
  void setQuantitiesSet(bool value) {
    _quantitiesSet = value;
    notifyListeners();
  }
  bool get quantitiesSet => _quantitiesSet;
  void clear_cart(){
    _cartItems.clear();
  }
  List<Cart> get cartItems => _cartItems;
  int get totalQuantity => _cartItems.fold<int>(0, (sum, cart) => sum + cart.quantity!.toInt());
  // Constructor to load cart items when the provider is initialized

  // Add item to cart
  CartProvider(){
    if (_cartItems.isEmpty) {
      loadCartItems();
    }
    // Listen for cart count changes only once
    if (cartCount == 0) {
      listenForCartsCount();
    }
  }
  void listenForCartsCount() async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
        this.cartCount = _count;
        print(_count);
    }, onError: (a) {
      //    print(a);

    });
    notifyListeners();
  }
  Future<void> addToCart(Cart cart) async {
    Cart newCart = await addCart(cart, false);
    _cartItems.add(newCart);
    notifyListeners();
  }

  // Remove item from cart
  Future<void> removeFromCart(Cart cart) async {
    await removeCart(cart);
    _cartItems.remove(cart);
    notifyListeners();
  }

  // Method to remove all items from the cart
  Future<void> removeAllItemsFromCart() async {
    await removeAllCart();

    // for (Cart cart in _cartItems) {
    //   await removeFromCart(cart);
    // }
    _cartItems.clear(); // Clear the list after removing all items
    notifyListeners();
  }
  void cartassign(List<Cart> carts){


    _cartItems = carts;
    cartCount = _cartItems.fold(0, (sum, item) => sum + item.quantity!.toInt());

    // cartCount = _cartItems.length;
    calculateSubtotal();
    //listenForCartsCount();
    notifyListeners();
  }
  void cartassignfromcarrt(List<Cart> carts){

   // print("hello "+carts.first.food.restaurant.image.url);

    _cartItems.add( carts[0]);
    cartCount = _cartItems.fold(0, (sum, item) => sum + item.quantity!.toInt());

   // cartCount = _cartItems.length;
    calculateSubtotal();
   // listenForCartsCount();
    notifyListeners();
  }

  // Load cart items
  Future<void> loadCartItems() async {
    _cartItems.clear();
    Map<String, dynamic> data = await getCart();
    print("provider cart data call");
    if (data['success'] == true) {
      List<dynamic> items = data['data']['items'];
      double deliveryCharge =  data['data']['delivery_charge'].toDouble();

      // Process the cart items
      if (items.isNotEmpty) {
        items.forEach((item) {
          Cart _cart = Cart.fromJSON(item);

          _cartItems.add(_cart);
        });
      }
    }
   // print("_cartitem_length ====>${_cartItems.length}");
  //  print("_cartitem_length ====>${totalQuantity}");
    calculateSubtotal();
    notifyListeners();
  }
  void calculateSubtotal() {
    double cartPrice = 0;
    subTotal = 0;
    _cartItems.forEach((cart) {
      // Use discount price if available, otherwise use the regular price
      cartPrice = cart.food!.discountPrice > 0 ? cart.food!.discountPrice : cart.food!.price;
      cart.extras!.forEach((element) {
        cartPrice += element.price;
      });
      cartPrice *= cart.quantity!;
      subTotal += cartPrice;
    });

    // Calculate taxAmount if necessary, based on your existing commented code
    // Uncomment and adjust as needed
    // taxAmount = (subTotal) * carts[0].food.restaurant.defaultTax / 100;

    // Print subtotal for debugging
    print(subTotal);

    if (deliveryCharges > 0) {
      total = subTotal + taxAmount + deliveryCharges;
    } else {
      total = subTotal + taxAmount;
    }

    notifyListeners();
  }

}
class OffersProvider with ChangeNotifier {
  List<Offer> _offers = [];

  List<Offer> get offers => _offers;

  OffersProvider(){
    if(_offers.isEmpty)
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    print('${GlobalConfiguration().getValue('api_base_url')}offers');
    final response = await http.get(Uri.parse('${GlobalConfiguration().getValue('api_base_url')}offers'));
    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body)['data'];
   //   print(responseData);
      _offers = List<Offer>.from(responseData.map((offerData) => Offer.fromJson(offerData)));
   //   print(_offers.length);
      notifyListeners();
    } else {
      throw Exception('Failed to load offers');
    }
  }
}
class OrderProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  List<OrderStatus> _orderStatusList = [];

  List<Map<String, dynamic>> get orders => _orders;
  List<OrderStatus> get orderStatusList => _orderStatusList;

  OrderProvider(){
    fetchOrders();
    listenForOrderStatus();
  }

  Future<void> fetchOrders() async {
    print("fetch orders calling");
    User _user = userRepo.currentUser.value;
    final url = 'https://eatathome.in/app/api/current-orders';
    final headers = {
      'Authorization': 'Bearer ${_user.apiToken}',
    };
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['success'] == true) {
        _orders = List<Map<String, dynamic>>.from(responseData['data']);
        notifyListeners();
      } else {
        // Handle error
      }
    } catch (error) {
      // Handle network error
      print('Error fetching orders: $error');
    }
  }
  void closeorder(){
    _orders.clear();
    notifyListeners();
  }

  void listenForOrderStatus() async {
    final Stream<OrderStatus> stream = await getOrderStatus();
    stream.listen((OrderStatus _orderStatus) {
      _orderStatusList.add(_orderStatus);
      notifyListeners();
    }, onError: (a) {}, onDone: () {});
  }
  String? getStatusNameById(String statusId) {
    final status = _orderStatusList.firstWhere((status) => status.id == statusId, orElse: () =>OrderStatus());
    return status != null ? status.status : null;
  }
}
class RestaurantDataProvider extends ChangeNotifier {
  List<RestaurantModel> _restaurants = [];
  List<Food> _foodsbreakfast = [];
  List<Food> _foodslunch = [];
  List<Food> _foodsdinner = [];
  List<Food> _foodssnacks = [];
  bool _isLoading = false;

  List<RestaurantModel> get restaurants => _restaurants;
  List<Food> get foodsbreakfast => _foodsbreakfast;
  List<Food> get foodslunch => _foodslunch;
  List<Food> get foodsdinner => _foodsdinner;
  List<Food> get foodssnacks => _foodssnacks;
  bool get isLoading => _isLoading;

  RestaurantDataProvider(){
    fetchRestaurantsAndFoods();
  }

  Future<void> fetchRestaurantsAndFoods({String? search}) async {
    if (search == null) {
      search = await getRecentSearch();
    }
    _isLoading = true;
    notifyListeners();

  //  Address _address = deliveryAddress.value;
    try {
      final Stream<Map<String, dynamic>> stream = await searchKitchen(search);
      stream.listen((Map<String, dynamic> result) {
        // print(result);

          // print("hello");
          restaurants.clear();
          foodsbreakfast.clear();
          foodslunch.clear();
          foodsdinner.clear();
          foodssnacks.clear();

//          foods.clear();
          List<RestaurantModel> _restaurants = (result['kitchens'] as List).map((data) => RestaurantModel.fromJson(data)).toList();

          List<Food>  _foodsbreckfast = (result['foods']["8"] as List).map((data) => Food.fromJSON(data)).toList();
          List<Food>  _foodslunch = (result['foods']["9"] as List).map((data) => Food.fromJSON(data)).toList();
          List<Food>  _foodssnacks = (result['foods']["7"] as List).map((data) => Food.fromJSON(data)).toList();
          List<Food>  _foodsdinner = (result['foods']["10"] as List).map((data) => Food.fromJSON(data)).toList();
          print(_foodsbreckfast.length);
          print(_foodslunch.length);
          print(_foodssnacks.length);
          print(_foodsdinner.length);
        //  print(_foods.first.name);
          restaurants.addAll(_restaurants);
         foodsbreakfast.addAll(_foodsbreckfast);
         foodslunch.addAll(_foodslunch);
         foodsdinner.addAll(_foodssnacks);
         foodssnacks.addAll(_foodsdinner);
  //        foods.addAll(_foods);

      }, onError: (a) {
        // print(a);
      }, onDone: () {});
    } catch (error) {
      // Handle error
      print(error);
    }

    _isLoading = false;
    notifyListeners();
  }
  void saveSearch(String search) {
    setRecentSearch(search);

  }
  Future<void> refreshSearch(search) async {



    fetchRestaurantsAndFoods(search: search);

    /*  listenForRestaurants(search: search);
    listenForFoods(search: search);*/
  }
}