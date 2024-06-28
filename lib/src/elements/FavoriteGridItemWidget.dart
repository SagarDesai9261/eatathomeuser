import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/restaurant_controller.dart';
import 'package:food_delivery_app/src/models/add_to_favourite_model.dart';
import 'package:food_delivery_app/src/models/favourite_model.dart';
import 'package:food_delivery_app/src/models/remove_from_favourite.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../utils/color.dart';
import '../models/favorite.dart';
import '../models/route_argument.dart';

class FavoriteGridItemWidget extends StatefulWidget {
  final String heroTag;
  final FavouriteModel favorite;
  final Function(String) onRemoveFavorite;

  FavoriteGridItemWidget({ required this.heroTag,required this.favorite,required this.onRemoveFavorite,})
      ;


  @override
  _FavoriteGridItemWidgetState createState() {
    return _FavoriteGridItemWidgetState();
  }
}

class _FavoriteGridItemWidgetState extends StateMVC<FavoriteGridItemWidget> {

  RestaurantController? _con;

  _FavoriteGridItemWidgetState() : super(RestaurantController()) {
    _con = controller as RestaurantController? ;
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
     // splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      onTap: () {
       /* Navigator.of(context).pushNamed('/Food',
            arguments: new RouteArgument(
                heroTag: this.widget.heroTag, id: this.widget.favorite.id.toString()));*/
      },
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Hero(
                  tag: widget.heroTag + widget.favorite.id.toString(),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).pushNamed('/Details',
                          arguments: RouteArgument(
                            id: '0',
                            param: widget.favorite.restaurant_id.toString(),
                            heroTag: widget.heroTag,
                            isDelivery: true,
                            selectedDate: "",
                            parentScaffoldKey: new GlobalKey(),
                          ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(this.widget.favorite.image),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                widget.favorite.name,
                style: Theme.of(context).textTheme.bodyText1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                widget.favorite.name,
                style: Theme.of(context).textTheme.caption,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: 50,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    kPrimaryColororange,
                    kPrimaryColorLiteorange
                  ],)
              ),
              child: MaterialButton(
                elevation: 0,
                focusElevation: 0,
                highlightElevation: 0,
                padding: EdgeInsets.all(0),
                onPressed: () async {
                  if (currentUser
                      .value.apiToken ==
                      null) {
                    Navigator.of(context)
                        .pushNamed("/Login");
                  } else {
                    DeleteFromFavouriteModel apiResponse =
                        await _con
                        !.removeRestaurantFromFavouriteList(
                        widget.favorite.favourite_id.toString(),
                        currentUser
                            .value
                            .apiToken);

                    print("DS>> res## " +
                        apiResponse.message
                            .toString());
                    widget.onRemoveFavorite(widget.favorite.favourite_id.toString());
                    ScaffoldMessenger.of(
                        context)
                        .showSnackBar(SnackBar(
                      content: Text(apiResponse
                          .message
                          .toString()),
                    ));
                  }
                },
                child: Icon(
                  Icons.favorite,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                //color: Theme.of(context).accentColor.withOpacity(0.9),
               // shape: StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
