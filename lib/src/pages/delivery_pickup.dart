import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/pages/CardsCarouselWidgetHome.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/checkoutPage.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/pages.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:food_delivery_app/utils/color.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/homr_test.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/NotDeliverableAddressesItemWidget.dart';
import '../elements/PickUpMethodItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/address.dart' as addressRepo;
import '../models/payment_method.dart';
import '../models/route_argument.dart';

import '../repository/settings_repository.dart' as settingRepo;
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import 'package:http/http.dart' as http;

class DeliveryPickupWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  dynamic currentTab;
  Widget currentPage = HomePage();
  bool isCurrentKitchen = true;

 // final GlobalKey<ScaffoldState> parentScaffoldKey = new GlobalKey<ScaffoldState>();


  DeliveryPickupWidget({Key key, this.routeArgument, GlobalKey<ScaffoldState> parentScaffoldKey}) : super(key: key);

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {
  DeliveryPickupController _con;
  HomeController _homeCon;
  String param;
  String defaultLanguage;

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller;
    _homeCon = HomeController();
  }

  Map<String, dynamic> paymentIntent;

  @override
  void initState() {
    // TODO: implement initState
    getCurrentDefaultLanguage();
    _selectTab(widget.currentTab);
    setState(() {

    });
    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode){
      print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });

    });
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(DeliveryPickupWidget());
  }

  @override
  Widget build(BuildContext context) {


    if (_con.list == null) {
      _con.list = new PaymentMethodList(context);
    }
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: /*Text(
          S.of(context).delivery_or_pickup,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        )*/
        TranslationWidget(
          message:    S.of(context).delivery_or_pickup,
          fromLanguage: "English",
          toLanguage: defaultLanguage,
          builder: (translatedMessage) => Text(
            translatedMessage,
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        actions: <Widget>[
         // new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: widget.isCurrentKitchen ? SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  Icons.domain,
                  color: Theme.of(context).hintColor,
                ),
                title: /*Text(
                  S.of(context).pickup,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline4,
                )*/
                TranslationWidget(
                  message:  S.of(context).pickup,
                  fromLanguage: "English",
                  toLanguage: defaultLanguage,
                  builder: (translatedMessage) => Text(
                    translatedMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                subtitle: /*Text(
                  S.of(context).pickup_your_food_from_the_restaurant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                )*/
                TranslationWidget(
                  message: S.of(context).pickup_your_food_from_the_restaurant,
                  fromLanguage: "English",
                  toLanguage: defaultLanguage,
                  builder: (translatedMessage) => Text(
                    translatedMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
            ),
            PickUpMethodItem(
                paymentMethod: _con.getPickUpMethod(),
                onPressed: (paymentMethod) {
                  _con.togglePickUp();
                }),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.map,
                      color: Theme.of(context).hintColor,
                    ),
                    title: /*Text(
                      S.of(context).delivery,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4,
                    )*/

                    TranslationWidget(
                      message:  S.of(context).delivery,
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(
                        translatedMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    subtitle: _con.carts.isNotEmpty && Helper.canDelivery(_con.carts[0].food.restaurant, carts: _con.carts)
                        ? /*Text(
                            S.of(context).click_to_confirm_your_address_and_pay_or_long_press,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          )*/
                    TranslationWidget(
                      message:  S.of(context).click_to_confirm_your_address_and_pay_or_long_press,
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(
                        translatedMessage,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    )
                        : /*Text(
                            S.of(context).deliveryMethodNotAllowed,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          )*/
                    TranslationWidget(
                      message:  S.of(context).deliveryMethodNotAllowed,
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(
                        translatedMessage,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ),
                ),
                _con.carts.isNotEmpty && Helper.canDelivery(_con.carts[0].food.restaurant, carts: _con.carts)
                    ? DeliveryAddressesItemWidget(
                        paymentMethod: _con.getDeliveryMethod(),
                        address: _con.deliveryAddress,
                        onPressed: (addressRepo.Address _address) {
                          if (_con.deliveryAddress.id == null || _con.deliveryAddress.id == 'null') {
                            DeliveryAddressDialog(
                              context: context,
                              address: _address,
                              onChanged: (addressRepo.Address _address) {
                                _con.addAddress(_address);
                              },
                            );
                          } else {
                            _con.toggleDelivery();
                          }
                        },
                        onLongPress: (addressRepo.Address _address) {
                          DeliveryAddressDialog(
                            context: context,
                            address: _address,
                            onChanged: (addressRepo.Address _address) {
                              _con.updateAddress(_address);
                            },
                          );
                        },
                      )
                    : NotDeliverableAddressesItemWidget()
              ],
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                    ), ),
                  child: MaterialButton(
                    onPressed: () {
                      print('tap');
                      /// stripe integration
                     /* Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(),
                        ),
                      );*/

                      makePayment();
                    },
                    disabledColor:
                    Theme.of(context).focusColor.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    // color: !_con.carts[0].food.restaurant.closed
                    //     ? Theme.of(context).accentColor
                    //     : Theme.of(context).focusColor.withOpacity(0.5),
                    //shape: StadiumBorder(),
                    child: /*Text(
                      S.of(context).checkout,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyText1.merge(
                          TextStyle(
                              color: Theme.of(context).primaryColor)),
                    )*/
                    TranslationWidget(
                      message:    S.of(context).checkout,
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(
                        translatedMessage,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyText1.merge(
                            TextStyle(
                                color: Theme.of(context).primaryColor)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ) : widget.currentPage,
    );
  }

  Future<void> makePayment() async {
    try {
      //STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent('100', 'USD');


      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(

          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent[
              'client_secret'],
              //Gotten from payment intent
              style: ThemeMode.light,
              merchantDisplayName: 'Ikay',
              customFlow: true))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100.0,
                  ),
                  SizedBox(height: 10.0),
                  Text("Payment Successful!"),
                ],
              ),
            ));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }


  void _selectTab(int tabItem) {
   /* setState(() {
      print("DS>> am i here?? "+tabItem.toString());
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.isCurrentKitchen = false;
          widget.currentPage = SettingsWidget(); //ProfileWidget(parentScaffoldKey: widget.parentScaffoldKey);
          break;
        case 1:
          widget.isCurrentKitchen = false;
          widget.currentPage = KitchenList();
          break;
        case 2:
          widget.isCurrentKitchen = false;
          //widget.currentPage = HomeWidget(parentScaffoldKey: widget.parentScaffoldKey, currentTab: tabItem,);
          break;
        case 3:
          widget.isCurrentKitchen = false;
          widget.currentPage = DeliveryPickupWidget();
          break;
        case 4:
          widget.isCurrentKitchen = false;
          widget.currentPage = CartWidget(key: new GlobalKey()); //FavoritesWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });*/
    setState(() {
      print("DS>> am i here?? "+tabItem.toString());
      widget.currentTab = tabItem;
      switch (tabItem) {

        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SettingsWidget()
            ),
          );

          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CalendarDialogWithoutRestaurant()
            ),
          );
          break;
        case 2:

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(parentScaffoldKey: widget.routeArgument.parentScaffoldKey,
                  currentTab: tabItem, directedFrom: "forHome",)
            ),
          );
          break;
        case 3:

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => KitchenListDeliveryWidget(restaurantsList: _homeCon.AllRestaurantsDelivery,
                  heroTag: "KitchenListDelivery",)
            ),
          );
          break;
        case 4:

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartWidget(
                parentScaffoldKey: widget.routeArgument.parentScaffoldKey,
              ),
            ),
          );
          break;
      }
    });
  }
}
