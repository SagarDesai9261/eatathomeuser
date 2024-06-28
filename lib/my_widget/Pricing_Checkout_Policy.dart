import 'package:flutter/material.dart';

import '../src/elements/DrawerWidget.dart';

class PricingCheckoutPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return new IconButton(
              icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
              onPressed: () => Scaffold.of(context).openDrawer());
        }),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title:  Text(
          "Pricing & Checkout Policy",
          style:
          Theme.of(context).textTheme.headline6!.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pricing & Checkout Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              buildSectionTitle('1. Pricing'),
              buildSubsectionTitle('1. Menu Prices'),
              buildParagraph(
                'Prices listed on EatAtHome are set by the restaurants and can change anytime. Prices include taxes unless stated otherwise. Extra charges like delivery fees or service fees will be shown during checkout.',
              ),
              buildSubsectionTitle('2. Promotions and Discounts'),
              buildParagraph(
                'EatAtHome and restaurants may offer discounts and special deals. Terms and conditions will apply. Apply discounts and promo codes at checkout. They can’t be used after placing an order.',
              ),
              buildSubsectionTitle('3. Dynamic Pricing'),
              buildParagraph(
                'Prices might change based on time, demand, or item availability. These changes will be shown on the app.',
              ),
              SizedBox(height: 16),
              buildSectionTitle('2. Checkout Process'),
              buildSubsectionTitle('1. Order Review'),
              buildParagraph(
                'Before paying, you can review your order, including item details, quantities, prices, and any extra charges. Make sure your order details are correct. EatAtHome isn’t responsible for user errors.',
              ),
              buildSubsectionTitle('2. Payment Methods'),
              buildParagraph(
                'We accept credit/debit cards, digital wallets, and other online payment options. Available methods will be shown at checkout. Provide accurate payment details. We use secure payment systems to protect your information.',
              ),
              buildSubsectionTitle('3. Order Confirmation'),
              buildParagraph(
                'After payment, you’ll get an order confirmation in the app and via email. It will include order details, delivery time, and restaurant contact info. Once confirmed, orders can’t usually be changed or canceled.',
              ),
              SizedBox(height: 16),
              buildSectionTitle('3. Delivery and Service Fees'),
              buildSubsectionTitle('1. Delivery Fees'),
              buildParagraph(
                'Delivery fees depend on the restaurant’s location and distance to your address. The fee will be shown at checkout. Some orders might get free delivery based on offers or order size.',
              ),
              buildSubsectionTitle('2. Service Charges'),
              buildParagraph(
                'There may be a service charge for operational costs, shown at checkout.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PricingCheckoutPolicyScreen(),
  ));
}
