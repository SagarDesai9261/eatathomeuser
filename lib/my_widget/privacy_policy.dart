import 'package:flutter/material.dart';

import '../src/elements/DrawerWidget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
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
          "Privacy Policy",
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
                'Privacy Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'This Privacy Policy outlines how FARIS BIOERA TECHNOLOGIES PRIVATE LIMITED ("Company", "We", "Us", or "Our") collects, uses, and protects your personal data when you use our service, eatathome, accessible from https://eatathome.in.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Types of Data Collected',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Personal Data: We collect information that identifies you personally, such as your email address, name, phone number, and address when you register for an account or use our services.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Usage Data: Automatically collected data includes your IP address, browser type, device information, and usage patterns when you interact with our service.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Tracking Technologies and Cookies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We use cookies and similar tracking technologies to monitor activity and improve our service. You can control cookie settings through your browser, but some parts of our service may not function properly if you disable cookies.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Use of Your Personal Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We use your data to provide and improve our service, manage your account, contact you, and for other business purposes like data analysis and marketing. We may share your information with service providers, business partners, and affiliates as necessary.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Data Retention and Security',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We retain your personal data only as long as necessary for the purposes stated in this policy, and we implement reasonable security measures to protect your information.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Transfer of Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your data may be transferred and processed in locations outside your state or country, where data protection laws may differ. By using our service, you consent to such transfers.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Deleting Your Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You have the right to request the deletion of your personal data. However, we may retain certain data when required by law or for legitimate business purposes.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Children\'s Privacy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Our service is not intended for children under 13. We do not knowingly collect data from children under 13 without parental consent. If we learn we have collected such data, we will delete it.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Changes to This Privacy Policy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We may update our Privacy Policy periodically. Changes will be posted on this page, and we will notify you via email and a prominent notice on our service prior to the changes taking effect.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Contact Us',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'If you have any questions about this Privacy Policy, please contact us.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PrivacyPolicyScreen(),
  ));
}
