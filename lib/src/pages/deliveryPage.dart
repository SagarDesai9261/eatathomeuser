  import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../controllers/cart_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/CartItemWidget.dart';
import '../elements/EmptyCartWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class DeliveryPage extends StatefulWidget {
  final RouteArgument routeArgument;

  DeliveryPage({Key key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends StateMVC<DeliveryPage> {
  CartController _con;

  _DeliveryPageState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCarts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
        //bottomNavigationBar: CartBottomDetailsWidget(con: _con),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);

              // if (widget.routeArgument != null) {
              //   Navigator.of(context).pushReplacementNamed(widget.routeArgument.param, arguments: RouteArgument(id: widget.routeArgument.id));
              // } else {
              //   Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
              // }
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).delivery,
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _con.refreshCarts,
          child: _con.carts.isEmpty
              ? EmptyCartWidget()
              : Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    ListView(
                      primary: true,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            leading: Icon(
                              Icons.shopping_cart,
                              color: Theme.of(context).hintColor,
                            ),
                            title: Text(
                              "Order Review",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            subtitle: Text(
                              S.of(context).verify_your_quantity_and_click_checkout,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                        ),
                        Container(
                          height: 300,
                          child: ListView.separated(
                            padding: EdgeInsets.only(top: 15, bottom: 120),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: _con.carts.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 15);
                            },
                            itemBuilder: (context, index) {
                              return CartItemWidget(
                                cart: _con.carts.elementAt(index),
                                heroTag: 'cart',
                                increment: () {
                                  _con.incrementQuantity(_con.carts.elementAt(index));
                                },
                                decrement: () {
                                  _con.decrementQuantity(_con.carts.elementAt(index));
                                },
                                onDismissed: () {
                                  _con.removeFromCart(_con.carts.elementAt(index));
                                  //_con.refreshCarts();
                                },
                                onCartChanged: () {
                                  _con.refreshCarts();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Container(
                    //   padding: const EdgeInsets.all(18),
                    //   margin: EdgeInsets.only(bottom: 15),
                    //   decoration: BoxDecoration(
                    //       color: Theme.of(context).primaryColor,
                    //       borderRadius: BorderRadius.all(Radius.circular(20)),
                    //       boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, 2), blurRadius: 5.0)]),
                    //   child: TextField(
                    //     keyboardType: TextInputType.text,
                    //     onSubmitted: (String value) {
                    //       _con.doApplyCoupon(value);
                    //     },
                    //     cursorColor: Theme.of(context).accentColor,
                    //     controller: TextEditingController()..text = coupon?.code ?? '',
                    //     decoration: InputDecoration(
                    //       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    //       floatingLabelBehavior: FloatingLabelBehavior.always,
                    //       hintStyle: Theme.of(context).textTheme.bodyText1,
                    //       suffixText: coupon?.valid == null ? '' : (coupon.valid ? S.of(context).validCouponCode : S.of(context).invalidCouponCode),
                    //       suffixStyle: Theme.of(context).textTheme.caption.merge(TextStyle(color: _con.getCouponIconColor())),
                    //       suffixIcon: Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 15),
                    //         child: Icon(
                    //           Icons.confirmation_number,
                    //           color: _con.getCouponIconColor(),
                    //           size: 28,
                    //         ),
                    //       ),
                    //       hintText: S.of(context).haveCouponCode,
                    //       border: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    //       focusedBorder: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                    //       enabledBorder: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 10,),
                    Positioned(
                      bottom: 100,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            height: 70,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                   Text( S.of(context).subtotal,
                                   style: Theme.of(context).textTheme.headlineMedium,),
                                   Text( "Charges"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('₹'),
                                    SizedBox(width: 2,),
                                    Text('530',style: Theme.of(context).textTheme.headlineMedium,)
                                  ],
                                )

                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            height: 70,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                   Text( S.of(context).delivery,
                                   style: Theme.of(context).textTheme.headlineMedium,),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('₹'),
                                    SizedBox(width: 2,),
                                    Text('30',style: Theme.of(context).textTheme.headlineMedium,)
                                  ],
                                )

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/checkoutPage');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        height: 50,
                        width:MediaQuery.of(context).size.width*0.90 ,
                        decoration: BoxDecoration(
                          gradient:  LinearGradient(
                            colors: [
                              kPrimaryColororange,
                              kPrimaryColorLiteorange
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: Center(
                          child: Text( S.of(context).checkout,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            color: Colors.white
                          ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
