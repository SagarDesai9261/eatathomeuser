import 'package:flutter/material.dart';
import 'package:food_delivery_app/utils/couponutils/HorizontalCouponExample1.dart';
import 'package:food_delivery_app/utils/couponutils/HorizontalCouponExample2.dart';
import 'package:food_delivery_app/utils/couponutils/VerticalCouponExample.dart';
import '../../utils/color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/couponModel.dart';
import '../repository/user_repository.dart' as userRepo;


class CouponWidget extends StatefulWidget {


  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {

  String apiToken = "";
  List<CouponModel> couponModelList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiToken = userRepo.currentUser.value.apiToken;
    // print(apiToken);

    getCouponApi(apiToken);
  }

  getCouponApi(String token){
    fetchCoupons(token).then((coupons) {
      // Use the list of coupons as needed
      for (var coupon in coupons) {
        // print('Coupon Code: ${coupon.code}');
        // print('Discount: ${coupon.discount}%');
        couponModelList.add(coupon);
        // Add other fields as needed
      }
      setState(() {

      });
    }).catchError((error) {
      // print('Error: $error');
    });
  }

  Future<List<CouponModel>> fetchCoupons(String token) async {
    final url = Uri.parse('https://comeeathome.com/app/api/coupons');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    // print("DS>> coupon response"+ response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      List<CouponModel> coupons = data.map((json) => CouponModel.fromJson(json)).toList();
      return coupons;
    } else {
      throw Exception('Failed to load coupons');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:  AppBar(
        title: Text('Coupons'),
        backgroundColor: kPrimaryColororange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            children:  [
              couponModelList.length>0 ?
              HorizontalCouponExample1(couponModelList):SizedBox(),
              SizedBox(height: 14),
              VerticalCouponExample(),
              SizedBox(height: 14),
              HorizontalCouponExample2(),
            ],
          ),
        ),
      ),
    );
  }
}
