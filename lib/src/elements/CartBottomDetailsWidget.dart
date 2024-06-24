import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/src/models/couponModel.dart';
import 'package:food_delivery_app/src/pages/CouponWidget.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:provider/provider.dart';
import '../../my_widget/delivery_adressess.dart';
import '../models/coupons.dart';
import '../models/user.dart';
import '../pages/Coupon.dart';
import '../provider.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';
import '../pages/delivery_pickup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../repository/settings_repository.dart' as settingRepo;
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:intl/intl.dart';
import '../../src/helpers/app_config.dart' as config;

class CartBottomDetailsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  const CartBottomDetailsWidget(
      {Key key, @required CartController con, this.parentScaffoldKey})
      : _con = con,
        super(key: key);

  final CartController _con;

  @override
  State<CartBottomDetailsWidget> createState() =>
      _CartBottomDetailsWidgetState();
}

class _CartBottomDetailsWidgetState extends State<CartBottomDetailsWidget> {
  Map<String, dynamic> paymentIntent = {};
  String defaultLanguage;
  String apiToken = "";
  TextEditingController _couponCodeController = TextEditingController();
  double coupondiscount = 0.0;
  int grandTotal = 0;
  String CouponText = "Apply";
  Coupon appliedCoupon;
  double appliedCouponamount = 0.0;
  bool IsMakePayment = false;
  Map selectedAddresses ;
  @override
  void initState() {
    getCurrentDefaultLanguage();
    apiToken = userRepo.currentUser.value.apiToken;
    print(apiToken);
    super.initState();
    if (widget._con.deliveryCharges > 0) {
      grandTotal = (widget._con.subTotal +
              widget._con.taxAmount +
              widget._con.deliveryCharges)
          .toInt();
    } else {
      grandTotal = (widget._con.subTotal + widget._con.taxAmount).toInt();
      widget._con.total = grandTotal.toDouble();
    }
    widget._con.total = grandTotal.toDouble();
    if(widget._con.coupon_code !=""){
      appliedCoupon = Coupon(
        code: widget._con.coupon_code,
      );
      print(" amt ===>${widget._con.coupon_amount}");
      appliedCouponamount = double.parse(widget._con.coupon_amount);
    }
    if(widget._con.delivery_address_id !=""){

      selectedAddresses ={"Address": widget._con.delivery_address_text, "id": widget._con.delivery_address_id};
    }

  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode) {
      // print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }
  Removecoupon() async{
    User _user = userRepo.currentUser.value;
    final response = await http.post(
        Uri.parse('https://eatathome.in/app/api/remove-coupon'),
        headers: {
          "Authorization": "Bearer ${_user.apiToken}"
        },

    );
    print(response.body);
    final Map jsondata = jsonDecode(response.body);
    if (jsondata["success"] == true) {

         //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Coupan applied ${discountAmount} ${coupon.discounttype}")));
   //   Navigator.pop(context, result);
      /* final List<dynamic> json = jsonDecode(response.body)['data'];
      return json.map((e) => Coupon.fromJson(e)).toList();*/
      // } else {
      //   throw Exception('Failed to load coupons');
    }

  }
  @override
  Widget build(BuildContext context) {
    return widget._con.carts.isEmpty
        ? SizedBox(height: 0)
        : Container(
            height: appliedCoupon == null ? selectedAddresses != null ? 245 : 220: 270,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.15),
                      offset: Offset(0, -2),
                      blurRadius: 5.0)
                ]),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 30,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: /*Text(
                            S.of(context).subtotal,
                            style: Theme.of(context).textTheme.bodyText1,
                          )*/
                              TranslationWidget(
                            message: S.of(context).subtotal,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ),
                        Helper.getPrice(widget._con.subTotal, context,
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: config.Colors().secondColor(1),
                                height: 1.35),
                            zeroPlaceholder: '0')
                      ],
                    ),
                    SizedBox(height: 3),

                    /*  Row(

                      children: [
                        IconButton(
                            icon: new Icon(Icons.card_giftcard, color: Theme.of(context).hintColor),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CouponWidget()
                              ),
                            )
                        ),
                        Container(
                          //height:MediaQuery.of(context).size.height/18,
                          width: MediaQuery.of(context).size.width*2/4.2,
                          child: TextField(
                            controller: _couponCodeController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Coupon Code',
                              labelStyle:  TextStyle(color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async{


                          print("DS>> "+_couponCodeController.text);
                            CouponModel coupon = await getCouponDetails(_couponCodeController.text,apiToken);

                            if (coupon != null) {
                              // Access the properties of the CouponModel object

                              int id = coupon.id;
                              String code = coupon.code;
                              int discount = coupon.discount;
                              String discountType = coupon.discountType;
                              String description = coupon.description;
                              DateTime expiresAt = coupon.expiresAt;
                              bool enabled = coupon.enabled;
                              String createdAt = coupon.createdAt;
                              String updatedAt = coupon.updatedAt;

                              // Use the coupon data as needed
                              print('Coupon ID: $id');
                              print('Coupon Code: $code');
                              print('Discount: $discount');
                              print('Description: $description');
                              print('Expires At: $expiresAt');
                              print('Enabled: $enabled');
                              // ...
                            } else {
                              print('No coupons found or API call failed.');
                            }
                            if(coupon.enabled){
                              setCouponDiscount(coupon.discount);
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Invalid or Disabled Coupon Code."),
                              ));
                            }


                          },
                          child: Text(CouponText, style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        Spacer(),
                        Text(coupondiscount.toString(), style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),*/
                    if(appliedCoupon!= null)
                    SizedBox(height: 5),
                     if(appliedCoupon!= null)
                     Row(
                            children: <Widget>[
                              Expanded(
                                child: /*Text(
                            '${S.of(context).tax} (${widget._con.carts[0].food.restaurant.defaultTax}%)',
                            style: Theme.of(context).textTheme.bodyText1,
                          )*/
                                    TranslationWidget(
                                  message: 'You have ${appliedCoupon.code} coupon Applied',
                                  fromLanguage: "English",
                                  toLanguage: defaultLanguage,
                                  builder: (translatedMessage) => Text(
                                    translatedMessage,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Removecoupon();
                                  setState(() {
                                    appliedCoupon = null;
                                    appliedCouponamount = 0.0;
                                  });
                                },
                                child: Container(
                                  width: 70,
                                  height: 30,

                                  child: Center(
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(
                                        color: kPrimaryColororange,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //Text(grandTotal.toString())
                            ],
                          ),

                    if (appliedCoupon != null)
                    SizedBox(height: 5),
                    if (appliedCoupon != null)
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: /*Text(
        S.of(context).delivery_fee,
        style: Theme.of(context).textTheme.bodyText1,
      )*/
                            TranslationWidget(
                              message: "Applied Coupon-",
                              fromLanguage: "English",
                              toLanguage: defaultLanguage,
                              builder: (translatedMessage) => RichText(
                                text: TextSpan(
                                  text: translatedMessage,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "(${appliedCoupon.code})", // Bold this part
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          //   if (widget._con.deliveryCharges >0)
                          RichText(
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            text: TextSpan(
                              text: "-₹",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                                color: kFBBlue,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: appliedCouponamount.toStringAsFixed(2) ?? '',
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: /*Text(
                            S.of(context).delivery_fee,
                            style: Theme.of(context).textTheme.bodyText1,
                          )*/
                              TranslationWidget(
                            message: "Delivery fees",
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ),
                        if (widget._con.deliveryCharges > 0)
                          Helper.getPrice(widget._con.deliveryCharges, context,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: config.Colors().secondColor(1),
                                  height: 1.35),
                              zeroPlaceholder: 'Free')
                        else
                          Helper.getPrice(0, context,
                              style: Theme.of(context).textTheme.subtitle1,
                              zeroPlaceholder: 'Free')
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: /*Text(
                            '${S.of(context).tax} (${widget._con.carts[0].food.restaurant.defaultTax}%)',
                            style: Theme.of(context).textTheme.bodyText1,
                          )*/
                              TranslationWidget(
                            message:
                                'GST',
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ),
                        Helper.getPrice(
                            (widget._con.subTotal *
                                widget
                                    ._con.carts[0].food.restaurant.defaultTax /
                                100),
                            context,
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: config.Colors().secondColor(1),
                                height: 1.35))

                        //Text(grandTotal.toString())
                      ],
                    ),
                    // SizedBox(height: 5),
                    // Row(
                    //   children: <Widget>[
                    //     Expanded(
                    //       child: /*Text(
                    //         '${S.of(context).tax} (${widget._con.carts[0].food.restaurant.defaultTax}%)',
                    //         style: Theme.of(context).textTheme.bodyText1,
                    //       )*/
                    //       TranslationWidget(
                    //         message: 'GST (5%)',
                    //         fromLanguage: "English",
                    //         toLanguage: defaultLanguage,
                    //         builder: (translatedMessage) => Text(
                    //           translatedMessage,
                    //           style: Theme.of(context).textTheme.bodyText1,
                    //         ),
                    //       ),
                    //     ),
                    //     Helper.getPrice( (widget._con.subTotal * 5 /100), context,
                    //         style: Theme.of(context).textTheme.subtitle1)
                    //
                    //     //Text(grandTotal.toString())
                    //   ],
                    // ),

                    Divider(thickness: 3,),
                    if(selectedAddresses == null)
                    InkWell(
                      onTap: ()async{
                        final selectedAddress = await
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Delivery_address_seelction()));
                        print(selectedAddress);
                        if (selectedAddress != null) {
                          setState(() {
                            widget._con.refreshCartsaddress();
                            selectedAddresses = selectedAddress;
                            // Update the state with the selected address
                            // For example, you could store it in a variable and display it in the UI
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add), SizedBox(width: 10),
                          Text("Add Delivery Address", style: TextStyle(
                           // color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ))
                        ],
                      ),
                    ),
                    if(selectedAddresses != null)
                     ListTile(
                       contentPadding: EdgeInsets.zero,
                       title: Text("Delivers To ${selectedAddresses["Address"]}",),
                       trailing: InkWell(
                           onTap: ()async{
                             final selectedAddress = await
                             Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Delivery_address_seelction()));
                             print(selectedAddress);
                             if (selectedAddress != null) {
                               setState(() {
                                 widget._con.refreshCartsaddress();
                                 selectedAddresses = selectedAddress;
                                 // Update the state with the selected address
                                 // For example, you could store it in a variable and display it in the UI
                               });
                             }
                           },
                           child: Text("Change", style: TextStyle(
                             color: Colors.red,
                             fontSize: 15,
                             fontWeight: FontWeight.w500,
                           ),)),
                     ),
                       SizedBox(height: 10),
                    Stack(
                      fit: StackFit.loose,
                      alignment: AlignmentDirectional.centerEnd,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [
                                  kPrimaryColororange,
                                  kPrimaryColorLiteorange
                                ],
                              ),
                            ),
                            child: MaterialButton(
                              onPressed: () {

                                if(selectedAddresses!= null){
                                  if (IsMakePayment == false) {
                                    makePayment(
                                        ( (grandTotal.toDouble() +
                                            (widget._con.subTotal *
                                                widget._con.carts[0].food
                                                    .restaurant.defaultTax /
                                                100)- appliedCouponamount) )
                                            .toInt()
                                            .toString(),
                                        context);
                                    setState(() {
                                      IsMakePayment = true;
                                    });
                                  }
                                }
                                else {
                                  Fluttertoast.showToast(msg: "please add delivery address");
                                }

                                //placeOrder(context);
                                /*Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>  DeliveryPickupWidget(parentScaffoldKey:  new GlobalKey())
                                  ),
                                );*/
                              },
                              disabledColor:
                                  Theme.of(context).focusColor.withOpacity(0.5),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: Align(
                                alignment:
                                    Alignment.centerLeft, // Align the text left

                                child: /*Text(
                                  S.of(context).checkout,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.headline4.merge(
                                      TextStyle(
                                          color: Theme.of(context).primaryColor)),
                                )*/
                                    TranslationWidget(
                                  message:"Place Order",
                                  fromLanguage: "English",
                                  toLanguage: defaultLanguage,
                                  builder: (translatedMessage) => Text(
                                    translatedMessage,
                                    textAlign: TextAlign.left,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .merge(TextStyle(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Helper.getPrice(
                              (widget._con.subTotal +
                                  (widget._con.deliveryCharges == -1
                                      ? 0
                                      : widget._con.deliveryCharges) +
                                  (widget._con.subTotal *
                                      widget._con.carts[0].food.restaurant
                                          .defaultTax /
                                      100))- appliedCouponamount,
                              context,
                              style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                      color: config.Colors().secondColor(1),
                                      height: 1.35)
                                  .merge(TextStyle(
                                      color: Theme.of(context).primaryColor)),
                              zeroPlaceholder: 'Free'),
                        )
                      ],
                    ),

                  ],
                ),
              ),
            ),
          );
  }

  setCouponDiscount(int discount) {
    setState(() {
      coupondiscount =
          widget._con.subTotal - widget._con.subTotal * (discount / 100);
      grandTotal = (widget._con.taxAmount + coupondiscount).toInt();
      widget._con.total = grandTotal.toDouble();
      CouponText = "Remove";
    });
  }

  Future<CouponModel> getCouponDetails(String id, String apiToken) async {
    final url = Uri.parse(
        'https://eatathome.in/app/api/coupons/$id'); // Replace with your API endpoint
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $apiToken',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('data')) {
        final Map<String, dynamic> couponData = data['data'];

        if (couponData != null) {
          final CouponModel coupon = CouponModel.fromJson(couponData);
          return coupon;
        }
      }
    } else if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Coupon not found"),
      ));
    }
  }

  Future<void> makePayment(String totalamount, BuildContext context) async {
    try {
      print(totalamount);
      paymentIntent = await createPaymentIntent(totalamount, 'AED');
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          googlePay: const stripe.PaymentSheetGooglePay(
              testEnv: true, currencyCode: "AED", merchantCountryCode: "+971"),
          style: ThemeMode.dark,
          merchantDisplayName: 'Abc',
        ),
      );
      displayPaymentSheet(context);
    } catch (e) {
      if (kDebugMode) {
        print("exception $e");
      }
    }
  }

  displayPaymentSheet(BuildContext context) async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  Text("Payment Successful"),
                ],
              ),
            ],
          ),
        ),
      );
      String transactionId = paymentIntent['id'];
      print('Transaction ID: $transactionId');
      placeOrder(context, transactionId);

      //   Navigator.push(context,MaterialPageRoute(builder: (context)=>OrderSuccessWidget()));
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );*/
      paymentIntent = null;
    } on stripe.StripeException catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Cancelled"),
        ),
      );
      setState(() {
        IsMakePayment = false;
      });
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var SECRET_KEY =
          "sk_test_51O9PqlI87pCKWFaiXf6fgVOF9aRH5uxkNKZNnHHu1yeVHNvyaoklsepeyHZZU3kMOaRC0FK3XEpoUDUEASrBBwlE00uNZDuszp";
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $SECRET_KEY',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print('Payment Intent Body: ${response.body.toString()}');
      return jsonDecode(response.body.toString());
    } catch (err) {
      print('Error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }

  Future<void> placeOrder(BuildContext context, String transaction_id) async {
    String sltdDate = "";
    DateTime datetime = DateTime.now();
    sltdDate = DateFormat('yyyy-MM-dd').format(datetime);
    final url = Uri.parse("https://eatathome.in/app/api/orders");
    final String baseUri = 'https://eatathome.in/app/api/orders';
    final headers = {
      'Authorization': 'Bearer ${currentUser.value.apiToken}',
      'Content-Type': 'application/json',
    };
    print("DS>> food display " +
        widget._con.carts.length.toString() +
        " " +
        widget._con.carts[0].food.price.toString());
    final foods = <Map<String, dynamic>>[];
    for (int i = 0; i < widget._con.carts.length; i++) {
      final food = {
        'price': '${widget._con.carts[i].food.price.toString()}',
        'quantity': '${widget._con.carts[i].quantity.toString()}',
        'food_id': '${widget._con.carts[i].food.id.toString()}',
        'order_date': sltdDate,
      };
      // Add more items as needed
      foods.add(food); // Add elements to the array
      print('Added food: $food');
    }
    //print('foods: ${json.encode(foods)}');

    final payload = {
      'payment': {
        'method': 'Credit Card (Stripe Gateway)',
      },
      'user_id': '${currentUser.value.id}',
      'order_status_id': 1,
      'tax': widget._con.carts[0].food.restaurant.defaultTax,
      'delivery_address_id': null,
      'coupon_id':'${appliedCoupon!= null ? appliedCoupon.code : ""}',
      'delivery_fee':
          widget._con.deliveryCharges > 0 ? widget._con.deliveryCharges : 0.0,
      'hint': null,
      'foods': foods,
      'restaurant_id': widget._con.carts.first.food.restaurant.id,
      'delivery_dinein': 1,
      "delivery_address_id":selectedAddresses["id"],
      'payment_id': transaction_id
    };
    /*  final payload = {
      'payment': {
        'method': 'Credit Card (Stripe Gateway)',
      },
      'user_id': '${currentUser.value.id}',
      'order_status_id': 1,
      'tax': 5.00,
      'delivery_address_id': null,
      'delivery_fee': 0.00,
      'hint': null,
      'foods': foods,
       'delivery_dinein' : 1,
      "payment_id":transaction_id
    };*/
    print(payload);
    final String payloadJson = json.encode(payload);
    final Uri finalUri =
        Uri.parse(baseUri).replace(queryParameters: {'payload': payloadJson});

    print("DS>> Re " + finalUri.toString());

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      // Request successful, handle the response
      print('API response: ${response.body}');
      await Provider.of<CartProvider>(
              settingRepo.navigatorKey.currentState.context,
              listen: false)
          .clear_cart();
      Navigator.of(context).pushReplacementNamed('/OrderSuccess');
      //  widget._con.goCheckout(context);
    } else {
      // Request failed, handle the error
      print(
          'API request failed with status code: ${response.statusCode} ${response.body.toString()}');
    }
  }
}
class AppliedCouponResult {
  final Coupon coupon;
  final double discountAmount;

  AppliedCouponResult(this.coupon, this.discountAmount);
}