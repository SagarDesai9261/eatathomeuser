import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/route_argument.dart';

import '../repository/settings_repository.dart' as settingRepo;
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import '../../src/helpers/app_config.dart' as config;
// ignore: must_be_immutable
class CartItemWidget extends StatefulWidget {
  String heroTag;
  Cart cart;
  VoidCallback increment;
  VoidCallback decrement;
  VoidCallback onDismissed;
  final Function onCartChanged;

  CartItemWidget(
      {Key key,
      this.cart,
      this.heroTag,
      this.increment,
      this.decrement,
        this.onCartChanged, // Add this callback
      this.onDismissed})
      : super(key: key);

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {

  String defaultLanguage;

  @override
  void initState() {
    getCurrentDefaultLanguage();
    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode){
      // print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.cart.id),
      onDismissed: (direction) {
        setState(() {
          widget.onDismissed();
         // Call the callback when item is dismissed
        });
      },
      child: Container(
        height: 90,
        child: Container(

          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(

            color: Theme.of(context).primaryColor.withOpacity(0.9),
            borderRadius: BorderRadius.all(Radius.circular(5)),
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
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CachedNetworkImage(
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  imageUrl: widget.cart.food.image.thumb,
                  placeholder: (context, url) => Image.asset(
                    'assets/img/loading.gif',
                    fit: BoxFit.cover,
                    height: 90,
                    width: 90,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(width: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width/3.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /*Text(
                          widget.cart.food.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        )*/

                      Text(
                            widget.cart.food.name??"",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),


                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5,
                          children: <Widget>[
                            /*Helper.getPrice(widget.cart.food.price, context,
                                style: Theme.of(context).textTheme.headline6,
                                zeroPlaceholder: 'Free'),*/
                           /* Text(widget.cart.food.price.toString()+" AED", style: TextStyle(fontSize: 15),),*/
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
                                      text:  (widget.cart.food.price).toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ]),
                            ),
                            widget.cart.food.discountPrice > 0
                                ? Helper.getPrice(
                                    widget.cart.food.discountPrice, context,
                                    style: TextStyle(fontSize: 12.0, color: config
                                        .Colors().secondColor(1), height: 1.35)
                                        .merge(TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough)))
                                : SizedBox(height: 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                 // SizedBox(width: MediaQuery.of(context).size.width/8),
                  SizedBox(width: 30),
                  SizedBox(
                    height: 110,
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[


                        SizedBox(
                          height: 30,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                widget.decrement();
                              //    widget.onCartChanged(); // Call the callback when item is increased
                              });
                            },
                            iconSize: 30,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            icon: Icon(Icons.remove_circle_outline),
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          child: Text(widget.cart.quantity.toInt().toString(),
                              style: Theme.of(context).textTheme.subtitle1),
                        ),
                        SizedBox(
                          height: 30,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                widget.increment();
                                //  widget.onCartChanged(); // Call the callback when item is increased
                              });
                            },
                            iconSize: 30,
                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                            icon: Icon(Icons.add_circle_outline),
                            color: Theme.of(context).hintColor,

                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
