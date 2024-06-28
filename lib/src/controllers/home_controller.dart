import 'package:flutter/cupertino.dart';
import 'package:food_delivery_app/src/models/cuisine.dart';
import 'package:food_delivery_app/src/models/home_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../models/location.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/slide.dart';
import '../provider.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/slider_repository.dart';

class HomeController extends ControllerMVC {
  List<Category> categories = <Category>[];
  List<Slide> slides = <Slide>[];
  List<Cuisine> cuisineList = <Cuisine>[];
  List<Cuisine> cuisineList2 = <Cuisine>[];
  List<LocationModel> locationList = <LocationModel>[];
  List<LocationModel> locationList2 = <LocationModel>[];
  List<Restaurant> AllRestaurantsDelivery = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  int count = 0;
  List<FoodItem> trendingFoodItems = [];
  List<RestaurantModel> topKitchens = [];
  List<RestaurantModel> popularKitchens = [];
  List<FoodItem> trendingFoodItemsFake = [];
  List<RestaurantModel> topKitchensFake = [];
  List<RestaurantModel> popularKitchensFake = [];
  Add_the_address? addressProvider;
  List<FoodItem> trendingFoodItemsDelivery = [];
  List<RestaurantModel> topKitchensDelivery = [];
  List<RestaurantModel> popularKitchensDelivery = [];
  bool isTrendingFoodLoaded = false, isTopKitchensLoaded = false, isPopularKitchenLoaded = false;
  bool isTrendingFoodDlvryLoaded = false, isTopKitchensDlvryLoaded = false, isPopularKitchenDlvryLoaded = false;

  HomeController() {
    DateTime now = DateTime.now();
    String todayDate = "${now.day}-${now.month}-${now.year}";
    addressProvider = Add_the_address(); // Instantiate the Add_the_address provider
    addressProvider!.initialize();
  }

