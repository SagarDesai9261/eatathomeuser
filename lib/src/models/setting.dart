import 'package:flutter/material.dart';

import '../helpers/custom_trace.dart';

class Setting {
  String appName = '';
  double defaultTax = 0.0;
  String defaultCurrency = '';
  String distanceUnit = 'km';
  bool currencyRight = false;
  int currencyDecimalDigits = 2;
  bool payPalEnabled = true;
  bool stripeEnabled = true;
  bool razorPayEnabled = true;
  String mainColor = '';
  String mainDarkColor = '';
  String secondColor = '';
  String secondDarkColor = '';
  String accentColor = '';
  String accentDarkColor = '';
  String scaffoldDarkColor = '';
  String scaffoldColor = '';
  String googleMapsKey = '';
  String fcmKey = '';
  String specialFoodImage = '';
  ValueNotifier<Locale> mobileLanguage = ValueNotifier(Locale('en', ''));
  String appVersion = '';
  bool enableVersion = true;
  List<String> homeSections = [];

  ValueNotifier<Brightness> brightness = ValueNotifier(Brightness.light);

  Setting();

  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      appName = jsonMap['app_name'] ?? '';
      mainColor = jsonMap['main_color'] ?? '';
      mainDarkColor = jsonMap['main_dark_color'] ?? '';
      secondColor = jsonMap['second_color'] ?? '';
      secondDarkColor = jsonMap['second_dark_color'] ?? '';
      accentColor = jsonMap['accent_color'] ?? '';
      accentDarkColor = jsonMap['accent_dark_color'] ?? '';
      scaffoldDarkColor = jsonMap['scaffold_dark_color'] ?? '';
      scaffoldColor = jsonMap['scaffold_color'] ?? '';
      googleMapsKey = jsonMap['google_maps_key'] ?? '';
      fcmKey = jsonMap['fcm_key'] ?? '';
      specialFoodImage = jsonMap['special_food_image'] ?? '';
      mobileLanguage.value = Locale(jsonMap['mobile_language'] ?? 'en', '');
      appVersion = jsonMap['app_version'] ?? '';
      distanceUnit = jsonMap['distance_unit'] ?? 'km';
      enableVersion = jsonMap['enable_version'] != null && jsonMap['enable_version'] != '0';
      defaultTax = double.tryParse(jsonMap['default_tax']?.toString() ?? '0') ?? 0.0;
      defaultCurrency = jsonMap['default_currency'] ?? '';
      currencyDecimalDigits = int.tryParse(jsonMap['default_currency_decimal_digits']?.toString() ?? '2') ?? 2;
      currencyRight = jsonMap['currency_right'] != null && jsonMap['currency_right'] != '0';
      payPalEnabled = jsonMap['enable_paypal'] != null && jsonMap['enable_paypal'] != '0';
      stripeEnabled = jsonMap['enable_stripe'] != null && jsonMap['enable_stripe'] != '0';
      razorPayEnabled = jsonMap['enable_razorpay'] != null && jsonMap['enable_razorpay'] != '0';
      for (int i = 1; i <= 12; i++) {
        homeSections.add(jsonMap['home_section_$i'] ?? 'empty');
      }
    } catch (e) {
      // print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "app_name": appName,
      "default_tax": defaultTax,
      "default_currency": defaultCurrency,
      "default_currency_decimal_digits": currencyDecimalDigits,
      "currency_right": currencyRight,
      "enable_paypal": payPalEnabled,
      "enable_stripe": stripeEnabled,
      "enable_razorpay": razorPayEnabled,
      "mobile_language": mobileLanguage.value.languageCode,
    };
  }
}
