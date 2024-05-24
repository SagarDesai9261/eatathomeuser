import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class orderStatus extends StatefulWidget {

  final RouteArgument routeArgument;
  orderStatus({Key key, this.routeArgument}) : super(key: key);

  @override
  State<orderStatus> createState() => _orderStatusState();
}

class _orderStatusState extends State<orderStatus> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushNamed('/orderPage', arguments: 0);
    });
    //
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   openCheckoutPopup(context: context);
    // });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.popUntil(context, (route) => true);
            // if (widget.routeArgument != null) {
            //   Navigator.of(context).pushReplacementNamed(widget.routeArgument.param, arguments: RouteArgument(id: widget.routeArgument.id));
            // } else {
            //   Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
            // }
          },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).hintColor,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text( "Order confirmed",
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Center(
        child: Card(
          elevation: 10,
          child: Container(

            height: 300,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
                color: Colors.white60,
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey,
              //     blurRadius: 5.0, // soften the shadow
              //     spreadRadius: 5.0, //extend the shadow
              //     offset: Offset(
              //       5.0, // Move to right 5  horizontally
              //       5.0, // Move to bottom 5 Vertically
              //     ),
              //   )
              // ],

            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/img/order_confirmed.png',height: 70,
                  color: Colors.grey,
                ),
                Text(currentUser.value.name,style: Theme.of(context).textTheme.titleSmall.merge(
                    TextStyle(
                        color: Colors.grey
                    )
                ),),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/Pages');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 52,
                    width: 250,
                    decoration: BoxDecoration(

                        gradient:  LinearGradient(
                          colors: [
                            kPrimaryColororange,
                            kPrimaryColorLiteorange
                          ],),
                        borderRadius: BorderRadius.circular(25)
                    ),
                    child: Center(child: Text('Order is Confirmed!',
                      style: Theme.of(context).textTheme.titleLarge.merge(
                          TextStyle(color: Colors.white)
                      ),)),
                  ),
                ),
                Text('Check Status',style: Theme.of(context).textTheme.titleSmall.merge(
                    TextStyle(
                        color: Colors.grey
                    )
                ),)

              ],
            ),
          ),
        ),
      ),
    );
  }


  openCheckoutPopup({  BuildContext context})
  {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content:Container(
            height: 300,
            width: 100,
            decoration: BoxDecoration(
                color: Colors.white60
            ),
            child: Column(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
               Image.asset('assets/img/order_confirmed.png',height: 100,
               ),
                Text('Hey Michel E. Quinn',style: Theme.of(context).textTheme.titleSmall.merge(
                  TextStyle(
                    color: Colors.grey
                  )
                ),),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 52,
                    width: MediaQuery.of(context).size.width*0.9,
                    decoration: BoxDecoration(
                      gradient:  LinearGradient(
                          colors: [
                            kPrimaryColororange,
                            kPrimaryColorLiteorange
                          ],),
                          borderRadius: BorderRadius.circular(25)
                    ),
                    child: Center(child: Text('Order Confirmed !',
                    style: Theme.of(context).textTheme.titleLarge.merge(
                      TextStyle(color: Colors.white)
                    ),)),
                  ),
                ),
                Text('Check Status !!',style: Theme.of(context).textTheme.titleSmall.merge(
                  TextStyle(
                    color: Colors.grey
                  )
                ),)

              ],
            ),
          ),
        );
      },);

  }
}
