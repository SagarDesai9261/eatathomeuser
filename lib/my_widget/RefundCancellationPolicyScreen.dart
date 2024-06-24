import 'package:flutter/material.dart';

import '../src/elements/DrawerWidget.dart';

class RefundCancellationPolicyScreen extends StatelessWidget {
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
          "Refund & Cancellation Policy",
          style:
          Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
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
                'Refund & Cancellation Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              buildSectionTitle('Customer Cancellation'),
              buildParagraph(
                'Buyers can cancel an order within 90 seconds of placing it. However, Eatathome reserves the right to deny a refund and suspend the account if there\'s a history of frequent cancellations.',
              ),
              SizedBox(height: 16),
              buildSectionTitle('Non-Customer Cancellation'),
              buildParagraph(
                'Eatathome may collect a penalty for orders canceled due to reasons beyond its control, like incorrect addresses, unavailability of items, or failure to contact the buyer. No penalty is charged if the cancellation is attributable to Eatathome, the Cook, or the PDP.',
              ),
              SizedBox(height: 16),
              buildSectionTitle('Refunds'),
              buildParagraph(
                'Buyers may be eligible for refunds on prepaid orders. Eatathome retains the right to deduct penalties from the refund amount. Refunds for undelivered orders due to PDP\'s fault are assessed case-by-case.',
              ),
              SizedBox(height: 16),
              buildSectionTitle('Refund Process'),
              buildParagraph(
                'Refunds are credited back to the source account within 5-7 business days. Payment at the time of delivery is not required for certain issues like damaged packaging, wrong orders, or missing items, provided they\'re reported before delivery is marked complete.',
              ),
              SizedBox(height: 16),
              buildSectionTitle('Refunds for Prepaid Orders'),
              buildParagraph(
                'Refunds for prepaid orders may be requested if:',
              ),
              buildBulletPoint('The order isn\'t delivered within 2 hours.'),
              buildBulletPoint('The Cook cancels the order for reasons not attributable to the buyer.'),
              buildBulletPoint('Eatathome cancels the order for reasons beyond the buyer\'s control. Refund eligibility depends on the nature of the issue.'),
              SizedBox(height: 16),
              buildSectionTitle('Important Notes'),
              buildParagraph(
                'Buyers must inspect orders before providing OTP to the PDP. Once OTP is provided, it\'s considered acceptance of delivery, and cancellation/refund requests won\'t be entertained.',
              ),
              buildParagraph(
                'Eatathome isn\'t liable for spurious products sold by Cooks and encourages reporting such incidents for appropriate action.',
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

  Widget buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RefundCancellationPolicyScreen(),
  ));
}
