// import 'dart:convert';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:intl/intl.dart';
//
// import '../generated/l10n.dart';
// import '../src/controllers/cart_controller.dart';
// import '../src/controllers/order_controller.dart';
// import '../src/models/order.dart';
// import '../utils/color.dart';
//
// void main(){
//   runApp(MaterialApp(home: dine_in_order_view()));
// }
// class dine_in_order_view extends StatefulWidget {
//   OrderController con;
//   Order order;
//    dine_in_order_view({key,this.order,this.con});
//
//   @override
//   State<dine_in_order_view> createState() => _dine_in_order_viewState();
// }
//
// class _dine_in_order_viewState extends State<dine_in_order_view> {
//   String mapToString(Map<String, dynamic> inputMap) {
//     List<String> parts = [];
//
//     inputMap.forEach((type, count) {
//       parts.add('$count $type');
//     });
//
//     return parts.join(', ');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String time;
//
//     String resultString ;
//     return Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(Icons.arrow_back),
//             color: Theme.of(context).hintColor,
//           ),
//           elevation: 0,
//           backgroundColor: Colors.white.withOpacity(0.9),
//           centerTitle: true,
//           title: Text(
//             "Dine-In",
//             style: Theme.of(context)
//                 .textTheme
//                 .headline6
//                 .merge(TextStyle(letterSpacing: 1.3)),
//           ),
//         ),
//         body: Container(
//           color: Colors.white.withOpacity(0.9),
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(
//                       context); // Close the screen when tapped outside the card
//                 },
//                 child: Container(
//                   color: Colors.white.withOpacity(0.9),
//                   //height: MediaQuery.of(context).size.height*2/3,// Semi-transparent background
//                 ),
//               ),
//               Center(
//                 child: Card(
//                   // Replace Card with your desired widget
//                   elevation: 5,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Container(
//                     width: 300,
//                     height: MediaQuery.of(context).size.height * 3.5 / 4.5,
//                     padding: EdgeInsets.symmetric(vertical: 10),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(20.0),
//                           child: Row(
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/img/dine_in.svg',
//                                 width: 30,
//                                 fit: BoxFit.cover,
//                               ),
//                               SizedBox(
//                                 width: 15,
//                               ),
//                               Text(
//                                 'Dine-In',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: CustomScrollView(
//                               primary: true,
//                               shrinkWrap: false,
//                               slivers: <Widget>[
//                                 SliverAppBar(
//                                   backgroundColor: kPrimaryColorLiteorange
//                                       .withOpacity(0.9),
//                                   expandedHeight: 150,
//                                   elevation: 0,
// //                          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
//                                   automaticallyImplyLeading: false,
//                                   flexibleSpace: FlexibleSpaceBar(
//                                     collapseMode: CollapseMode.parallax,
//                                     background: CachedNetworkImage(
//                                       fit: BoxFit.cover,
//                                       height: 200,
//                                       imageUrl: widget.order.foodOrders[0].food.restaurant.image.url ?? "",
//                                       placeholder: (context, url) =>
//                                           Image.asset(
//                                             'assets/img/loading.gif',
//                                             fit: BoxFit.cover,
//                                             height: 200,
//                                           ),
//                                       errorWidget: (context, url, error) =>
//                                           Icon(Icons.error),
//                                     ),
//                                   ),
//                                 ),
//                                 SliverToBoxAdapter(
//                                   child: Wrap(
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 10,
//                                             top: 25),
//                                         child: Row(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: <Widget>[
//                                             Text(
//                                               widget.order.foodOrders[0].food.restaurant.name??   '',
//                                               overflow: TextOverflow.fade,
//                                               softWrap: false,
//                                               maxLines: 2,
//                                               style: Theme.of(context)
//                                                   .textTheme
//                                                   .headline3,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 10,
//                                             top: 0),
//                                         child: Row(
//                                           children: [
//                                             Text(
//                                                 widget.order.foodOrders[0].food.restaurant.address.length > 18 ?'${widget.order.foodOrders[0].food.restaurant.address.substring(0, 18)}...' :
//                                                 widget.order.foodOrders[0].food.restaurant.address ??   '',
//                                                 overflow: TextOverflow.ellipsis,
//                                                 softWrap: true,
//                                                 maxLines: 2,
//
//                                                 style: TextStyle(
//                                                     fontSize: 15)),
//                                             Spacer(),
//                                             Text("View Map",
//                                                 overflow: TextOverflow.fade,
//                                                 softWrap: false,
//                                                 maxLines: 1,
//                                                 style: TextStyle(
//                                                     fontSize: 10)),
//                                             SizedBox(
//                                               width: 2,
//                                             ),
//                                             Container(
//                                               margin: EdgeInsets.all(0),
//                                               padding: EdgeInsets.all(4),
//                                               decoration: BoxDecoration(
//                                                   gradient: LinearGradient(
//                                                     colors: [
//                                                       kPrimaryColororange,
//                                                       kPrimaryColorLiteorange
//                                                     ],
//                                                   ),
//                                                   borderRadius:
//                                                   BorderRadius.circular(
//                                                       100)),
//                                               child:
//                                               // Image.asset("assets/img/")
//                                               GestureDetector(
//                                                 onTap: () {
//                                                  /* MapWidget(
//                                                       parentScaffoldKey: widget
//                                                           .parentScaffoldKey,
//                                                       routeArgument:
//                                                       RouteArgument(
//                                                           param: widget
//                                                               .restaurant));*/
//                                                 },
//                                                 child: Icon(
//                                                   Icons.turn_right_sharp,
//                                                   color: Colors.white,
//                                                   size: 18,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: 100,
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 10,
//                                             top: 0),
//                                         child: Row(
//                                           children: [
//                                             Text("Date",
//                                                 overflow: TextOverflow.fade,
//                                                 softWrap: false,
//                                                 maxLines: 2,
//                                                 style: TextStyle(
//                                                     fontSize: 12,
//                                                     color: Colors.grey)),
//                                             Spacer(),
//
//                                           ],
//                                         ),
//                                       ),
//                                     /*  Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 0,
//                                             top: 0),
//                                         child: Container(
//                                           width: 250,
//                                           child: Text(  DateFormat('dd MMM yyyy').format(DateTime.parse(widget.order.dine_in_date)) ?? '',
//                                               overflow: TextOverflow.fade,
//                                               softWrap: false,
//                                               maxLines: 2,
//                                               style:
//                                               TextStyle(fontSize: 15)),
//                                         ),
//                                       ),*/
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 5,
//                                             top: 0),
//                                         child: Container(
//                                           width: 250,
//                                           child: Divider(
//                                             color: Colors.grey,
//                                             thickness: 1,
//                                             height: 20,
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 10,
//                                             top: 0),
//                                         child: Container(
//                                           width: 250,
//                                           child: Text("Time",
//                                               overflow: TextOverflow.fade,
//                                               softWrap: false,
//                                               maxLines: 2,
//                                               style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.grey)),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 0,
//                                             top: 0),
//                                         child: Container(
//                                           width: 250,
//                                           child: Text(
//                                               time ,
//                                               overflow: TextOverflow.fade,
//                                               softWrap: false,
//                                               maxLines: 2,
//                                               style:
//                                               TextStyle(fontSize: 15)),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 5,
//                                             top: 0),
//                                         child: Container(
//                                           width: 250,
//                                           child: Divider(
//                                             color: Colors.grey,
//                                             thickness: 1,
//                                             height: 20,
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 10,
//                                             top: 0),
//                                         child: Row(
//                                           children: [
//                                             Text("Number of Pax",
//                                                 overflow: TextOverflow.fade,
//                                                 softWrap: false,
//                                                 maxLines: 2,
//                                                 style: TextStyle(
//                                                     fontSize: 12,
//                                                     color: Colors.grey)),
//                                             Spacer(),
//
//                                           ],
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 0,
//                                             top: 0),
//                                         child: Container(
//                                           width: 250,
//                                           child: Text(
//                                               resultString ,
//                                               overflow: TextOverflow.fade,
//                                               softWrap: false,
//                                               maxLines: 2,
//                                               style:
//                                               TextStyle(fontSize: 15)),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 20,
//                                             left: 20,
//                                             bottom: 5,
//                                             top: 0),
//                                         child: Container(
//                                           width: 250,
//                                           child: Divider(
//                                             color: Colors.grey,
//                                             thickness: 1,
//                                             height: 20,
//                                           ),
//                                         ),
//                                       ),
//                                   SizedBox(height: 5,),
//                                       Row(
//                                        mainAxisAlignment: MainAxisAlignment.center,
//                                     //    crossAxisAlignment: CrossAxisAlignment.center,
//                                         //   mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Container(
//                                             // height: 28,
//                                             width: 150,
//                                             height: 40,
//
//                                             /*decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(100)),
//               color: widget.order.activ
//                   ? Theme.of(context).accentColor
//                   : Colors.redAccent),*/
//                                             decoration: BoxDecoration(
//
//                                               borderRadius: BorderRadius.all(Radius.circular(30)),
//                                               gradient: LinearGradient(
//                                                 colors: [kPrimaryColororange, kPrimaryColorLiteorange],
//                                               ),
//                                             ),
//                                             child: Center(
//                                               child: MaterialButton(
//                                                 onPressed: () {
//                                                   // Handle View button click
//                                                   print('View button clicked');
//                                                   // Navigator.push(context, MaterialPageRoute(builder: (context)=>dine_in_order_view(order: _o,)));
//                                                 },
//                                                 child: Text('Send Message',style: TextStyle(
//                                                     color: Colors.white
//                                                 ),),
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 20,
//                                           ),
//                                           InkWell(
//                                             onTap: (){
//                                               showDialog(
//                                                 context: context,
//                                                 builder: (BuildContext context) {
//                                                   // return object of type Dialog
//                                                   return AlertDialog(
//                                                     title: Wrap(
//                                                       spacing: 10,
//                                                       children: <Widget>[
//                                                         Icon(Icons.report, color: Colors.orange),
//                                                         /*Text(
//                                       S.of(context).confirmation,
//                                       style: TextStyle(color: Colors.orange),
//                                     )*/
//                                                         Text(
//                                                           S.of(context).confirmation,
//                                                           style: TextStyle(color: Colors.orange),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     content: /*Text(S
//                                     .of(context)
//                                     .areYouSureYouWantToCancelThisOrder)*/
//                                                     Text(
//                                                       S.of(context)
//                                                           .areYouSureYouWantToCancelThisOrder,
//                                                     ),
//                                                     contentPadding: EdgeInsets.symmetric(
//                                                         horizontal: 30, vertical: 25),
//                                                     actions: <Widget>[
//                                                       MaterialButton(
//                                                         elevation: 0,
//                                                         focusElevation: 0,
//                                                         highlightElevation: 0,
//                                                         child: /*new Text(
//                                       S.of(context).yes,
//                                       style: TextStyle(
//                                           color: Theme.of(context).hintColor),
//                                     )*/
//                                                         Text(
//                                                           S.of(context).yes,
//                                                           style: TextStyle(
//                                                               color:
//                                                               Theme.of(context).hintColor),
//                                                         ),
//
//                                                         onPressed: () {
//                                                           widget.con.doCancelOrder(widget.order);
//                                                        //   widget.onCanceled(widget.order);
//                                                           Navigator.of(context).pop();
//                                                         },
//                                                       ),
//                                                       MaterialButton(
//                                                         elevation: 0,
//                                                         focusElevation: 0,
//                                                         highlightElevation: 0,
//                                                         child: /*new Text(
//                                       S.of(context).close,
//                                       style: TextStyle(color: Colors.orange),
//                                     )*/
//                                                         Text(
//                                                           S.of(context).close,
//                                                           style:
//                                                           TextStyle(color: Colors.orange),
//                                                         ),
//
//                                                         onPressed: () {
//                                                           Navigator.of(context).pop();
//                                                         },
//                                                       ),
//                                                     ],
//                                                   );
//                                                 },
//                                               );
//                                             },
//                                             child: Container(
//
//                                               child: Text('Cancel\nBooking' ,style: TextStyle(fontSize: 12,color: Colors.grey),),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//
//
//
//                                     ],
//                                   ),
//                                 )
//                               ]),
//                         ),
//
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//     );
//   }
// }
