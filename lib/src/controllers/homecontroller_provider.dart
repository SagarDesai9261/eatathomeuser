import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/cuisine.dart';
import 'package:food_delivery_app/src/models/home_model.dart';
import '../../my_widget/HomeScreen.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../models/location.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/slide.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/slider_repository.dart';

class HomeProvider with ChangeNotifier {
  List<Category> categories = <Category>[];
  List<Slide> slides = <Slide>[];
  List<Cuisine> cuisineList = <Cuisine>[];
  List<Cuisine> cuisineList2 = <Cuisine>[];
  List<LocationModel> locationList = <LocationModel>[];
  List<LocationModel> locationList2 = <LocationModel>[];
  List<Restaurant> allRestaurantsDelivery = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  int count = 0;
  List<FoodItem> trendingFoodItems = [];
  List<RestaurantModel> topKitchens = [];
  List<RestaurantModel> popularKitchens = [];
  Add_the_address addressProvider;
  List<FoodItem> trendingFoodItemsDelivery = [];
  List<RestaurantModel> topKitchensDelivery = [];
  List<RestaurantModel> popularKitchensDelivery = [];
  bool isTrendingFoodLoaded = false, isTopKitchensLoaded = false, isPopularKitchenLoaded = false;
  bool isTrendingFoodDlvryLoaded = false, isTopKitchensDlvryLoaded = false, isPopularKitchenDlvryLoaded = false;

  HomeProvider() {
    DateTime now = DateTime.now();
    String todayDate = "${now.day}-${now.month}-${now.year}";
    addressProvider = Add_the_address(); // Instantiate the Add_the_address provider
    addressProvider.initialize();
    listenForCategories();
    fetchKitchensDelivery();
    fetchKitchens();

  }

