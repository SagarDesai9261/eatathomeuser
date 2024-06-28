import 'package:flutter/material.dart';
import 'package:food_delivery_app/my_widget/people_count_dailog.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';

import '../src/models/coupons.dart';
import '../src/models/food.dart';
import '../src/models/restaurant.dart';
import '../src/models/route_argument.dart';
import '../src/pages/dinein_summary_page.dart';
import '../utils/color.dart';
import '../src/repository/settings_repository.dart' as settingRepo;

class Change_people_count extends StatefulWidget {
  Restaurant restaurant;
  String selectedDate, selectedPeople, selectedTime, fromTime, toTime;
  List<Food> selectedFoodList;
  String default_tax;
  int total;
  Coupon? selectedCoupon;
  List<ProductItem> products ;
  List<Map<String,dynamic>>  fooditems;
  Change_people_count(
      this.total,
      this.restaurant,
      this.selectedPeople,
      this.selectedDate,
      this.selectedTime,
      this.fromTime,
      this.toTime,
      this.selectedFoodList,
      this.default_tax,
      this.products,
      this.fooditems,
      this.selectedCoupon
      );

  @override
  _Change_people_countState createState() => _Change_people_countState();
}

class _Change_people_countState extends State<Change_people_count> {
  List<ProductItem> _products = [
    ProductItem(name: 'Adults,', subtitle: "Ages 13 or above", quantity: 0),
    ProductItem(name: 'Children,', subtitle: 'Ages 2-12', quantity: 0),
    ProductItem(name: 'Infants,', subtitle: "Under 2", quantity: 0),
    ProductItem(
        name: 'Pets,', subtitle: 'Bringing a service animal?', quantity: 0),
  ];
  void updateProductQuantity(String input) {
    // Parse the input to extract category and quantity
    final parts = input.split(' ');

    if (parts.length != 2) {
      throw ArgumentError('Input must contain exactly two parts: category and quantity.');
    }

    final category = parts[0]; // e.g., "Adults"
    final quantity = int.tryParse(parts[1]); // e.g., 1

    if (quantity == null) {
      throw ArgumentError('The quantity must be an integer.');
    }

    // Find the product with the matching name
    final productIndex = _products.indexWhere((product) => product.name == category);

    if (productIndex == -1) {
      throw ArgumentError('No product found with name: $category');
    }

    // Update the quantity for the matching product
    _products[productIndex].quantity = quantity;
  }

  String? selectedPeople;
  String? defaultLanguage;
  String? heroTag;

  void _incrementQuantity(int index) {
    // Debounce the increment action by adding a small delay
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _products[index].quantity++;
      });
    });
  }

  void _decrementQuantity(int index) {
    // Debounce the decrement action by adding a small delay
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        if (_products[index].quantity > 0) {
          _products[index].quantity--;
        }
      });
    });
  }

  @override
  void initState() {
    getCurrentDefaultLanguage();
   // updateProductQuantity(widget.selectedPeople);
    _products = widget.products;
    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode) {
      setState(() {
        defaultLanguage = _langCode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.selectedPeople);
    print(_products.length);
    print(widget.products.length);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return new IconButton(
                icon: new Icon(Icons.arrow_back,
                    color: Theme.of(context).hintColor),
                onPressed: () => Navigator.pop(context));
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: TranslationWidget(
          message: "Schedule Dine-in",
          fromLanguage: "English",
          toLanguage: defaultLanguage!,
          builder: (translatedMessage) => Text(
            translatedMessage,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context)
                .textTheme
                .headline6
                !.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/img/whoiscoming.png",
                      height: 27, width: 27),
                  SizedBox(
                    width: 8,
                  ),
                  TranslationWidget(
                    message: 'Who’s coming?',
                    fromLanguage: "English",
                    toLanguage: defaultLanguage!,
                    builder: (translatedMessage) => Text(
                      translatedMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 1.3,
                        fontSize: 18,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: LinearProgressIndicator(
                value: 0.9,
                backgroundColor: Colors.grey[300],
                valueColor:
                AlwaysStoppedAnimation<Color>(kPrimaryColororange.withOpacity(0.7)),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    title: TranslationWidget(
                      message: _products[index].name,
                      fromLanguage: "English",
                      toLanguage: defaultLanguage!,
                      builder: (translatedMessage) => Text(translatedMessage),
                    ),
                    subtitle: TranslationWidget(
                      message: _products[index].subtitle,
                      fromLanguage: "English",
                      toLanguage: defaultLanguage!,
                      builder: (translatedMessage) => Text(translatedMessage),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        QuantityButton(
                          icon: Icons.remove,
                          onPressed: () => _decrementQuantity(index),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TranslationWidget(
                            message: _products[index].quantity.toString(),
                            fromLanguage: "English",
                            toLanguage: defaultLanguage!,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        QuantityButton(
                          icon: Icons.add,
                          onPressed: () => _incrementQuantity(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 10, right: 10,),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    StringBuffer stringBuffer = StringBuffer();

                    for (int i = 0; i < _products.length; i++) {
                      if (_products[i].quantity > 0) {
                        stringBuffer.write(_products[i].quantity.toString());
                        stringBuffer.write(" ");
                        stringBuffer.write(_products[i].name);
                        if (i < _products.length - 1) {
                          stringBuffer.write(", ");
                        }
                      }
                    }

                    selectedPeople = stringBuffer.toString();

                    if (selectedPeople!.isNotEmpty) {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DineInSummaryPage(widget.total,widget.restaurant,selectedPeople!,widget.selectedDate,widget.selectedTime,widget.fromTime,widget.toTime,widget.selectedFoodList,widget.default_tax,_products,widget.fooditems,widget.selectedCoupon)
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: TranslationWidget(
                    message: "Next",
                    fromLanguage: "English",
                    toLanguage: defaultLanguage!,
                    builder: (translatedMessage) => Text(
                      translatedMessage,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onPressed;

  const QuantityButton({ this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).hintColor),
        color: Colors.white,
      ),
      child: InkWell(
        onTap: onPressed,
        child: Icon(
          icon,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}




