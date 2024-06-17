import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../my_widget/calander_widget.dart';
import '../../my_widget/calander_widget_search.dart';
import '../../utils/color.dart';
import '../controllers/food_controller.dart';
import '../controllers/homecontroller_provider.dart';
import '../controllers/search_controller.dart'; // Import your SearchController
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../pages/cart.dart';
import '../provider.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../../generated/l10n.dart';

import '../models/food.dart'; // Import your Food model

import '../repository/translation_widget.dart';
import '../repository/user_repository.dart';
import 'CircularLoadingWidget.dart';
import 'FoodItemWidget.dart'; // Import your RestaurantModel class

class SearchResultWidget extends StatefulWidget {
  final String heroTag;
  final bool isDinein;
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  SearchResultWidget({Key key, this.heroTag, this.isDinein,this.parentScaffoldKey}) : super(key: key);

  @override
  _SearchResultWidgetState createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget>  with SingleTickerProviderStateMixin {
  String defaultLanguage = "en";
  bool isBreakfastVisible = true;
  bool isLunchVisible = true;
  bool isSnacksVisible = true;
  bool isDinnerVisible = true;
  TabController _tabController;
  int _quantity = 1;
  List<Food> foodList = [];
  bool iscartload = false;
  FoodController _foodcon;
  bool isBreakfastSelected = false;
  bool isLunchSelected = false;
  bool isSnacksSelected = false;
  bool isDinnerSelected = false;
  bool buttonPressed = false;
  bool isbreckfastenable =false;
  bool islunchenable =false;
  bool isdinnerenable =false;
  bool issnacksenable =false;
  var breakfastslot_start ;
  var breakfastslot_end ;
  var lunchslot_start ;
  var lunchslot_end ;
  var snacksslot_start ;
  var snacksslot_end ;
  var dinnerslot_start ;
  var dinnerslot_end ;
  DateTime b_startTime ;
  DateTime b_endTime ;
  DateTime l_startTime ;
  DateTime l_endTime ;
  DateTime s_startTime ;
  DateTime s_endTime ;
  DateTime d_startTime ;
  DateTime d_endTime ;
  List<Map<String,dynamic>> fooditems = [];
  Map<String, int> _quantities = {};
  DateTime todayWithTime(String time) {
    var currentTime = DateTime.now();
    final DateFormat timeFormat = DateFormat('HH:mm:ss');
    final parsedTime = timeFormat.parse(time);
    return DateTime(currentTime.year, currentTime.month, currentTime.day, parsedTime.hour, parsedTime.minute, parsedTime.second);
  }
  void _scheduleButtonPress() {
    Future.delayed(Duration(seconds: 1), () {

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

      print(b_endTime);
      print( currentTime.isBefore(b_endTime));
      if (currentTime.isAfter(d_startTime)) {
        setState(() {
          isbreckfastenable = false;
          islunchenable = false;
          issnacksenable = false;
          isdinnerenable = true;

          isBreakfastSelected = false;
          isLunchSelected = false;
          isSnacksSelected = false;
          isDinnerSelected = true;
        });
      } else if (currentTime.isAfter(s_startTime)) {
        setState(() {
          isbreckfastenable = false;
          islunchenable = false;
          isdinnerenable = true;
          issnacksenable = true;

          isBreakfastSelected = false;
          isLunchSelected = false;
          isSnacksSelected = true;
          isDinnerSelected = false;
        });
      } else if (currentTime.isAfter(l_startTime)) {
        setState(() {
          isbreckfastenable = false;
          islunchenable = true;
          isdinnerenable = true;
          issnacksenable = true;

          isBreakfastSelected = false;
          isLunchSelected = true;
          isSnacksSelected = false;
          isDinnerSelected = false;
        });
      } else if (currentTime.isAfter(b_startTime)) {
        setState(() {
          isbreckfastenable = true;
          islunchenable = true;
          isdinnerenable = true;
          issnacksenable = true;

          isBreakfastSelected = true;
          isLunchSelected = false;
          isSnacksSelected = false;
          isDinnerSelected = false;
        });
      }

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _foodcon = FoodController();
    _scheduleButtonPress();
  }
  @override
  Widget build(BuildContext context) {
    final searchController = Provider.of<RestaurantDataProvider>(context);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              trailing: IconButton(
                icon: Icon(Icons.close),
                color: Theme.of(context).hintColor,
                onPressed: () {
                 // searchController.clearSearchResults();
                  Navigator.pop(context);
                },
              ),
              title: Text(
                S.of(context).search,
                style: Theme.of(context).textTheme.headline4,
              ),
              subtitle: Text(
                S.of(context).ordered_by_nearby_first,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (text) async {
                await searchController.refreshSearch(text);
                searchController.saveSearch(text);
              },
              autofocus: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(12),
                hintText: "Search for kitchen or foods",
                hintStyle: Theme.of(context)
                    .textTheme
                    .caption
                    .merge(TextStyle(fontSize: 14)),
                prefixIcon:
                Icon(Icons.search, color: Theme.of(context).accentColor),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.3))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.1))),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Restaurants'),
              Tab(text: 'Foods'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Consumer<RestaurantDataProvider>(
                  builder: (context, searchController, _) {
                    print(searchController.foodsbreakfast.length);
                    return searchController.isLoading
                        ? CircularLoadingWidget(height: 288)
                        : Expanded(
                      child: ListView(
                        children: <Widget>[
                         /* Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  if (searchController.foodsbreakfast.isNotEmpty)
                                  Expanded(
                                    child: Container(
                                      // width:235,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.only(
                                              topLeft: Radius.circular(0),
                                              bottomLeft: Radius.circular(0)),
                                          color: *//*currentHour < 7 || *//* !isbreckfastenable ? Colors.grey[200] : isBreakfastSelected ? kPrimaryColororange : Colors.white,
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
                                        child:
                                        GestureDetector(
                                         *//* onTap: !isbreckfastenable ? null : () {


                                            _controller
                                                .isDateUpdated =
                                            false;
                                            // _controller.listenForFoodsByCategoryAndKitchen(id: "8", restaurantId: _con.restaurant.id);
                                            showBreakFastView();
                                          },*//*
                                          child:
                                          TranslationWidget(
                                            message:
                                            "Breakfast",
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
                                                      12,
                                                      fontWeight:
                                                      FontWeight
                                                          .normal,
                                                      color: isBreakfastSelected
                                                          ? Colors
                                                          .white
                                                          : Colors
                                                          .black),
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
                                  if (searchController.foodslunch.isNotEmpty)
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: *//*currentHour < 11 || *//*
                                          !islunchenable ? Colors.grey[200]:
                                         isLunchSelected
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
                                        child:
                                        GestureDetector(
                                          // onTap: !islunchenable ? null: () {
                                          //   _controller
                                          //       .isDateUpdated =
                                          //   false;
                                          //
                                          //   showLunchView();
                                          // },
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [
                                              TranslationWidget(
                                                message:
                                                "Lunch",
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
                                                          12,
                                                          fontWeight: FontWeight
                                                              .normal,
                                                          color: isLunchSelected
                                                              ? Colors.white
                                                              : Colors.black),
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
                                  if (searchController.foodssnacks.isNotEmpty)
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: !issnacksenable ? Colors.grey[200]: isSnacksSelected
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
                                        child:
                                        GestureDetector(
                                        *//*  onTap: !issnacksenable ?null : () {
                                            _controller
                                                .isDateUpdated =
                                            false;

                                            showSnacksView();
                                          },*//*
                                          child:
                                          TranslationWidget(
                                            message:
                                            "Snacks",
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
                                                      12,
                                                      fontWeight:
                                                      FontWeight
                                                          .normal,
                                                      color: isSnacksSelected
                                                          ? Colors
                                                          .white
                                                          : Colors
                                                          .black),
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
                                  if (searchController.foodsdinner.isNotEmpty)
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
                                          color: *//*currentHour < 19 || *//* !isdinnerenable ?  Colors.grey[200]  : isDinnerSelected ? kPrimaryColororange : Colors.white,
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
                                        child:
                                        GestureDetector(
                                          // onTap: !isdinnerenable ? null : () {
                                          //   _controller
                                          //       .isDateUpdated =
                                          //   false;
                                          //
                                          //   showDinnerView();
                                          // },
                                          child:
                                          TranslationWidget(
                                            message:
                                            "Dinner",
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
                                                      12,
                                                      fontWeight:
                                                      FontWeight
                                                          .normal,
                                                      color: isDinnerSelected
                                                          ? Colors
                                                          .white
                                                          : Colors
                                                          .black),
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
                          if (searchController.foodsbreakfast.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                title: Text(
                                  S.of(context).foods_results,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            ),
                          ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: searchController.foodsbreakfast.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 10);
                            },
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                 print(searchController.foodsbreakfast.elementAt(index).name);
                                  *//* Navigator.of(context).pushNamed('/Food',
                                  arguments: RouteArgument(
                                  id:searchController.foods[index].id
                                  ));*//*

                                 *//* if (isDinein) {
                                    showCalendarDialog(context, searchController.foods.elementAt(index).restaurant.id, false, -1);
                                  } else {
                                    Navigator.of(context).pushNamed('/Details',
                                        arguments: RouteArgument(
                                          id: '0',
                                          param: searchController.foods.elementAt(index).restaurant.id,
                                          heroTag: widget.heroTag,
                                          isDelivery: true,
                                          selectedDate: "",
                                        ));
                                  }*//*
                                },
                                child: FoodItemWidget(
                                  heroTag: 'search_list',
                                  food: searchController.foodsbreakfast.elementAt(index),
                                ),
                              );
                            },
                          ),
                          if (searchController.restaurants.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                title: Text(
                                  S.of(context).restaurants_results,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            ),*/

                          ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: searchController.restaurants.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  print( searchController.restaurants[index].id);
                                  if (widget.isDinein) {
                                    showCalendarDialog(context, searchController.restaurants[index].id, false, -1);
                                  } else {
                                    Navigator.of(context).pushNamed('/Details',
                                        arguments: RouteArgument(
                                          id: '0',
                                          param: searchController.restaurants[index].id,
                                          heroTag: widget.heroTag,
                                          isDelivery: true,
                                          selectedDate: "",
                                        ));
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).focusColor.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Hero(
                                        tag: widget.heroTag,
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                              child: searchController.restaurants[index].closed == "0"
                                                  ? CachedNetworkImage(
                                                height: 60,
                                                width: 60,
                                                fit: BoxFit.cover,
                                                imageUrl: searchController.restaurants[index].media.length == 0
                                                    ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ14AJXokxXlQNidFd1P1rK_JuRjzRpaFC4DQ&usqp=CAU"
                                                    : searchController.restaurants[index].media[0].url,
                                                placeholder: (context, url) => Image.asset(
                                                  'assets/img/loading.gif',
                                                  fit: BoxFit.cover,
                                                  height: 60,
                                                  width: 60,
                                                ),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                              )
                                                  : ColorFiltered(
                                                colorFilter: ColorFilter.mode(
                                                  Colors.black, // Apply a black and white filter
                                                  BlendMode.saturation,
                                                ),
                                                child: CachedNetworkImage(
                                                  height: 60,
                                                  width: 60,
                                                  fit: BoxFit.cover,
                                                  imageUrl: searchController.restaurants[index].media.length == 0
                                                      ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ14AJXokxXlQNidFd1P1rK_JuRjzRpaFC4DQ&usqp=CAU"
                                                      : searchController.restaurants[index].media[0].url,
                                                  placeholder: (context, url) => Image.asset(
                                                    'assets/img/loading.gif',
                                                    fit: BoxFit.cover,
                                                    height: 60,
                                                    width: 60,
                                                  ),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Flexible(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    searchController.restaurants[index].name,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: Theme.of(context).textTheme.subtitle1,
                                                  ),
                                                  RatingBar.builder(
                                                    itemSize: 18,
                                                    initialRating: searchController.restaurants[index].rate != "null"
                                                        ? double.parse(searchController.restaurants[index].rate)
                                                        : 0.0,
                                                    minRating: 0,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemBuilder: (context, _) => ShaderMask(
                                                      shaderCallback: (Rect bounds) {
                                                        return LinearGradient(
                                                          colors: [
                                                            kPrimaryColororange,
                                                            kPrimaryColorLiteorange
                                                          ],
                                                        ).createShader(bounds);
                                                      },
                                                      child: Icon(
                                                        Icons.star,
                                                        color: Colors.white,
                                                        size: 18.0,
                                                      ),
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      print(rating);
                                                    },
                                                  ),
                                                  if (searchController.restaurants[index].closed == "1")
                                                    Text(
                                                      "Currently not accepting order",
                                                      style: TextStyle(color: Colors.redAccent),
                                                    )
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Consumer<RestaurantDataProvider>(
                  builder: (context, searchController, _) {
                    print(searchController.foodsbreakfast.length);
                    // Determine if the current session has food items
                    bool hasBreakfast = searchController.foodsbreakfast.isNotEmpty;
                    bool hasLunch = searchController.foodslunch.isNotEmpty;
                    bool hasSnacks = searchController.foodssnacks.isNotEmpty;
                    bool hasDinner = searchController.foodsdinner.isNotEmpty;

                    // Determine which session's food to display
                    bool displayBreakfast = isBreakfastSelected && hasBreakfast;
                    bool displayLunch = isLunchSelected && hasLunch;
                    bool displaySnacks = isSnacksSelected && hasSnacks;
                    bool displayDinner = isDinnerSelected && hasDinner;

                    // Determine if we need to display all food items
                    bool displayAll = !(displayBreakfast || displayLunch || displaySnacks || displayDinner);

                    return searchController.isLoading
                        ? CircularLoadingWidget(height: 288)
                        : Expanded(
                      child: ListView(
                        children: <Widget>[
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  if (searchController.foodsbreakfast.isNotEmpty)
                                    Expanded(
                                      child: Container(
                                        // width:235,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                bottomLeft: Radius.circular(0)),
                                            color: /*currentHour < 7 || */ !isbreckfastenable ? Colors.grey[200] : isBreakfastSelected ? kPrimaryColororange : Colors.white,
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
                                          child:
                                          GestureDetector(
                                             onTap: !isbreckfastenable ? null : () {
                                               setState(() {
                                                  isBreakfastSelected = true;
                                                  isLunchSelected = false;
                                                  isSnacksSelected = false;
                                                  isDinnerSelected = false;
                                               });
                                          },
                                            child:
                                            TranslationWidget(
                                              message:
                                              "Breakfast",
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
                                                        12,
                                                        fontWeight:
                                                        FontWeight
                                                            .normal,
                                                        color: isBreakfastSelected
                                                            ? Colors
                                                            .white
                                                            : Colors
                                                            .black),
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
                                  if (searchController.foodslunch.isNotEmpty)
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: /*currentHour < 11 || */
                                            !islunchenable ? Colors.grey[200]:
                                            isLunchSelected
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
                                          child:
                                          GestureDetector(
                                            onTap: !islunchenable ? null: () {
                                              setState(() {
                                                isBreakfastSelected = false;
                                                isLunchSelected = true;
                                                isSnacksSelected = false;
                                                isDinnerSelected = false;
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              children: [
                                                TranslationWidget(
                                                  message:
                                                  "Lunch",
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
                                                            12,
                                                            fontWeight: FontWeight
                                                                .normal,
                                                            color: isLunchSelected
                                                                ? Colors.white
                                                                : Colors.black),
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
                                  if (searchController.foodssnacks.isNotEmpty)
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: !issnacksenable ? Colors.grey[200]: isSnacksSelected
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
                                          child:
                                          GestureDetector(
                                              onTap: !issnacksenable ?null : () {
                                                setState(() {
                                                  isBreakfastSelected = false;
                                                  isLunchSelected = false;
                                                  isSnacksSelected = true;
                                                  isDinnerSelected = false;
                                                });
                                          },
                                            child:
                                            TranslationWidget(
                                              message:
                                              "Snacks",
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
                                                        12,
                                                        fontWeight:
                                                        FontWeight
                                                            .normal,
                                                        color: isSnacksSelected
                                                            ? Colors
                                                            .white
                                                            : Colors
                                                            .black),
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
                                  if (searchController.foodsdinner.isNotEmpty)
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
                                            color: /*currentHour < 19 || */ !isdinnerenable ?  Colors.grey[200]  : isDinnerSelected ? kPrimaryColororange : Colors.white,
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
                                          child:
                                          GestureDetector(
                                            onTap: !isdinnerenable ? null : () {
                                              setState(() {
                                                isBreakfastSelected = false;
                                                isLunchSelected = false;
                                                isSnacksSelected = false;
                                                isDinnerSelected = true;
                                              });
                                            },
                                            child:
                                            TranslationWidget(
                                              message:
                                              "Dinner",
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
                                                        12,
                                                        fontWeight:
                                                        FontWeight
                                                            .normal,
                                                        color: isDinnerSelected
                                                            ? Colors
                                                            .white
                                                            : Colors
                                                            .black),
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
                          if (searchController.foodsbreakfast.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                title: Text(
                                  S.of(context).foods_results,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            ),
                          if (displayAll || isBreakfastSelected)
                          ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: searchController.foodsbreakfast.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 10);
                            },
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  print(searchController.foodsbreakfast.elementAt(index).name);
                                  /* Navigator.of(context).pushNamed('/Food',
                                  arguments: RouteArgument(
                                  id:searchController.foods[index].id
                                  ));*/

                                  /* if (isDinein) {
                                    showCalendarDialog(context, searchController.foods.elementAt(index).restaurant.id, false, -1);
                                  } else {
                                    Navigator.of(context).pushNamed('/Details',
                                        arguments: RouteArgument(
                                          id: '0',
                                          param: searchController.foods.elementAt(index).restaurant.id,
                                          heroTag: widget.heroTag,
                                          isDelivery: true,
                                          selectedDate: "",
                                        ));
                                  }*/
                                },
                                child: FoodItemWidget(
                                  heroTag: 'search_list',
                                  food: searchController.foodsbreakfast.elementAt(index),
                                  fieldenable: isbreckfastenable ? true : false,
                                  onTap: (){
                                    _showDialog(context,searchController.foodsbreakfast.elementAt(index));
                                  },
                                ),
                              );
                            },
                          ),
                          if (displayAll || isLunchSelected)
                            ListView.separated(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              primary: false,
                              itemCount: searchController.foodslunch.length,
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 10);
                              },
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    print(searchController.foodslunch.elementAt(index).name);
                                    /* Navigator.of(context).pushNamed('/Food',
                                  arguments: RouteArgument(
                                  id:searchController.foods[index].id
                                  ));*/

                                    /* if (isDinein) {
                                    showCalendarDialog(context, searchController.foods.elementAt(index).restaurant.id, false, -1);
                                  } else {
                                    Navigator.of(context).pushNamed('/Details',
                                        arguments: RouteArgument(
                                          id: '0',
                                          param: searchController.foods.elementAt(index).restaurant.id,
                                          heroTag: widget.heroTag,
                                          isDelivery: true,
                                          selectedDate: "",
                                        ));
                                  }*/
                                  },
                                  child: FoodItemWidget(
                                    heroTag: 'search_list',
                                    food: searchController.foodslunch.elementAt(index),
                                    fieldenable: islunchenable ? true : false,
                                    onTap: (){
                                      _showDialog(context,searchController.foodslunch.elementAt(index));
                                    },
                                  ),
                                );
                              },
                            ),
                          if (displayAll || isSnacksSelected)
                            ListView.separated(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              primary: false,
                              itemCount: searchController.foodssnacks.length,
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 10);
                              },
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    print(searchController.foodssnacks.elementAt(index).name);
                                    /* Navigator.of(context).pushNamed('/Food',
                                  arguments: RouteArgument(
                                  id:searchController.foods[index].id
                                  ));*/

                                    /* if (isDinein) {
                                    showCalendarDialog(context, searchController.foods.elementAt(index).restaurant.id, false, -1);
                                  } else {
                                    Navigator.of(context).pushNamed('/Details',
                                        arguments: RouteArgument(
                                          id: '0',
                                          param: searchController.foods.elementAt(index).restaurant.id,
                                          heroTag: widget.heroTag,
                                          isDelivery: true,
                                          selectedDate: "",
                                        ));
                                  }*/
                                  },
                                  child: FoodItemWidget(
                                    heroTag: 'search_list',
                                    food: searchController.foodssnacks.elementAt(index),
                                    fieldenable: issnacksenable ? true : false,
                                    onTap: (){
                                      _showDialog(context,searchController.foodssnacks.elementAt(index));
                                    },
                                  ),
                                );
                              },
                            ),
                          if (displayAll || isDinnerSelected)
                            ListView.separated(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              primary: false,
                              itemCount: searchController.foodsdinner.length,
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 10);
                              },
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    print(searchController.foodsdinner.elementAt(index).name);
                                    /* Navigator.of(context).pushNamed('/Food',
                                  arguments: RouteArgument(
                                  id:searchController.foods[index].id
                                  ));*/

                                    /* if (isDinein) {
                                    showCalendarDialog(context, searchController.foods.elementAt(index).restaurant.id, false, -1);
                                  } else {
                                    Navigator.of(context).pushNamed('/Details',
                                        arguments: RouteArgument(
                                          id: '0',
                                          param: searchController.foods.elementAt(index).restaurant.id,
                                          heroTag: widget.heroTag,
                                          isDelivery: true,
                                          selectedDate: "",
                                        ));
                                  }*/
                                  },
                                  child: FoodItemWidget(
                                    heroTag: 'search_list',
                                    food: searchController.foodsdinner.elementAt(index),
                                    fieldenable: isdinnerenable ? true : false,
                                    onTap: (){
                                      _showDialog(context,searchController.foodsdinner.elementAt(index));
                                    },
                                  ),
                                );
                              },
                            ),
                       /*   if (searchController.restaurants.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                title: Text(
                                  S.of(context).restaurants_results,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            ),

                          ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: searchController.restaurants.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  print( searchController.restaurants[index].id);
                                  if (widget.isDinein) {
                                    showCalendarDialog(context, searchController.restaurants[index].id, false, -1);
                                  } else {
                                    Navigator.of(context).pushNamed('/Details',
                                        arguments: RouteArgument(
                                          id: '0',
                                          param: searchController.restaurants[index].id,
                                          heroTag: widget.heroTag,
                                          isDelivery: true,
                                          selectedDate: "",
                                        ));
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).focusColor.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Hero(
                                        tag: widget.heroTag,
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                              child: searchController.restaurants[index].closed == "0"
                                                  ? CachedNetworkImage(
                                                height: 60,
                                                width: 60,
                                                fit: BoxFit.cover,
                                                imageUrl: searchController.restaurants[index].media.length == 0
                                                    ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ14AJXokxXlQNidFd1P1rK_JuRjzRpaFC4DQ&usqp=CAU"
                                                    : searchController.restaurants[index].media[0].url,
                                                placeholder: (context, url) => Image.asset(
                                                  'assets/img/loading.gif',
                                                  fit: BoxFit.cover,
                                                  height: 60,
                                                  width: 60,
                                                ),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                              )
                                                  : ColorFiltered(
                                                colorFilter: ColorFilter.mode(
                                                  Colors.black, // Apply a black and white filter
                                                  BlendMode.saturation,
                                                ),
                                                child: CachedNetworkImage(
                                                  height: 60,
                                                  width: 60,
                                                  fit: BoxFit.cover,
                                                  imageUrl: searchController.restaurants[index].media.length == 0
                                                      ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ14AJXokxXlQNidFd1P1rK_JuRjzRpaFC4DQ&usqp=CAU"
                                                      : searchController.restaurants[index].media[0].url,
                                                  placeholder: (context, url) => Image.asset(
                                                    'assets/img/loading.gif',
                                                    fit: BoxFit.cover,
                                                    height: 60,
                                                    width: 60,
                                                  ),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Flexible(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    searchController.restaurants[index].name,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: Theme.of(context).textTheme.subtitle1,
                                                  ),
                                                  RatingBar.builder(
                                                    itemSize: 18,
                                                    initialRating: searchController.restaurants[index].rate != "null"
                                                        ? double.parse(searchController.restaurants[index].rate)
                                                        : 0.0,
                                                    minRating: 0,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemBuilder: (context, _) => ShaderMask(
                                                      shaderCallback: (Rect bounds) {
                                                        return LinearGradient(
                                                          colors: [
                                                            kPrimaryColororange,
                                                            kPrimaryColorLiteorange
                                                          ],
                                                        ).createShader(bounds);
                                                      },
                                                      child: Icon(
                                                        Icons.star,
                                                        color: Colors.white,
                                                        size: 18.0,
                                                      ),
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      print(rating);
                                                    },
                                                  ),
                                                  if (searchController.restaurants[index].closed == "1")
                                                    Text(
                                                      "Currently not accepting order",
                                                      style: TextStyle(color: Colors.redAccent),
                                                    )
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),*/
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _showDialog(BuildContext context, Food food) {

// Initialize the quantity for this food item if not already set
    if (!_quantities.containsKey(food.id)) {
      _quantities[food.id] = 1; // Default quantity is 0
    }
    // Calculate the height needed for the content
    double baseHeight = 330.0; // Base height for the dialog content
    double descriptionHeight = 0.0;
    if (food.description != null) {
      // Calculate height based on the number of lines in description
      int descriptionLines = (food.description.length / 35).ceil(); // Assuming each line is 30 characters long
      descriptionLines = descriptionLines > 3 ? 3 : descriptionLines; // Limit to maximum 3 lines
      descriptionHeight = descriptionLines * 20.0; // Each line height is 20
    }
    double contentHeight = baseHeight + descriptionHeight;

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
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
                    height: contentHeight,
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        food.image.url.toString(),
                                        height: 200,
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      food.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      Helper.skipHtml(food.description) ?? '',
                                      textAlign: TextAlign.justify,
                                      style: Theme.of(context).textTheme.caption,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
                                  Row(
                                    children: [
                                      Container(
                                        width: 100,
                                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                  onTap: (){
                                                    setState(() {
                                                      if (_quantities[food.id] > 1) {
                                                        _quantities[food.id] = _quantities[food.id] - 1;
                                                      }
                                                    });

                                                  },
                                                 // onTap: onTap,
                                                  /*onTap: () {
                                              if (_con.restaurant.closed == "1") {
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
                                                    Icons.remove,
                                                    size: 15,
                                                    color: Theme.of(context).hintColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                               _quantities[food.id].toString(),
                                              style: TextStyle(fontSize: 18),
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
                                                    setState(() {
                                                      _quantities[food.id] = _quantities[food.id] + 1;
                                                    });
                                                  },
                                                  // onTap: onTap,
                                                  /*onTap: () {
                                              if (_con.restaurant.closed == "1") {
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
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: (){
                                            if(currentUser.value.apiToken != null )
                                            {
                                              if(widget.isDinein){
                                                foodList.clear();
                                                fooditems.clear();
                                                fooditems.add({"food":food,"Quantity" : _quantities[food.id].toDouble()});
                                                foodList.add(food);

                                                showCalendarDialogsearch(
                                                  context,food.restaurant.id,false,fooditems,-1 ,(food.price * _quantities[food.id]).toInt(),foodList,food.restaurant,
                                                );
                                              }
                                              else {
                                                setState(() {
                                                  iscartload = true;
                                                });
                                                _foodcon.addToCart(food,
                                                    quantity: _quantities[food
                                                        .id].toDouble(),
                                                    restaurant_id: food
                                                        .restaurant.id,
                                                    coupon_id: null);
                                                Future.delayed(
                                                    Duration(seconds: 3), () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CartWidget(
                                                              parentScaffoldKey: widget
                                                                  .parentScaffoldKey),
                                                    ),
                                                  );
                                                  setState(() {
                                                    iscartload = false;
                                                  });
                                                });
                                              }
                                            }
                                            else {
                                              Navigator.of(context).pushNamed('/Login');
                                            }

                                          },
                                          child: Container(
                                            height: 40,
                                            padding: EdgeInsets.all(5),
                                            margin: EdgeInsets.only(
                                                left: 10, bottom: 5),


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
                                            child:iscartload ?Center(child: CircularProgressIndicator(color: Colors.white,)) :   Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Add item ₹${_quantity * food.price}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontFamily: 'Roboto', // Explicitly set to a normal font
                                                  ),
                                                ),
                                                Icon(Icons.arrow_circle_right_outlined,color: Colors.white,)
                                              ],
                                            )
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
          }
        );
      },
    );
  }

}
