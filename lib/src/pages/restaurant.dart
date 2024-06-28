import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/controllers/food_controller.dart';
import 'package:food_delivery_app/src/elements/AddToCartAlertDialog.dart';
import 'package:food_delivery_app/src/elements/IndividualFoodItemWidget.dart';
import 'package:food_delivery_app/src/models/add_to_favourite_model.dart';

import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/kitchen_detail_response.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/map.dart';
import 'package:food_delivery_app/src/pages/pages.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:food_delivery_app/src/repository/food_repository.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import 'package:intl/intl.dart';

import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../my_widget/shimmering_data.dart';
import '../../utils/color.dart';
import '../controllers/cart_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/homecontroller_provider.dart';
import '../controllers/homr_test.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/coupons.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import '../provider.dart';
import '../repository/user_repository.dart';
import 'package:provider/provider.dart';
import '../repository/settings_repository.dart' as settingRepo;
import 'chatscreen.dart';
import 'coupen_restaurant.dart';

class RestaurantWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  dynamic currentTab;
  Widget currentPage = HomePage();
  bool isCurrentKitchen = true;

  HomeController _con = HomeController();

  bool isBreakfastVisible = false;
  bool isLunchVisible = false;
  bool isSnacksVisible = false;
  bool isDinnerVisible = false;

  bool isBreakfastSelected = false;
  bool isLunchSelected = false;
  bool isSnacksSelected = false;
  bool isDinnerSelected = false;
  bool buttonPressed = false;

  RestaurantWidget({Key? key,  this.parentScaffoldKey, this.routeArgument})
      : super(key: key);

  @override
  _RestaurantWidgetState createState() {
    return _RestaurantWidgetState();
  }
}

class _RestaurantWidgetState extends StateMVC<RestaurantWidget> {
  RestaurantController? _con;
  FoodController? _foodcon;
  HomeController? _homecon;
  String updatedQuantity = "0";
  List<Food> foodList = [];
  List<Food> foodListNew = [];
  CategoryController? _controller;
  bool showProgress = true;
  String defaultLanguage = "";
  bool hasData = false;
  double min_price = 0;
  double max_price = 0;
  String nextSessionStartTime = '';
  bool showServiceMessage = false;
  bool isLoadmore = false;
  bool isbreackfastLoadmore = false;
  bool islunchLoadmore = false;
  bool issnacksLoadmore = false;
  bool isdinnerLoadmore = false;
  bool isbreackfastLoad = false;
  bool islunchLoad = false;
  bool issnacksLoad = false;
  bool isdinnerLoad = false;
  bool iscartload = false;
  List<FoodItem> breakfast_food = <FoodItem>[];
  List<FoodItem> snack_food = <FoodItem>[];
  List<FoodItem> lunch_food = <FoodItem>[];
  List<FoodItem> dinner_food = <FoodItem>[];
  Map<String, int> itemQuantities = {};
  var breakfastslot_start ;
  var breakfastslot_end ;
  var lunchslot_start ;
  var lunchslot_end ;
  var snacksslot_start ;
  var snacksslot_end ;
  var dinnerslot_start ;
  var dinnerslot_end ;
  var breakfastslotstart ="";
  var breakfastslotend ="";
  var lunchslotstart ="";
  var lunchslotend ="";
  var snacksslotstart ="";
  var snacksslotend ="";
  var dinnerslotstart ="";
  var dinnerslotend ="";
  DateTime? b_startTime ;
  DateTime? b_endTime ;
  DateTime? l_startTime ;
  DateTime? l_endTime ;
  DateTime? s_startTime ;
  DateTime? s_endTime ;
  DateTime? d_startTime ;
  DateTime? d_endTime ;
  Coupon? selectedCoupon;
  bool isbreckfastenable =false;
  bool islunchenable =false;
  bool isdinnerenable =false;
  bool issnacksenable =false;
  FoodItem? breakfastFoodItem, lunchFoodItem, snacksFoodItem, dinnerFoodItem;
  bool isBreakfastAvailable = false,
      isLunchAvailable = false,
      isSnacksAvailable = false,
      isDinnerAvailable = false;

  DateTime currentTime = DateTime.now();
  int? currentHour;
  String? enjoy;
/*  KitchenDetails kitchenDetails;

  // Access the separate items for each item (if available)
  List<SeparateItem> separateItems;
  bool success;
  String apimessage;*/

  _RestaurantWidgetState() : super(RestaurantController()) {
    _con = controller as RestaurantController?;
    _foodcon = FoodController();
    _homecon = HomeController();
    _controller = CategoryController();
  }

