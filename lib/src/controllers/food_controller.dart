import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/extra.dart';
import '../models/favorite.dart';
import '../models/food.dart';
import '../models/kitchain_details.dart';
import '../repository/cart_repository.dart';
import '../repository/food_repository.dart';
import 'package:http/http.dart' as http;
import '../provider.dart';
import 'package:provider/provider.dart';

import 'cart_controller.dart';
import '../repository/settings_repository.dart' as settingRepo;

class FoodController extends ControllerMVC {
  Food food;
  double quantity = 0;
  double total = 0;
  List<Cart> carts = [];
  Favorite favorite;
  bool loadCart = false;
  GlobalKey<ScaffoldState> scaffoldKey;
  CartController cartController;
  FoodController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<Restaurant> getKetchainDetails(
      String kitchenid, String kitchenType) async {
    final Uri uri =
        Uri.parse('https://comeeathome.com/app/api/kitchen-details');

    // Adding parameters to the request
    final Map<String, String> queryParams = {
      'kitchen': kitchenid.toString(),
      'kitchenType': kitchenType.toString(),
      // Add more parameters as needed
    };
    final Uri uriWithParams = uri.replace(queryParameters: queryParams);

    final response = await http.get(uriWithParams);

    //   // print("request:"+response.request.toString());
    //final response = await http.get(Uri.parse(uri.toString()));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      //   // print("----"+data.toString());
      return Restaurant.fromJson(data['data']);
    }
  }

  void listenForFood({String foodId, String message}) async {
    final Stream<Food> stream = await getFood(foodId);
    stream.listen((Food _food) {
      setState(() => food = _food);
    }, onError: (a) {
      //  // print(a);
      ScaffoldMessenger.of(scaffoldKey.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      calculateTotal();
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForFavorite({String foodId}) async {
    final Stream<Favorite> stream = await isFavoriteFood(foodId);
    stream.listen((Favorite _favorite) {
      setState(() => favorite = _favorite);
    }, onError: (a) {
      //  // print(a);
    });
  }

  void listenForCart() async {
    carts.clear();
    final Map<String, dynamic> data = await getCart();
    print("Cart data callls");
    // Check if the API call was successful
    if (data['success'] == true) {
      List<dynamic> items = data['data']['items'];
      double deliveryCharge = data['data']['delivery_charge'].toDouble();

      // Process the cart items
      if (items.isNotEmpty) {
        items.forEach((item) {
          Cart _cart = Cart.fromJSON(item);
          setState(() {
            carts.add(_cart);
          });
        });
      }
      setState(() {
        // deliveryCharges = deliveryCharge;
      });
      // calculateSubtotal();

      // Process delivery charge
      if (deliveryCharge != -1) {
        // Handle delivery charge as needed
      }

      // Other logic for calculating subtotal, handling messages, etc.
    } else {
      // If the API call was not successful, print an error message
      print('Error: ${data['message']}');
    }
  }

  bool isSameRestaurants(Food food) {
    if (carts.isNotEmpty) {
    //  return carts[0].food?.restaurant?.id == food.restaurant?.id;
    }
    return true;
  }

  void addToCart(Food food, {double quantity = 1.0, bool reset = false,String restaurant_id,String coupon_id}) async {
    print(coupon_id);
    setState(() {
      this.loadCart = true;
    });
    carts.clear();
    final Map<String, dynamic> data = await getCart();
    print("Cart data callls ${food.restaurant.image.url}");
    // Check if the API call was successful
    if (data['success'] == true) {
      List<dynamic> items = data['data']['items'];
      double deliveryCharge = data['data']['delivery_charge'].toDouble();

      // Process the cart items
      if (items.isNotEmpty) {
        items.forEach((item) {
          Cart _cart = Cart.fromJSON(item);
          carts.add(_cart);
        });
      }
      if(items.isNotEmpty){
        int existingIndex = carts.indexWhere((cart) => cart.food.id == food.id);
        print("existing index  ==>" + existingIndex.toString());
        print("${carts[0].food.restaurant.id}  ==> ${carts[0].food.restaurant.id.runtimeType}");
         print("${food.restaurant.id}  ==> ${food.restaurant.id.runtimeType}");
        bool same_restaurant =  carts[0].food.restaurant.id == food.restaurant.id;
        print("same_restaurant " +same_restaurant.toString());
        //  bool same_restaurant = false;
        if(same_restaurant == true){
          if (existingIndex != -1) {
            print("Food already in cart. Updating quantity.");

            // Update the quantity if the food item already exists in the cart
            carts[existingIndex].quantity = quantity;
            carts[existingIndex].Couponid = coupon_id;
            updateCart(carts[existingIndex]).then((value) {
              setState(() {
                this.loadCart = false;
              });
              Provider.of<CartProvider>(settingRepo.navigatorKey.currentState.context,listen: false).cartassignfromcarrt(carts);
            }).whenComplete(() {
              /*   ScaffoldMessenger.of(scaffoldKey?.currentContext)
              .showSnackBar(SnackBar(
            content: Text(S.of(state.context).this_food_was_added_to_cart),
          ));*/
            });
          } else {
            print("Food not in cart. Creating new cart item.");
            // Create a new cart item if the food doesn't exist in the cart
            var newCart = Cart();
            newCart.food = food;
            newCart.extras = [];
            newCart.quantity = quantity;
            newCart.Couponid = coupon_id;

            addCart(newCart, false).then((value) {
              setState(() {
                this.loadCart = false;
              });
              Provider.of<CartProvider>(settingRepo.navigatorKey.currentState.context,listen: false).cartassignfromcarrt([newCart]);
            }).whenComplete(() {
              /*ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(
            content: Text(S.of(state.context).this_food_was_added_to_cart),
          ));*/
            });
          }
        }
        else{
          print(carts.length);
          carts.forEach((element) {
            removeCart(element).then((value) {
              //  calculateSubtotal();
              //   ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
              //     content: Text(S.of(state.context).the_food_was_removed_from_your_cart(_cart.food.name)),
              //   ));
            });
          });
          var newCart = Cart();
          newCart.food = food;
          newCart.extras = [];
          newCart.quantity = quantity;
          newCart.Couponid = coupon_id;
          addCart(newCart, false).then((value) {
            setState(() {
              this.loadCart = false;
            });
            Provider.of<CartProvider>(settingRepo.navigatorKey.currentState.context,listen: false).cartassignfromcarrt([newCart]);
          }).whenComplete(() {
            ScaffoldMessenger.of(settingRepo.navigatorKey.currentState.context).showSnackBar(SnackBar(
              content: Text(S.of(state.context).this_food_was_added_to_cart),
            ));
          });
        }
      }
      else{
        var newCart = Cart();
        newCart.food = food;
        newCart.extras = [];
        newCart.quantity = quantity;
        newCart.Couponid = coupon_id;
        addCart(newCart, false).then((value) {
          setState(() {
            this.loadCart = false;
          });
          Provider.of<CartProvider>(settingRepo.navigatorKey.currentState.context,listen: false).cartassignfromcarrt([newCart]);
        }).whenComplete(() {

        });
      }


    } else {
      // If the API call was not successful, print an error message
      print("Food not in cart. Creating new cart item.");
      // Create a new cart item if the food doesn't exist in the cart
      var newCart = Cart();
      newCart.food = food;
      newCart.extras = [];
      newCart.quantity = quantity;
      newCart.Couponid = coupon_id;
      addCart(newCart, false).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        ScaffoldMessenger.of(settingRepo.navigatorKey.currentState.context).showSnackBar(SnackBar(
          content: Text(S.of(state.context).this_food_was_added_to_cart),
        ));
      });
    }
    print("Carts length"+carts.length.toString());
    /* print(carts.length);
    // Check if the same food item is already in the cart
    int existingIndex = carts.indexWhere((cart) => cart.food.id == food.id);

    if (existingIndex != -1) {
      print("Food already in cart. Updating quantity.");
      // Update the quantity if the food item already exists in the cart
      carts[existingIndex].quantity += quantity;
      updateCart(carts[existingIndex]).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(S.of(state.context).this_food_was_added_to_cart),
        ));
      });
    } else {
      print("Food not in cart. Creating new cart item.");
      // Create a new cart item if the food doesn't exist in the cart
      var newCart = Cart();
      newCart.food = food;
      newCart.extras = [];
      newCart.quantity = quantity;

      addCart(newCart, false).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(S.of(state.context).this_food_was_added_to_cart),
        ));
      });
    }*/
  }

  Cart isExistInCart(Cart _cart) {
    return carts.firstWhere((Cart oldCart) => _cart.isSame(oldCart),
        orElse: () => null);
  }

  void addToFavorite(Food food) async {
    var _favorite = new Favorite();
    _favorite.food = food;
    _favorite.extras = food.extras.where((Extra _extra) {
      return _extra.checked;
    }).toList();
    addFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = value;
      });
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).thisFoodWasAddedToFavorite),
      ));
    });
  }

  void removeFromFavorite(Favorite _favorite) async {
    removeFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = new Favorite();
      });
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).thisFoodWasRemovedFromFavorites),
      ));
    });
  }

  Future<void> refreshFood() async {
    var _id = food.id;
    food = new Food();
    listenForFavorite(foodId: _id);
    listenForFood(
        foodId: _id, message: S.of(state.context).foodRefreshedSuccessfuly);
  }

  void calculateTotal() {
    total = food?.price ?? 0;
    food?.extras?.forEach((extra) {
      total += extra.checked ? extra.price : 0;
    });
    total *= quantity;
    setState(() {});
  }

  incrementQuantity() {
    if (this.quantity <= 99) {
      ++this.quantity;
      calculateTotal();
    }
  }

  decrementQuantity() {
    if (this.quantity > 0) {
      --this.quantity;
      calculateTotal();
    }
  }
}
