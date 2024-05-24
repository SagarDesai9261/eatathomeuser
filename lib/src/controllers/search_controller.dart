import 'package:food_delivery_app/src/models/home_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/address.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../repository/food_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/search_repository.dart';
import '../repository/settings_repository.dart';

class SearchController extends ControllerMVC {
  List<RestaurantModel> restaurants = <RestaurantModel>[];
  List<Food> foods = <Food>[];

  SearchController() {
    listenForRestaurants();
    listenForFoods();
    listenForRestaurantsAndFoods();
  }

  void listenForRestaurants({String search}) async {
    // print("search food $search");
    if (search == null) {
      search = await getRecentSearch();
    }
    Address _address = deliveryAddress.value;
    final Stream<RestaurantModel> stream = await searchRestaurants(search, _address);
    stream.listen((RestaurantModel _restaurant) {
      setState(() => restaurants.add(_restaurant));
    }, onError: (a) {
      // print(a);
    }, onDone: () {});
  }

  void listenForFoods({String search}) async {
    if (search == null) {
      search = await getRecentSearch();
    }
    Address _address = deliveryAddress.value;
    final Stream<Food> stream = await searchFoods(search, _address);
    stream.listen((Food _food) {
      setState(() => foods.add(_food));
    }, onError: (a) {
      // print(a);
    }, onDone: () {});
  }
  void listenForRestaurantsAndFoods({String search}) async {
    // print("search food $search");
    if (search == null) {
      search = await getRecentSearch();
    }
    restaurants.clear();
    foods.clear();
    Address _address = deliveryAddress.value;
    final Stream<Map<String, dynamic>> stream = await searchKitchen(search);
    stream.listen((Map<String, dynamic> result) {
      // print(result);
      setState(() {
        // print("hello");
        restaurants.clear();
        foods.clear();
        List<RestaurantModel> _restaurants = (result['kitchens'] as List).map((data) => RestaurantModel.fromJson(data)).toList();

        List<Food> _foods = (result['foods'] as List).map((data) => Food.fromJSON(data)).toList();

        restaurants.addAll(_restaurants);
        foods.addAll(_foods);
      });
    }, onError: (a) {
      // print(a);
    }, onDone: () {});
  }

  Future<void> refreshSearch(search) async {
    setState(() {
      restaurants = <RestaurantModel>[];
      foods = <Food>[];
    });
    listenForRestaurantsAndFoods(search: search);

  /*  listenForRestaurants(search: search);
    listenForFoods(search: search);*/
  }

  void saveSearch(String search) {
    setRecentSearch(search);
    notifyListeners();
  }
}
