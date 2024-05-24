import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../my_widget/calander_widget.dart';
import '../../utils/color.dart';
import '../controllers/search_controller.dart'; // Import your SearchController
import '../models/route_argument.dart';
import '../provider.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../../generated/l10n.dart';

import '../models/food.dart'; // Import your Food model

import 'CircularLoadingWidget.dart';
import 'FoodItemWidget.dart'; // Import your RestaurantModel class

class SearchResultWidget extends StatefulWidget {
  final String heroTag;
  final bool isDinein;

  SearchResultWidget({Key key, this.heroTag, this.isDinein}) : super(key: key);

  @override
  _SearchResultWidgetState createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
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
          Consumer<RestaurantDataProvider>(
            builder: (context, searchController, _) {
              return searchController.isLoading
                  ? CircularLoadingWidget(height: 288)
                  : Expanded(
                child: ListView(
                  children: <Widget>[
                    if (searchController.foods.isNotEmpty)
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
                      itemCount: searchController.foods.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            if (widget.isDinein) {
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
                            }
                          },
                          child: FoodItemWidget(
                            heroTag: 'search_list',
                            food: searchController.foods.elementAt(index),
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
                      ),

                    ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: searchController.restaurants.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (widget.isDinein) {
                              showCalendarDialog(context, searchController.restaurants.elementAt(index).id, false, -1);
                            } else {
                              Navigator.of(context).pushNamed('/Details',
                                  arguments: RouteArgument(
                                    id: '0',
                                    param: searchController.restaurants.elementAt(index).id,
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
        ],
      ),
    );
  }
}
