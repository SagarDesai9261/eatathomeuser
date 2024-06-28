import 'package:flutter/material.dart';
import '../../src/helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/favorite.dart';
import '../models/favourite_model.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class FavoriteListItemWidget extends StatelessWidget {
  String heroTag;
  FavouriteModel favorite;

  FavoriteListItemWidget({ required this.heroTag,required this.favorite})
     ;

  @override
  Widget build(BuildContext context) {
    return InkWell(
     // splashColor: Theme.of(context).accentColor,
     // focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        print('object');
        /*Navigator.of(context).pushNamed('/Food',
            arguments: new RouteArgument(
                heroTag: this.heroTag, id: this.favorite.id.toString()));*/
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag + favorite.id.toString(),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(
                      image: NetworkImage(favorite.image),
                      fit: BoxFit.cover),
                ),
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
                          favorite.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          favorite.name,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Helper.getPrice(double.parse(favorite.maxPrice.toString()), context,
                      style:TextStyle(fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: config.Colors().secondColor(1),
                          height: 1.35)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