  Future<void> listenForCuisine() async {
    if (cuisineList.isNotEmpty) return; // Avoid duplicate calls
    cuisineList.clear();
    cuisineList2.clear();
    final Stream<Cuisine> stream = await fetchCuisine();
    stream.listen((Cuisine _cuisine) {
      setState(() {
        cuisineList.add(_cuisine);
      });
      cuisineList2.add(_cuisine);
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForLocation() async {
    if (locationList.isNotEmpty) return; // Avoid duplicate calls
    final Stream<LocationModel> stream = await fetchLocation();
    stream.listen((LocationModel _locationModel) {
      setState(() => locationList.add(_locationModel));
      locationList2.add(_locationModel);
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForSlides() async {
    if (slides.isNotEmpty) return; // Avoid duplicate calls
    final Stream<Slide> stream = await getSlides();
    stream.listen((Slide _slide) {
      setState(() => slides.add(_slide));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForCategories() async {
    if (categories.isNotEmpty) return; // Avoid duplicate calls
    categories.clear();
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForAllRestaurantsDelivery(
      String kitchenType, String todayDate) async {
    if (AllRestaurantsDelivery.isNotEmpty) return; // Avoid duplicate calls
    final Stream<Restaurant> stream =
    await getAllRestaurants(kitchenType, todayDate, "0", "0");
    stream.listen((Restaurant _restaurant) {
      AllRestaurantsDelivery.add(_restaurant);
    }, onError: (a) {}, onDone: () {});
  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      deliveryAddress.value = _address;
      await refreshHome();
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }

  Future<void> listenForRecentReviews() async {
    if (recentReviews.isNotEmpty) return; // Avoid duplicate calls
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> fetchKitchens() async {
    if (isTrendingFoodLoaded && isTopKitchensLoaded && isPopularKitchenLoaded) return; // Avoid duplicate calls
    final data = await fetchAllKitchens();

    setState(() {
      isTrendingFoodLoaded = data['trending']['success'];
      isTopKitchensLoaded = data['topkitchens']['success'];
      isPopularKitchenLoaded = data['popular']['success'];
    });

    trendingFoodItems.clear();
    for (var item in data['trending']['data']) {
      trendingFoodItems.add(FoodItem.fromJson(item));
    }

    topKitchens.clear();
    for (var item in data['topkitchens']['data']) {
      topKitchens.add(RestaurantModel.fromJson(item));
    }

    popularKitchens.clear();
    for (var item in data['popular']['data']) {
      popularKitchens.add(RestaurantModel.fromJson(item));
    }
  }

  Future<void> fetchKitchensDelivery() async {
    if (isTrendingFoodDlvryLoaded && isTopKitchensDlvryLoaded && isPopularKitchenDlvryLoaded) return; // Avoid duplicate calls
    final data = await fetchAllKitchensDelivery();

    setState(() {
      isTrendingFoodDlvryLoaded = data['trending']['success'];
      isTopKitchensDlvryLoaded = data['topkitchens']['success'];
      isPopularKitchenDlvryLoaded = data['popular']['success'];
    });

    topKitchensDelivery.clear();
    trendingFoodItemsDelivery.clear();
    popularKitchensDelivery.clear();

    for (var item in data['trending']['data']) {
      trendingFoodItemsDelivery.add(FoodItem.fromJson(item));
    }

    for (var item in data['topkitchens']['data']) {
      topKitchensDelivery.add(RestaurantModel.fromJson(item));
    }

    for (var item in data['popular']['data']) {
      popularKitchensDelivery.add(RestaurantModel.fromJson(item));
    }
  }

  Future<void> fetchKitchensWithCuisine(
      String cuisinesQueryParam, String fromDineInorDelivery) async {
    count = count + 1;
    final data = await fetchAllKitchensWithCuisine(
        cuisinesQueryParam, fromDineInorDelivery);

    trendingFoodItems.clear();
    for (var item in data['trending']['data']) {
      trendingFoodItems.add(FoodItem.fromJson(item));
    }
    topKitchens.clear();
    for (var item in data['topkitchens']['data']) {
      topKitchens.add(RestaurantModel.fromJson(item));
    }

    popularKitchens.clear();
    for (var item in data['popular']['data']) {
      popularKitchens.add(RestaurantModel.fromJson(item));
    }

    setState(() {});
  }

  Future<void> fetchKitchensWithLocation(
      String locationQueryParam, String fromDineInorDelivery) async {
    final data = await fetchAllKitchensWithLocation(
        locationQueryParam, fromDineInorDelivery);

    trendingFoodItems.clear();
    for (var item in data['trending']['data']) {
      trendingFoodItems.add(FoodItem.fromJson(item));
    }
    topKitchens.clear();
    for (var item in data['topkitchens']['data']) {
      topKitchens.add(RestaurantModel.fromJson(item));
    }
    popularKitchens.clear();
    for (var item in data['popular']['data']) {
      popularKitchens.add(RestaurantModel.fromJson(item));
    }

    setState(() {});
  }

  Future<void> refreshHome() async {
    setState(() {
      slides = <Slide>[];
      categories = <Category>[];
      AllRestaurantsDelivery.clear();
      AllRestaurantsDelivery = <Restaurant>[];
      recentReviews = <Review>[];
      cuisineList = <Cuisine>[];
      locationList = <LocationModel>[];

      trendingFoodItems = <FoodItem>[];
      topKitchens = <RestaurantModel>[];
      popularKitchens = <RestaurantModel>[];

      topKitchensDelivery = <RestaurantModel>[];
      popularKitchensDelivery = <RestaurantModel>[];
      isTrendingFoodLoaded= false;
      isTopKitchensLoaded= false;
      isPopularKitchenLoaded = false;
    });

    await listenForCategories();
    await fetchKitchensDelivery();
    await fetchKitchens();
  }

  Future<void> refreshSubHome() async {
    setState(() {
      slides = <Slide>[];
      categories = <Category>[];
      AllRestaurantsDelivery.clear();
      AllRestaurantsDelivery = <Restaurant>[];
      recentReviews = <Review>[];
      cuisineList = <Cuisine>[];
      locationList = <LocationModel>[];

      trendingFoodItems = <FoodItem>[];
      topKitchens = <RestaurantModel>[];
      popularKitchens = <RestaurantModel>[];

      trendingFoodItemsDelivery = <FoodItem>[];
      topKitchensDelivery = <RestaurantModel>[];
      popularKitchensDelivery = <RestaurantModel>[];
      isTrendingFoodLoaded= false;
      isTopKitchensLoaded= false;
      isPopularKitchenLoaded = false;
    });

    await listenForCategories();
    await fetchKitchensDelivery();
    await fetchKitchens();
  }
}