  Future<void> listenForCuisine() async {
    if (cuisineList.isNotEmpty) return; // Avoid duplicate calls
    cuisineList.clear();
    cuisineList2.clear();
    final Stream<Cuisine> stream = await fetchCuisine();
    stream.listen((Cuisine _cuisine) {
      cuisineList.add(_cuisine);
      cuisineList2.add(_cuisine);
      notifyListeners();
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForLocation() async {
    if (locationList.isNotEmpty) return; // Avoid duplicate calls
    final Stream<LocationModel> stream = await fetchLocation();
    stream.listen((LocationModel _locationModel) {
      locationList.add(_locationModel);
      locationList2.add(_locationModel);
      notifyListeners();
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForSlides() async {
    if (slides.isNotEmpty) return; // Avoid duplicate calls
    final Stream<Slide> stream = await getSlides();
    stream.listen((Slide _slide) {
      slides.add(_slide);
      notifyListeners();
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForCategories() async {
    if (categories.isNotEmpty) return; // Avoid duplicate calls
    categories.clear();
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      categories.add(_category);
      notifyListeners();
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForAllRestaurantsDelivery(String kitchenType, String todayDate) async {
    if (allRestaurantsDelivery.isNotEmpty) return; // Avoid duplicate calls
    final Stream<Restaurant> stream = await getAllRestaurants(kitchenType, todayDate, "0", "0");
    stream.listen((Restaurant _restaurant) {
      allRestaurantsDelivery.add(_restaurant);
      notifyListeners();
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForRecentReviews() async {
    if (recentReviews.isNotEmpty) return; // Avoid duplicate calls
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      recentReviews.add(_review);
      notifyListeners();
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> fetchKitchens() async {
   /// if (isTrendingFoodLoaded && isTopKitchensLoaded && isPopularKitchenLoaded) return; // Avoid duplicate calls
    final data = await fetchAllKitchens();

    isTrendingFoodLoaded = data['trending']['success'];
    isTopKitchensLoaded = data['topkitchens']['success'];
    isPopularKitchenLoaded = data['popular']['success'];

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

    notifyListeners();
  }
  Future<void> fetchKitchensfromcategory(String category) async {
    /// if (isTrendingFoodLoaded && isTopKitchensLoaded && isPopularKitchenLoaded) return; // Avoid duplicate calls
    final data = await fetchAllKitchensfromcategory(category_id: category);

    isTrendingFoodLoaded = data['trending']['success'];
    isTopKitchensLoaded = data['topkitchens']['success'];
    isPopularKitchenLoaded = data['popular']['success'];

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

    notifyListeners();
  }

  Future<void> fetchKitchensDelivery() async {
  //  if (isTrendingFoodDlvryLoaded && isTopKitchensDlvryLoaded && isPopularKitchenDlvryLoaded) return; // Avoid duplicate calls
    final data = await fetchAllKitchensDelivery();

    isTrendingFoodDlvryLoaded = data['trending']['success'];
    isTopKitchensDlvryLoaded = data['topkitchens']['success'];
    isPopularKitchenDlvryLoaded = data['popular']['success'];

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

    notifyListeners();
  }
  Future<void> fetchKitchensDeliveryforEnjoyLater() async {
    //  if (isTrendingFoodDlvryLoaded && isTopKitchensDlvryLoaded && isPopularKitchenDlvryLoaded) return; // Avoid duplicate calls
    final data = await fetchAllKitchensDelivery(enjoy: 2);

    isTrendingFoodDlvryLoaded = data['trending']['success'];
    isTopKitchensDlvryLoaded = data['topkitchens']['success'];
    isPopularKitchenDlvryLoaded = data['popular']['success'];

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

    notifyListeners();
  }
  Future<void> fetchKitchensWithCuisine(String cuisinesQueryParam, String fromDineInorDelivery) async {
    count = count + 1;
    final data = await fetchAllKitchensWithCuisine(cuisinesQueryParam, fromDineInorDelivery);

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

    notifyListeners();
  }

  Future<void> fetchKitchensWithLocation(String locationQueryParam, String fromDineInorDelivery) async {
    final data = await fetchAllKitchensWithLocation(locationQueryParam, fromDineInorDelivery);

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

    notifyListeners();
  }

  Future<void> refreshHome() async {
    slides = <Slide>[];
    categories = <Category>[];
    allRestaurantsDelivery.clear();
    recentReviews = <Review>[];
    cuisineList = <Cuisine>[];
    locationList = <LocationModel>[];

    trendingFoodItems = <FoodItem>[];
    topKitchens = <RestaurantModel>[];
    popularKitchens = <RestaurantModel>[];

    topKitchensDelivery = <RestaurantModel>[];
    popularKitchensDelivery = <RestaurantModel>[];
    isTrendingFoodLoaded = false;
    isTopKitchensLoaded = false;
    isPopularKitchenLoaded = false;

    await listenForCategories();
    await fetchKitchensDelivery();
    await fetchKitchens();
  }

  Future<void> refreshSubHome() async {
    slides = <Slide>[];
    categories = <Category>[];
    allRestaurantsDelivery.clear();
    recentReviews = <Review>[];
    cuisineList = <Cuisine>[];
    locationList = <LocationModel>[];

    trendingFoodItems = <FoodItem>[];
    topKitchens = <RestaurantModel>[];
    popularKitchens = <RestaurantModel>[];

    trendingFoodItemsDelivery = <FoodItem>[];
    topKitchensDelivery = <RestaurantModel>[];
    popularKitchensDelivery = <RestaurantModel>[];
    isTrendingFoodLoaded = false;
    isTopKitchensLoaded = false;
    isPopularKitchenLoaded = false;

    await listenForCategories();
    await fetchKitchensDelivery();
    await fetchKitchens();
  }
  Future<void> refreshSubHomeforenjoylater() async {
    slides = <Slide>[];
   // categories = <Category>[];
    allRestaurantsDelivery.clear();
    recentReviews = <Review>[];
    cuisineList = <Cuisine>[];
    locationList = <LocationModel>[];

    //trendingFoodItems = <FoodItem>[];
    //topKitchens = <RestaurantModel>[];
    //popularKitchens = <RestaurantModel>[];

    trendingFoodItemsDelivery = <FoodItem>[];
    topKitchensDelivery = <RestaurantModel>[];
    popularKitchensDelivery = <RestaurantModel>[];
    isTrendingFoodLoaded = false;
    isTopKitchensLoaded = false;
    isPopularKitchenLoaded = false;

 //   await listenForCategories();
    await fetchKitchensDeliveryforEnjoyLater();
    //await fetchKitchens();
  }
  Future<void> refreshDatawithCategaroies(String category) async {
    slides = <Slide>[];
    // categories = <Category>[];
    //allRestaurantsDelivery.clear();
    recentReviews = <Review>[];
    cuisineList = <Cuisine>[];
    locationList = <LocationModel>[];

    trendingFoodItems = <FoodItem>[];
    topKitchens = <RestaurantModel>[];
    popularKitchens = <RestaurantModel>[];

    // trendingFoodItemsDelivery = <FoodItem>[];
    // topKitchensDelivery = <RestaurantModel>[];
    // popularKitchensDelivery = <RestaurantModel>[];
    isTrendingFoodLoaded = false;
    isTopKitchensLoaded = false;
    isPopularKitchenLoaded = false;

    //   await listenForCategories();
    await fetchKitchensfromcategory(category);
    //await fetchKitchens();
  }
  Future<void> refreshSubHomeforenjoynow() async {
    slides = <Slide>[];
    // categories = <Category>[];
    allRestaurantsDelivery.clear();
    recentReviews = <Review>[];
    cuisineList = <Cuisine>[];
    locationList = <LocationModel>[];

    //trendingFoodItems = <FoodItem>[];
    //topKitchens = <RestaurantModel>[];
    //popularKitchens = <RestaurantModel>[];

    trendingFoodItemsDelivery = <FoodItem>[];
    topKitchensDelivery = <RestaurantModel>[];
    popularKitchensDelivery = <RestaurantModel>[];
    isTrendingFoodLoaded = false;
    isTopKitchensLoaded = false;
    isPopularKitchenLoaded = false;

    //   await listenForCategories();
    await fetchKitchensDelivery();
    //await fetchKitchens();
  }
}
