import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/generated/l10n.dart';
import 'package:food_delivery_app/my_widget/calander_widget.dart';
// import 'package:food_delivery_app/my_widget/people_count_dailog.dart';
import 'package:food_delivery_app/src/controllers/cart_controller.dart';
import 'package:food_delivery_app/src/models/cart.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/delivery_pickup.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/map.dart';
import 'package:food_delivery_app/src/pages/pages.dart';
import 'package:food_delivery_app/src/pages/profile.dart';
import 'package:food_delivery_app/src/pages/restaurant.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:food_delivery_app/utils/color.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../my_widget/Change_people_count_dialog.dart';
import '../../my_widget/change_date_calender.dart';
import '../../my_widget/people_count_dailog.dart';
import '../controllers/homr_test.dart';
import '../helpers/helper.dart';
import '../models/coupons.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../models/food.dart';
import '../models/restaurant.dart';
import '../repository/translation_widget.dart';
import 'Coupon.dart';
import 'checkoutPage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'order_success.dart';

class DineInSummaryPage extends StatefulWidget {

  Restaurant restaurant;
  String selectedDate, selectedPeople, selectedTime, fromTime, toTime;
  List<Food> selectedFoodList;
  String default_tax;
  Coupon? selectedCoupon;
  List<Map<String,dynamic>>  fooditems;
  final GlobalKey<ScaffoldState> parentScaffoldKey =
      new GlobalKey<ScaffoldState>();
  dynamic currentTab;
  Widget currentPage = HomePage();
  bool isCurrentKitchen = true;
  int total;
  List<ProductItem> products;

  List<Cart> carts = <Cart>[];
  DineInSummaryPage(
      this.total,
      this.restaurant,
      this.selectedPeople,
      this.selectedDate,
      this.selectedTime,
      this.fromTime,
      this.toTime,
      this.selectedFoodList,
      this.default_tax,
      this.products,this.fooditems,this.selectedCoupon
      );



  @override
  _DineInSummaryPageState createState() {
    return _DineInSummaryPageState();
  }
}

