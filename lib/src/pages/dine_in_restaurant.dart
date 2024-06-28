import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/controllers/food_controller.dart';
import 'package:food_delivery_app/src/elements/DineInIndividualFoodItemWidget.dart';
import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/kitchen_detail_response.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/pages/pages.dart';
import 'package:food_delivery_app/src/pages/restaurant.dart';
import 'package:food_delivery_app/src/pages/settings.dart';
import 'package:food_delivery_app/src/repository/food_repository.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';

import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
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
import '../models/add_to_favourite_model.dart';
import '../models/coupons.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import '../provider.dart';
import '../repository/user_repository.dart';
import 'coupen_restaurant.dart';
import 'dinein_summary_page.dart';

import '../repository/settings_repository.dart' as settingRepo;
import 'map.dart';

class DineInRestaurantWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  String? SelectedDate;
  String? SelectedTime;
  String? selectedPeople;
  dynamic currentTab;
  Widget currentPage = HomePage();
  bool isCurrentKitchen = true;

  bool isBreakfastVisible = false;
  bool isLunchVisible = false;
  bool isSnacksVisible = false;
  bool isDinnerVisible = false;

  bool isBreakfastSelected = false;
  bool isLunchSelected = false;
  bool isSnacksSelected = false;
  bool isDinnerSelected = false;

  HomeController _con = HomeController();

  DineInRestaurantWidget(
      {Key? key,
      this.parentScaffoldKey,
      this.routeArgument,
      this.SelectedDate,
      this.selectedPeople,
      this.SelectedTime})
      : super(key: key);

  @override
  _RestaurantWidgetState createState() {
    return _RestaurantWidgetState();
  }
}

class _RestaurantWidgetState extends StateMVC<DineInRestaurantWidget> {
  RestaurantController? _con;
  FoodController? _foodcon;
  HomeController? _homecon;
  String updatedQuantity = "0.0";
  List<Food> foodList = [];
  List<Food> foodListNew = [];
  CategoryController? _controller;
  CartController _cartController = CartController();
  String? day, month;
  int? total;
  int loader_count = 1;
  List<FoodItem> breakfast_food = <FoodItem>[];
  List<FoodItem> selected_food = <FoodItem>[];
  List<FoodItem> snack_food = <FoodItem>[];
  List<FoodItem> lunch_food = <FoodItem>[];
  List<FoodItem> dinner_food = <FoodItem>[];
  double min_price = 0;
  double max_price = 0;
  double subtotal = 0.0;
  final ScrollController _scrollController = ScrollController();
  bool showProgress = true;
  String selectedFood = "snacks";
  String defaultLanguage = "";
  DateTime currentTime = DateTime.now();
  int? currentHour;
  int? currentday;
  Coupon? selectedCoupon;
  bool isbreackfastLoadmore = false;
  bool islunchLoadmore = false;
  bool issnacksLoadmore = false;
  bool isdinnerLoadmore = false;
  bool isbreackfastLoad = false;
  bool islunchLoad = false;
  bool issnacksLoad = false;
  bool isdinnerLoad = false;
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
  FoodItem? breakfastFoodItem,
      lunchFoodItem,
      snacksFoodItem,
      dinnerFoodItem,
      selectedFoodItem,
      selectedPriceFood;
  bool isBreakfastAvailable = false,
      isLunchAvailable = false,
      isSnacksAvailable = false,
      isDinnerAvailable = false;
  Map<String, int> itemQuantities = {};

