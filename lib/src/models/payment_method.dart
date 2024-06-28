import 'package:flutter/widgets.dart';
import '../../generated/l10n.dart';

class PaymentMethod {
  String id;
  String name;
  String description;
  String logo;
  String route;
  bool isDefault;
  bool selected;

  PaymentMethod(
      this.id,
      this.name,
      this.description,
      this.route,
      this.logo, {
        this.isDefault = false,
        this.selected = false,
      });
}

class PaymentMethodList {
  late List<PaymentMethod> _paymentsList;
  late List<PaymentMethod> _cashList;
  late List<PaymentMethod> _pickupList;

  PaymentMethodList(BuildContext context) {
    _paymentsList = [
      PaymentMethod(
        "visacard",
        S.of(context).visa_card,
        S.of(context).click_to_pay_with_your_visa_card,
        "/Checkout",
        "assets/img/visacard.png",
        isDefault: true,
      ),
      PaymentMethod(
        "mastercard",
        S.of(context).mastercard,
        S.of(context).click_to_pay_with_your_mastercard,
        "/Checkout",
        "assets/img/mastercard.png",
      ),
      PaymentMethod(
        "razorpay",
        S.of(context).razorpay,
        S.of(context).clickToPayWithRazorpayMethod,
        "/RazorPay",
        "assets/img/razorpay.png",
      ),
      PaymentMethod(
        "paypal",
        S.of(context).paypal,
        S.of(context).click_to_pay_with_your_paypal_account,
        "/PayPal",
        "assets/img/paypal.png",
      ),
    ];

    _cashList = [
      PaymentMethod(
        "cod",
        S.of(context).cash_on_delivery,
        S.of(context).click_to_pay_cash_on_delivery,
        "/CashOnDelivery",
        "assets/img/cash.png",
      ),
    ];

    _pickupList = [
      PaymentMethod(
        "pop",
        S.of(context).pay_on_pickup,
        S.of(context).click_to_pay_on_pickup,
        "/PayOnPickup",
        "assets/img/pay_pickup.png",
      ),
      PaymentMethod(
        "delivery",
        S.of(context).delivery_address,
        S.of(context).click_to_pay_on_pickup,
        "/PaymentMethod",
        "assets/img/pay_pickup.png",
      ),
    ];
  }

  List<PaymentMethod> get paymentsList => _paymentsList;
  List<PaymentMethod> get cashList => _cashList;
  List<PaymentMethod> get pickupList => _pickupList;
}