class _DineInSummaryPageState extends StateMVC<DineInSummaryPage> {
  CartController _cartCon = CartController();
  Map<String, dynamic> paymentIntent = {};
  //_con = RestaurantController();
  //_cartCon = CartController();
  String defaultLanguage = "";
  double taxAmount = 0.0;
  bool IsMakePayment = false;
  int grandtotal = 0;
  Coupon? appliedCoupon;
  double? appliedCouponamount = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    // widget._cartCon.listenForCarts();
    Future.delayed(Duration(seconds: 4), () {
      _initializeData();
    });
   // _selectTab(widget.currentTab);
    calculateSubtotal();
    appliedCoupon = widget.selectedCoupon;
    super.initState();
  }

  Future<void> _initializeData() async {
    setState(() {
      widget.carts = _cartCon.carts;
    });

    print("DS>> cart length: ${widget.selectedFoodList.length}");
  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode) {
      print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    String date = "";
    DateTime datetime = DateTime.parse(widget.selectedDate.toString());
    date = DateFormat('dd MMM').format(datetime);
    print(date); // Output: 2023-06-21
    print(widget.fooditems);
    print("defalut tax:-  ${widget.default_tax}");
    print(widget.selectedFoodList[0].name);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).hintColor,
        ),
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.9),
        centerTitle: true,
        title: Text(
          "Dine-In(Confirm)",
          style: Theme.of(context)
              .textTheme
              .headline6
              !.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: widget.isCurrentKitchen
          ? Container(
              color: Colors.white.withOpacity(0.9),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(
                          context); // Close the screen when tapped outside the card
                    },
                    child: Container(
                      color: Colors.white.withOpacity(0.9),
                      //height: MediaQuery.of(context).size.height*2/3,// Semi-transparent background
                    ),
                  ),
                  Center(
                    child: Card(
                      // Replace Card with your desired widget
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width *0.90,
                        height: (MediaQuery.of(context).size.height * 3.5 / 4)-10,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/img/dine_in.svg',
                                    width: 30,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    'Dine-In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: CustomScrollView(
                                  primary: true,
                                  shrinkWrap: false,
                                  slivers: <Widget>[
                                    SliverAppBar(
                                      backgroundColor: kPrimaryColorLiteorange
                                          .withOpacity(0.9),
                                      expandedHeight: 150,
                                      elevation: 0,
//                          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                                      automaticallyImplyLeading: false,
                                      flexibleSpace: FlexibleSpaceBar(
                                        collapseMode: CollapseMode.parallax,
                                        background: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          height: 400,
                                          imageUrl: widget.restaurant.image!.url,
                                          placeholder: (context, url) =>
                                              Image.asset(
                                            'assets/img/loading.gif',
                                            fit: BoxFit.cover,
                                            height: 200,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    SliverToBoxAdapter(
                                      child: Wrap(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 10,
                                                top: 5),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  widget.restaurant?.name ?? '',
                                                  overflow: TextOverflow.fade,
                                                  softWrap: false,
                                                  maxLines: 2,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline3,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 10,
                                                top: 0),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 150,
                                                  child: Text(
                                                    widget.restaurant?.address ?? '',
                                                    overflow: TextOverflow.fade,
                                                    softWrap: true, // Allow wrapping to multiple lines
                                                    maxLines: 4, // Limit to 2 lines
                                                    style: TextStyle(fontSize: 15),
                                                  ),
                                                ),
                                                Spacer(),
                                                Text("View Map",
                                                    overflow: TextOverflow.fade,
                                                    softWrap: false,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 10)),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Container(
                                                  margin: EdgeInsets.all(0),
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          kPrimaryColororange,
                                                          kPrimaryColorLiteorange
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100)),
                                                  child:
                                                      // Image.asset("assets/img/")
                                                      GestureDetector(
                                                    onTap: ()async {
                                                      print("map calling");
                                                     // if(_con != null){
                                                        http://maps.google.com/maps?daddr=${_con.restaurant.latitude},${_con.restaurant.longitude}
                                                        String url = 'http://maps.google.com/maps?daddr=${widget.restaurant.latitude},${widget.restaurant.longitude}';
                                                        if (await canLaunchUrl(Uri.parse(url))) {
                                                      await launch(url);
                                                      } else {
                                                      throw 'Could not launch $url';
                                                      }
                                                    //}
                                                     /* MapWidget(
                                                          parentScaffoldKey: widget
                                                              .parentScaffoldKey,
                                                          routeArgument:
                                                              RouteArgument(
                                                                  param: widget
                                                                      .restaurant));*/
                                                    },
                                                    child: Icon(
                                                      Icons.turn_right_sharp,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 10,
                                                top: 0),
                                            child: Row(
                                              children: [
                                                Text("Food Items",
                                                    overflow: TextOverflow.fade,
                                                    softWrap: false,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children:  widget.fooditems.map((foodItem) {
                                              Food food = foodItem['food'];
                                              double quantity = foodItem['Quantity'];

                                             return Padding(
                                               padding:EdgeInsets.symmetric(horizontal: 20),
                                               child: Row(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: [

                                                   SizedBox(width: 8.0),
                                                   Expanded(
                                                     child: Column(
                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                       children: [
                                                         Text(
                                                           food.name,
                                                           style: TextStyle(
                                                             fontSize: 14.0,
                                                             fontWeight: FontWeight.normal,
                                                           ),
                                                         ),
                                                         Text(
                                                           '₹${food.price.toStringAsFixed(2)}',
                                                           style: TextStyle(
                                                             color: Colors.grey,
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                   ),
                                                   Text(
                                                     'x ${quantity.toInt()}',
                                                     style: TextStyle(
                                                       fontSize: 16.0,
                                                       fontWeight: FontWeight.normal,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                             );
                                            }).toList(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 10,
                                                top: 0),
                                            child: Row(
                                              children: [
                                                Text("Date",
                                                    overflow: TextOverflow.fade,
                                                    softWrap: false,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                                Spacer(),
                                                GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Change_calender(widget.total,widget.restaurant,widget.selectedPeople,widget.selectedDate,widget.selectedTime,widget.fromTime,widget.toTime,widget.selectedFoodList,widget.default_tax,widget.fooditems,widget.selectedCoupon)
                                                ),
                                              );
                                                     /* showCalendarDialog(
                                                          context,
                                                          widget.restaurant.id,
                                                          false);*/
                                                    },
                                                    child: Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Colors.grey,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 0,
                                                top: 0),
                                            child: Container(
                                              width: 250,
                                              child: Text(date ?? '',
                                                  overflow: TextOverflow.fade,
                                                  softWrap: false,
                                                  maxLines: 2,
                                                  style:
                                                      TextStyle(fontSize: 15)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 5,
                                                top: 0),
                                            child: Container(
                                              width: (MediaQuery.of(context).size.width * 0.90 )-40,
                                              child: Divider(
                                                color: Colors.grey,
                                                thickness: 1,
                                                height: 20,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 10,
                                                top: 0),
                                            child: Container(
                                              width: 250,
                                              child: Text("Session",
                                                  overflow: TextOverflow.fade,
                                                  softWrap: false,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 0,
                                                top: 0),
                                            child: Container(
                                              width: 250,
                                              child: Text(
                                                  widget.selectedTime ??
                                                      '',
                                                  overflow: TextOverflow.fade,
                                                  softWrap: false,
                                                  maxLines: 2,
                                                  style:
                                                      TextStyle(fontSize: 15)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 5,
                                                top: 0),
                                            child: Container(
                                              width: (MediaQuery.of(context).size.width * 0.90 )-40,
                                              child: Divider(
                                                color: Colors.grey,
                                                thickness: 1,
                                                height: 20,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 10,
                                                top: 0),
                                            child: Row(
                                              children: [
                                                Text("Number of Pax",
                                                    overflow: TextOverflow.fade,
                                                    softWrap: false,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                                Spacer(),
                                                GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => Change_people_count(widget.total,widget.restaurant,widget.selectedPeople,widget.selectedDate,widget.selectedTime,widget.fromTime,widget.toTime,widget.selectedFoodList,widget.default_tax,widget.products,widget.fooditems,widget.selectedCoupon)
                                                        ),
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Colors.grey,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 0,
                                                top: 0),
                                            child: Container(
                                              width: 250,
                                              child: Text(
                                                  widget.selectedPeople ?? '',
                                                  overflow: TextOverflow.fade,
                                                  softWrap: false,
                                                  maxLines: 2,
                                                  style:
                                                      TextStyle(fontSize: 15)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 5,
                                                top: 0),
                                            child: Container(
                                              width: (MediaQuery.of(context).size.width * 0.90 )-40,
                                              child: Divider(
                                                color: Colors.grey,
                                                thickness: 1,
                                                height: 20,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            // padding: const EdgeInsets.all(8.0),
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                bottom: 0,
                                                top: 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TranslationWidget(
                                                  message:
                                                      S.of(context).subtotal,
                                                  fromLanguage: "English",
                                                  toLanguage: defaultLanguage,
                                                  builder:
                                                      (translatedMessage) =>
                                                          Text(
                                                    translatedMessage,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                      text: "₹",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Theme.of(context).hintColor,
                                                        fontSize: 15,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: widget.total.toDouble().toString(),
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          if(widget.selectedCoupon!= null && appliedCouponamount! > 0.0)
                                          appliedCoupon != null
                                              ? Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20, left: 20, bottom: 0, top: 0),
                                                child: Row(
                                            children: <Widget>[
                                                Expanded(
                                                  child: /*Text(
                            '${S.of(context).tax} (${widget._con.carts[0].food.restaurant.defaultTax}%)',
                            style: Theme.of(context).textTheme.bodyText1,
                          )*/
                                                  TranslationWidget(
                                                    message: 'You have ${appliedCoupon!.code} coupon Applied',
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
                                                   // Removecoupon();
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
                                              )
                                              : Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20, left: 20, bottom: 0, top: 0),
                                                child: Row(
                                            children: <Widget>[
                                                Expanded(
                                                  child: /*Text(
                            '${S.of(context).tax} (${widget._con.carts[0].food.restaurant.defaultTax}%)',
                            style: Theme.of(context).textTheme.bodyText1,
                          )*/
                                                  TranslationWidget(
                                                    message: 'You have a coupon',
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
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => CouponsPage(
                                                              dine_in: true,
                                                              totalprice:
                                                              widget.total.toDouble(),
                                                              res_id: widget.restaurant.id,
                                                              onCouponApplied: (coupon,) {
                                                                setState(() {
                                                                  appliedCoupon = coupon.coupon;
                                                                  appliedCouponamount = coupon.discountAmount;

                                                                });
                                                              },
                                                            )));
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                      'Apply',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                //Text(grandTotal.toString())
                                            ],
                                          ),
                                              ),
                                          SizedBox(height: 5),
                                          if (appliedCoupon != null && widget.selectedCoupon != null && appliedCouponamount! > 0.0)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20, left: 20, bottom: 0, top: 0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: /*Text(
                            S.of(context).delivery_fee,
                            style: Theme.of(context).textTheme.bodyText1,
                          )*/
                                                    TranslationWidget(
                                                      message:
                                                      "Restaurant Coupon-(${appliedCoupon!.code})",
                                                      fromLanguage: "English",
                                                      toLanguage: defaultLanguage,
                                                      builder: (translatedMessage) => Text(
                                                        translatedMessage,
                                                        style: Theme.of(context).textTheme.bodyText1,
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
                                                        style:
                                                        TextStyle(fontWeight: FontWeight.w400, fontSize: Theme.of(context).textTheme.subtitle1!.fontSize,color: kFBBlue),


                                                        children: <TextSpan>[
                                                          TextSpan(text: appliedCouponamount!.toStringAsFixed(2) ?? '', style:  Theme.of(context).textTheme.subtitle1),
                                                        ],
                                                      )


                                                  )
                                                ],
                                              ),
                                            ),
                                         /* SizedBox(height: 5),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 30, left: 20, bottom: 0, top: 0),
                                           // padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: TranslationWidget(
                                                    message: "Shipping & Tax",
                                                    fromLanguage: "English",
                                                    toLanguage: defaultLanguage,
                                                    builder:
                                                        (translatedMessage) =>
                                                            Text(
                                                      translatedMessage,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    ),
                                                  ),
                                                ),
                                                Helper.getPrice(0, context,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle1,
                                                    zeroPlaceholder: 'Free')
                                              ],
                                            ),
                                          ),*/
                                          SizedBox(height: 5),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20, left: 20, bottom: 0, top: 0),
                                        //    padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: /*Text(
                          '${S.of(context).tax} (${widget._con.carts[0].food.restaurant.defaultTax}%)',
                          style: Theme.of(context).textTheme.bodyText1,
                        )*/
                                                  TranslationWidget(
                                                    message: 'GST',
                                                    fromLanguage: "English",
                                                    toLanguage: defaultLanguage,
                                                    builder: (translatedMessage) => Text(
                                                      translatedMessage,
                                                      style: Theme.of(context).textTheme.bodyText1,
                                                    ),
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                      text: "₹",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Theme.of(context).hintColor,
                                                        fontSize: 15,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text:  (taxAmount).toString(),
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ]),
                                                ),

                                                //Text(grandTotal.toString())
                                              ],
                                            ),
                                          ),

                                          SizedBox(height: 5),
                                         /* Padding(
                                            padding: const EdgeInsets.only(
                                                right: 30, left: 20, bottom: 0, top: 0),
                                            //    padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: *//*Text(
                          '${S.of(context).tax} (${widget._con.carts[0].food.restaurant.defaultTax}%)',
                          style: Theme.of(context).textTheme.bodyText1,
                        )*//*
                                                  TranslationWidget(
                                                    message: 'GST (5%)',
                                                    fromLanguage: "English",
                                                    toLanguage: defaultLanguage,
                                                    builder: (translatedMessage) => Text(
                                                      translatedMessage,
                                                      style: Theme.of(context).textTheme.bodyText1,
                                                    ),
                                                  ),
                                                ),
                                                Helper.getPrice((widget.total * 5 /100), context,
                                                    style: Theme.of(context).textTheme.subtitle1)

                                                //Text(grandTotal.toString())
                                              ],
                                            ),
                                          ),*/
                                        ],
                                      ),
                                    )
                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 2),
                              child: Row(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                        text: "₹",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).hintColor,
                                          fontSize: 25,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:  (grandtotal-appliedCouponamount!).toString(),
                                            style: TextStyle(
                                              fontSize: 25,
                                            ),
                                          ),
                                        ]),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: EdgeInsets.only(right: 0, top: 0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          gradient: LinearGradient(
                                            colors: [
                                              kPrimaryColororange,
                                              kPrimaryColorLiteorange
                                            ],
                                          ),
                                        ),
                                        child: MaterialButton(
                                          elevation: 0,
                                          focusElevation: 0,
                                          highlightElevation: 0,
                                          onPressed: () async{
                                            //addtocart
                                         //     placeOrder(context);
                                            if(currentUser.value.is_verified == "1"){
                                              if(IsMakePayment == false){
                                                makePayment((grandtotal-appliedCouponamount!).toInt().toString(),
                                                    context);
                                                setState(() {
                                                  IsMakePayment = true;
                                                });
                                              }
                                            }
                                            else {
                                              _showVerificationDialog(context);
                                             // Fluttertoast.showToast(msg: "Please verified your profile");
                                            }


                                            /////////////
                                            /* Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CartWidget(parentScaffoldKey: widget.parentScaffoldKey)
                                        ),
                                      );*/
                                          },
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 35, vertical: 8),
                                          shape: StadiumBorder(),
                                          //color: Theme.of(context).accentColor,
                                          child: Wrap(
                                            spacing: 10,
                                            children: [
                                              Text(
                                                "Book Now",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 16),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : widget.currentPage,
     /* bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.grey,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: 28,
        elevation: 0,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.grey[100],
        //selectedIconTheme: IconThemeData(size: 28),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        //   unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
        currentIndex: 1,
        onTap: (int i) {
          this._selectTab(i);
        },
        // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          *//* BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/img/dinein.svg',color: Colors.grey,height: 17,),
              label: '',
            ),*//*
          BottomNavigationBarItem(
              label: '',
              icon: new SvgPicture.asset(
                'assets/img/home.svg',
                height: 80,
              )),
          *//* BottomNavigationBarItem(
              icon: new SvgPicture.asset('assets/img/delivery.svg',color: Colors.grey,height: 17,),
              label: '',
            ),*//*
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Carts',
          ),
        ],
      ),*/
    );
  }
  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Verification Required'),
          content: Text('Please verify your profile by uploading your Aadhar Card or Driving Licence in the profile identity section. Once uploaded, the document will be verified within a few hours.' ,textAlign: TextAlign.justify,),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                settingRepo.navigatorKey.currentState!.pushNamed('/Settings');
              },
            ),
          ],
        );
      },
    );
  }
  void calculateSubtotal()  {
    appliedCoupon = widget.selectedCoupon;

    taxAmount = ( widget.total * double.parse( widget.default_tax)) / 100;
   // total = subTotal + taxAmount + deliveryFee;
    grandtotal = (widget.total + taxAmount).toInt();

    if(widget.selectedCoupon != null && widget.total >= widget.selectedCoupon!.minOrder!)
      {
        double calculatedDiscount = (widget.total * appliedCoupon!.discount!) / 100;
        calculatedDiscount =  calculatedDiscount > appliedCoupon!.maxDiscount!
            ? appliedCoupon!.maxDiscount!.toDouble()
            : calculatedDiscount.toDouble();
        appliedCouponamount = widget.selectedCoupon == appliedCoupon ? appliedCoupon!.discounttype == 'fixed' ? appliedCoupon!.discount  : calculatedDiscount   : 0.0 ! ;
      }

    setState(() {});
  }

  void _selectTab(int tabItem) {
    setState(() {
      print("DS>> am i here?? " + tabItem.toString());
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.isCurrentKitchen = false;
          widget.currentPage =
              SettingsWidget(); //ProfileWidget(parentScaffoldKey: widget.parentScaffoldKey);
          break;
        case 1:
          widget.isCurrentKitchen = false;
          widget.currentPage =
              RestaurantWidget(parentScaffoldKey: widget.parentScaffoldKey);
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
          widget.currentPage = CartWidget(
              key: widget
                  .parentScaffoldKey); //FavoritesWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }

  Future<void> placeOrder(BuildContext context,String transaction_id) async {
    String sltdDate = "";
    DateTime datetime = DateTime.parse(widget.selectedDate.toString());
    sltdDate = DateFormat('yyyy-MM-dd').format(datetime);
    print(sltdDate); // O
    final url = Uri.parse("https://eatathome.in/app/api/orders");
    final String baseUri = 'https://eatathome.in/app/api/orders';
    final headers = {
      'Authorization': 'Bearer ${currentUser.value.apiToken}',
      'Content-Type': 'application/json',
    };
    print("DS>> food " + widget.selectedFoodList.length.toString());
    final foods = <Map<String, dynamic>>[];
    for (int i = 0; i < widget.fooditems.length; i++) {
     var foodItem = widget.fooditems;
      Food fooddata = foodItem[i]['food'];
      double quantity = foodItem[i]['Quantity'];
      final food = {
        'price': '${fooddata.price.toString()}',
        'quantity':quantity,
        'food_id': '${fooddata.id.toString()}',
        'number_of_persons': '${widget.selectedPeople}',
        'order_date': sltdDate,
      };
      // Add more items as needed
      foods.add(food); // Add elements to the array
      print('Added food: $food');
    }
    //print('foods: ${json.encode(foods)}');
    Map<String, int> resultMap = parseString(widget.selectedPeople);

    print(resultMap);
    final payload = {
      'payment': {
        'method': 'Credit Card (Stripe Gateway)',
      },
      'user_id': '${currentUser.value.id}',
      'order_status_id': 1,
      'tax':5.00,
      'delivery_address_id': null,
      'delivery_fee': 0.00,
      'hint': null,
      'foods': foods,
       'delivery_dinein' : 2,
      'restaurant_id':widget.restaurant.id,
      'coupon_id':'${appliedCoupon!= null ? appliedCoupon!.code : ""}',
      "payment_id":transaction_id
    };
    /*final payload = {
      'payment': {
        'method': 'Credit Card (Stripe Gateway)',
      },
      'user_id': '${currentUser.value.id}',
      'order_status_id': 1,
      'tax': widget.default_tax,
      'delivery_address_id': null,
      'delivery_fee': 0.00,
      'hint': null,
      'foods': foods,
      'delivery_dinein': 2,
      //'payment_id':transaction_id

    };
*/
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
      Navigator.of(context).pushReplacementNamed('/OrderSuccess');
      //_cartCon.goCheckout(context);
      //  await makePayment(widget.total.toString());
      /* Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CheckoutPage(total:widget.total.toString()),
        ),
      );*/
    } else {
      // Request failed, handle the error
      print(
          'API request failed with status code: ${response.statusCode} ${response.body.toString()}');
    }
  }

  Future<void> makePayment(String totalamount, BuildContext context) async {
    try {
      paymentIntent = await createPaymentIntent(totalamount, 'AED');
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          // googlePay: const stripe.PaymentSheetGooglePay(
          //     testEnv: true, currencyCode: "AED", merchantCountryCode: "+971"),
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
      placeOrder(context,transactionId);

      //   Navigator.push(context,MaterialPageRoute(builder: (context)=>OrderSuccessWidget()));
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );*/
      paymentIntent = {};
    } on stripe.StripeException catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Cancelled"),
        ),
      );
      setState(() { IsMakePayment = false ; });
    } catch (e) {
      print('$e');
    }
  }
  Map<String, int> parseString(String input) {
    Map<String, int> resultMap = {};

    List<String> parts = input.split(',');

    parts.forEach((part) {
      List<String> temp = part.trim().split(' ');
      if (temp.length == 2) {
        int count = int.tryParse(temp[0])!;
        if (count != null) {
          String type = temp[1];
          resultMap[type] = count;
        }
      }
    });

    return resultMap;
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
}