  _RestaurantWidgetState() : super(RestaurantController()) {
    _con = controller as RestaurantController?;
    _foodcon = FoodController();
    _homecon = HomeController();
    _controller = CategoryController();
  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode) {
      print("DS>> DefaultLanguageret " + _langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }

  @override
  void initState() {
    getCurrentDefaultLanguage();
    //
    _foodcon!.getKetchainDetails(widget.routeArgument!.id!, '1').then((value) {
      print("tacc");
    });
    _scheduleButtonPress();
    Provider.of<LoaderProvider>(context, listen: false).startLoading();
    Future.delayed(Duration(seconds: 3), () {
      Provider.of<LoaderProvider>(context, listen: false).stopLoading();
      //  setState(() { });
    });
    _con!.restaurant = widget.routeArgument!.param as Restaurant;
    // /* _controller.listenForFoodsByCategoryAndRestaurant(id: "8",
    //     restaurantId: _con!.restaurant.id);*/
    listenForFoodsByCategoryAndRestaurantHere(
        id: "8", restaurantId: _con!.restaurant!.id);
    /* listenForFoodsByCategoryAndRestaurantHere(
        id: "8", restaurantId: _con!.restaurant.id);
    _con!.listenForGalleries(_con!.restaurant.id);
    _con!.listenForFoodImages(_con.restaurant.image.toString());
    _con.listenForFeaturedFoods(_con.restaurant.id);
    _con.listenForRestaurantReviews(id: _con.restaurant.id);
    _con.listenForIndividualFoods(_con.restaurant.id);
    //_homecon.listenForTrendingFoods();

    _controller.listenForFoodsByCategoryAndKitchen(
        id: "8", restaurantId: _con.restaurant.id);*/
    _con!.foods = [];
    _homecon!.trendingFoodItems = [];
    _controller!.foods = [];
    print(widget.SelectedTime);
    String date = "";
    DateTime datetime = DateTime.parse(widget.SelectedDate.toString());
    date = DateFormat('dd MMM').format(datetime);
    print(date); // Output: 2023-06-21
    List<String> parts = date.split(' '); // Split the string by space

    day = parts[0]; // Extract the day
    month = parts[1]; // Extract the month
  //  _selectTab(widget.currentTab);
    currentHour = currentTime.hour;

    if (widget.SelectedTime == "Breakfast") {
      showBreakFastView();
    }

    if (widget.SelectedTime == "Lunch") {
      showLunchView();
    }

    if (widget.SelectedTime == "Snacks") {
      showSnacksView();
    }
    if (widget.SelectedTime == "Dinner") {
      showDinnerView();
    }
    super.initState();
  }

  void updateFoodList(Food food) {
    foodList.add(food);
  }
  DateTime todayWithTime(String time) {
    var currentTime = DateTime.now();
    final DateFormat timeFormat = DateFormat('HH:mm:ss');
    final parsedTime = timeFormat.parse(time);
    return DateTime(currentTime.year, currentTime.month, currentTime.day, parsedTime.hour, parsedTime.minute, parsedTime.second);
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
    //   min_price = double.parse(stream.restaurant!.price.min);
    //   max_price = double.parse(stream.restaurant!.price.max);
    // });
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  calculateTotal() {
    // total = (selectedFoodItem.price +
    //         (selectedFoodItem.price *
    //             double.parse(_con!.restaurant.defaultTax.toString()) /
    //             100))
    //     .toInt();
    // print("tax" + _con!.restaurant.defaultTax.toString());
    // print("total:::" + total.toString());
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  void _scheduleButtonPress() {
    Future.delayed(Duration(seconds: 4), () {

      breakfastslot_start = Provider.of<HomeProvider>(context,listen: false).categories[0].start_slot;
      breakfastslot_end = Provider.of<HomeProvider>(context,listen: false).categories[0].end_slot;
      lunchslot_start = Provider.of<HomeProvider>(context,listen: false).categories[1].start_slot;
      lunchslot_end = Provider.of<HomeProvider>(context,listen: false).categories[1].end_slot;
      snacksslot_start = Provider.of<HomeProvider>(context,listen: false).categories[2].start_slot;
      snacksslot_end = Provider.of<HomeProvider>(context,listen: false).categories[2].end_slot;
      dinnerslot_start = Provider.of<HomeProvider>(context,listen: false).categories[3].start_slot;
      dinnerslot_end = Provider.of<HomeProvider>(context,listen: false).categories[3].end_slot;
      print(breakfastslot_start);
      print(breakfastslot_end);
      var currentTime = DateTime.now();
      final DateFormat dateFormat = DateFormat('HH:mm:ss');
      b_startTime = todayWithTime(breakfastslot_start);
      b_endTime = todayWithTime(breakfastslot_end);
      l_startTime = todayWithTime(lunchslot_start);
      l_endTime = todayWithTime(lunchslot_end);
      s_startTime = todayWithTime(snacksslot_start);
      s_endTime = todayWithTime(snacksslot_end);
      d_startTime = todayWithTime(dinnerslot_start);
      d_endTime = todayWithTime(dinnerslot_end);
      final DateFormat timeFormat = DateFormat.Hm();
      breakfastslotstart  = timeFormat.format(b_startTime!);
      breakfastslotend = timeFormat.format(b_endTime!);
      lunchslotstart = timeFormat.format(l_startTime!);
      lunchslotend = timeFormat.format(l_endTime!);
      snacksslotstart = timeFormat.format(s_startTime!);
      snacksslotend = timeFormat.format(s_endTime!);
      dinnerslotstart = timeFormat.format(d_startTime!);
      dinnerslotend = timeFormat.format(d_endTime!);
      print(l_startTime);
      print(currentTime);
      print( currentTime.isAfter(l_startTime!));
      print( currentTime.isAfter(b_startTime!));



      /*  if (currentHour >= 7 && currentHour <= 11) {
        showBreakFastView();
      }

      if (currentHour >= 11 && currentHour <= 15) {
        showLunchView();
      }

      if (currentHour >= 15 && currentHour <= 19) {
        showSnacksView();
      }
      if (currentHour >= 19 && currentHour <= 23) {
        showDinnerView();
      }*/
    });
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[kPrimaryColororange, kPrimaryColorLiteorange],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 70.0));

  @override
  Widget build(BuildContext context) {
    // total = breakfastFoodItem.price.toInt() + _con!.restaurant.defaultTax.toInt();

    /* if(widget.SelectedTime == "Breakfast"){
      selectedFoodItem = breakfastFoodItem;
    }
    if(widget.SelectedTime == "Lunch"){
      selectedFoodItem = lunchFoodItem;
    }
    if(widget.SelectedTime == "Dinner"){
      selectedFoodItem = dinnerFoodItem;
    }
    if(widget.SelectedTime == "Snacks"){
      selectedFoodItem = snacksFoodItem;
    }
*/
    bool isToday = _isToday(DateTime.parse(widget.SelectedDate.toString()));
    print(isToday);

    return Scaffold(
      // bottomNavigationBar: DetailsWidget(),
      key: _con!.scaffoldKey,
      body: FutureBuilder(
          future: Future.delayed(Duration(seconds: 2), () {}),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                loader_count < 3) {
              loader_count = loader_count + 1;
              print("loader_count ===> $loader_count");
              return Center(child: MyShimmerEffect());
            }

            return widget.isCurrentKitchen
                ? RefreshIndicator(
                    onRefresh: () async {
                      _foodcon
                          !.getKetchainDetails(widget.routeArgument!.id!, '2')
                          .then((value) {});
                      _con!.restaurant =
                          widget.routeArgument!.param as Restaurant;
                      /* _controller.listenForFoodsByCategoryAndRestaurant(
        id: "8", restaurantId: _con!.restaurant.id);
    showBreakFastView();*/

                      /*  listenForFoodsByCategoryAndRestaurantHere(
        id: "8", restaurantId: _con!.restaurant.id);*/
                      _con!.listenForRestaurant(id: _con!.restaurant!.id);
                      _con!.listenForGalleries(_con!.restaurant!.id!);
                      /*_con!.listenForGalleries(_con!.restaurant.id);
    _con!.listenForFoodImages(_con!.restaurant.image.toString());
    _con!.listenForFeaturedFoods(_con!.restaurant.id);
    _con!.listenForRestaurantReviews(id: _con!.restaurant.id);
    _con!.listenForIndividualFoods(_con!.restaurant.id);
    _controller.listenForFoodsByCategoryAndKitchen(
        id: "7", restaurantId: _con!.restaurant.id);*/
                      listenForFoodsByCategoryAndRestaurantHere(
                          id: "8", restaurantId: _con!.restaurant!.id);
                      _selectTab(widget.currentTab);

                      // _scheduleButtonPress();
                      //currentHour = currentTime.hour;
                    },
                    child: _con!.restaurant == null
                        ? Center(child: MyShimmerEffect())
                        : _con!.restaurant!.name!.isEmpty ||
                                _controller!.isData == true
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/img/No_data_found.png",
                                    height: 150,
                                    width: 150,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Center(
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
                                  ),
                                ],
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  CustomScrollView(
                                    primary: true,
                                    shrinkWrap: false,
                                    slivers: <Widget>[
                                      SliverAppBar(
                                        backgroundColor: mainColor(0.9),
                                        expandedHeight: 300,
                                        elevation: 0,
//                          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                                        automaticallyImplyLeading: false,
                                        leading: new IconButton(
                                          icon: new Icon(
                                              Icons.keyboard_backspace,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          onPressed: () => Navigator.pop(
                                              context), /*widget
                                        .parentScaffoldKey.currentState
                                        .openDrawer(),*/
                                        ),
                                        flexibleSpace: FlexibleSpaceBar(
                                          collapseMode: CollapseMode.parallax,
                                          background: Hero(
                                            tag: (widget?.routeArgument
                                                        ?.heroTag ??
                                                    '') +
                                                _con!.restaurant!.id!,
                                            child: Stack(
                                              children: [
                                                ColorFiltered(
                                                  colorFilter: _con!.restaurant
                                                              !.closed ==
                                                          "0"
                                                      ? ColorFilter.mode(
                                                          Colors.transparent,
                                                          BlendMode.saturation)
                                                      : ColorFilter.mode(
                                                          Colors.grey,
                                                          BlendMode.saturation),
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
                                                    // imageUrl: _con!.restaurant.banner_image.isEmpty ?  _con!.restaurant
                                                    //         .image.url : _con!.restaurant.banner_image ??
                                                    //     "https://picsum.photos/250?image=9",
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/img/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
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
                                                    child: /*Text(
                                    _con!.restaurant?.name ?? '',
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    maxLines: 2,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headline3,
                                  )*/
                                                        TranslationWidget(
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
                                                        style: Theme.of(context)
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
                                                      decoration: BoxDecoration(
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
                                                          /*Text(_con!.restaurant.rate,
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .bodyText1
                                                .merge(TextStyle(
                                                color: Theme
                                                    .of(
                                                    context)
                                                    .primaryColor)))*/
                                                          TranslationWidget(
                                                            message: _controller
                                                                    !.kitchenDetails
                                                                    .rate ??
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
                                                                        color: Theme.of(context)
                                                                            .primaryColor))),
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
                                            Row(
                                              children: <Widget>[
                                                SizedBox(width: 20),
                                                SizedBox(width: 10),
                                                Expanded(
                                                    child: SizedBox(height: 0)),
                                                SizedBox(width: 20),
                                              ],
                                            ),
                                            // Padding(
                                            //     padding:
                                            //         const EdgeInsets.symmetric(
                                            //             horizontal: 20,
                                            //             vertical: 0),
                                            //     child: Helper.applyHtml(
                                            //       context,
                                            //       _con!.restaurant!.description,
                                            //     )),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                  top: 6,
                                                  bottom: 12),
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
                                                      /*Text(
                                      _con!.restaurant.address,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    )*/
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
                                                      /*Text(
                                      "Dubai, UAE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    )*/
                                                      /* TranslationWidget(
                                      message:"Dubai, UAE",
                                      fromLanguage: "English",
                                      toLanguage: defaultLanguage,
                                      builder: (translatedMessage) => Text(
                                          translatedMessage,
                                          style:  TextStyle(
                                              fontWeight: FontWeight.w600)
                                      ),
                                    ),*/
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      RatingBar.builder(
                                                        itemSize: 18,
                                                        initialRating:
                                                            double.parse(_con
                                                                !.restaurant
                                                                !.rate!),
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
                                                            color: Colors.white,
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
                                                                  fontSize: 20,
                                                                ),
                                                              ),
                                                            ]),
                                                      ),
                                                      /* Text(
                                      "Avg.for one",
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    )*/
                                                      TranslationWidget(
                                                        message: "Avg. for one",
                                                        fromLanguage: "English",
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
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    /* Expanded(
                                                child: Container(
                                                  // width:237,
                                                  // width: 79,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight:
                                                                  Radius.circular(
                                                                      4),
                                                              bottomRight:
                                                                  Radius.circular(
                                                                      4)),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            blurRadius: 12,
                                                            spreadRadius: -9)
                                                      ]),
                                                  child: TextButton(
                                                    onPressed: () async{
                                                      if(_con != null){
                                                        http://maps.google.com/maps?daddr=${_con!.restaurant.latitude},${_con!.restaurant.longitude}
                                                        String url = 'http://maps.google.com/maps?daddr=${_con!.restaurant.latitude},${_con!.restaurant.longitude}';
                                                        if (await canLaunchUrl(Uri.parse(url))) {
                                                          await launch(url);
                                                        } else {
                                                          throw 'Could not launch $url';
                                                        }
                                                      }
                                                    },
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        // _openDialog(context);
                                                      */
                                                    /*  Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>  MapWidget(parentScaffoldKey: widget.parentScaffoldKey,
                                                                  routeArgument: RouteArgument(param:snacksFoodItem.restaurant))
                                                          ),
                                                        );*/
                                                    /*

                                                        if(_con != null){
                                                          http://maps.google.com/maps?daddr=${_con!.restaurant.latitude},${_con!.restaurant.longitude}
                                                          String url = 'http://maps.google.com/maps?daddr=${_con!.restaurant.latitude},${_con!.restaurant.longitude}';
                                                          if (await canLaunchUrl(Uri.parse(url))) {
                                                            await launch(url);
                                                          } else {
                                                            throw 'Could not launch $url';
                                                          }
                                                        }

                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .directions_outlined,
                                                            size: 11,
                                                            color: Theme.of(context)
                                                                .hintColor,
                                                          ),
                                                          SizedBox(
                                                            width: 4,
                                                          ),
                                                          */
                                                    /*Text(
                                                "Direction",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Theme
                                                        .of(
                                                        context)
                                                        .hintColor),
                                              )*/
                                                    /*
                                                          TranslationWidget(
                                                            message: "Direction",
                                                            fromLanguage: "English",
                                                            toLanguage:
                                                                defaultLanguage,
                                                            builder:
                                                                (translatedMessage) =>
                                                                    Text(
                                                              translatedMessage,
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .hintColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),*/
                                                    VerticalDivider(
                                                      color:
                                                          Colors.grey.shade100,
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
                                                      color:
                                                          Colors.grey.shade100,
                                                      thickness: 1,
                                                      indent: 0,
                                                      width: 2,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        // width:237,
                                                        //width: 79,
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
                                                          onPressed: () async {
                                                            print(
                                                                "DS>> clicked like");
                                                            if (currentUser
                                                                    .value
                                                                    .apiToken ==
                                                                "") {
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                      "/Login");
                                                            } else {
                                                              /* final AddToFavouriteModel apiResponse = await _con
                                                            .addRestaurantToFavouriteList(
                                                            _con!.restaurant.id,
                                                            currentUser
                                                                .value.id,
                                                            currentUser.value
                                                                .apiToken);

                                                        print("DS>> res## " +
                                                            apiResponse.toString());

                                                        ScaffoldMessenger.of(
                                                            context)
                                                            .showSnackBar(SnackBar(
                                                          content: Text(apiResponse
                                                              .message
                                                              .toString()),
                                                        ));*/
                                                            }
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
                                                              setState(() {
                                                                loader_count =
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

                                                              /*print("DS>> res## " +
                                                            apiResponse.toString());

                                                        ScaffoldMessenger.of(
                                                            context)
                                                            .showSnackBar(SnackBar(
                                                          content: Text(apiResponse
                                                              .message
                                                              .toString()),
                                                        ));*/
                                                              setState(() {
                                                                loader_count =
                                                                    2;
                                                              });
                                                              _con!.refreshRestaurant();
                                                            }
                                                          },
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              print(
                                                                  "DS>> clicked like");
                                                              if (currentUser
                                                                      .value
                                                                      .apiToken ==
                                                                  "") {
                                                                Navigator.of(
                                                                        context)
                                                                    .pushNamed(
                                                                        "/Login");
                                                              } else {
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
                                                                } else {
                                                                  Provider.of<favourite_item_provider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .add_to_favorite(_con
                                                                          !.restaurant
                                                                          !.name!);
                                                                  final AddToFavouriteModel apiResponse = await _con!.addRestaurantToFavouriteList(
                                                                      _con!.restaurant
                                                                          !.id!,
                                                                      currentUser
                                                                          .value
                                                                          .id,
                                                                      currentUser
                                                                          .value
                                                                          .apiToken);

                                                                  /*  print("DS>> res## " +
                                                                apiResponse.toString());

                                                            ScaffoldMessenger.of(
                                                                context)
                                                                .showSnackBar(SnackBar(
                                                              content: Text(apiResponse
                                                                  .message
                                                                  .toString()),
                                                            ));*/
                                                                }
                                                                setState(() {
                                                                  loader_count =
                                                                      2;
                                                                });
                                                                _con!.refreshRestaurant();
                                                              }
                                                            },
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
                                                                    size: 16,
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
                                                    color: Theme
                                                        .of(
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
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: Theme.of(context)
                                                                            .hintColor),
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
                                            /* Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        child: Row(
                                          children: [
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.13,
                                                height: 150,
                                                child: ListView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    children: new List.generate(10,
                                                        (int index) {
                                                      return Container(
                                                        margin: EdgeInsets.only(
                                                            right: 18),
                                                        height: 220,
                                                        width: 200,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  8), // Image border
                                                          child: SizedBox.fromSize(
                                                            size:
                                                                Size.fromRadius(48),
                                                            // Image radius
                                                            child: Image.network(
                                                              _con!.restaurant.image
                                                                  .thumb
                                                                  .toString(),
                                                              // "assets/img/image-Ae.png",
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    })))
                                          ],
                                        ),
                                      ),*/
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: currentHour! >= 11 && isToday
                                                            ? null // Disable button if current hour is greater than 11
                                                            : () {
                                                          _controller!.isDateUpdated = false;
                                                          showBreakFastView();
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(4),
                                                              bottomLeft: Radius.circular(4),
                                                            ),
                                                            color: currentHour! >= 11 && isToday
                                                                ? Colors.grey[200] // Disable button if not in the time slot
                                                                : widget.isBreakfastSelected
                                                                ? kPrimaryColororange
                                                                : Colors.white,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.grey,
                                                                blurRadius: 12,
                                                                spreadRadius: -9,
                                                              )
                                                            ],
                                                          ),
                                                          child: TextButton(
                                                            onPressed: currentHour! >= 11 && isToday
                                                                ? null // Disable button if current hour is greater than 11
                                                                : () {
                                                              _controller!.isDateUpdated = false;
                                                              showBreakFastView();
                                                            },
                                                            child: TranslationWidget(
                                                              message: "Breakfast",
                                                              fromLanguage: "English",
                                                              toLanguage: defaultLanguage,
                                                              builder: (translatedMessage) =>Text.rich(
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
                                                      color: Colors.grey.shade100,
                                                      thickness: 1,
                                                      indent: 0,
                                                      width: 2,
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: currentHour! >= 15 && isToday
                                                            ? null // Disable button if current hour is greater than 15
                                                            : () {
                                                          _controller!.isDateUpdated = false;
                                                          showLunchView();
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: currentHour! >= 15 && isToday
                                                                ? Colors.grey[200] // Disable button if not in the time slot
                                                                : widget.isLunchSelected
                                                                ? kPrimaryColororange
                                                                : Colors.white,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.grey,
                                                                blurRadius: 12,
                                                                spreadRadius: -9,
                                                              )
                                                            ],
                                                          ),
                                                          child: TextButton(
                                                            onPressed: currentHour! >= 15 && isToday
                                                                ? null // Disable button if current hour is greater than 15
                                                                : () {
                                                              _controller!.isDateUpdated = false;
                                                              showLunchView();
                                                            },
                                                            child: TranslationWidget(
                                                              message: "Lunch",
                                                              fromLanguage: "English",
                                                              toLanguage: defaultLanguage,
                                                              builder: (translatedMessage) =>  Text.rich(
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
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    VerticalDivider(
                                                      color: Colors.grey.shade100,
                                                      thickness: 1,
                                                      indent: 0,
                                                      width: 2,
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: currentHour! >= 19 && isToday
                                                            ? null // Disable button if current hour is greater than 19
                                                            : () {
                                                          _controller!.isDateUpdated = false;
                                                          showSnacksView();
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: currentHour! >= 19 && isToday
                                                                ? Colors.grey[200] // Disable button if not in the time slot
                                                                : widget.isSnacksSelected
                                                                ? kPrimaryColororange
                                                                : Colors.white,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.grey,
                                                                blurRadius: 12,
                                                                spreadRadius: -9,
                                                              )
                                                            ],
                                                          ),
                                                          child: TextButton(
                                                            onPressed: currentHour! >= 19 && isToday
                                                                ? null // Disable button if current hour is greater than 19
                                                                : () {
                                                              _controller!.isDateUpdated = false;
                                                              showSnacksView();
                                                            },
                                                            child: TranslationWidget(
                                                              message: "Snacks",
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
                                                      color: Colors.grey.shade100,
                                                      thickness: 1,
                                                      indent: 0,
                                                      width: 2,
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: currentHour! >= 23 && isToday
                                                            ? null // Disable button if current hour is greater than 23
                                                            : () {
                                                          _controller!.isDateUpdated = false;
                                                          showDinnerView();
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(4),
                                                              bottomRight: Radius.circular(4),
                                                            ),
                                                            color: currentHour! >= 23 && isToday
                                                                ? Colors.grey[200] // Disable button if not in the time slot
                                                                : widget.isDinnerSelected
                                                                ? kPrimaryColororange
                                                                : Colors.white,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.grey,
                                                                blurRadius: 12,
                                                                spreadRadius: -9,
                                                              )
                                                            ],
                                                          ),
                                                          child: TextButton(
                                                            onPressed: currentHour! >= 23 && isToday
                                                                ? null // Disable button if current hour is greater than 23
                                                                : () {
                                                              _controller!.isDateUpdated = false;
                                                              showDinnerView();
                                                            },
                                                            child: TranslationWidget(
                                                              message: "Dinner",
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

                                            widget.isBreakfastVisible
                                                ? RefreshIndicator(
                                                    onRefresh: _controller
                                                        !.refreshCategory,
                                                    child: buildBreakfastFoods(
                                                        context,
                                                        breakfast_food,
                                                        8,
                                                        _con!.restaurant!.id!))
                                                : Visibility(
                                                    visible: false,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors
                                                          .deepOrangeAccent,
                                                    )),
                                            widget.isLunchVisible
                                                ? RefreshIndicator(
                                                    onRefresh: _controller
                                                        !.refreshCategory,
                                                    child: buildLunchFoods(
                                                        context,
                                                        lunch_food,
                                                        9,
                                                        _con!.restaurant!.id!))
                                                : Visibility(
                                                    visible: false,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors
                                                          .deepOrangeAccent,
                                                    )),
                                            widget.isSnacksVisible
                                                ? RefreshIndicator(
                                                    onRefresh: _controller
                                                        !.refreshCategory,
                                                    child: buildSnacksFoods(
                                                        context,
                                                        snack_food,
                                                        7,
                                                        _con!.restaurant!.id!))
                                                : Visibility(
                                                    visible: false,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors
                                                          .deepOrangeAccent,
                                                    )),
                                            widget.isDinnerVisible
                                                ? RefreshIndicator(
                                                    onRefresh: _controller
                                                        !.refreshCategory,
                                                    child: buildDinnerFoods(
                                                        context,
                                                        dinner_food,
                                                        10,
                                                        _con!.restaurant!.id!))
                                                : Visibility(
                                                    visible: false,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors
                                                          .deepOrangeAccent,
                                                    )),
                                            if (widget.isBreakfastVisible &&
                                                    breakfastFoodItem != null &&
                                                    breakfastFoodItem
                                                        !.separateItems
                                                        !.isNotEmpty ||
                                                widget.isSnacksVisible &&
                                                    snacksFoodItem != null &&
                                                    snacksFoodItem!.separateItems
                                                        !.isNotEmpty ||
                                                widget.isLunchVisible &&
                                                    lunchFoodItem != null &&
                                                    lunchFoodItem!.separateItems
                                                        !.isNotEmpty &&
                                                    lunchFoodItem!.comboMedia
                                                        .isNotEmpty ||
                                                widget.isDinnerVisible &&
                                                    dinnerFoodItem != null &&
                                                    dinnerFoodItem!.separateItems
                                                        !.isNotEmpty)
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 24,
                                                        vertical: 2),
                                                    child: TranslationWidget(
                                                      message: "Items Included",
                                                      fromLanguage: "English",
                                                      toLanguage:
                                                          defaultLanguage,
                                                      builder:
                                                          (translatedMessage) =>
                                                              Text(
                                                        translatedMessage,
                                                        style: Theme.of(context)
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
                                                            offset:
                                                                Offset(0, -20),
                                                            child: ListView
                                                                .separated(
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              shrinkWrap: true,
                                                              primary: false,
                                                              itemCount:
                                                                  breakfastFoodItem
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
                                                                return DineInIndividualFoodItemWidget(
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
                                                                  primary:
                                                                      false,
                                                                  itemCount:
                                                                      lunchFoodItem
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
                                                                    return DineInIndividualFoodItemWidget(
                                                                      heroTag:
                                                                          'individual_food_list',
                                                                      food: lunchFoodItem
                                                                              !.separateItems![
                                                                          index],
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
                                                                            height:
                                                                                6);
                                                                      },
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        return DineInIndividualFoodItemWidget(
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
                                                                          _controller
                                                                              !.refreshCategory,
                                                                      child: Transform
                                                                          .translate(
                                                                        offset: Offset(
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
                                                                          itemCount: snacksFoodItem
                                                                              !.separateItems
                                                                              !.length,
                                                                          separatorBuilder:
                                                                              (context, index) {
                                                                            return SizedBox(height: 6);
                                                                          },
                                                                          itemBuilder:
                                                                              (context, index) {
                                                                            return DineInIndividualFoodItemWidget(
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
                                                                            style:
                                                                                TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                                                      ),
                                                                    ),
                                                ],
                                              ),
                                            Visibility(
                                              visible: false,
                                              child: Container(
                                                color:
                                                    Colors.grey.withOpacity(0.15),
                                                margin: EdgeInsets.only(top: 30),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width:
                                                            MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                3,
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                /*Text(
                                                 showProgress ? "" : "AED "+ selectedFoodItem.price.toString(),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight.w800,
                                                    color: Colors
                                                        .grey.shade600),
                                              )*/
                                                                if (selected_food
                                                                    .isNotEmpty)
                                                                  RichText(
                                                                    text: TextSpan(
                                                                        text: "₹",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .grey
                                                                                .shade600),
                                                                        children: [
                                                                          TextSpan(
                                                                              text: (subtotal.toStringAsFixed(2))
                                                                                  .toString(),
                                                                              style: TextStyle(
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Colors.grey.shade600)),
                                                                        ]),
                                                                  ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                /*Text(
                                                day,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.w800,
                                                    color: Colors
                                                        .grey.shade600),
                                              )*/
                                                                TranslationWidget(
                                                                  message: day!,
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
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w800,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade600),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                /* Text(
                                                month,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight.w400,
                                                    color: Colors
                                                        .grey.shade600),
                                              )*/
                                                                TranslationWidget(
                                                                  message: month!,
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
                                                                                .w800,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade600),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 2,
                                                                ),
                                                                /*Text(
                                                "Edit",
                                                style: TextStyle(
                                                    fontSize: 10),
                                              )*/
                                                                TranslationWidget(
                                                                  message: "",
                                                                  fromLanguage:
                                                                      "English",
                                                                  toLanguage:
                                                                      defaultLanguage,
                                                                  builder:
                                                                      (translatedMessage) =>
                                                                          Text(
                                                                    translatedMessage,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                /*Text(
                                                widget.selectedPeople
                                                    .length >
                                                    15
                                                    ? widget.selectedPeople
                                                    .substring(
                                                    0, 15) +
                                                    "..." // Truncate text after 10 characters
                                                    : widget
                                                    .selectedPeople,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight.w400,
                                                    color: Colors
                                                        .grey.shade600),
                                                overflow:
                                                TextOverflow.fade,
                                                maxLines:
                                                1, // Set the maximum number of lines to 1
                                              )*/
                                                                TranslationWidget(
                                                                  message: widget
                                                                              .selectedPeople
                                                                              !.length >
                                                                          15
                                                                      ? widget.selectedPeople!.substring(
                                                                              0,
                                                                              15) +
                                                                          "..." // Truncate text after 10 characters
                                                                      : widget
                                                                          .selectedPeople!,
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
                                                                                .w400,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade600),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .fade,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 2,
                                                                ),
                                                                /*Text(
                                                "Edit",
                                                style: TextStyle(
                                                    fontSize: 10),
                                              )*/
                                                                TranslationWidget(
                                                                  message: "",
                                                                  fromLanguage:
                                                                      "English",
                                                                  toLanguage:
                                                                      defaultLanguage,
                                                                  builder:
                                                                      (translatedMessage) =>
                                                                          Text(
                                                                    translatedMessage,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            right: 0, top: 8),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          40),
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
                                                              highlightElevation:
                                                                  0,
                                                              onPressed: () {
                                                                if (currentUser
                                                                        .value
                                                                        .apiToken ==
                                                                    null) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pushNamed(
                                                                          "/Login");
                                                                } else {
                                                                  if (selected_food
                                                                      .isEmpty) {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                "Please Select the food");
                                                                  } else {

                                                                    if (_foodcon
                                                                        !.isSameRestaurants(
                                                                            _foodcon
                                                                                !.food!)!) {
                                                                      for (var selectedFoodsItem
                                                                          in selected_food) {

                                                                        updateFoodList(new Food
                                                                                .withId(
                                                                            id: selectedFoodsItem
                                                                                .id
                                                                                .toString(),
                                                                            foodImg: selectedFoodsItem
                                                                                .comboMedia[
                                                                                    0]
                                                                                .url,
                                                                            name: selectedFoodsItem
                                                                                .name,
                                                                            price: double.parse(selectedFoodsItem
                                                                                .price
                                                                                .toString())));
                                                                        print("price::" +
                                                                            double.parse(selectedFoodsItem.price.toString())
                                                                                .toString());
                                                                      }
                                                                      addFoodToCart();
                                                                      // _foodcon.addToCart(_foodcon.food);
                                                                    }
                                                                  }
                                                                }
                                                              },
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          35,
                                                                      vertical:
                                                                          8),
                                                              shape:
                                                                  StadiumBorder(),
                                                              //color: Theme.of(context).accentColor,
                                                              child: Wrap(
                                                                spacing: 10,
                                                                children: [
                                                                  /*Text(
                                                  S
                                                      .of(context)
                                                      .booknow,
                                                  style: TextStyle(
                                                      color: Theme
                                                          .of(
                                                          context)
                                                          .primaryColor,
                                                      fontSize: 16),
                                                )*/
                                                                  TranslationWidget(
                                                                    message: "Book Now",
                                                                    fromLanguage:
                                                                        "English",
                                                                    toLanguage:
                                                                        defaultLanguage,
                                                                    builder:
                                                                        (translatedMessage) =>
                                                                            Text(
                                                                      translatedMessage,
                                                                      style: TextStyle(
                                                                          color: Theme.of(context)
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
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ( foodList.length != 0)
                                    Visibility(
                                      visible: true,
                                      child: Container(
                                          alignment: Alignment.bottomCenter,
                                          child: InkWell(
                                            onTap: () {
                                              if (currentUser
                                                  .value
                                                  .apiToken ==
                                                  null) {
                                                Navigator.of(
                                                    context)
                                                    .pushNamed(
                                                    "/Login");
                                              } else {
                                               /* if (selected_food
                                                    .isEmpty) {
                                                  Fluttertoast
                                                      .showToast(
                                                      msg:
                                                      "Please Select the food");
                                                } else {*/


                                                    for (var selectedFoodsItem
                                                    in selected_food) {

                                                      updateFoodList(new Food
                                                          .withId(
                                                          id: selectedFoodsItem
                                                              .id
                                                              .toString(),
                                                          foodImg: selectedFoodsItem
                                                              .comboMedia[
                                                          0]
                                                              .url,
                                                          name: selectedFoodsItem
                                                              .name,
                                                          price: double.parse(selectedFoodsItem
                                                              .price
                                                              .toString())));
                                                      print("price::" +
                                                          double.parse(selectedFoodsItem.price.toString())
                                                              .toString());
                                                    }
                                                    addFoodToCart();
                                                    // _foodcon.addToCart(_foodcon.food);

                                             //   }
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
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text("${foodList.length} Item added ",style: TextStyle(color: Colors.white,fontSize:
                                                  16),),
                                                  Icon(Icons.arrow_circle_right_outlined,color: Colors.white,)
                                                ],
                                              ),
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

  void _makePhoneCall(String phone) {
    final Uri phoneCallUri = Uri(scheme: 'tel', path: phone);
    if (canLaunch(phoneCallUri.toString()) != null) {
      launch(phoneCallUri.toString());
    } else {
      throw 'Could not launch $phoneCallUri';
    }
  }

  void addFoodToCart() {

    Map<String, double> groupedFood = {};
    List<Map<String,dynamic>> fooditems = [];
    double subtotal = 0.0;
    for (int i = 0; i < foodList.length; i++) {
      String foodId = foodList[i].name;
      double quantity = groupedFood[foodId] ?? 0.0;
      quantity += 1.0;
      groupedFood[foodId] = quantity;
    }
    groupedFood.forEach((foodId, quantity) {
      Food food = foodList.firstWhere((item) => item.name == foodId.toString());
      // print(food.restaurant.id);
      print(_controller!.kitchenDetails.id);
      print("object calling======>asa ${food.restaurant!.name}");
      print("Quantity" + quantity.toString());
      subtotal += food.price * quantity ;
      fooditems.add({"food":food,"Quantity" : quantity});
    });

    print(groupedFood);
    for (int i = 0; i < foodList.length; i++) {
      print("FoodList: " + foodList[i].name);

    //  calculateTotal();

      /*setState(() {
        _foodcon.addToCart(foodList[i]);
      });*/
    }
    if (currentUser.value.apiToken != "") {
      switch (selectedFood) {
        case "breakfast":
          //  selectedFoodItem = breakfastFoodItem;
          break;
        case "lunch":
          //    selectedFoodItem = lunchFoodItem;
          break;
        case "snacks":
          //  selectedFoodItem = snacksFoodItem;
          break;
        case "dinner":
          //   selectedFoodItem = dinnerFoodItem;
          break;
      }

      setState(() {
        print(total);
        print(fooditems.first);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DineInSummaryPage(
                subtotal.toInt(),
                _con!.restaurant!,
                widget.selectedPeople!,
                widget.SelectedDate!,
                widget.SelectedTime!,
               "selectedFoodItem.timeSlots.from".toString(),
                "selectedFoodItem.timeSlots.to".toString(),
                foodList,
                _con!.restaurant!.defaultTax.toString(),
                widget.routeArgument!.products!,
                fooditems,
                selectedCoupon


            ),


          ),
        );
      });
    } else {
      Navigator.of(context).pushNamed('/Login');
    }
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
    getFoodsByCategoryAndKitchenlist(8, _con!.restaurant!.id!).then((value) {
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
    getFoodsByCategoryAndKitchenlist(9, _con!.restaurant!.id!).then((value) {
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
    //     await getFoodsByCategoryAndKitchenlist(7, _con!.restaurant.id);
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
    getFoodsByCategoryAndKitchenlist(7, _con!.restaurant!.id!).then((value) {
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
    //     await getFoodsByCategoryAndKitchenlist(10, _con!.restaurant.id);
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
    getFoodsByCategoryAndKitchenlist(10, _con!.restaurant!.id!).then((value) {
      setState(() {
        dinner_food.clear();
        dinner_food.addAll(value);
        isdinnerLoad = false;
      });
    });
  }
  // void showBreakFastView() async {
  //   List<FoodItem> breakfastFoods =
  //       await getFoodsByCategoryAndKitchenlist(8, _con!.restaurant.id);
  //   print("show breakfast called");
  //
  //   setState(() {
  //     breakfast_food.clear();
  //     breakfast_food.addAll(breakfastFoods);
  //     isbreackfastLoadmore = false;
  //     print("show breakfast called in setstate");
  //     widget.isBreakfastVisible = true;
  //     widget.isLunchVisible = false;
  //     widget.isSnacksVisible = false;
  //     widget.isDinnerVisible = false;
  //
  //     widget.isBreakfastSelected = true;
  //     widget.isLunchSelected = false;
  //     widget.isSnacksSelected = false;
  //     widget.isDinnerSelected = false;
  //   });
  // }
  //
  // void showLunchView() async {
  //   print("show lunch called");
  //   List<FoodItem> breakfastFoods =
  //       await getFoodsByCategoryAndKitchenlist(9, _con!.restaurant.id);
  //   setState(() {
  //     lunch_food.clear();
  //     lunch_food.addAll(breakfastFoods);
  //     islunchLoadmore = false;
  //     print("show lunch called in setstate");
  //
  //     widget.isBreakfastVisible = false;
  //     widget.isLunchVisible = true;
  //     widget.isSnacksVisible = false;
  //     widget.isDinnerVisible = false;
  //
  //     widget.isBreakfastSelected = false;
  //     widget.isLunchSelected = true;
  //     widget.isSnacksSelected = false;
  //     widget.isDinnerSelected = false;
  //   });
  // }
  //
  // void showSnacksView() async {
  //   print("show snacks called");
  //   List<FoodItem> breakfastFoods =
  //       await getFoodsByCategoryAndKitchenlist(7, _con!.restaurant.id);
  //   setState(() {
  //     snack_food.clear();
  //     snack_food.addAll(breakfastFoods);
  //     issnacksLoadmore = false;
  //     print("show snacks called in setstate");
  //     widget.isBreakfastVisible = false;
  //     widget.isLunchVisible = false;
  //     widget.isSnacksVisible = true;
  //     widget.isDinnerVisible = false;
  //
  //     widget.isBreakfastSelected = false;
  //     widget.isLunchSelected = false;
  //     widget.isSnacksSelected = true;
  //     widget.isDinnerSelected = false;
  //   });
  // }
  //
  // void showDinnerView() async {
  //   print("show dinner called");
  //   List<FoodItem> breakfastFoods =
  //       await getFoodsByCategoryAndKitchenlist(10, _con!.restaurant.id);
  //   setState(() {
  //     dinner_food.clear();
  //     isdinnerLoadmore = false;
  //     dinner_food.addAll(breakfastFoods);
  //     print("show dinner called in setstate");
  //     widget.isBreakfastVisible = false;
  //     widget.isLunchVisible = false;
  //     widget.isSnacksVisible = false;
  //     widget.isDinnerVisible = true;
  //
  //     widget.isBreakfastSelected = false;
  //     widget.isLunchSelected = false;
  //     widget.isSnacksSelected = false;
  //     widget.isDinnerSelected = true;
  //   });
  // }
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
  Widget buildBreakfastFoods(BuildContext context,
      List<FoodItem> breakfastFoods, int categoryId, String RestaurantId) {
    List<String> updatedQuantities = List.filled(breakfastFoods.length, "0");
    final provider = Provider.of<QuantityProvider>(context, listen: false);
   // provider.initializeQuantities(breakfastFoods.length);
    final ScrollController _scrollController = ScrollController();
    void _loadMoreData() async {
      List<FoodItem> moreFoods = await getFoodsByCategoryAndKitchenlist(
          categoryId, RestaurantId,
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
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context).hintColor),
                                          color: Colors.white,
                                        ),
                                        child: InkWell(
                                          child: GestureDetector(
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
                                            },
                                            child: Icon(
                                              Icons.remove,
                                              size: 15,
                                              color: Theme.of(context).hintColor,
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
                                              quantity.toString(),
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context).hintColor),
                                          color: Colors.white,
                                        ),
                                        child: InkWell(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (_con!.restaurant!.closed == "1") {
                                                _showClosedDialog(context);
                                              } else {
                                                print("DS>> GD increment" +
                                                    _foodcon!.quantity.toString());
                                                _foodcon!.incrementQuantity();
                                                setState(() {
                                                  print(breakfastFoodItem.restaurant!.image!.url);
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
                                                          !.restaurant!,
                                                      price: double.parse(
                                                          breakfastFoodItem.discountPrice != 0.0 ?breakfastFoodItem.discountPrice.toString() :
                                                          breakfastFoodItem.price
                                                              .toString())));
                                                  quantity++;
                                                  itemQuantities[breakfastFoodItem
                                                      .id
                                                      .toString()] = quantity;
                                                });
                                                setState(() {});
                                                //    provider.incrementQuantity(index);
                                              }
                                            },
                                            child: Icon(
                                              Icons.add,
                                              size: 15,
                                              color: Theme.of(context).hintColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  TranslationWidget(
                                    message:
                                        breakfastFoodItem.standards,
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
                                    _showBottomSheet(context, breakfastFoodItem);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 160,
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
                                        fit: BoxFit.fill,
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

  Widget buildLunchFoods(BuildContext context, List<FoodItem> breakfastFoods,
      int categoryId, String RestaurantId) {
    List<String> updatedQuantities = List.filled(breakfastFoods.length, "0");
    // final provider = Provider.of<QuantityProvider>(context,listen: false);
    //  provider.initializeQuantities(breakfastFoods.length);

    Future<void> _loadMoreData() async {
      List<FoodItem> moreFoods = await getFoodsByCategoryAndKitchenlist(
          categoryId, RestaurantId,
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

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData(); // Load more data when scrolled to the bottom
      }
    });

    if(islunchLoad){
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

    }
    else {
      if (breakfastFoods.isEmpty) {
        // If there are no breakfast foods available, display a message or placeholder
        return Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
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
      }
      else {
        // If breakfast foods are available, display them
        return Column(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: breakfastFoods
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final breakfastFoodItem = entry.value;

                  if (index == breakfastFoods.length - 1 &&
                      islunchLoadmore == false) {
                    _loadMoreData();
                  }
                  int quantity =
                      itemQuantities[breakfastFoodItem.id.toString()] ?? 0;
                  // final index = entry.key;
                  //  int quantity = itemQuantities[breakfastFoodItem.id.toString()] ?? 0;
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
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context).hintColor),
                                          color: Colors.white,
                                        ),
                                        child: InkWell(
                                          child: GestureDetector(
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
                                            },
                                            child: Icon(
                                              Icons.remove,
                                              size: 15,
                                              color: Theme.of(context).hintColor,
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
                                              quantity.toString(),
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context).hintColor),
                                          color: Colors.white,
                                        ),
                                        child: InkWell(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (_con!.restaurant!.closed == "1") {
                                                _showClosedDialog(context);
                                              } else {
                                                print("DS>> GD increment" +
                                                    _foodcon!.quantity.toString());
                                                _foodcon!.incrementQuantity();
                                                setState(() {
                                                  print(breakfastFoodItem.restaurant!.image!.url);
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
                                                          breakfastFoodItem.discountPrice != 0.0 ?breakfastFoodItem.discountPrice.toString() :
                                                          breakfastFoodItem.price
                                                              .toString())));
                                                  quantity++;
                                                  itemQuantities[breakfastFoodItem
                                                      .id
                                                      .toString()] = quantity;
                                                });
                                                setState(() {});
                                                //    provider.incrementQuantity(index);
                                              }
                                            },
                                            child: Icon(
                                              Icons.add,
                                              size: 15,
                                              color: Theme.of(context).hintColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  TranslationWidget(
                                    message:
                                    breakfastFoodItem.standards,
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
                                    _showBottomSheet(context, breakfastFoodItem);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 160,
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
                                        fit: BoxFit.fill,
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
            if(islunchLoadmore == true && selected_food.length > 0)
              SizedBox(height: 60,)
          ],
        );
      }
    }
  }

  Widget buildSnacksFoods(BuildContext context, List<FoodItem> breakfastFoods,
      int categoryId, String RestaurantId) {
    List<String> updatedQuantities = List.filled(breakfastFoods.length, "0");
    // final provider = Provider.of<QuantityProvider>(context,listen: false);
    //  provider.initializeQuantities(breakfastFoods.length);

    Future<void> _loadMoreData() async {
      List<FoodItem> moreFoods = await getFoodsByCategoryAndKitchenlist(
          categoryId, RestaurantId,
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

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData(); // Load more data when scrolled to the bottom
      }
    });
    if(issnacksLoad){
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

    }
    else {
      if (breakfastFoods.isEmpty) {
        // If there are no breakfast foods available, display a message or placeholder
        return Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
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
      }
      else {
        // If breakfast foods are available, display them
        return Column(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: breakfastFoods
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final breakfastFoodItem = entry.value;

                  if (index == breakfastFoods.length - 1 &&
                      issnacksLoadmore == false) {
                    _loadMoreData();
                  }
                  int quantity =
                      itemQuantities[breakfastFoodItem.id.toString()] ?? 0;
                  // final index = entry.key;
                  //  int quantity = itemQuantities[breakfastFoodItem.id.toString()] ?? 0;
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
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context).hintColor),
                                          color: Colors.white,
                                        ),
                                        child: InkWell(
                                          child: GestureDetector(
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
                                            },
                                            child: Icon(
                                              Icons.remove,
                                              size: 15,
                                              color: Theme.of(context).hintColor,
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
                                              quantity.toString(),
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context).hintColor),
                                          color: Colors.white,
                                        ),
                                        child: InkWell(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (_con!.restaurant!.closed == "1") {
                                                _showClosedDialog(context);
                                              } else {
                                                print("DS>> GD increment" +
                                                    _foodcon!.quantity.toString());
                                                _foodcon!.incrementQuantity();
                                                setState(() {
                                                  print(breakfastFoodItem.restaurant!.image!.url);
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
                                                          breakfastFoodItem.discountPrice != 0.0 ?breakfastFoodItem.discountPrice.toString() :
                                                          breakfastFoodItem.price
                                                              .toString())));
                                                  quantity++;
                                                  itemQuantities[breakfastFoodItem
                                                      .id
                                                      .toString()] = quantity;
                                                });
                                                setState(() {});
                                                //    provider.incrementQuantity(index);
                                              }
                                            },
                                            child: Icon(
                                              Icons.add,
                                              size: 15,
                                              color: Theme.of(context).hintColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  TranslationWidget(
                                    message:
                                    breakfastFoodItem.standards,
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
                                    _showBottomSheet(context, breakfastFoodItem);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 160,
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
                                        fit: BoxFit.fill,
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
            if(issnacksLoadmore == true && selected_food.length > 0)
              SizedBox(height: 60,)
          ],
        );
      }
    }
  }

  Widget buildDinnerFoods(BuildContext context, List<FoodItem> breakfastFoods,
      int categoryId, String RestaurantId) {
    List<String> updatedQuantities = List.filled(breakfastFoods.length, "0");
    // final provider = Provider.of<QuantityProvider>(context,listen: false);
    //  provider.initializeQuantities(breakfastFoods.length);

    Future<void> _loadMoreData() async {
      List<FoodItem> moreFoods = await getFoodsByCategoryAndKitchenlist(
          categoryId, RestaurantId,
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

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData(); // Load more data when scrolled to the bottom
      }
    });
    if(isdinnerLoad){
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

    }
    else {
      if (breakfastFoods.isEmpty) {
        // If there are no breakfast foods available, display a message or placeholder
        return Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
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
      }
      else {
        // If breakfast foods are available, display them
        return Column(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: breakfastFoods
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final breakfastFoodItem = entry.value;

                  if (index == breakfastFoods.length - 1 &&
                      isdinnerLoadmore == false) {
                    _loadMoreData();
                  }
                  int quantity =
                      itemQuantities[breakfastFoodItem.id.toString()] ?? 0;
                  // final index = entry.key;
                  //  int quantity = itemQuantities[breakfastFoodItem.id.toString()] ?? 0;
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
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context).hintColor),
                                          color: Colors.white,
                                        ),
                                        child: InkWell(
                                          child: GestureDetector(
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
                                            },
                                            child: Icon(
                                              Icons.remove,
                                              size: 15,
                                              color: Theme.of(context).hintColor,
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
                                              quantity.toString(),
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context).hintColor),
                                          color: Colors.white,
                                        ),
                                        child: InkWell(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (_con!.restaurant!.closed == "1") {
                                                _showClosedDialog(context);
                                              } else {
                                                print("DS>> GD increment" +
                                                    _foodcon!.quantity.toString());
                                                _foodcon!.incrementQuantity();
                                                setState(() {
                                                 // print(breakfastFoodItem.restaurant.image.url);
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
                                                          breakfastFoodItem.discountPrice != 0.0 ?breakfastFoodItem.discountPrice.toString() :
                                                          breakfastFoodItem.price
                                                              .toString())));
                                                  quantity++;
                                                  itemQuantities[breakfastFoodItem
                                                      .id
                                                      .toString()] = quantity;
                                                });
                                                setState(() {});
                                                //    provider.incrementQuantity(index);
                                              }
                                            },
                                            child: Icon(
                                              Icons.add,
                                              size: 15,
                                              color: Theme.of(context).hintColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  TranslationWidget(
                                    message:
                                    breakfastFoodItem.standards,
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
                                    _showBottomSheet(context, breakfastFoodItem);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 160,
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
                                        fit: BoxFit.fill,
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
            if(isdinnerLoadmore == true && selected_food.length > 0)
              SizedBox(height: 60,)
          ],
        );
      }
    }
  }

  void _showBottomSheet(BuildContext context, FoodItem food) {
    // Calculate the height needed for the content
    double contentHeight = 350.0; // Base height for the dialog content
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
                height: contentHeight > 500 ? 500 : contentHeight+50,
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
                                  child: Text(
                                    "₹" + food.price.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      /*Card(
                        child:food.comboMedia.length == 0
                            ? Image.asset(
                          "assets/img/No_imge_food.png",
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.75,
                          fit: BoxFit.fill,
                        )
                            : Image.network(
                          food.comboMedia[0].url.toString(),
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.9,
                          fit: BoxFit.fill,
                        ),
                      ),
                      // Add other content for your bottom sheet here

                      SizedBox(height: 10),
                      Text(
                        food.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        Helper.skipHtml(food.description) ?? '',
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "₹" + food.price.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),*/
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