  CartController _cartController = CartController();
  DateTime todayWithTime(String time) {
    var currentTime = DateTime.now();
    final DateFormat timeFormat = DateFormat('HH:mm:ss');
    final parsedTime = timeFormat.parse(time);
    return DateTime(currentTime.year, currentTime.month, currentTime.day, parsedTime.hour, parsedTime.minute, parsedTime.second);
  }
  void _scheduleButtonPress() {
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        widget.buttonPressed = true;
      });
      showServiceMessage = false; // Reset message flag
      bool allSessionsDisabled = false;

      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      breakfastslot_start = homeProvider.categories[0].start_slot;
      breakfastslot_end = homeProvider.categories[0].end_slot;
      lunchslot_start = homeProvider.categories[1].start_slot;
      lunchslot_end = homeProvider.categories[1].end_slot;
      snacksslot_start = homeProvider.categories[2].start_slot;
      snacksslot_end = homeProvider.categories[2].end_slot;
      dinnerslot_start = homeProvider.categories[3].start_slot;
      dinnerslot_end = homeProvider.categories[3].end_slot;

      var currentTime = DateTime.now();
      final DateFormat timeFormat = DateFormat.Hm();

      b_startTime = todayWithTime(breakfastslot_start);
      b_endTime = todayWithTime(breakfastslot_end);
      l_startTime = todayWithTime(lunchslot_start);
      l_endTime = todayWithTime(lunchslot_end);
      s_startTime = todayWithTime(snacksslot_start);
      s_endTime = todayWithTime(snacksslot_end);
      d_startTime = todayWithTime(dinnerslot_start);
      d_endTime = todayWithTime(dinnerslot_end);

      breakfastslotstart = timeFormat.format(b_startTime!);
      breakfastslotend = timeFormat.format(b_endTime!);
      lunchslotstart = timeFormat.format(l_startTime!);
      lunchslotend = timeFormat.format(l_endTime!);
      snacksslotstart = timeFormat.format(s_startTime!);
      snacksslotend = timeFormat.format(s_endTime!);
      dinnerslotstart = timeFormat.format(d_startTime!);
      dinnerslotend = timeFormat.format(d_endTime!);
      print("enjoy ===>" + enjoy!);
      if (enjoy == "1") {
        // Enable current session only
        if (currentTime.isAfter(d_startTime!) && currentTime.isBefore(d_endTime!)) {
          setState(() {
            isbreckfastenable = false;
            islunchenable = false;
            issnacksenable = false;
            isdinnerenable = true;
          });
          showDinnerView();
        } else if (currentTime.isAfter(s_startTime!) && currentTime.isBefore(s_endTime!)) {
          setState(() {
            isbreckfastenable = false;
            islunchenable = false;
            issnacksenable = true;
            isdinnerenable = false;
          });
          showSnacksView();
        } else if (currentTime.isAfter(l_startTime!) && currentTime.isBefore(l_endTime!)) {
          setState(() {
            isbreckfastenable = false;
            islunchenable = true;
            issnacksenable = false;
            isdinnerenable = false;
          });
          showLunchView();
        } else if (currentTime.isAfter(b_startTime!) && currentTime.isBefore(b_endTime!)) {
          setState(() {
            isbreckfastenable = true;
            islunchenable = false;
            issnacksenable = false;
            isdinnerenable = false;
          });
          showBreakFastView();
        }
        else {
          allSessionsDisabled = true;
          nextSessionStartTime = getNextSessionStartTime(currentTime);
        }
      }
      else if (enjoy == "2") {
        // Enable upcoming session only
        if (currentTime.isAfter(d_startTime!)) {
          setState(() {
            isbreckfastenable = false;
            islunchenable = false;
            issnacksenable = false;
            isdinnerenable = false;
          });
          //showBreakFastView();
        } else if (currentTime.isAfter(s_startTime!)) {
          setState(() {
            isbreckfastenable = false;
            islunchenable = false;
            issnacksenable = false;
            isdinnerenable = true;
          });
          showDinnerView();
        } else if (currentTime.isAfter(l_startTime!)) {
          setState(() {
            isbreckfastenable = false;
            islunchenable = false;
            issnacksenable = true;
            isdinnerenable = true;
          });
          showSnacksView();
        } else if (currentTime.isAfter(b_startTime!)) {
          setState(() {
            isbreckfastenable = false;
            islunchenable = true;
            issnacksenable = true;
            isdinnerenable = true;
          });
          showLunchView();
        }
        else {
          allSessionsDisabled = true;
          nextSessionStartTime = getNextSessionStartTime(currentTime);
        }
      }
      if (allSessionsDisabled) {
        setState(() {
          showServiceMessage = true;
        });
      }
    });
  }
  String getNextSessionStartTime(DateTime currentTime) {
    if (currentTime.isBefore(b_startTime!)) {
      return breakfastslotstart;
    } else if (currentTime.isBefore(l_startTime!)) {
      return lunchslotstart;
    } else if (currentTime.isBefore(s_startTime!)) {
      return snacksslotstart;
    } else if (currentTime.isBefore(d_startTime!)) {
      return dinnerslotstart;
    } else {
      return breakfastslotstart; // Next day's breakfast if all sessions are over for today
    }
  }
  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode) {
      print("DS>> DefaultLanguageret " + _langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }

  int loaderCount = 1;
  @override
  void initState() {
    getCurrentDefaultLanguage();
    // print("heelloo ===> ${widget.routeArgument.selectedDate}");
    _foodcon!.getKetchainDetails(widget.routeArgument!.id!, '2').then((value) {});
    _con!.restaurant = widget.routeArgument!.param as Restaurant;
    enjoy = widget.routeArgument!.selectedDate;
    /* _controller.listenForFoodsByCategoryAndRestaurant(
        id: "8", restaurantId: _con!.restaurant.id);
    showBreakFastView();*/

    /*  listenForFoodsByCategoryAndRestaurantHere(
        id: "8", restaurantId: _con.restaurant.id);*/
    _con!.listenForGalleries(_con!.restaurant!.id!);
    /*_con.listenForGalleries(_con.restaurant.id);
    _con.listenForFoodImages(_con.restaurant.image.toString());
    _con.listenForFeaturedFoods(_con.restaurant.id);
    _con.listenForRestaurantReviews(id: _con.restaurant.id);
    _con.listenForIndividualFoods(_con.restaurant.id);
    _controller.listenForFoodsByCategoryAndKitchen(
        id: "7", restaurantId: _con.restaurant.id);*/
    listenForFoodsByCategoryAndRestaurantHere(
      id: "8", restaurantId: _con!.restaurant!.id, );
    // if(widget.currentTab != null)
    // _selectTab(widget.currentTab);

    _scheduleButtonPress();
    currentHour = currentTime.hour;

    super.initState();
  }

  void updateFoodList(Food food) {
    foodList.add(food);
  }

  void removeFoodFromList(Food food) {
    bool removed = false;
    foodList.removeWhere((item) {
      if (!removed && item.id == food.id) {
        removed = true;
        return true; // Remove only one item
      }
      return false;
    });
  }

  void listenForFoodsByCategoryAndRestaurantHere(
      {String? id, String? message, String? restaurantId}) async {
    // foods.clear();
    final FoodItem stream =
    await getFoodsByCategoryAndKitchenData(restaurantId!);
    //print("price data ---------->"+stream.length.toString());
    if (stream == null) {
      print("No data found");
      // Handle no data found scenario
      return;
    }

    // setState(() {
    //   min_price = double.parse(stream.restaurant.price.min);
    //   max_price = double.parse(stream.restaurant.price.max);
    // });
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller!.success) {
      hasData = true;
      showProgress = false;
      if (_controller!.foodDataMap.containsKey("8")) {
        isBreakfastAvailable = true;
        breakfastFoodItem = _controller!.foodDataMap["8"];
        print(breakfastFoodItem);
        print("Xyzz      ${breakfastFoodItem!.restaurant}");
        print('Food Name: ${breakfastFoodItem!.name}');
        print('Price: ${breakfastFoodItem!.price}');
      } else {
        print('Key not found:');
      }

      if (_controller!.foodDataMap.containsKey("7")) {
        isSnacksAvailable = true;
        snacksFoodItem = _controller!.foodDataMap["7"];
        print(snacksFoodItem!.restaurant!.image);

        ///   print("Xyzz      ${breakfastFoodItem.restaurant}");
        print('Food Name: ${snacksFoodItem!.name}');
        print('Price: ${snacksFoodItem!.price}');
      } else {
        print('Key not found:');
      }

      if (_controller!.foodDataMap.containsKey("9")) {
        isLunchAvailable = true;
        lunchFoodItem = _controller!.foodDataMap["9"];
        print('Food Name: ${lunchFoodItem!.name}');
        print('Price: ${lunchFoodItem!.price}');
      } else {
        print('Key not found:');
      }

      if (_controller!.foodDataMap.containsKey("10")) {
        isDinnerAvailable = true;
        dinnerFoodItem = _controller!.foodDataMap["10"];
        print('Food Name: ${dinnerFoodItem!.name}');
        print('Price: ${dinnerFoodItem!.price}');
      } else {
        print('Key not found:');
      }
    } else {
      hasData = false;
      showProgress = false;
    }

    if (_controller!.foodDataMap.length > 0 &&
        _controller!.separateItems.length > 0) {
      showProgress = false;
    }
    String res_imag = "";
    //print("DS>> length increase" + _controller.foods.length.toString());


    var totalQuantity = Provider.of<QuantityProvider>(context).getTotalQuantityForRestaurant(_con!.restaurant!.id!);

    return Scaffold(
      // bottomNavigationBar: DetailsWidget(),
      key: _con!.scaffoldKey,
      body: FutureBuilder(
          future: Future.delayed(Duration(seconds: 1), () {}),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                loaderCount < 3) {
              loaderCount = loaderCount + 1;
              print(loaderCount);
              return Center(child: MyShimmerEffect());
            }

            return widget.isCurrentKitchen
                ? RefreshIndicator(
              onRefresh: _controller!.refreshCategory,
              child: showProgress
                  ? Center(child: MyShimmerEffect())
                  : Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _controller!.isData == true
                      ? Center(
                    child: TranslationWidget(
                      message: "Oops! No Data Available",
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(
                        translatedMessage,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                      : CustomScrollView(
                    primary: true,
                    shrinkWrap: false,
                    slivers: <Widget>[
                      SliverAppBar(
                        backgroundColor: mainColor(1)
                            .withOpacity(0.9),
                        expandedHeight: 300,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        leading: new IconButton(
                          icon: new Icon(
                              Icons.keyboard_backspace,
                              color: Theme.of(context)
                                  .primaryColor),
                          onPressed: () =>
                              Navigator.pop(context),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: Hero(
                            tag: (widget?.routeArgument
                                ?.heroTag ??
                                '') +
                                _controller!.kitchenDetails.id
                                    .toString(),
                            child: Stack(
                              children: [
                                ColorFiltered(
                                  colorFilter: _con!.restaurant
                                      !.closed ==
                                      "0"
                                      ? ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode
                                          .saturation)
                                      : ColorFilter.mode(
                                      Colors.grey,
                                      BlendMode
                                          .saturation),
                                  child: CachedNetworkImage(
                                    width:
                                    MediaQuery.of(context)
                                        .size
                                        .width,
                                    height: 350,
                                    fit: BoxFit.fill,
                                    imageUrl:   _con!.restaurant
                                        !.image!.url ??
                                        "https://picsum.photos/250?image=9",
                                    // imageUrl: _con.restaurant.banner_image.isEmpty ?  _con.restaurant
                                    //     .image.url : _con.restaurant.banner_image ??
                                    //     "https://picsum.photos/250?image=9",
                                    placeholder:
                                        (context, url) =>
                                        Image.asset(
                                          'assets/img/loading.gif',
                                          fit: BoxFit.cover,
                                        ),
                                    errorWidget: (context,
                                        url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                if (_con!.restaurant!.closed ==
                                    "1")
                                  Center(
                                      child: Image.asset(
                                          "assets/img/closed.png")),
                              ],
                            ),
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
                                  top: 25),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: TranslationWidget(
                                      message: _con!.restaurant
                                          !.name ??
                                          '',
                                      fromLanguage: "English",
                                      toLanguage:
                                      defaultLanguage,
                                      builder:
                                          (translatedMessage) =>
                                          Text(
                                            translatedMessage,
                                            overflow:
                                            TextOverflow.fade,
                                            softWrap: false,
                                            maxLines: 2,
                                            style:
                                            Theme.of(context)
                                                .textTheme
                                                .headline3,
                                          ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 35,
                                    child: Container(
                                      padding:
                                      EdgeInsets.all(10),
                                      decoration:
                                      BoxDecoration(
                                        borderRadius:
                                        BorderRadius
                                            .circular(22),
                                        gradient:
                                        LinearGradient(
                                          colors: [
                                            kPrimaryColororange,
                                            kPrimaryColorLiteorange
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          TranslationWidget(
                                            message: _con
                                                !.restaurant
                                                !.rate ??
                                                '',
                                            fromLanguage:
                                            "English",
                                            toLanguage:
                                            defaultLanguage,
                                            builder: (translatedMessage) => Text(
                                                translatedMessage,
                                                style: Theme.of(
                                                    context)
                                                    .textTheme
                                                    .bodyText1
                                                    !.merge(TextStyle(
                                                    color:
                                                    Theme.of(context).primaryColor))),
                                          ),
                                          Icon(
                                            Icons.star_border,
                                            color: Theme.of(
                                                context)
                                                .primaryColor,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Padding(
                            //     padding: const EdgeInsets
                            //         .symmetric(
                            //         horizontal: 20,
                            //         vertical: 0),
                            //     child: Helper.applyHtml(
                            //       context,
                            //       _con!.restaurant!.description,
                            //     )),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Container(
                                        width: 170,
                                        child:
                                        Row(
                                          children: [
                                            Text("FSSAI  ",style:TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14
                                            )),
                                            TranslationWidget(
                                              message: _con
                                                  !.restaurant
                                                  !.fssai_number ??
                                                  '',
                                              fromLanguage:
                                              "English",
                                              toLanguage:
                                              defaultLanguage,
                                              builder: (translatedMessage) => Text(
                                                translatedMessage,
                                                maxLines: 3,
                                                overflow:
                                                TextOverflow
                                                    .ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      RatingBar.builder(
                                        itemSize: 18,
                                        initialRating:
                                        double.parse(_con
                                            !.restaurant
                                            !.rate ??
                                            "0.0"),
                                        minRating: 1,
                                        direction:
                                        Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                        itemBuilder:
                                            (context, _) =>
                                            ShaderMask(
                                              shaderCallback:
                                                  (Rect bounds) {
                                                return LinearGradient(
                                                  colors: [
                                                    kPrimaryColororange,
                                                    kPrimaryColorLiteorange
                                                  ],
                                                ).createShader(
                                                    bounds);
                                              },
                                              child: Icon(
                                                Icons.star,
                                                color:
                                                Colors.white,
                                                size: 60.0,
                                              ),
                                            ),
                                        onRatingUpdate:
                                            (rating) {
                                          print(rating);
                                        },
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      RichText(
                                        text: TextSpan(
                                            text: "₹",
                                            style: TextStyle(
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              color: Theme.of(
                                                  context)
                                                  .hintColor,
                                              fontSize: 20,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                "${_con!.restaurant!.average_price}",
                                                style:
                                                TextStyle(
                                                  fontSize:
                                                  20,
                                                ),
                                              ),
                                            ]),
                                      ),
                                      TranslationWidget(
                                        message:
                                        "Avg. for one",
                                        fromLanguage:
                                        "English",
                                        toLanguage:
                                        defaultLanguage,
                                        builder:
                                            (translatedMessage) =>
                                            Text(
                                              translatedMessage,
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            if(_con!.restaurant!.is_hrs == "0")
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10) ,
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        double.parse(_con!.restaurant!.average_preparation_time!) > 30 ? Icon(Icons.timer,size:20,color:Colors.green) :  HalfColoredIcon(
                                          icon: Icons.timer,
                                          size: 20,
                                          color: Colors.green,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("${_con!.restaurant!.average_preparation_time} mins  |  ${_con!.restaurant!.restaurant_distance}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)
                                      ],
                                    ),


                                  ],
                                ),
                              ),
                            if(_con!.restaurant!.is_hrs == "1")
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10) ,
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        double.parse(_con!.restaurant!.average_preparation_time!) > 30 ? Icon(Icons.timer,size:20,color:Colors.green) :  HalfColoredIcon(
                                          icon: Icons.timer,
                                          size: 20,
                                          color: Colors.green,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("${_con!.restaurant!.average_preparation_time} hrs  |  ${_con!.restaurant!.restaurant_distance}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)
                                      ],
                                    ),


                                  ],
                                ),
                              ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    VerticalDivider(
                                      color: Colors
                                          .grey.shade100,
                                      thickness: 1,
                                      indent: 0,
                                      width: 1,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: ()async{
                                          var coupon = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CouponRestaurantPage(res_id: _con!.restaurant!.id,)));
                                          setState(() {
                                            selectedCoupon = coupon;
                                            print(selectedCoupon!.code);
                                          });
                                        },
                                        child: Container(
                                          // width:237,
                                          //width: 79,
                                          height: 48,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.only(
                                                topRight: Radius.circular(4),
                                                bottomRight: Radius.circular(4),
                                                topLeft: Radius.circular(4),
                                                bottomLeft: Radius.circular(4),
                                              ),
                                              gradient: LinearGradient(
                                                colors: [
                                                  kPrimaryColororange,
                                                  kPrimaryColorLiteorange
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors
                                                        .grey,
                                                    blurRadius:
                                                    12,
                                                    spreadRadius:
                                                    -9)
                                              ]),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [

                                              Icon(
                                                  Icons.card_giftcard,
                                                  size: 16,
                                                  color: Colors.white),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              TranslationWidget(
                                                message:
                                                "Offers",
                                                fromLanguage:
                                                "English",
                                                toLanguage:
                                                defaultLanguage,
                                                builder:
                                                    (translatedMessage) =>
                                                    Text(
                                                      translatedMessage,
                                                      style: TextStyle(
                                                          fontSize:
                                                          14,
                                                          fontWeight:
                                                          FontWeight
                                                              .normal,
                                                          color:Colors.white),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    VerticalDivider(
                                      color: Colors
                                          .grey.shade100,
                                      thickness: 1,
                                      indent: 0,
                                      width: 1,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.only(
                                                topRight: Radius.circular(4),
                                                bottomRight: Radius.circular(4)),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors
                                                      .grey,
                                                  blurRadius:
                                                  12,
                                                  spreadRadius:
                                                  -9)
                                            ]),
                                        child: TextButton(
                                          onPressed:
                                              () async {
                                            if (currentUser
                                                .value
                                                .apiToken ==
                                                null) {
                                              Navigator.of(
                                                  context)
                                                  .pushNamed(
                                                  "/Login");
                                            } else {}

                                            if (Provider.of<
                                                favourite_item_provider>(
                                                context,
                                                listen:
                                                false)
                                                .restaurant_name
                                                .contains(_con
                                                !.restaurant
                                                !.name)) {
                                              Provider.of<favourite_item_provider>(
                                                  context,
                                                  listen:
                                                  false)
                                                  .removeFromFavorite(_con
                                                  !.restaurant
                                                  !.name!);
                                              await _con!.removeRestaurantFromFavouriteList(
                                                  _con!.restaurant
                                                      !.id!,
                                                  currentUser
                                                      .value
                                                      .apiToken);
                                              setState(() {
                                                loaderCount =
                                                2;
                                              });
                                              _con!.refreshRestaurant();
                                            } else {
                                              Provider.of<favourite_item_provider>(
                                                  context,
                                                  listen:
                                                  false)
                                                  .add_to_favorite(_con
                                                  !.restaurant
                                                  !.name!);
                                              final AddToFavouriteModel
                                              apiResponse =
                                              await _con!.addRestaurantToFavouriteList(
                                                  _con!.restaurant
                                                      !.id!,
                                                  currentUser
                                                      .value
                                                      .id,
                                                  currentUser
                                                      .value
                                                      .apiToken);

                                              /*print("DS>> res## " + apiResponse.toString());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(apiResponse.message.toString()),
      ));*/
                                              setState(() {
                                                loaderCount =
                                                2;
                                              });
                                              _con!.refreshRestaurant();
                                            }
                                          },
                                          child:
                                          GestureDetector(
                                            onTap: () {},
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              children: [
                                                Icon(
                                                    Provider.of<favourite_item_provider>(context, listen: false).restaurant_name.contains(_con
                                                        !.restaurant
                                                        !.name)
                                                        ? Icons
                                                        .favorite
                                                        : Icons
                                                        .favorite_border,
                                                    size: 12,
                                                    color: Provider.of<favourite_item_provider>(context, listen: false).restaurant_name.contains(_con
                                                        !.restaurant
                                                        !.name)
                                                        ? Colors
                                                        .red
                                                        : Theme.of(context)
                                                        .hintColor),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                /*Text(
                                                            "Like",
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Theme.of(
                                                                        context)
                                                                    .hintColor),
                                                          )*/
                                                TranslationWidget(
                                                  message:
                                                  "Like",
                                                  fromLanguage:
                                                  "English",
                                                  toLanguage:
                                                  defaultLanguage,
                                                  builder:
                                                      (translatedMessage) =>
                                                      Text(
                                                        translatedMessage,
                                                        style: TextStyle(
                                                            fontSize:
                                                            10,
                                                            fontWeight: FontWeight
                                                                .normal,
                                                            color:
                                                            Theme.of(context).hintColor),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        // width:235,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                bottomLeft: Radius.circular(0)),
                                            color: /*currentHour < 7 || */ !isbreckfastenable ? Colors.grey[200] : widget.isBreakfastSelected ? kPrimaryColororange : Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors
                                                      .grey,
                                                  blurRadius:
                                                  12,
                                                  spreadRadius:
                                                  -9)
                                            ]),
                                        child: TextButton(
                                          onPressed: (){},
                                          child: GestureDetector(
                                            onTap: !isbreckfastenable ? null : () {


                                              _controller
                                                  !.isDateUpdated =
                                              false;
                                              // _controller.listenForFoodsByCategoryAndKitchen(id: "8", restaurantId: _con!.restaurant!.id);
                                              showBreakFastView();
                                            },
                                            child:
                                            TranslationWidget(
                                              message: "Breakfast\n7:30-11:00",
                                              fromLanguage: "English",
                                              toLanguage: defaultLanguage,
                                              builder: (translatedMessage) => Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Breakfast\n",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.normal,
                                                        color: widget.isBreakfastSelected ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${breakfastslotstart}-${breakfastslotend}",
                                                      style: TextStyle(
                                                        fontSize: 8, // Smaller font size for the time
                                                        fontWeight: FontWeight.normal,
                                                        color: widget.isBreakfastSelected ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),

                                          ),
                                        ),
                                      ),
                                    ),
                                    VerticalDivider(
                                      color: Colors
                                          .grey.shade100,
                                      thickness: 1,
                                      indent: 0,
                                      width: 2,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: /*currentHour < 11 || */
                                            !islunchenable ? Colors.grey[200]:
                                            widget
                                                .isLunchSelected
                                                ? kPrimaryColororange
                                                : Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors
                                                      .grey,
                                                  blurRadius:
                                                  12,
                                                  spreadRadius:
                                                  -9)
                                            ]),
                                        child: TextButton(
                                          onPressed: (){},
                                          child: GestureDetector(
                                            onTap: !islunchenable ? null: () {
                                              _controller
                                                  !.isDateUpdated =
                                              false;

                                              showLunchView();
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              children: [
                                                TranslationWidget(
                                                  message: "Lunch\n12:00-15:00",
                                                  fromLanguage: "English",
                                                  toLanguage: defaultLanguage,
                                                  builder: (translatedMessage) => Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "Lunch\n",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.normal,
                                                            color: widget.isLunchSelected ? Colors.white : Colors.black,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: "${lunchslotstart}-${lunchslotend}",
                                                          style: TextStyle(
                                                            fontSize: 8, // Smaller font size for the time
                                                            fontWeight: FontWeight.normal,
                                                            color: widget.isLunchSelected ? Colors.white : Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    VerticalDivider(
                                      color: Colors
                                          .grey.shade100,
                                      thickness: 1,
                                      indent: 0,
                                      width: 2,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: !issnacksenable ? Colors.grey[200]: widget
                                                .isSnacksSelected
                                                ? kPrimaryColororange
                                                : Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors
                                                      .grey,
                                                  blurRadius:
                                                  12,
                                                  spreadRadius:
                                                  -9)
                                            ]),
                                        child: TextButton(
                                          onPressed: (){},
                                          child: GestureDetector(
                                            onTap: !issnacksenable ?null : () {
                                              _controller
                                                  !.isDateUpdated =
                                              false;

                                              showSnacksView();
                                            },
                                            child:
                                            TranslationWidget(
                                              message: "Snacks\n15:30-18:00",
                                              fromLanguage: "English",
                                              toLanguage: defaultLanguage,
                                              builder: (translatedMessage) => Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Snacks\n",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.normal,
                                                        color: widget.isSnacksSelected ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${snacksslotstart}-${snacksslotend}",
                                                      style: TextStyle(
                                                        fontSize: 8, // Smaller font size for the time
                                                        fontWeight: FontWeight.normal,
                                                        color: widget.isSnacksSelected ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),

                                          ),
                                        ),
                                      ),
                                    ),
                                    VerticalDivider(
                                      color: Colors
                                          .grey.shade100,
                                      thickness: 1,
                                      indent: 0,
                                      width: 2,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration:
                                        BoxDecoration(
                                            borderRadius:
                                            BorderRadius
                                                .only(
                                              topRight: Radius
                                                  .circular(
                                                  0),
                                              bottomRight:
                                              Radius.circular(
                                                  0),
                                            ),
                                            color: /*currentHour < 19 || */ !isdinnerenable ?  Colors.grey[200]  : widget.isDinnerSelected ? kPrimaryColororange : Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors
                                                      .grey,
                                                  blurRadius:
                                                  12,
                                                  spreadRadius:
                                                  -9)
                                            ]),
                                        child: TextButton(
                                          onPressed: (){},
                                          child: GestureDetector(
                                            onTap: !isdinnerenable ? null : () {
                                              _controller
                                                  !.isDateUpdated =
                                              false;

                                              showDinnerView();
                                            },
                                            child:
                                            TranslationWidget(
                                              message: "Dinner\n19:00-23:00",
                                              fromLanguage: "English",
                                              toLanguage: defaultLanguage,
                                              builder: (translatedMessage) => Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Dinner\n",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.normal,
                                                        color: widget.isDinnerSelected ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${dinnerslotstart}-${dinnerslotend}",
                                                      style: TextStyle(
                                                        fontSize: 8, // Smaller font size for the time
                                                        fontWeight: FontWeight.normal,
                                                        color: widget.isDinnerSelected ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),

                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //CategoryFoodById(),

                            widget.isBreakfastVisible
                                ? RefreshIndicator(
                                onRefresh: _controller
                                    !.refreshCategory,
                                child:
                                buildBreakfastFoods(
                                    breakfast_food,
                                    8,
                                    _con!.restaurant
                                        !.id!))
                                : SizedBox(),

                            widget.isLunchVisible
                                ? RefreshIndicator(
                                onRefresh: _controller
                                    !.refreshCategory,
                                child: buildLunchFoods(
                                    lunch_food,
                                    9,
                                    _con!.restaurant!.id!))
                                : SizedBox(),

                            widget.isSnacksVisible
                                ? RefreshIndicator(
                                onRefresh: _controller
                                    !.refreshCategory,
                                child: buildSnacksFoods(
                                    snack_food,
                                    7,
                                    _con!.restaurant!.id!))
                                : SizedBox(),

                            widget.isDinnerVisible
                                ? RefreshIndicator(
                                onRefresh: _controller
                                    !.refreshCategory,
                                child: buildDinnerFoods(
                                    dinner_food,
                                    10,
                                    _con!.restaurant!.id!))
                                : SizedBox(),
                            if (showServiceMessage)
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(0.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/img/No-food.png", height: 100, width: 100),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * .7,
                                      child: Text(
                                        "Food service begins after $nextSessionStartTime. Thank you for your understanding.",
                                        style: TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 50,)
                                  ],
                                ),
                              ),

                            if (widget.isBreakfastVisible &&
                                breakfastFoodItem !=
                                    null &&
                                breakfastFoodItem
                                    !.separateItems
                                    !.isNotEmpty ||
                                widget.isSnacksVisible &&
                                    snacksFoodItem != null &&
                                    snacksFoodItem
                                        !.separateItems
                                        !.isNotEmpty ||
                                widget.isLunchVisible &&
                                    lunchFoodItem != null &&
                                    lunchFoodItem
                                        !.separateItems
                                        !.isNotEmpty ||
                                widget.isDinnerVisible &&
                                    dinnerFoodItem != null &&
                                    dinnerFoodItem
                                        !.separateItems
                                        !.isNotEmpty)
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        horizontal: 20,
                                        vertical: 2),
                                    child: /*Text(
                                          "Individual Items Order",
                                          style:
                                              Theme.of(context).textTheme.headline3,
                                        )*/
                                    TranslationWidget(
                                      message:
                                      "Individual Items Order",
                                      fromLanguage: "English",
                                      toLanguage:
                                      defaultLanguage,
                                      builder:
                                          (translatedMessage) =>
                                          Text(
                                            translatedMessage,
                                            style:
                                            Theme.of(context)
                                                .textTheme
                                                .headline3,
                                          ),
                                    ),
                                  ),
                                  widget.isBreakfastVisible &&
                                      breakfastFoodItem !=
                                          null &&
                                      breakfastFoodItem
                                          !.separateItems
                                          !.isNotEmpty
                                      ? RefreshIndicator(
                                    onRefresh: _controller
                                        !.refreshCategory,
                                    child: Transform
                                        .translate(
                                      offset: Offset(
                                          0, -20),
                                      child: ListView
                                          .separated(
                                        scrollDirection:
                                        Axis.vertical,
                                        shrinkWrap:
                                        true,
                                        primary: false,
                                        itemCount:
                                        breakfastFoodItem
                                            !.separateItems
                                            !.length,
                                        separatorBuilder:
                                            (context,
                                            index) {
                                          return SizedBox(
                                              height:
                                              6);
                                        },
                                        itemBuilder:
                                            (context,
                                            index) {
                                          return IndividualFoodItemWidget(
                                            heroTag:
                                            'individual_food_list',
                                            food: breakfastFoodItem
                                                !.separateItems![
                                            index],
                                            updateFoodList:
                                            updateFoodList,
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                      : widget.isLunchVisible &&
                                      lunchFoodItem !=
                                          null &&
                                      lunchFoodItem
                                          !.separateItems
                                          !.isNotEmpty
                                      ? RefreshIndicator(
                                    onRefresh:
                                    _controller
                                        !.refreshCategory,
                                    child: Transform
                                        .translate(
                                      offset:
                                      Offset(0,
                                          -20),
                                      child: ListView
                                          .separated(
                                        scrollDirection:
                                        Axis.vertical,
                                        shrinkWrap:
                                        true,
                                        primary:
                                        false,
                                        itemCount: lunchFoodItem
                                            !.separateItems
                                            !.length,
                                        separatorBuilder:
                                            (context,
                                            index) {
                                          return SizedBox(
                                              height:
                                              6);
                                        },
                                        itemBuilder:
                                            (context,
                                            index) {
                                          return IndividualFoodItemWidget(
                                            heroTag:
                                            'individual_food_list',
                                            food: lunchFoodItem
                                                !.separateItems![index],
                                            updateFoodList:
                                            updateFoodList,
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                      : widget.isDinnerVisible &&
                                      dinnerFoodItem !=
                                          null &&
                                      dinnerFoodItem
                                          !.separateItems
                                          !.isNotEmpty
                                      ? RefreshIndicator(
                                    onRefresh:
                                    _controller
                                        !.refreshCategory,
                                    child: Transform
                                        .translate(
                                      offset:
                                      Offset(
                                          0,
                                          -20),
                                      child: ListView
                                          .separated(
                                        scrollDirection:
                                        Axis.vertical,
                                        shrinkWrap:
                                        true,
                                        primary:
                                        false,
                                        itemCount: dinnerFoodItem
                                            !.separateItems
                                            !.length,
                                        separatorBuilder:
                                            (context,
                                            index) {
                                          return SizedBox(
                                              height: 6);
                                        },
                                        itemBuilder:
                                            (context,
                                            index) {
                                          return IndividualFoodItemWidget(
                                            heroTag:
                                            'individual_food_list',
                                            food:
                                            dinnerFoodItem!.separateItems![index],
                                            updateFoodList:
                                            updateFoodList,
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                      : widget.isSnacksVisible &&
                                      snacksFoodItem !=
                                          null &&
                                      snacksFoodItem
                                          !.separateItems
                                          !.isNotEmpty
                                      ? RefreshIndicator(
                                    onRefresh:
                                    _controller!.refreshCategory,
                                    child: Transform
                                        .translate(
                                      offset: Offset(
                                          0,
                                          -20),
                                      child:
                                      ListView.separated(
                                        scrollDirection:
                                        Axis.vertical,
                                        shrinkWrap:
                                        true,
                                        primary:
                                        false,
                                        itemCount:
                                        snacksFoodItem!.separateItems!.length,
                                        separatorBuilder:
                                            (context, index) {
                                          return SizedBox(height: 6);
                                        },
                                        itemBuilder:
                                            (context, index) {
                                          return IndividualFoodItemWidget(
                                            heroTag: 'individual_food_list',
                                            food: snacksFoodItem!.separateItems![index],
                                            updateFoodList: updateFoodList,
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                      : Center(
                                    child: /*Text("No Food available")*/
                                    TranslationWidget(
                                      message:
                                      "Currently No Individual Items Available",
                                      fromLanguage:
                                      "English",
                                      toLanguage:
                                      defaultLanguage,
                                      builder: (translatedMessage) => Text(
                                          translatedMessage,
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                ],
                              ),

                            Visibility(
                              visible: false,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: 16,
                                    top: 8,
                                    left: 16),
                                child: Align(
                                  alignment:
                                  Alignment.bottomCenter,
                                  child: Container(
                                    width:
                                    MediaQuery.of(context)
                                        .size
                                        .width,
                                    margin: EdgeInsets.only(
                                        top: 30, bottom: 0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius
                                          .circular(45),
                                      gradient:
                                      LinearGradient(
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
                                      onPressed: () {
                                        if (currentUser.value
                                            .apiToken ==
                                            null) {

                                          Navigator.of(
                                              context)
                                              .pushNamed(
                                              "/Login");
                                        } else {
                                          print("DS>> else");
                                          if (_foodcon
                                              !.isSameRestaurants(
                                              _foodcon
                                                  !.food!)!) {
                                            print(
                                                "DS>> else if");
                                            addFoodToCart(
                                                foodList);
                                            // _foodcon.addToCart(_foodcon.food);
                                          } else {
                                           /* showDialog(
                                              context:
                                              context,
                                              builder:
                                                  (BuildContext
                                              context) {
                                                // return object of type Dialog
                                                return AddToCartAlertDialogWidget(
                                                    oldFood: _foodcon
                                                        .carts
                                                        .elementAt(
                                                        0)
                                                        ?.food,
                                                    newFood:
                                                    _foodcon
                                                        .food,
                                                    onPressed:
                                                        (food,
                                                        {reset: true}) {
                                                      return _foodcon.addToCart(
                                                          _foodcon
                                                              .food,
                                                          reset:
                                                          true);
                                                    });
                                              },
                                            );*/
                                          }
                                        }
                                      },
                                      padding: EdgeInsets
                                          .symmetric(
                                          horizontal: 40,
                                          vertical: 8),
                                      shape: StadiumBorder(),

                                      //color: Theme.of(context).accentColor,
                                      child: Wrap(
                                        spacing: 10,
                                        children: [
                                          TranslationWidget(
                                            message:
                                            "Order Now",
                                            fromLanguage:
                                            "English",
                                            toLanguage:
                                            defaultLanguage,
                                            builder:
                                                (translatedMessage) =>
                                                Text(
                                                  translatedMessage,
                                                  style: TextStyle(
                                                      color: Theme.of(
                                                          context)
                                                          .primaryColor,
                                                      fontSize:
                                                      16),
                                                ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (foodList.isNotEmpty || (totalQuantity != null && totalQuantity > 0))
                    Visibility(
                      visible: true,
                      child: Container(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            onTap: () {
                              if (currentUser.value
                                  .apiToken ==
                                  "") {
                                print("quantity remove");
                                Provider.of<QuantityProvider>(context,listen: false).clearQuantity();
                                Navigator.of(
                                    context)
                                    .pushNamed(
                                    "/Login");
                              } else {
                                print("DS>> else");

                                  print(
                                      "DS>> else if");
                                  addFoodToCart(
                                      foodList);
                                  // _foodcon.addToCart(_foodcon.food);
                               /* } else {
                                  *//*showDialog(
                                    context:
                                    context,
                                    builder:
                                        (BuildContext
                                    context) {
                                      // return object of type Dialog
                                      return AddToCartAlertDialogWidget(
                                          oldFood: _foodcon
                                              .carts
                                              .elementAt(
                                              0)
                                              ?.food,
                                          newFood:
                                          _foodcon
                                              .food,
                                          onPressed:
                                              (food,
                                              {reset: true}) {
                                            return _foodcon.addToCart(
                                                _foodcon
                                                    .food,
                                                reset:
                                                true);
                                          });
                                    },
                                  );*//*
                                }*/
                              }
                            },
                            child: Container(
                              height: 55,
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.only(
                                  left: 10, bottom: 5),
                              width:
                              MediaQuery.of(context).size.width *
                                  0.9,
                              decoration: BoxDecoration(
                                //   color: Color.fromRGBO(237, 236, 237, 1),
                                gradient: LinearGradient(
                                  colors: [
                                    kPrimaryColororange,
                                    kPrimaryColorLiteorange
                                  ],
                                ),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: ! iscartload ?  Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [


                                  Text("${Provider.of<QuantityProvider>(context).getTotalQuantityForRestaurant(_con!.restaurant!.id!)} Item added ",style: TextStyle(color: Colors.white,fontSize:
                                  16),),
                                  Icon(Icons.arrow_circle_right_outlined,color: Colors.white,)
                                ],
                              ):Center(child: CircularProgressIndicator(color: Colors.white,)),
                            ),
                          ))

                      /* Consumer<OrderProvider>(


                                  builder: (context, orderProvider, _) {
                                    // Check if there is an ongoing order
                                    if (orderProvider.orders.isNotEmpty) {
                                      // Get the latest order status
                                      final latestOrderStatus = orderProvider.orders.first;
                                      String status  =  orderProvider.getStatusNameById(latestOrderStatus["order_status_id"].toString());
                                      return Container(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: 55,
                                          padding: EdgeInsets.all(5),
                                          margin: EdgeInsets.only(left: 10, bottom: 5),
                                          width: MediaQuery.of(context).size.width * 0.9,
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(237, 236, 237, 1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              // Display an icon or image indicating order status
                                              //    Icon(Icons.shopping_bag, color: Colors.blue),
                                              SizedBox(width: 10),
                                              Text("Your order #${latestOrderStatus["id"]} is $status"),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    // Add button or action to view order details
                                                    IconButton(
                                                      onPressed: ()async {
                                                        if(latestOrderStatus["delivery_dinein"] == 1)
                                                          await settingRepo.navigatorKey.currentState.pushNamed('/Tracking',
                                                              arguments: RouteArgument(
                                                                  id:latestOrderStatus["id"].toString(),
                                                                  heroTag:
                                                                  "1"));
                                                        else if(latestOrderStatus["delivery_dinein"] == 2){
                                                          await settingRepo.navigatorKey.currentState.pushNamed('/TrackingForDinein',
                                                              arguments: RouteArgument(
                                                                  id: latestOrderStatus["id"].toString(),
                                                                  // latitude:widget.order.res_latitude,
                                                                  //longitude:widget.order.res_longitude,
                                                                  heroTag:
                                                                  "2"));
                                                        }
                                                        // Implement action to close the popup
                                                      },
                                                      icon: Icon(Icons.visibility,size: 20, color: Colors.redAccent,),
                                                    ),
                                                    // Add button or action to close the popup
                                                    IconButton(
                                                      onPressed: () {
                                                        orderProvider.closeorder();
                                                        // Implement action to close the popup
                                                      },
                                                      icon: Icon(Icons.close,size: 20,),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      // If there are no ongoing orders, return an empty container
                                      return Container();
                                    }
                                  },
                                )*/
                      ,
                    ),
                ],
              ),
            )
                : widget.currentPage;
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:   FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                  parentScaffoldKey: widget.parentScaffoldKey,
                  currentTab: 1,
                  directedFrom: "forHome",
                )),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56.0,
          height: 56.0,
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:Colors.white,

          ),
          child: Image.asset("assets/img/logo_bottom.png"),
        ),
      ),


      bottomNavigationBar:

      BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        height: 65,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 70),
                child: IconButton(
                  icon: const Icon(
                    Icons.assignment,
                    size: 30,
                  ),
                  onPressed: () {
                    if (currentUser.value.apiToken != "") {
                      Navigator.of(context).pushNamed('/orderPage', arguments: 0);
                    } else {
                      Navigator.of(context).pushNamed('/Login');
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 30,
                ),
                onPressed: () {
                  if(currentUser.value.apiToken != ""){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartWidget(
                          parentScaffoldKey: widget.parentScaffoldKey,
                        ),
                      ),
                    );}
                  else{
                    Navigator.of(context).pushNamed('/Login');
                  }
                },
              ),
            ],
          ),
        ),
      )
      ,
    );
  }

  void addFoodToCart(List<Food> foodList) {
    Map<int, double> groupedFood = {};
    setState(() {
      iscartload =  true;
    });
    //   print("object==============> ${foodListNew.length}");
    if(foodListNew.isNotEmpty || foodList.isNotEmpty){
      for (int i = 0; i < foodListNew.length; i++) {
        int foodId = int.parse(foodListNew[i].id);
        int quantity = Provider.of<QuantityProvider>(context, listen : false).getQuantity(foodListNew[i].restaurant!.id!, int.parse(foodListNew[i].id));
        //    print(quantity);
        groupedFood[foodId] = quantity.toDouble();

      }
      groupedFood.forEach((foodId, quantity) {
        Food food = foodListNew.firstWhere((item) => item.id == foodId.toString());
        // print(food.restaurant!.id);
        //print(_controller.kitchenDetails.id);
        // print("object calling======>asa ${food.restaurant!.name}");
        //   print("${selectedCoupon.code} ++ ${selectedCoupon.id}");

        _foodcon!.addToCart(food,
            quantity: quantity, restaurant_id: _controller!.kitchenDetails.id,coupon_id:selectedCoupon != null? selectedCoupon!.id: null);
      });

      if (currentUser.value.apiToken != "") {
        Provider.of<CartProvider>(context, listen: false).loadCartItems();
        Provider.of<CartProvider>(context, listen: false).listenForCartsCount();
        //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Items is Add in the Cart")));
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            iscartload =  false;
            foodListNew.clear();
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  CartWidget(parentScaffoldKey: widget.parentScaffoldKey),
            ),
          );
        });
      } else {

        Navigator.of(context).pushNamed('/Login');
      }


    }
    else{
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          iscartload =  false;
          foodListNew.clear();
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                CartWidget(parentScaffoldKey: widget.parentScaffoldKey),
          ),
        );
      });
    }
    /* if (foodList.isEmpty) {
      Fluttertoast.showToast(msg: "please select the food");
    }
    else
    {
      for (int i = 0; i < foodList.length; i++) {
        int foodId = int.parse(foodList[i].id);
        double quantity = groupedFood[foodId] ?? 0.0;
        quantity += 1.0;
        groupedFood[foodId] = quantity;
      }
      print(groupedFood);

      // Add the grouped food items to the cart
      groupedFood.forEach((foodId, quantity) {
        Food food = foodList.firstWhere((item) => item.id == foodId.toString());
        // print(food.restaurant!.id);
        //print(_controller.kitchenDetails.id);
       // print("object calling======>asa ${food.restaurant!.name}");
     //   print("${selectedCoupon.code} ++ ${selectedCoupon.id}");

        _foodcon.addToCart(food,
            quantity: quantity, restaurant_id: _controller.kitchenDetails.id,coupon_id:selectedCoupon != null? selectedCoupon.id: null);
      });


      if (currentUser.value.apiToken != "") {
        Provider.of<CartProvider>(context, listen: false).loadCartItems();
        Provider.of<CartProvider>(context, listen: false).listenForCartsCount();
        //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Items is Add in the Cart")));
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            iscartload =  false;
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  CartWidget(parentScaffoldKey: widget.parentScaffoldKey),
            ),
          );
        });
      } else {
        Navigator.of(context).pushNamed('/Login');
      }
    }*/
    // Group the food items by their IDs and sum the quantities
  }

  void _selectTab(int tabItem) {
    setState(() {
      print("DS>> am i here?? " + tabItem.toString());
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          if (currentUser.value.apiToken != "") {
            Navigator.of(context).pushNamed('/orderPage', arguments: 0);
          } else {
            Navigator.of(context).pushNamed('/Login');
          }

          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CalendarDialogWithoutRestaurant()),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                  parentScaffoldKey: widget.parentScaffoldKey,
                  currentTab: 1,
                  directedFrom: "forHome",
                )),
          );
          break;
        case 5:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => KitchenListDeliveryWidget(
                  restaurantsList: widget._con!.AllRestaurantsDelivery,
                  heroTag: "KitchenListDelivery",
                )),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartWidget(
                parentScaffoldKey: widget.parentScaffoldKey,
              ),
            ),
          );
          break;
      }
    });
  }

  void showBreakFastView() async {
    print("show breakfast called");
    setState(() {
      // breakfast_food.addAll(breakfastFoods);
      isbreackfastLoadmore = false;
      print("show breakfast called in setstate");
      widget.isBreakfastVisible = true;
      widget.isLunchVisible = false;
      widget.isSnacksVisible = false;
      widget.isDinnerVisible = false;

      widget.isBreakfastSelected = true;
      widget.isLunchSelected = false;
      widget.isSnacksSelected = false;
      widget.isDinnerSelected = false;
      isbreackfastLoad = true;
    });
    List<FoodItem> breakfastFoods = [];
    getFoodsByCategoryAndKitchenlist(8, _con!.restaurant!.id!,enjoy: enjoy!).then((value) {
      setState(() {
        breakfast_food.clear();
        breakfast_food.addAll(value);
        isbreackfastLoad = false;
      });
    });
  }

  void showLunchView() async {
    lunch_food.clear();
    print("show lunch called");

    setState(() {
      islunchLoadmore = false;
      print("show lunch called in setstate");
      widget.isBreakfastVisible = false;
      widget.isLunchVisible = true;
      widget.isSnacksVisible = false;
      widget.isDinnerVisible = false;

      widget.isBreakfastSelected = false;
      widget.isLunchSelected = true;
      widget.isSnacksSelected = false;
      widget.isDinnerSelected = false;
      islunchLoad = true;
    });
    // List<FoodItem> breakfastFoods = [];
    getFoodsByCategoryAndKitchenlist(9, _con!.restaurant!.id!,enjoy: enjoy!).then((value) {
      setState(() {
        lunch_food.clear();
        lunch_food.addAll(value);
        islunchLoad = false;
      });
    });
  }

  void showSnacksView() async {
    snack_food.clear();
    print("show snacks called");
    // List<FoodItem> breakfastFoods =
    //     await getFoodsByCategoryAndKitchenlist(7, _con!.restaurant!.id);
    setState(() {
      // snack_food.addAll(breakfastFoods);
      issnacksLoadmore = false;
      print("show snacks called in setstate");
      widget.isBreakfastVisible = false;
      widget.isLunchVisible = false;
      widget.isSnacksVisible = true;
      widget.isDinnerVisible = false;

      widget.isBreakfastSelected = false;
      widget.isLunchSelected = false;
      widget.isSnacksSelected = true;
      widget.isDinnerSelected = false;
      issnacksLoad = true;
    });
    // List<FoodItem> breakfastFoods = [];
    getFoodsByCategoryAndKitchenlist(7, _con!.restaurant!.id!,enjoy: enjoy!).then((value) {
      setState(() {
        snack_food.clear();
        snack_food.addAll(value);
        issnacksLoad = false;
      });
    });
  }

  void showDinnerView() async {
    dinner_food.clear();
    // print("show dinner called");
    // List<FoodItem> breakfastFoods =
    //     await getFoodsByCategoryAndKitchenlist(10, _con!.restaurant!.id);
    setState(() {
      // dinner_food.addAll(breakfastFoods);
      isdinnerLoadmore = false;
      print("show dinner called in setstate");
      widget.isBreakfastVisible = false;
      widget.isLunchVisible = false;
      widget.isSnacksVisible = false;
      widget.isDinnerVisible = true;

      widget.isBreakfastSelected = false;
      widget.isLunchSelected = false;
      widget.isSnacksSelected = false;
      widget.isDinnerSelected = true;
      isdinnerLoad = true;
    });
    // List<FoodItem> breakfastFoods = [];
    getFoodsByCategoryAndKitchenlist(10, _con!.restaurant!.id!,enjoy: enjoy!).then((value) {
      setState(() {
        dinner_food.clear();
        dinner_food.addAll(value);
        isdinnerLoad = false;
      });
    });
  }

  Widget buildBreakfastFoods(
      List<FoodItem> breakfastFoods, int categoryId, String RestaurantId) {
    List<String> updatedQuantities = List.filled(breakfastFoods.length, "0");
    final provider = Provider.of<QuantityProvider>(context, listen: false);
    //   provider.initializeQuantities(breakfastFoods.length);
    final ScrollController _scrollController = ScrollController();
    void _loadMoreData() async {
      List<FoodItem> moreFoods = await getFoodsByCategoryAndKitchenlist(
          categoryId, RestaurantId,
          enjoy: enjoy!,
          limit: 4, offset: breakfastFoods.length);

      if (moreFoods.length == 0) {
        setState(() {
          isbreackfastLoadmore = true;
        });
      }
      moreFoods = moreFoods
          .where((food) =>
      !breakfastFoods.any((existingFood) => existingFood.id == food.id))
          .toList();
      setState(() {
        breakfastFoods.addAll(moreFoods);
      });
    }

    if (isbreackfastLoad) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          child: Card(
            child: Container(
              height: 100,
            ),
          ),
        ),
      );
    } else {
      if (breakfastFoods.isEmpty) {
        // If there are no breakfast foods available, display a message or placeholder
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/img/No-food.png", height: 100, width: 100),
              Text("No Food Available"),
            ],
          ),
        );
      } else {
        // If breakfast foods are available, display them
        return Column(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: breakfastFoods.asMap().entries.map((entry) {
                  final index = entry.key;
                  final breakfastFoodItem = entry.value;

                  if (index == breakfastFoods.length - 1 &&
                      isbreackfastLoadmore == false) {
                    _loadMoreData();
                  }
                  // final index = entry.key;
                  int quantity =
                      itemQuantities[breakfastFoodItem.id.toString()] ?? 0;
                  // print(itemQuantities[breakfastFoodItem.id.toString()]);
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    child: Card(
                      elevation: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TranslationWidget(
                                    message: breakfastFoodItem.name,
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TranslationWidget(
                                    message: Helper.skipHtml(
                                        breakfastFoodItem.description),
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                      softWrap: false,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  breakfastFoodItem.discountPrice > 0 && breakfastFoodItem.discountPrice != null?
                                  Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: "₹",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).hintColor,
                                            fontSize: 20,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: breakfastFoodItem.discountPrice.toString(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                //decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      RichText(
                                        text: TextSpan(
                                          text: "₹",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).hintColor,
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: breakfastFoodItem.price.toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ):
                                  RichText(

                                    text: TextSpan(
                                      text: "₹",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).hintColor,
                                        fontSize: 20,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: breakfastFoodItem.price.toString(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            //decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (_con!.restaurant!.closed == "1") {
                                            _showClosedDialog(context);
                                          } else {
                                            print("DS>> GD decrement");
                                            _foodcon!.decrementQuantity();
                                            setState(() {
                                              print("hello");
                                              if (quantity > 0) {
                                                quantity--;
                                                itemQuantities[breakfastFoodItem
                                                    .id
                                                    .toString()] = quantity;
                                              }
                                              bool foodExists = foodListNew.any((food) => food.id == breakfastFoodItem.id.toString());
                                              if (!foodExists)
                                                foodListNew.add(Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    restaurant: _con!.restaurant,
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia
                                                        .length ==
                                                        0
                                                        ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                        : breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));
                                              updatedQuantity = _foodcon
                                                  !.quantity
                                                  .toInt()
                                                  .toString();
                                              removeFoodFromList(Food.withId(
                                                  id: breakfastFoodItem.id
                                                      .toString(),
                                                  foodImg: breakfastFoodItem
                                                      .comboMedia
                                                      .length ==
                                                      0
                                                      ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                      : breakfastFoodItem
                                                      .comboMedia[0].url,
                                                  name: breakfastFoodItem.name,
                                                  price: double.parse(
                                                      breakfastFoodItem.price
                                                          .toString())));
                                              /*updateFoodList(new Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));*/
                                            });
                                          } //provider.decrementQuantity(index);

                                          provider.decrementQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id);


                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Theme.of(context).hintColor),
                                            color: Colors.white,
                                          ),
                                          child: InkWell(
                                            child: GestureDetector(

                                              child: Icon(
                                                Icons.remove,
                                                size: 15,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 35,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              provider.getQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id).toString(),

                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (_con!.restaurant!.closed == "1") {
                                            _showClosedDialog(context);
                                          } else {
                                            print("DS>> GD increment" +
                                                _foodcon!.quantity.toString());
                                            _foodcon!.incrementQuantity();
                                            setState(() {
                                              bool foodExists = foodListNew.any((food) => food.id == breakfastFoodItem.id.toString());
                                              if (!foodExists)
                                                foodListNew.add(Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    restaurant: _con!.restaurant,
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia
                                                        .length ==
                                                        0
                                                        ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                        : breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));
                                              //  print("hello");
                                              updatedQuantity = _foodcon
                                                  !.quantity
                                                  .toInt()
                                                  .toString();
                                              updateFoodList(new Food.withId(
                                                  id: breakfastFoodItem.id
                                                      .toString(),
                                                  foodImg: breakfastFoodItem
                                                      .comboMedia
                                                      .length ==
                                                      0
                                                      ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                      : breakfastFoodItem
                                                      .comboMedia[0].url,
                                                  name: breakfastFoodItem.name,
                                                  restaurant: breakfastFoodItem
                                                      .restaurant,
                                                  price: double.parse(
                                                      breakfastFoodItem.price
                                                          .toString())));
                                              quantity++;
                                              itemQuantities[breakfastFoodItem
                                                  .id
                                                  .toString()] = quantity;
                                            });


                                            setState(() {});
                                          }
                                          provider.incrementQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id);
                                          //    provider.incrementQuantity(index);
                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Theme.of(context).hintColor),
                                            color: Colors.white,
                                          ),
                                          child: InkWell(
                                            child: GestureDetector(

                                              child: Icon(
                                                Icons.add,
                                                size: 15,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )

                                  // Add buttons to increment and decrement quantity here
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Stack(
                              alignment: AlignmentDirectional.topStart,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _showDialog(context, breakfastFoodItem);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 135,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                      child: breakfastFoodItem.comboMedia.length ==
                                          0
                                          ? Image.asset(
                                          "assets/img/No_imge_food.png")
                                          : Image.network(
                                        breakfastFoodItem.comboMedia[0].url
                                            .toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                if (breakfastFoodItem.is_signature_food == "1")
                                  Container(
                                      child: Image.network(
                                        settingRepo.setting.value!.specialFoodImage,
                                        height: 50,
                                        width: 80,
                                        fit: BoxFit.fill,
                                      )),

                                // color: Colors.blue,
                                //child: Image.asset("assets/img/special.png",height: 50,width: 80,fit: BoxFit.fill,))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if(isbreackfastLoadmore == true && foodList.length > 0)
              SizedBox(height: 60,)
          ],
        );
      }
    }
  }

  void _showClosedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content:
          Text('Sorry, this restaurant is currently not accepting orders.'),
          actions: <Widget>[
            MaterialButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildLunchFoods(
      List<FoodItem> breakfastFoods, int categoryId, String RestaurantId) {
    List<String> updatedQuantities = List.filled(breakfastFoods.length, "0");
    final provider = Provider.of<QuantityProvider>(context);
    // provider.initializeQuantities(breakfastFoods.length);
    final ScrollController _scrollController = ScrollController();
    void _loadMoreData() async {
      List<FoodItem> moreFoods = await getFoodsByCategoryAndKitchenlist(
          categoryId, RestaurantId,
          enjoy: enjoy!,
          limit: 4, offset: breakfastFoods.length);

      if (moreFoods.length == 0) {
        setState(() {
          islunchLoadmore = true;
        });
      }
      moreFoods = moreFoods
          .where((food) =>
      !breakfastFoods.any((existingFood) => existingFood.id == food.id))
          .toList();
      setState(() {
        breakfastFoods.addAll(moreFoods);
      });
    }

    if (islunchLoad) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          child: Card(
            child: Container(
              height: 100,
            ),
          ),
        ),
      );
    } else {
      if (breakfastFoods.isEmpty) {
        // If there are no breakfast foods available, display a message or placeholder
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/img/No-food.png", height: 100, width: 100),
              Text("No Food Available"),
            ],
          ),
        );
      } else {
        // If breakfast foods are available, display them
        return Column(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: breakfastFoods.asMap().entries.map((entry) {
                  final index = entry.key;
                  final breakfastFoodItem = entry.value;

                  if (index == breakfastFoods.length - 1 &&
                      islunchLoadmore == false) {
                    _loadMoreData();
                  }
                  // final index = entry.key;
                  int quantity =
                      itemQuantities[breakfastFoodItem.id.toString()] ?? 0;
                  //   print(itemQuantities[breakfastFoodItem.id.toString()]);
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    child: Card(
                      elevation: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TranslationWidget(
                                    message: breakfastFoodItem.name,
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TranslationWidget(
                                    message: Helper.skipHtml(
                                        breakfastFoodItem.description),
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                      softWrap: false,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  breakfastFoodItem.discountPrice > 0 && breakfastFoodItem.discountPrice != null?
                                  Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: "₹",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).hintColor,
                                            fontSize: 20,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: breakfastFoodItem.discountPrice.toString(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                //decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      RichText(
                                        text: TextSpan(
                                          text: "₹",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).hintColor,
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: breakfastFoodItem.price.toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ):
                                  RichText(

                                    text: TextSpan(
                                      text: "₹",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).hintColor,
                                        fontSize: 20,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: breakfastFoodItem.price.toString(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            //decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (_con!.restaurant!.closed == "1") {
                                            _showClosedDialog(context);
                                          } else {
                                            print("DS>> GD decrement");
                                            _foodcon!.decrementQuantity();
                                            setState(() {
                                              print("hello");
                                              if (quantity > 0) {
                                                quantity--;
                                                itemQuantities[breakfastFoodItem
                                                    .id
                                                    .toString()] = quantity;
                                              }
                                              bool foodExists = foodListNew.any((food) => food.id == breakfastFoodItem.id.toString());
                                              if (!foodExists)
                                                foodListNew.add(Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    restaurant: _con!.restaurant,
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia
                                                        .length ==
                                                        0
                                                        ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                        : breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));
                                              updatedQuantity = _foodcon
                                                  !.quantity
                                                  .toInt()
                                                  .toString();
                                              removeFoodFromList(Food.withId(
                                                  id: breakfastFoodItem.id
                                                      .toString(),
                                                  foodImg: breakfastFoodItem
                                                      .comboMedia
                                                      .length ==
                                                      0
                                                      ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                      : breakfastFoodItem
                                                      .comboMedia[0].url,
                                                  name: breakfastFoodItem.name,
                                                  price: double.parse(
                                                      breakfastFoodItem.price
                                                          .toString())));
                                              /*updateFoodList(new Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));*/
                                            });
                                          } //provider.decrementQuantity(index);

                                          provider.decrementQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id);


                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Theme.of(context).hintColor),
                                            color: Colors.white,
                                          ),
                                          child: InkWell(
                                            child: GestureDetector(

                                              child: Icon(
                                                Icons.remove,
                                                size: 15,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 35,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              provider.getQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id).toString(),
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (_con!.restaurant!.closed == "1") {
                                            _showClosedDialog(context);
                                          } else {
                                            print("DS>> GD increment" +
                                                _foodcon!.quantity.toString());
                                            _foodcon!.incrementQuantity();
                                            setState(() {
                                              bool foodExists = foodListNew.any((food) => food.id == breakfastFoodItem.id.toString());
                                              if (!foodExists)
                                                foodListNew.add(Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    restaurant: _con!.restaurant,
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia
                                                        .length ==
                                                        0
                                                        ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                        : breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));
                                              //  print("hello");
                                              updatedQuantity = _foodcon
                                                  !.quantity
                                                  .toInt()
                                                  .toString();
                                              updateFoodList(new Food.withId(
                                                  id: breakfastFoodItem.id
                                                      .toString(),
                                                  foodImg: breakfastFoodItem
                                                      .comboMedia
                                                      .length ==
                                                      0
                                                      ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                      : breakfastFoodItem
                                                      .comboMedia[0].url,
                                                  name: breakfastFoodItem.name,
                                                  restaurant: breakfastFoodItem
                                                      .restaurant,
                                                  price: double.parse(
                                                      breakfastFoodItem.price
                                                          .toString())));
                                              quantity++;
                                              itemQuantities[breakfastFoodItem
                                                  .id
                                                  .toString()] = quantity;
                                            });


                                            setState(() {});
                                          }
                                          provider.incrementQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id);
                                          //    provider.incrementQuantity(index);
                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Theme.of(context).hintColor),
                                            color: Colors.white,
                                          ),
                                          child: InkWell(
                                            child: GestureDetector(

                                              child: Icon(
                                                Icons.add,
                                                size: 15,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )

                                  // Add buttons to increment and decrement quantity here
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Stack(
                              alignment: AlignmentDirectional.topStart,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _showDialog(context, breakfastFoodItem);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 135,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                      child: breakfastFoodItem.comboMedia.length ==
                                          0
                                          ? Image.asset(
                                          "assets/img/No_imge_food.png")
                                          : Image.network(
                                        breakfastFoodItem.comboMedia[0].url
                                            .toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                if (breakfastFoodItem.is_signature_food == "1")
                                  Container(
                                      child: Image.network(
                                        settingRepo.setting.value.specialFoodImage,
                                        height: 50,
                                        width: 80,
                                        fit: BoxFit.fill,
                                      )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if(islunchLoadmore == true && foodList.length > 0)
              SizedBox(height: 60,)
          ],
        );
      }
    }
  }

  Widget buildSnacksFoods(
      List<FoodItem> breakfastFoods, int categoryId, String RestaurantId) {
    List<String> updatedQuantities = List.filled(breakfastFoods.length, "0");
    final provider = Provider.of<QuantityProvider>(context, listen: false);
    // provider.initializeQuantities(breakfastFoods.length);
    final ScrollController _scrollController = ScrollController();
    void _loadMoreData() async {
      List<FoodItem> moreFoods = await getFoodsByCategoryAndKitchenlist(
          categoryId, RestaurantId,
          enjoy: enjoy!,
          limit: 4, offset: breakfastFoods.length);

      if (moreFoods.length == 0) {
        setState(() {
          issnacksLoadmore = true;
        });
      }
      moreFoods = moreFoods
          .where((food) =>
      !breakfastFoods.any((existingFood) => existingFood.id == food.id))
          .toList();
      setState(() {
        breakfastFoods.addAll(moreFoods);
      });
    }

    if (issnacksLoad) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          child: Card(
            child: Container(
              height: 100,
            ),
          ),
        ),
      );
    } else {
      if (breakfastFoods.isEmpty) {
        // If there are no breakfast foods available, display a message or placeholder
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/img/No-food.png", height: 100, width: 100),
              Text("No Food Available"),
            ],
          ),
        );
      } else {
        // If breakfast foods are available, display them
        return Column(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: breakfastFoods.asMap().entries.map((entry) {
                  final index = entry.key;
                  final breakfastFoodItem = entry.value;

                  if (index == breakfastFoods.length - 1 &&
                      issnacksLoadmore == false) {
                    _loadMoreData();
                  }
                  // final index = entry.key;
                  int quantity =
                      itemQuantities[breakfastFoodItem.id.toString()] ?? 0;
                  //  print(itemQuantities[breakfastFoodItem.id.toString()]);
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    child: Card(
                      elevation: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TranslationWidget(
                                    message: breakfastFoodItem.name,
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TranslationWidget(
                                    message: Helper.skipHtml(
                                        breakfastFoodItem.description),
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                      softWrap: false,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  breakfastFoodItem.discountPrice > 0 && breakfastFoodItem.discountPrice != null?
                                  Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: "₹",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).hintColor,
                                            fontSize: 20,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: breakfastFoodItem.discountPrice.toString(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                //decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      RichText(
                                        text: TextSpan(
                                          text: "₹",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).hintColor,
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: breakfastFoodItem.price.toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ):
                                  RichText(

                                    text: TextSpan(
                                      text: "₹",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).hintColor,
                                        fontSize: 20,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: breakfastFoodItem.price.toString(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            //decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (_con!.restaurant!.closed == "1") {
                                            _showClosedDialog(context);
                                          } else {
                                            print("DS>> GD decrement");
                                            _foodcon!.decrementQuantity();
                                            setState(() {
                                              print("hello");
                                              if (quantity > 0) {
                                                quantity--;
                                                itemQuantities[breakfastFoodItem
                                                    .id
                                                    .toString()] = quantity;
                                              }
                                              bool foodExists = foodListNew.any((food) => food.id == breakfastFoodItem.id.toString());
                                              if (!foodExists)
                                                foodListNew.add(Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    restaurant: _con!.restaurant,
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia
                                                        .length ==
                                                        0
                                                        ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                        : breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));
                                              // updatedQuantity = _foodcon
                                              //     .quantity
                                              //     .toInt()
                                              //     .toString();
                                              /* removeFoodFromList(Food.withId(
                                                  id: breakfastFoodItem.id
                                                      .toString(),
                                                  foodImg: breakfastFoodItem
                                                      .comboMedia
                                                      .length ==
                                                      0
                                                      ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                      : breakfastFoodItem
                                                      .comboMedia[0].url,
                                                  name: breakfastFoodItem.name,
                                                  price: double.parse(
                                                      breakfastFoodItem.price
                                                          .toString())));*/
                                              /*updateFoodList(new Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));*/
                                              provider.decrementQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id);
                                            });
                                          } //provider.decrementQuantity(index);




                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Theme.of(context).hintColor),
                                            color: Colors.white,
                                          ),
                                          child: InkWell(
                                            child: GestureDetector(
                                              /*onTap: () {
                                                if (_con!.restaurant!.closed == "1") {
                                                  _showClosedDialog(context);
                                                } else {
                                                  print("DS>> GD decrement");
                                                  _foodcon.decrementQuantity();
                                                  setState(() {
                                                    print("hello");
                                                    if (quantity > 0) {
                                                      quantity--;
                                                      itemQuantities[breakfastFoodItem
                                                          .id
                                                          .toString()] = quantity;
                                                    }
                                                    updatedQuantity = _foodcon
                                                        .quantity
                                                        .toInt()
                                                        .toString();
                                                    removeFoodFromList(Food.withId(
                                                        id: breakfastFoodItem.id
                                                            .toString(),
                                                        foodImg: breakfastFoodItem
                                                                    .comboMedia
                                                                    .length ==
                                                                0
                                                            ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                            : breakfastFoodItem
                                                                .comboMedia[0].url,
                                                        name: breakfastFoodItem.name,
                                                        price: double.parse(
                                                            breakfastFoodItem.price
                                                                .toString())));
                                                    */
                                              /*updateFoodList(new Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));*/
                                              /*
                                                  });
                                                } //provider.decrementQuantity(index);
                                              },*/
                                              child: Icon(
                                                Icons.remove,
                                                size: 15,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 35,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              Provider.of<QuantityProvider>(context).getQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id).toString(),
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (_con!.restaurant!.closed == "1") {
                                            _showClosedDialog(context);
                                          } else {
                                            print("DS>> GD increment" +
                                                _foodcon!.quantity.toString());
                                            // _foodcon.incrementQuantity();
                                            setState(() {
                                              bool foodExists = foodListNew.any((food) => food.id == breakfastFoodItem.id.toString());
                                              if (!foodExists)
                                                foodListNew.add(Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    restaurant: _con!.restaurant,
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia
                                                        .length ==
                                                        0
                                                        ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                        : breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));
                                              //  print("hello");
                                              // updatedQuantity = _foodcon
                                              //     .quantity
                                              //     .toInt()
                                              //     .toString();
                                              /* updateFoodList(new Food.withId(
                                                  id: breakfastFoodItem.id
                                                      .toString(),
                                                  foodImg: breakfastFoodItem
                                                      .comboMedia
                                                      .length ==
                                                      0
                                                      ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                      : breakfastFoodItem
                                                      .comboMedia[0].url,
                                                  name: breakfastFoodItem.name,
                                                  restaurant: breakfastFoodItem
                                                      .restaurant,
                                                  price: double.parse(
                                                      breakfastFoodItem.price
                                                          .toString())));
                                              quantity++;
                                              itemQuantities[breakfastFoodItem
                                                  .id
                                                  .toString()] = quantity;*/
                                              provider.incrementQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id);
                                            });



                                          }

                                          //    provider.incrementQuantity(index);
                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Theme.of(context).hintColor),
                                            color: Colors.white,
                                          ),
                                          child: InkWell(
                                            child: GestureDetector(
                                              /*  onTap: () {
                                                if (_con!.restaurant!.closed == "1") {
                                                  _showClosedDialog(context);
                                                } else {
                                                  print("DS>> GD increment" +
                                                      _foodcon.quantity.toString());
                                                  _foodcon.incrementQuantity();
                                                  setState(() {
                                                    //  print("hello");
                                                    updatedQuantity = _foodcon
                                                        .quantity
                                                        .toInt()
                                                        .toString();
                                                    updateFoodList(new Food.withId(
                                                        id: breakfastFoodItem.id
                                                            .toString(),
                                                        foodImg: breakfastFoodItem
                                                                    .comboMedia
                                                                    .length ==
                                                                0
                                                            ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                            : breakfastFoodItem
                                                                .comboMedia[0].url,
                                                        name: breakfastFoodItem.name,
                                                        restaurant: breakfastFoodItem
                                                            .restaurant,
                                                        price: double.parse(
                                                            breakfastFoodItem.price
                                                                .toString())));
                                                    quantity++;
                                                    itemQuantities[breakfastFoodItem
                                                        .id
                                                        .toString()] = quantity;
                                                  });
                                                  setState(() {});
                                                } //    provider.incrementQuantity(index);
                                              },*/
                                              child: Icon(
                                                Icons.add,
                                                size: 15,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )

                                  // Add buttons to increment and decrement quantity here
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Stack(
                              alignment: AlignmentDirectional.topStart,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _showDialog(context, breakfastFoodItem);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 135,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                      child: breakfastFoodItem.comboMedia.length ==
                                          0
                                          ? Image.asset(
                                          "assets/img/No_imge_food.png")
                                          : Image.network(
                                        breakfastFoodItem.comboMedia[0].url
                                            .toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                if (breakfastFoodItem.is_signature_food == "1")
                                  Container(
                                      child: Image.network(
                                        settingRepo.setting.value.specialFoodImage,
                                        height: 50,
                                        width: 80,
                                        fit: BoxFit.fill,
                                      )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if(issnacksLoadmore == true && foodList.length > 0)
              SizedBox(height: 60,)
          ],
        );
      }
    }
  }

  Widget buildDinnerFoods(
      List<FoodItem> breakfastFoods, int categoryId, String RestaurantId) {
    List<String> updatedQuantities = List.filled(breakfastFoods.length, "0");
    final provider = Provider.of<QuantityProvider>(context, listen: false);
    // provider.initializeQuantities(breakfastFoods.length);
    final ScrollController _scrollController = ScrollController();
    void _loadMoreData() async {
      List<FoodItem> moreFoods = await getFoodsByCategoryAndKitchenlist(
          categoryId, RestaurantId,
          enjoy: enjoy!,
          limit: 4, offset: breakfastFoods.length);

      if (moreFoods.length == 0) {
        setState(() {
          isdinnerLoadmore = true;
        });
      }
      moreFoods = moreFoods
          .where((food) =>
      !breakfastFoods.any((existingFood) => existingFood.id == food.id))
          .toList();
      setState(() {
        breakfastFoods.addAll(moreFoods);
      });
    }

    if (isdinnerLoad) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          child: Card(
            child: Container(
              height: 100,
            ),
          ),
        ),
      );
    } else {
      if (breakfastFoods.isEmpty) {
        // If there are no breakfast foods available, display a message or placeholder
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/img/No-food.png", height: 100, width: 100),
              Text("No Food Available"),
            ],
          ),
        );
      } else {
        // If breakfast foods are available, display them
        return Column(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: breakfastFoods.asMap().entries.map((entry) {
                  final index = entry.key;
                  final breakfastFoodItem = entry.value;

                  if (index == breakfastFoods.length - 1 &&
                      isdinnerLoadmore == false) {
                    _loadMoreData();
                  }
                  // final index = entry.key;
                  int quantity =
                      itemQuantities[breakfastFoodItem.id.toString()] ?? 0;
                  //  print(itemQuantities[breakfastFoodItem.id.toString()]);
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    child: Card(
                      elevation: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TranslationWidget(
                                    message: breakfastFoodItem.name,
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TranslationWidget(
                                    message: Helper.skipHtml(
                                        breakfastFoodItem.description),
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                      softWrap: false,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  breakfastFoodItem.discountPrice > 0 && breakfastFoodItem.discountPrice != null?
                                  Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: "₹",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).hintColor,
                                            fontSize: 20,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: breakfastFoodItem.discountPrice.toString(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                //decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      RichText(
                                        text: TextSpan(
                                          text: "₹",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).hintColor,
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: breakfastFoodItem.price.toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ):
                                  RichText(

                                    text: TextSpan(
                                      text: "₹",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).hintColor,
                                        fontSize: 20,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: breakfastFoodItem.price.toString(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            //decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (_con!.restaurant!.closed == "1") {
                                            _showClosedDialog(context);
                                          } else {
                                            print("DS>> GD decrement");
                                            _foodcon!.decrementQuantity();
                                            setState(() {
                                              print("hello");
                                              if (quantity > 0) {
                                                quantity--;
                                                itemQuantities[breakfastFoodItem
                                                    .id
                                                    .toString()] = quantity;
                                              }
                                              bool foodExists = foodListNew.any((food) => food.id == breakfastFoodItem.id.toString());
                                              if (!foodExists)
                                                foodListNew.add(Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    restaurant: _con!.restaurant,
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia
                                                        .length ==
                                                        0
                                                        ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                        : breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));
                                              updatedQuantity = _foodcon
                                                  !.quantity
                                                  .toInt()
                                                  .toString();
                                              removeFoodFromList(Food.withId(
                                                  id: breakfastFoodItem.id
                                                      .toString(),
                                                  foodImg: breakfastFoodItem
                                                      .comboMedia
                                                      .length ==
                                                      0
                                                      ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                      : breakfastFoodItem
                                                      .comboMedia[0].url,
                                                  name: breakfastFoodItem.name,
                                                  price: double.parse(
                                                      breakfastFoodItem.price
                                                          .toString())));
                                              /*updateFoodList(new Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));*/
                                            });
                                          } //provider.decrementQuantity(index);

                                          provider.decrementQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id);


                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Theme.of(context).hintColor),
                                            color: Colors.white,
                                          ),
                                          child: InkWell(
                                            child: GestureDetector(
                                              /* onTap: () {
                                                print("DS>> GD decrement");
                                                _foodcon.decrementQuantity();
                                                setState(() {
                                                  print("hello");
                                                  if (quantity > 0) {
                                                    quantity--;
                                                    itemQuantities[breakfastFoodItem
                                                        .id
                                                        .toString()] = quantity;
                                                  }
                                                  updatedQuantity = _foodcon.quantity
                                                      .toInt()
                                                      .toString();
                                                  removeFoodFromList(Food.withId(
                                                      id: breakfastFoodItem.id
                                                          .toString(),
                                                      foodImg: breakfastFoodItem
                                                                  .comboMedia
                                                                  .length ==
                                                              0
                                                          ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                          : breakfastFoodItem
                                                              .comboMedia[0].url,
                                                      name: breakfastFoodItem.name,
                                                      price: double.parse(
                                                          breakfastFoodItem.price
                                                              .toString())));
                                                  *//*updateFoodList(new Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));*//*
                                                });
                                                //provider.decrementQuantity(index);
                                              },*/
                                              child: Icon(
                                                Icons.remove,
                                                size: 15,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 35,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              Provider.of<QuantityProvider>(context).getQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id).toString(),
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (_con!.restaurant!.closed == "1") {
                                            _showClosedDialog(context);
                                          } else {
                                            print("DS>> GD increment" +
                                                _foodcon!.quantity.toString());
                                            _foodcon!.incrementQuantity();
                                            setState(() {
                                              bool foodExists = foodListNew.any((food) => food.id == breakfastFoodItem.id.toString());
                                              if (!foodExists)
                                                foodListNew.add(Food.withId(
                                                    id: breakfastFoodItem.id
                                                        .toString(),
                                                    restaurant: _con!.restaurant,
                                                    foodImg: breakfastFoodItem
                                                        .comboMedia
                                                        .length ==
                                                        0
                                                        ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                        : breakfastFoodItem
                                                        .comboMedia[0].url,
                                                    name: breakfastFoodItem.name,
                                                    price: double.parse(
                                                        breakfastFoodItem.price
                                                            .toString())));
                                              //  print("hello");
                                              updatedQuantity = _foodcon
                                                  !.quantity
                                                  .toInt()
                                                  .toString();
                                              updateFoodList(new Food.withId(
                                                  id: breakfastFoodItem.id
                                                      .toString(),
                                                  foodImg: breakfastFoodItem
                                                      .comboMedia
                                                      .length ==
                                                      0
                                                      ? "https://firebasestorage.googleapis.com/v0/b/comeeathome-bd91c.appspot.com/o/No_imge_food.png?alt=media&token=2a6c3b21-f3aa-4779-81d3-5192d1e7029c"
                                                      : breakfastFoodItem
                                                      .comboMedia[0].url,
                                                  name: breakfastFoodItem.name,
                                                  restaurant: breakfastFoodItem
                                                      .restaurant,
                                                  price: double.parse(
                                                      breakfastFoodItem.price
                                                          .toString())));
                                              quantity++;
                                              itemQuantities[breakfastFoodItem
                                                  .id
                                                  .toString()] = quantity;
                                            });


                                            setState(() {});
                                          }
                                          provider.incrementQuantity(breakfastFoodItem.restaurant!.id!,breakfastFoodItem.id);
                                          //    provider.incrementQuantity(index);
                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Theme.of(context).hintColor),
                                            color: Colors.white,
                                          ),
                                          child: InkWell(
                                            child: GestureDetector(

                                              child: Icon(
                                                Icons.add,
                                                size: 15,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )

                                  // Add buttons to increment and decrement quantity here
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Stack(
                              alignment: AlignmentDirectional.topStart,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _showDialog(context, breakfastFoodItem);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 135,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                      child: breakfastFoodItem.comboMedia.length ==
                                          0
                                          ? Image.asset(
                                          "assets/img/No_imge_food.png")
                                          : Image.network(
                                        breakfastFoodItem.comboMedia[0].url
                                            .toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                if (breakfastFoodItem.is_signature_food == "1")
                                  Container(
                                      child: Image.network(
                                        settingRepo.setting.value.specialFoodImage,
                                        height: 50,
                                        width: 80,
                                        fit: BoxFit.fill,
                                      )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if(isdinnerLoadmore == true && foodList.length > 0)
              SizedBox(height: 60,)
          ],
        );
      }
    }
  }

  void _showDialog(BuildContext context, FoodItem food) {
    // Calculate the height needed for the content
    double contentHeight = 300.0; // Base height for the dialog content
    if (food.description != null) {
      // Calculate height based on the number of lines in description
      int descriptionLines = (food.description.length / 30)
          .ceil(); // Assuming each line is 30 characters long
      contentHeight += descriptionLines * 20.0; // Each line height is 20
    }
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -50.0,
                left: MediaQuery.of(context).size.width / 2 - 15.0,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.black54,
                    maxRadius: 15.0,
                  ),
                ),
              ),
              Container(
                height: contentHeight > 500 ? 500 : contentHeight,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(244, 246, 251, .9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(5),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      food.comboMedia[0].url.toString(),
                                      height: 200,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Text(
                                    food.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Text(
                                    Helper.skipHtml(food.description) ?? '',
                                    textAlign: TextAlign.justify,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "₹",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).hintColor,
                                        fontSize: 18,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: food.price.toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



class QuantityProvider extends ChangeNotifier {
  Map<String, Map<int, int>> _quantities = {};

  void initializeQuantities(String restaurantId, List<int> foodIds) {
    _quantities[restaurantId] = {for (var id in foodIds) id: 0};
    print('Initialized quantities for restaurant $restaurantId: $_quantities');
    notifyListeners();
  }

  int getQuantity(String restaurantId, int foodId) {
    if (_quantities.containsKey(restaurantId)) {
      return _quantities[restaurantId]![foodId] ?? 0;
    } else {
      return 0;
    }
  }

  void incrementQuantity(String restaurantId, int foodId) {
    _ensureRestaurantInitialized(restaurantId);
    _quantities[restaurantId]![foodId] = (_quantities[restaurantId]![foodId] ?? 0) + 1;
    print('Incremented quantity for food $foodId at restaurant $restaurantId: ${_quantities[restaurantId]}');
    notifyListeners();
  }

  void _ensureRestaurantInitialized(String restaurantId) {
    if (!_quantities.containsKey(restaurantId)) {
      _quantities[restaurantId] = {};
    }
  }

  void decrementQuantity(String restaurantId, int foodId) {
    if (_quantities.containsKey(restaurantId) && _quantities[restaurantId]![foodId]! > 0) {
      _quantities[restaurantId]![foodId] = (_quantities[restaurantId]![foodId]! - 1)!;
      print('Decremented quantity for food $foodId at restaurant $restaurantId: ${_quantities[restaurantId]}');
      notifyListeners();
    }
  }

  void setQuantitiesFromCart(String restaurantId, List<Cart> cartItems) {
    _ensureRestaurantInitialized(restaurantId);
    for (var item in cartItems) {
      _quantities[restaurantId]![int.parse(item.food!.id)] = item.quantity!.toInt();
    }
    print('Set quantities from cart for restaurant $restaurantId: ${_quantities[restaurantId]}');
    notifyListeners();
  }

  void clearQuantity() {
    print("Clearing quantities");
    _quantities.clear();
    notifyListeners();
  }

  Map<int, int> getAllQuantities(String restaurantId) {
    return _quantities[restaurantId] ?? {};
  }

  int getTotalQuantityForRestaurant(String restaurantId) {
    if (_quantities.containsKey(restaurantId)) {
      return _quantities[restaurantId]!.values.fold(0, (sum, quantity) => sum! + quantity) ?? 0;
    }
    return 0;
  }
}

class HalfColoredIcon extends StatelessWidget {
  final IconData? icon;
  final double? size;
  final Color? color;

  HalfColoredIcon({
    this.icon,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [ color!.withOpacity(0.0),color!],
          stops: [0.5, 0.5],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: Icon(
        icon,
        size: size,
        color: Colors.grey,
      ),
    );
  }
}