import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/kitchen_detail_response.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../repository/cart_repository.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import 'package:provider/provider.dart';
class ContextHolder {
  static BuildContext _context;

  static void setContext(BuildContext context) {
    _context = context;
  }

  static BuildContext getContext() {
    return _context;
  }
}
class FoodsProvider extends ChangeNotifier {
  List<Food> _foods = [];

  List<Food> get foods => _foods;

  void addFoods(List<Food> newFoods) {
    _foods.addAll(newFoods);
    print("provider calls");
    notifyListeners();
  }
}
class CategoryController extends ControllerMVC {
  List<Food> foods = <Food>[];
  List<Food> foodList = [];
  List<FoodItem> foodsByCategory = <FoodItem>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  Category category;
  bool loadCart = false;
  List<Cart> carts = [];
  bool isDateUpdated = false;
  Restaurant kitchenDetails = Restaurant();
  List<SeparateItem> separateItems = <SeparateItem>[];
  bool success = false;
  String apimessage;
  List<FoodItem> foodItems = <FoodItem>[];
  //FoodItem7 _foodItem7;
  Map<String, dynamic> retrivedDataFromAPI = Map();
  Map<String, FoodItem>  foodDataMap = Map();
  int limit = 4; // Number of items to fetch per page
  int offset = 0; // Offset for pagination
  String message = "";
  bool isData = false;
  bool isLoading = false;
  Timer _debounceTimer;

  CategoryController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void loadMoreFoodsByCategory(BuildContext context,String categoryId) async {
    if (!isLoading) {
      print(foodList.length);
      offset = offset + limit;
      final Map<String, dynamic> response =
      await getFoodsByCategory(categoryId, limit, offset);

      if (response['data'] != null) {
        foodList.addAll(  response['data']);
       // print(newFoods.length);

        setState(() {

          //foods.addAll(foodList);
         // foodList.addAll(newFoods);
        });
       // Provider.of<FoodsProvider>(context, listen: false).addFoods(newFoods);

      }
      print(response['data']);
      print(foodList.length);
      print("loadmoreFoods calls");


    }
  }
  void debounceLoadMore(BuildContext context,String categoryId) {
    if (_debounceTimer != null && _debounceTimer.isActive) {
      _debounceTimer.cancel();
    }
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      loadMoreFoodsByCategory(context,categoryId);
    });
  }
  void listenForFoodsByCategory({String id, String message, String restaurantId}) async {

   /* final Stream<Food> stream = await getFoodsByCategory(id);
    stream.listen((Food _food) {
 //     print("DS>> #####"+_food.description);
      setState(() {foods.add(_food); });

    }, onError: (a) {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
    });*/
    final BuildContext context = ContextHolder.getContext();


    final Map<String,dynamic> response = (await getFoodsByCategory(id, limit, 0)) ;



    // response.listen((food) {
    //   // Handle each Food item in the stream
    //    print(food.name);
    // });

    if (response['data'] != null) {

       foodList = response['data'];
       setState(() {
         offset = 0;
        foods.addAll(foodList);
         Provider.of<FoodsProvider>(context).addFoods(foodList);
      });

    }


    if (response['message'] != null && response['message'].isNotEmpty) {
      // ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
      //   content: Text(response['message']),
      // ));
    }
  }

  void listenForFoodsByCategoryAndRestaurant({String id, String message, String restaurantId}) async {
   // foods.clear();
    final Stream<Food> stream = await getFoodsByCategoryAndRestaurant(id, restaurantId);
    stream.listen((Food _food) {
  //    print("DS>> #####"+_food.name);

      setState(() {

      });
      foods.add(_food);

    }, onError: (a) {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
    });
  }

  void listenForFoodsByCategoryAndKitchen({String id, String message, String restaurantId,int categoryId}) async {


      KitchenDetailResponse apiResponse = await getFoodsByCategoryAndKitchen(categoryId, restaurantId);


      success = apiResponse.success;
      apimessage = apiResponse.message;
       retrivedDataFromAPI = apiResponse.data;
        print("hello   =>>>>" + success.toString());
        print(apimessage);
       if(success){
         apiResponse.data.forEach((key, foodItem) {
           foodDataMap = apiResponse.data;

         });
          if(foodDataMap.isEmpty){
      //      print("No data found Food Item");
          }
         for (String key in foodDataMap.keys) {
           FoodItem foodItem = foodDataMap[key];
         //  print('Key: $key');
     //      print('Food Name: ${foodItem.name}');
    //       print('Price: ${foodItem.price}');

           kitchenDetails = foodItem.restaurant;
           separateItems = foodItem.separateItems;
           // Access other properties of FoodItem as needed

           if (kitchenDetails != null) {
  //           print('Restaurant Name: ${kitchenDetails.name}');
  //           print('Restaurant Address: ${kitchenDetails.address}');
             // Access other restaurant properties as needed
           }

           if (separateItems != null && separateItems.isNotEmpty) {
             for (SeparateItem item in separateItems) {
      //         print('Separate Item Name: ${item.name}');
       //        print('Separate Item Image URL: ${item.image}');
       //        print('Separate Item Price: ${item.price}');
               // Access other separate item properties as needed
             }
           }
         }
         setState(() { });
       }
       else {
         isData = true;
     //    print("No data food");
         message = apimessage;
       }


  }

  void setDatainList(List<Food> foodlist) {
    setState(() {
        isDateUpdated = true;
      });
  // print("DS>>> foodbyCategory size "+foods.length.toString());
  }

  void listenForCategory({String id, String message}) async {
    final Stream<Category> stream = await getCategory(id);
    stream.listen((Category _category) {
      setState(() => category = _category);
    }, onError: (a) {
   //  print(a);
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> listenForCart() async {
  /*  final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      carts.add(_cart);
    });*/
  }

  bool isSameRestaurants(Food food) {
    if (carts.isNotEmpty) {
      return carts[0].food?.restaurant?.id == food.restaurant?.id;
    }
    return true;
  }

  void addToCart(Food food, {bool reset = false}) async {
    setState(() {
      this.loadCart = true;
    });
    var _newCart = new Cart();
    _newCart.food = food;
    _newCart.extras = [];
    _newCart.quantity = 1;
    // if food exist in the cart then increment quantity
    var _oldCart = isExistInCart(_newCart);
    if (_oldCart != null) {
      _oldCart.quantity++;
      updateCart(_oldCart).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {

        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(S.of(state.context).this_food_was_added_to_cart),
        ));
      });
    } else {
      // the food doesnt exist in the cart add new one
      addCart(_newCart, reset).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        if (reset) carts.clear();
        carts.add(_newCart);
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(S.of(state.context).this_food_was_added_to_cart),
        ));
      });
    }
  }

  Cart isExistInCart(Cart _cart) {
    return carts.firstWhere((Cart oldCart) => _cart.isSame(oldCart), orElse: () => null);
  }

  Future<void> refreshCategory() async {
    foods.clear();
    category = new Category();
    separateItems.clear();
    foodDataMap.clear();
    kitchenDetails = new Restaurant();
    listenForFoodsByCategory(message: S.of(state.context).category_refreshed_successfuly);
    listenForFoodsByCategoryAndRestaurant(message: S.of(state.context).category_refreshed_successfuly);
    listenForFoodsByCategoryAndKitchen(message: S.of(state.context).category_refreshed_successfuly);
    listenForCategory(message: S.of(state.context).category_refreshed_successfuly);
  }


}
