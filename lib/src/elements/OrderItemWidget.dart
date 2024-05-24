import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import 'FoodOrderItemWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import '../../src/helpers/app_config.dart' as config;
class OrderItemWidget extends StatefulWidget {
  final bool expanded;
  final Order order;
  final ValueChanged<void> onCanceled;

  OrderItemWidget({Key key, this.expanded, this.order, this.onCanceled})
      : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  final Shader linearGradient = LinearGradient(
    colors: <Color>[kPrimaryColororange, kPrimaryColorLiteorange],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 70.0));

  // Create a function to generate the gradient shader
  String defaultLanguage;

  @override
  void initState() {
    getCurrentDefaultLanguage();
    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingsRepo.getDefaultLanguageName().then((_langCode) {
      print("DS>> DefaultLanguageret " + _langCode);
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Duration timeDifference = DateTime.now().difference(widget.order.dateTime);
    print(timeDifference.inDays);
    bool isOrderExpired = timeDifference.inDays > 1;

    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: widget.order.active ? 1 : 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 14),
                padding: EdgeInsets.only(top: 20, bottom: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Theme(
                  data: theme,
                  child: ExpansionTile(
                    initiallyExpanded: widget.expanded,
                    title: Column(
                      children: <Widget>[
                        /* Text('${S.of(context).order_id}: #${widget.order.id}',
                          style: TextStyle(foreground: Paint()..shader = linearGradient),)*/
                        SizedBox(
                          width: 160,
                          child: Row(
                            children: [
                              TranslationWidget(
                                message: '${S.of(context).order_id}: #',
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  style: TextStyle(
                                      foreground: Paint()
                                        ..shader = linearGradient),
                                ),
                              ),
                              TranslationWidget(
                                message: widget.order.id,
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  style: TextStyle(
                                      foreground: Paint()
                                        ..shader = linearGradient),
                                ),
                              )
                            ],
                          ),
                        ),
                        /*Text(
                          DateFormat('dd-MM-yyyy | HH:mm')
                              .format(widget.order.dateTime),
                          style: Theme.of(context).textTheme.caption,
                        ),*/

                        /*Text(
                          DateFormat('dd-MM-yyyy')
                              .format(widget.order.foodOrders.elementAt(0).dateTime),
                          style: Theme.of(context).textTheme.caption,
                        )*/
                        TranslationWidget(
                          message: DateFormat('dd-MM-yyyy').format(
                              widget.order.foodOrders.elementAt(0).dateTime),
                          fromLanguage: "English",
                          toLanguage: defaultLanguage,
                          builder: (translatedMessage) => Text(
                            translatedMessage,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Helper.getPrice(
                            Helper.getTotalOrdersPrice(widget.order), context,
                            style: TextStyle(fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: config.Colors().secondColor(1),
                          height: 1.35)),
                        Text(
                          '${widget.order.payment.method}',
                          style: Theme.of(context).textTheme.caption,
                        )
                        /* TranslationWidget(
                          message: widget.order.payment.method,
                          fromLanguage: "English",
                          toLanguage: defaultLanguage,
                          builder: (translatedMessage) => Text(
                            translatedMessage,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        )*/
                      ],
                    ),
                    children: <Widget>[
                      Column(
                          children: List.generate(
                        widget.order.foodOrders.length,
                        (indexFood) {
                          return FoodOrderItemWidget(
                              heroTag: 'mywidget.orders',
                              order: widget.order,
                              foodOrder:
                                  widget.order.foodOrders.elementAt(indexFood));
                        },
                      )),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: /*Text(
                                    S.of(context).delivery_fee,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )*/
                                      TranslationWidget(
                                    message: "Delivery fees",
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                ),
                                Helper.getPrice(
                                    widget.order.deliveryFee, context,
                                    style:
                                    TextStyle(fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: config.Colors().secondColor(1),
                                        height: 1.35))
                              ],
                            ),
                            if(widget.order.coupon_code != "")
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "Applied Coupon(${widget.order.coupon_code})",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1,
                                  ),
                                ),
                                RichText(
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    text: TextSpan(
                                      text: "-₹",
                                      style:
                                      TextStyle(fontWeight: FontWeight.w400, fontSize: Theme.of(context).textTheme.subtitle1.fontSize,color: kFBBlue),
                                      children: <TextSpan>[
                                        TextSpan(text: widget.order.coupon_amount ?? '', style:  Theme.of(context).textTheme.subtitle1),
                                      ],
                                    )


                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: /*Text(
                                    '${S.of(context).tax} (${widget.order.tax}%)',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )*/
                                      TranslationWidget(
                                    message:
                                        'GST',
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                ),
                                Helper.getPrice(
                                    Helper.getTaxOrder(widget.order), context,
                                    style:
                                    TextStyle(fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: config.Colors().secondColor(1),
                                        height: 1.35))
                              ],
                            ),

                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: /*Text(
                                    S.of(context).total,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )*/
                                      TranslationWidget(
                                    message: S.of(context).total,
                                    fromLanguage: "English",
                                    toLanguage: defaultLanguage,
                                    builder: (translatedMessage) => Text(
                                      translatedMessage,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                ),
                                Helper.getPrice(
                                    Helper.getTotalOrdersPrice(widget.order),
                                    context,
                                    style:
                                       TextStyle(fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: config.Colors().secondColor(1),
                          height: 1.35))
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: <Widget>[
                    MaterialButton(
                      elevation: 0,
                      focusElevation: 0,
                      highlightElevation: 0,
                      onPressed: () {
                        print(widget.order.res_longitude);
                        if(widget.order.active !=false){
                          if(widget.order.delivery_dinein == 2){
                            Navigator.of(context).pushNamed('/TrackingForDinein',
                                arguments: RouteArgument(
                                    id: widget.order.id,
                                    latitude:widget.order.res_latitude,
                                    longitude:widget.order.res_longitude,
                                    heroTag:
                                    widget.order.delivery_dinein.toString()));
                          }
                          else{
                            Navigator.of(context).pushNamed('/Tracking',
                                arguments: RouteArgument(
                                    id: widget.order.id,
                                    heroTag:
                                    widget.order.delivery_dinein.toString()));
                          }
                        }


                      },
                      textColor: Theme.of(context).hintColor,
                      child: Wrap(
                        children: <Widget>[Text(S.of(context).view)],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 0),
                    ),
                    if (isOrderExpired == false)
                      if (widget.order.canCancelOrder() && widget.order.orderStatus.status =="")
                        MaterialButton(
                          elevation: 0,
                          focusElevation: 0,
                          highlightElevation: 0,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return AlertDialog(
                                  title: Wrap(
                                    spacing: 10,
                                    children: <Widget>[
                                      Icon(Icons.report, color: Colors.orange),
                                      /*Text(
                                      S.of(context).confirmation,
                                      style: TextStyle(color: Colors.orange),
                                    )*/
                                      Text(
                                        S.of(context).confirmation,
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ],
                                  ),
                                  content: /*Text(S
                                    .of(context)
                                    .areYouSureYouWantToCancelThisOrder)*/
                                      Text(
                                    S.of(context)
                                        .areYouSureYouWantToCancelThisOrder,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 25),
                                  actions: <Widget>[
                                    MaterialButton(
                                      elevation: 0,
                                      focusElevation: 0,
                                      highlightElevation: 0,
                                      child: /*new Text(
                                      S.of(context).yes,
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                    )*/
                                        Text(
                                          S.of(context).yes,
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).hintColor),
                                        ),

                                      onPressed: () {
                                        widget.onCanceled(widget.order);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    MaterialButton(
                                      elevation: 0,
                                      focusElevation: 0,
                                      highlightElevation: 0,
                                      child: /*new Text(
                                      S.of(context).close,
                                      style: TextStyle(color: Colors.orange),
                                    )*/
                                          Text(
                                      S.of(context).close,
                                          style:
                                              TextStyle(color: Colors.orange),
                                        ),

                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          textColor: Theme.of(context).hintColor,
                          child: Wrap(
                            children: <Widget>[
                              Text(S.of(context).cancel + " ")
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(start: 20),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 28,
          width: 140,
          /*decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              color: widget.order.active
                  ? Theme.of(context).accentColor
                  : Colors.redAccent),*/
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            gradient: LinearGradient(
              colors: [kPrimaryColororange, kPrimaryColorLiteorange],
            ),
          ),
          alignment: AlignmentDirectional.center,
          child: /*Text(
            widget.order.active
                ? '${widget.order.orderStatus.status}'
                : S.of(context).canceled,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.caption.merge(
                TextStyle(height: 1, color: Theme.of(context).primaryColor)),
          )*/
              TranslationWidget(
            message: widget.order.active
                ? '${widget.order.orderStatus.status}'
                : S.of(context).canceled,
            fromLanguage: "English",
            toLanguage: defaultLanguage,
            builder: (translatedMessage) => Text(
              translatedMessage,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Theme.of(context).textTheme.caption.merge(
                  TextStyle(height: 1, color: Theme.of(context).primaryColor)),
            ),
          ),
        ),
      ],
    );
  }
}
