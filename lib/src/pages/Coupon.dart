import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../utils/color.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../models/coupons.dart';
import '../models/user.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/translation_widget.dart';
import '../repository/user_repository.dart' as userRepo;

// final List<Coupon> couponData = [
//   Coupon(
//       name: "Discount on Electronics",
//       code: "ELEC50",
//       discount: 50.0,
//       maxDiscount: 100,
//       minOrder: 180,
//       validUntil: DateTime(2024, 12, 31),
//       discounttype: "percent"),
//   Coupon(
//       name: "Food Fest Sale",
//       code: "FOOD15",
//       discount: 15.0,
//       maxDiscount: 50,
//       minOrder: 200,
//       validUntil: DateTime(2024, 10, 30),
//       discounttype: "percent"),
//   Coupon(
//       name: "Clothing Sale",
//       code: "CLOTH30",
//       discount: 100.0,
//       maxDiscount: 150,
//       minOrder: 700,
//       validUntil: DateTime(2024, 11, 15),
//       discounttype: "fixed"),
// ];

// Step 3: Create a stateful widget for the Coupon Display Page with card-based display and "Apply" button
class CouponsPage extends StatefulWidget {
  double totalprice;
  String res_id;
  bool dine_in;
  final Function(AppliedCouponResult) onCouponApplied;

  CouponsPage({this.totalprice, this.onCouponApplied,this.res_id,this.dine_in});
  @override
  _CouponsPageState createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  String searchTerm = ""; // Variable to hold the search term
  Future<List<Coupon>> _couponsFuture;
  Coupon coupons;
  @override
  void initState() {
    super.initState();
    _couponsFuture = fetchCoupons(widget.res_id); // Example kitchen_id
  }
  applidCoupen() async{
    User _user = userRepo.currentUser.value;
    final response = await http.post(
        Uri.parse('https://eatathome.in/app/api/apply-coupon'),
        headers: {
          "Authorization": "Bearer ${_user.apiToken}"
        },
        body:{
          "kitchen_id":widget.res_id,
          "coupon_code":coupons.code
        }
    );
    print(response.body);
    final Map jsondata = jsonDecode(response.body);
    if (jsondata["success"] == true) {
      final discount =
      coupons.discount.toDouble();
      final discountAmount =
      calculateDiscount(
          coupons, widget.totalprice);

      final result = AppliedCouponResult(
          coupons, discountAmount);

      widget.onCouponApplied(
          result); // Callback to update state
      //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Coupan applied ${discountAmount} ${coupon.discounttype}")));
      Navigator.pop(context, result);
     /* final List<dynamic> json = jsonDecode(response.body)['data'];
      return json.map((e) => Coupon.fromJson(e)).toList();*/
      // } else {
      //   throw Exception('Failed to load coupons');
    }

  }
  Future<List<Coupon>> fetchCoupons(String kitchenId) async {
    User _user = userRepo.currentUser.value;
    final response = await http.get(
      Uri.parse('https://eatathome.in/app/api/coupons?kitchen_id=$kitchenId'),
      headers: {
        "Authorization": "Bearer ${_user.apiToken}"
      }
    );
    final Map jsondata = jsonDecode(response.body);
    print(response.body);
    if (jsondata["success"] == true) {
      final List<dynamic> json = jsonDecode(response.body)['data'];
      return json.map((e) => Coupon.fromJson(e)).toList();
    // } else {
    //   throw Exception('Failed to load coupons');
    }
  }

  double calculateDiscount(Coupon coupon, double totalPrice) {
    print(coupon.discounttype == 'percent');
    print(coupon.discounttype == 'fixed');

    if (coupon.discounttype == 'percent') {
      final calculatedDiscount = (totalPrice * coupon.discount) / 100;
      return calculatedDiscount > coupon.maxDiscount
          ? coupon.maxDiscount.toDouble()
          : calculatedDiscount.toDouble();
    } else if (coupon.discounttype == 'fixed') {
      return coupon.discount; // For fixed discount, return the fixed value
    } else {
      return 0; // Default to zero if unknown discount type
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 240, 246, 1),
      appBar: AppBar(
        iconTheme: IconThemeData(color: kPrimaryColororange),
        // automaticallyImplyLeading: false,
        /* leading: Builder(
            builder: (context) {
              return new IconButton(
                  icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
                  onPressed: () =>  Scaffold.of(context).openDrawer()
              );
            }
        ),*/
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: /*Text(
            S.of(context).delivery,
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
          )*/
            TranslationWidget(
          message: "Coupons",
          fromLanguage: "English",
          toLanguage: "defaultLanguage",
          builder: (translatedMessage) => Text(
            translatedMessage,
            style: Theme.of(context)
                .textTheme
                .headline6
                .merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
      ),
      body: FutureBuilder<List<Coupon>>(
          future: _couponsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {

              return Center(child: Text('Failed to load coupons ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var couponData = snapshot.data;
              if(searchTerm !=null){
                couponData = couponData.where((element) {
                  String code = element.code.toLowerCase();
                  return code.contains(searchTerm.toLowerCase());
                }).toList();
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search Coupon",
                        filled: true,
                        fillColor: Colors.white,
                       /* suffixIcon: TextButton(
                          onPressed: () {
                            // Handle apply button click
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Apply clicked"),
                              ),
                            );
                          },
                          child: Text(
                            "Apply",
                            style: TextStyle(
                              color: kPrimaryColororange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),*/
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: couponData.length,
                      itemBuilder: (context, index) {
                        final coupon = couponData[index];
                        String currancy =
                            settingRepo.setting.value.defaultCurrency;
                        // Check if the total price is enough to apply the coupon
                        final canApply = widget.totalprice >= coupon.minOrder;
                        final difference = canApply
                            ? 0.0
                            : coupon.minOrder - widget.totalprice;

                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      coupon.code,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (canApply)
                                      InkWell(
                                        onTap: () {
                                        setState(() {
                                          coupons = coupon;
                                        });

                                        if(widget.dine_in == false)
                                        applidCoupen();
                                        if(widget.dine_in == true)
                                          {
                                            final discount =
                                            coupons.discount.toDouble();
                                            final discountAmount =
                                            calculateDiscount(
                                                coupons, widget.totalprice);

                                            final result = AppliedCouponResult(
                                                coupons, discountAmount);

                                            widget.onCouponApplied(
                                                result); // Callback to update state
                                            //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Coupan applied ${discountAmount} ${coupon.discounttype}")));
                                            Navigator.pop(context, result);
                                          }
                                        },
                                        child: Text("Apply",
                                            style: TextStyle(
                                                color: Colors.orange)),
                                      )
                                    else
                                      Text(
                                        "Add $currancy${difference.toStringAsFixed(2)} more to unlock",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontFamily:
                                              GoogleFonts.lato().fontFamily,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  coupon.getCustomDescription(coupon.discounttype),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: GoogleFonts.lato().fontFamily,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text('No coupons available'));
            }
          }),
    );
  }
}

// Step 4: Create the main function to run the app
void main() {
  runApp(MaterialApp(
    home: CouponsPage(),
  ));
}
