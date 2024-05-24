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
  Add_the_address addressProvider;
  List<FoodItem> trendingFoodItemsDelivery = [];
  List<RestaurantModel> topKitchensDelivery = [];
  List<RestaurantModel> popularKitchensDelivery = [];
  bool isTrendingFoodLoaded = false, isTopKitchensLoaded = false, isPopularKitchenLoaded = false;
  bool isTrendingFoodDlvryLoaded = false, isTopKitchensDlvryLoaded = false, isPopularKitchenDlvryLoaded = false;

  HomeController() {
    DateTime now = DateTime.now();
    String todayDate = "${now.day}-${now.month}-${now.year}";
   // fetchKitchens();
   // fetchKitchensDelivery();
    addressProvider = Add_the_address(); // Instantiate the Add_the_address provider
    addressProvider.initialize();
    //listenForSlides();
   // listenForAllRestaurantsDelivery("2", todayDate);
   // listenForRecentReviews();
   // listenForCategories();
  //  listenForCuisine();
   // listenForLocation();
  }

  Future<void> listenForCuisine() async {
    cuisineList.clear();
    cuisineList2.clear();
    final Stream<Cuisine> stream = await fetchCuisine();
    stream.listen((Cuisine _cuisine) {
     // print("DS>>> Cuisine: "+ _cuisine.name.toString());
      setState(() {
        cuisineList.add(_cuisine);
      });
      cuisineList2.add(_cuisine);
    }, onError: (a) {
  //    // print(a);
    }, onDone: () {});
  }

  Future<void> listenForLocation() async {
    final Stream<LocationModel> stream = await fetchLocation();
    stream.listen((LocationModel _locationModel) {
      setState(() => locationList.add(_locationModel));
      locationList2.add(_locationModel);
    }, onError: (a) {
    //  // print(a);
    }, onDone: () {});
  }

  Future<void> listenForSlides() async {
    final Stream<Slide> stream = await getSlides();
    stream.listen((Slide _slide) {
      setState(() => slides.add(_slide));
    }, onError: (a) {
    //  // print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories() async {
    categories.clear();
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
    //  // print("DS>> categories: "+_category.name);
      //categories.add(_category);
      setState(() => categories.add(_category));
    }, onError: (a) {
//      // print(a);
    }, onDone: () {});
  }

  Future<void> listenForAllRestaurantsDelivery(
      String kitchenType, String todayDate) async {
    final Stream<Restaurant> stream =
        await getAllRestaurants(kitchenType, todayDate, "0", "0");
    stream.listen((Restaurant _restaurant) {
   // print("DS>> Restaurantlist delivery: " + _restaurant.name);
      //setState(() => AllRestaurants.add(_restaurant));
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
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> fetchKitchens() async {
   /* double latitude = addressProvider.selectedlocationLatlong.latitude;
    double longitude = addressProvider.selectedlocationLatlong.longitude;

    print(" ===>>>> $latitude");
    print(" ===>>>> $longitude");
    print(" ===>>>> ${addressProvider.selectedlocation}");*/
  //  try {
      final data = await fetchAllKitchens();

   //   // print("before:"+topKitchens.length.toString());
      // GoogleTranslator translator = new GoogleTranslator();
      // var translation = await translator.translate(data['trending']['data'].toString(), from: "en", to: "hi");
     // // print("DS>> hindi "+translation.text.toString());

      setState(() {
        if(data['trending']['success']){
          //// print("DS>> home: trend ");
          isTrendingFoodLoaded = true;
        }
        else isTrendingFoodLoaded = false;

        if(data['topkitchens']['success']){
          isTopKitchensLoaded = true;
          //// print("DS>> home: top ");
        }
        else isTopKitchensLoaded = false;

        if(data['popular']['success']){
          isPopularKitchenLoaded = true;
         // print("DS>> home: pop ");
        }
        else isPopularKitchenLoaded = false;
      });
      trendingFoodItems.clear();
      // Parse and populate arrays here
      for (var item in data['trending']['data']) {
        //// print("DS>> home: trend list ");
        trendingFoodItems.add(FoodItem.fromJson(item));
      }
      topKitchens.clear();
      for (var item in data['topkitchens']['data']) {
        //// print("DS>> home: top list ");
        topKitchens.add(RestaurantModel.fromJson(item));
      }

      popularKitchens.clear();
      for (var item in data['popular']['data']) {
        //// print("DS>> home: pop list ");
        popularKitchens.add(RestaurantModel.fromJson(item));
      }
    // } catch (e) {
    //   // print('Error fetching kitchens: $e');
    // }
  }

  Future<void> fetchKitchensDelivery() async {
    // try {
      final data = await fetchAllKitchensDelivery();

      setState(() {
        if(data['trending']['success']){
          isTrendingFoodDlvryLoaded = true;
        }
        else isTrendingFoodDlvryLoaded = false;

        if(data['topkitchens']['success']){
          isTopKitchensDlvryLoaded = true;
        }
        else isTopKitchensDlvryLoaded = false;

        if(data['popular']['success']){
          isPopularKitchenDlvryLoaded = true;
        }
        else isPopularKitchenDlvryLoaded = false;
      });

      topKitchensDelivery.clear();
      trendingFoodItemsDelivery.clear();
      popularKitchensDelivery.clear();

      // Parse and populate arrays here
      for (var item in data['trending']['data']) {
        trendingFoodItemsDelivery.add(FoodItem.fromJson(item));
      }

      for (var item in data['topkitchens']['data']) {
        topKitchensDelivery.add(RestaurantModel.fromJson(item));
      }

      for (var item in data['popular']['data']) {
        popularKitchensDelivery.add(RestaurantModel.fromJson(item));
      }
    // } catch (e) {
    //   // print('Error fetching kitchens: $e');
    // }
  }

  Future<void> fetchKitchensWithCuisine(
      String cuisinesQueryParam, String fromDineInorDelivery) async {
    try {
      count = count + 1;
      final data = await fetchAllKitchensWithCuisine(
          cuisinesQueryParam, fromDineInorDelivery);

      // Parse and populate arrays here
      trendingFoodItems.clear();
      for (var item in data['trending']['data']) {
        trendingFoodItems.add(FoodItem.fromJson(item));
      }
      topKitchens.clear();
      for (var item in data['topkitchens']['data']) {
        topKitchens.add(RestaurantModel.fromJson(item));
      }

    //  // print(data["topkitchens"]);
      popularKitchens.clear();
      for (var item in data['popular']['data']) {
        popularKitchens.add(RestaurantModel.fromJson(item));
      }

      setState(() {});
    //  // print("after:" + topKitchens.length.toString());
    } catch (e) {
//      // print('Error fetching kitchens: $e');
    }
  //  // print("count function for calling $count");
  }


  Future<void> fetchKitchensWithLocation(
      String locationQueryParam, String fromDineInorDelivery) async {
    try {
      final data = await fetchAllKitchensWithLocation(
          locationQueryParam, fromDineInorDelivery);
      // Parse and populate arrays here
      trendingFoodItems.clear();
      for (var item in data['trending']['data']) {
        trendingFoodItems.add(FoodItem.fromJson(item));
      }
      topKitchens.clear();
      for (var item in data['topkitchens']['data']) {
        topKitchens.add(RestaurantModel.fromJson(item));
      }
      popularKitchens.clear();
     // print("after:" + topKitchens.length.toString());
      for (var item in data['popular']['data']) {
        popularKitchens.add(RestaurantModel.fromJson(item));
      }
      setState(() {});
    } catch (e) {
    //  // print('Error fetching kitchens: $e');
    }
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

   ///   trendingFoodItemsDelivery = <FoodItem>[];
     topKitchensDelivery = <RestaurantModel>[];
      popularKitchensDelivery = <RestaurantModel>[];
      isTrendingFoodLoaded= false;
      isTopKitchensLoaded= false;
      isPopularKitchenLoaded = false;
    });

    DateTime now = DateTime.now();
    String todayDate = "${now.day}-${now.month}-${now.year}";
    await listenForCategories();

    await fetchKitchensDelivery();
    await fetchKitchens();
  //  await listenForSlides();
   // await listenForRecentReviews();
  // await listenForAllRestaurantsDelivery("2", todayDate);
  //  await listenForCuisine();
  //  await listenForLocation();

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


    DateTime now = DateTime.now();
    String todayDate = "${now.day}-${now.month}-${now.year}";
    await listenForCategories();
    await fetchKitchensDelivery();
    await fetchKitchens();
   // await listenForSlides();
    //await listenForRecentReviews();
   // await listenForAllRestaurantsDelivery("2", todayDate);
    //await listenForCuisine();
   //await listenForLocation();

  }

}
