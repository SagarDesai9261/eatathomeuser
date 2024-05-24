import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../repository/cart_repository.dart';
import '../repository/coupon_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  double deliveryCharges = 0.0;
  bool isloading = false;
  String coupon_code  = "" ;
  String coupon_amount  = "" ;
  String delivery_address_text = "";
  String delivery_address_id = "";
  GlobalKey<ScaffoldState> scaffoldKey;

  CartController() {

    this.scaffoldKey = new GlobalKey<ScaffoldState>();

  }

 /* void listenForCarts({String message}) async {
    carts.clear();
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      // Check if the same food item is already in the list
      Cart existingCart = carts.firstWhere(
            (cart) => cart.food.id == _cart.food.id,
        orElse: () => null,
      );

      if (existingCart != null) {
        // Update the quantity if the food item already exists
        setState(() {
          existingCart.quantity += _cart.quantity;
          coupon = existingCart.food.applyCoupon(coupon);
        });
        print(existingCart.quantity);
      } else {
        // Add the new food item to the list
        setState(() {
          coupon = _cart.food.applyCoupon(coupon);
          carts.add(_cart);
        });
      }
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
      }
      if (message != null) {
        // Handle the message
      }
      onLoadingCartDone();
    });
  }*/
  void listenForCarts({String message}) async {
    isloading = true;
    carts.clear();
    final Map<String, dynamic> data = await getCart();

    // Check if the API call was successful
    if (data['success'] == true) {
      List<dynamic> items = data['data']['items'];
      double deliveryCharge =  data['data']['delivery_charge'].toDouble();
      String counpon_cd =   data['data']['coupon']["coupon_code"];
      double counpon_amt =   data['data']['coupon']["coupon_amount"];
      // Process the cart items
      if (items.isNotEmpty) {
        items.forEach((item) {
          Cart _cart = Cart.fromJSON(item);

          // Check if the same food item is already in the list
          Cart existingCart = carts.firstWhere(
                (cart) => cart.food.id == _cart.food.id,
            orElse: () => null,
          );

          if (existingCart != null) {
            // Update the quantity if the food item already exists
            setState(() {
              existingCart.quantity += _cart.quantity;
              coupon = existingCart.food.applyCoupon(coupon);
            });
          //  print(existingCart.quantity);
          } else {
            // Add the new food item to the list
            setState(() {
              coupon = _cart.food.applyCoupon(coupon);

              carts.add(_cart);
            });
          }
        });
      }
      setState(() {
        deliveryCharges = deliveryCharge;
        coupon_code = counpon_cd;
        coupon_amount = counpon_amt.toString() ;
        print("coupon ampo:-${coupon_amount}");
      });
      calculateSubtotal();
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        isloading = false;
      });

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

  void listenForCartsaddress({String message}) async {
    isloading = true;
    carts.clear();
    final Map<String, dynamic> data = await getcartfromAddress();

    // Check if the API call was successful
    if (data['success'] == true) {
      List<dynamic> items = data['data']['items'];
      double deliveryCharge =  data['data']['delivery_charge'].toDouble();
      String counpon_cd =   data['data']['coupon']["coupon_code"];
      String delivery_address =   data['data']['delivery_address_text'];
      String deliveryaddressid =   data['data']['delivery_address_id'];
      double counpon_amt =   data['data']['coupon']["coupon_amount"];
      // Process the cart items
      if (items.isNotEmpty) {
        items.forEach((item) {
          Cart _cart = Cart.fromJSON(item);

          // Check if the same food item is already in the list
          Cart existingCart = carts.firstWhere(
                (cart) => cart.food.id == _cart.food.id,
            orElse: () => null,
          );

          if (existingCart != null) {
            // Update the quantity if the food item already exists
            setState(() {
              existingCart.quantity += _cart.quantity;
              coupon = existingCart.food.applyCoupon(coupon);
            });
            //  print(existingCart.quantity);
          } else {
            // Add the new food item to the list
            setState(() {
              coupon = _cart.food.applyCoupon(coupon);

              carts.add(_cart);
            });
          }
        });
      }
      setState(() {
        deliveryCharges = deliveryCharge;
        coupon_code = counpon_cd;
        coupon_amount = counpon_amt.toString() ;
        delivery_address_text = delivery_address;
        delivery_address_id = deliveryaddressid;
        print("coupon ampo:-${coupon_amount}");
      });
      calculateSubtotal();
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        isloading = false;
      });

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

  void onLoadingCartDone() {}

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
  //    print(a);
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    });
  }

  Future<void> refreshCarts() async {
    setState(() {
      carts = [];
      delivery_address_id = "";
      delivery_address_text = "";
      carts.clear();
    });

    listenForCarts();
  }
  Future<void> refreshCartsaddress() async {
    setState(() {
      carts = [];
      carts.clear();
    });

    listenForCartsaddress();
  }
  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    removeCart(_cart).then((value) {
      calculateSubtotal();
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).the_food_was_removed_from_your_cart(_cart.food.name)),
      ));
    });
  }

  void calculateSubtotal() async {
    double cartPrice = 0;
    subTotal = 0;
    carts.forEach((cart) {
      cartPrice = cart.food.price;
      cart.extras.forEach((element) {
        cartPrice += element.price;
      });
      cartPrice *= cart.quantity;
      subTotal += cartPrice;
    });
   /* if (Helper.canDelivery(carts[0].food.restaurant, carts: carts)) {
      deliveryFee = carts[0].food.restaurant.deliveryFee;
    }*/
    //taxAmount = (subTotal) * carts[0].food.restaurant.defaultTax / 100;

    if(deliveryCharges > 0){
      total = subTotal + taxAmount  +deliveryCharges;
     // print(total);
      //setState(() {});
    }
    else{
      total = subTotal + taxAmount;
    }

    setState(() {});
  }

  void doApplyCoupon(String code, {String message}) async {
    coupon = new Coupon.fromJSON({"code": code, "valid": null});
    final Stream<Coupon> stream = await verifyCoupon(code);
    stream.listen((Coupon _coupon) async {
      coupon = _coupon;
    }, onError: (a) {
    // print(a);
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForCarts();
//      saveCoupon(currentCoupon).then((value) => {
//          });
    });
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity <= 99) {
      ++cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  void goCheckout(BuildContext context) {
    if (!currentUser.value.profileCompleted()) {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(context).completeYourProfileDetailsToContinue),
        action: SnackBarAction(
          label: S.of(context).settings,
          textColor: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.of(context).pushNamed('/Settings');
          },
        ),
      ));
    } else {
      if (carts[0].food.restaurant.closed == "") {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(S.of(context).this_restaurant_is_closed_),
        ));
      } else {
        Navigator.of(context).pushNamed('/DeliveryPickup');
      }
    }
  }

  Color getCouponIconColor() {
 //   print(coupon.toMap());
    if (coupon?.valid == true) {
      return Colors.white;
    } else if (coupon?.valid == false) {
      return Colors.redAccent;
    }
    return Theme.of(state.context).focusColor.withOpacity(0.7);
  }
}
