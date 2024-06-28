import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/order.dart';
import 'package:food_delivery_app/utils/color.dart';

class MyOrderItemWidget extends StatefulWidget {
  final bool expanded;
  final Order order;
  final ValueChanged<void> onCanceled;

  MyOrderItemWidget({Key? key, required this.expanded,required this.order,required this.onCanceled})
      : super(key: key);


  @override
  State<MyOrderItemWidget> createState() => _MyOrderItemWidgetState();
}

class _MyOrderItemWidgetState extends State<MyOrderItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 3,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(

                height: 60,
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: widget.order.foodOrders!.length>0 ? CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl:
                    widget.order.foodOrders![0].food!.image.toString() ,
                    placeholder: (context, url) => Image.asset(
                      'assets/img/loading.gif',
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) =>
                        Image.asset(
                          'assets/img/image-Ae.png',
                          fit: BoxFit.cover,
                        ),
                  ) : Image.asset(
                    'assets/img/image-Ae.png',
                    fit: BoxFit.cover,
                  ),
                ),

              ),
              SizedBox(width: 15),
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.order.foodOrders!.length>0 ? widget.order.foodOrders![0].food!.name : "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Text(
                              widget.order.orderStatus!.status.toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                            Text(
                              "Order ID: "+widget.order.id!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width/5,
                          height: 25,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                              ), ),
                            child: MaterialButton(
                              onPressed: () {
                              },
                              disabledColor:
                              Theme.of(context).focusColor.withOpacity(0.5),
                              padding: EdgeInsets.symmetric(vertical: 1),
                              child: Text(
                                "Track",
                                textAlign: TextAlign.start,
                                style:
                                    TextStyle(fontSize: 12,
                                        color: Theme.of(context).primaryColor)),

                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Cancel",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    )

                    /* Helper.getPrice(double.parse(widget.food.price.toString()), context,
                        style: Theme.of(context).textTheme.headline4),*/
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
