import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import '../src/models/restaurant.dart';
import '../src/models/route_argument.dart';
import '../utils/color.dart';
import '../src/repository/settings_repository.dart' as settingRepo;

class People_count_Dailog extends StatefulWidget {
  String restaurantId;
  bool isDelivery;
  String selectedDate;
  String selectedTime;

  People_count_Dailog(
      this.restaurantId, this.isDelivery, this.selectedDate, this.selectedTime);

  @override
  _People_count_DailogState createState() => _People_count_DailogState();
}

class _People_count_DailogState extends State<People_count_Dailog> {
  List<ProductItem> _products = [
    ProductItem(name: 'Adults', subtitle: "Ages 13 or above", quantity: 0),
    ProductItem(name: 'Children', subtitle: 'Ages 2-12', quantity: 0),
    ProductItem(name: 'Infants', subtitle: "Under 2", quantity: 0),
    ProductItem(
        name: 'Pets', subtitle: 'Bringing a service animal?', quantity: 0),
  ];

  String selectedPeople;
  String defaultLanguage;
  String heroTag;

  void _incrementQuantity(int index) {
    // Debounce the increment action by adding a small delay
    setState(() {
      _products[index].quantity++;
    });

  }

  void _decrementQuantity(int index) {
    // Debounce the decrement action by adding a small delay
    setState(() {
      if (_products[index].quantity > 0) {
        _products[index].quantity--;
      }
    });

  }

  @override
  void initState() {
    getCurrentDefaultLanguage();
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
          toLanguage: defaultLanguage,
          builder: (translatedMessage) => Text(
            translatedMessage,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context)
                .textTheme
                .headline6
                .merge(TextStyle(letterSpacing: 1.3)),
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
                    toLanguage: defaultLanguage,
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
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(translatedMessage),
                    ),
                    subtitle: TranslationWidget(
                      message: _products[index].subtitle,
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(translatedMessage),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        QuantityButton(
                          icon: Icons.remove,
                          onPressed: () => _decrementQuantity(index),
                        ),
                        SizedBox(
                          width:40,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: TranslationWidget(
                                message: _products[index].quantity.toString(),
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
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
               //     print(selectedPeople);

                    if (selectedPeople.isNotEmpty) {
                      Navigator.of(context).pushNamed(
                        '/Details',
                        arguments: RouteArgument(
                          id: '0',
                          param: widget.restaurantId,
                          heroTag: heroTag,
                          isDelivery: widget.isDelivery,
                          selectedDate: widget.selectedDate,
                          selectedPeople: selectedPeople,
                          selectedTime: widget.selectedTime,
                          products: _products
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
                    toLanguage: defaultLanguage,
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
  Map<String, int> parseString(String input) {
    Map<String, int> resultMap = {};

    List<String> parts = input.split(','); // Splitting the string by comma

    // Iterating through each part and extracting count and type
    parts.forEach((part) {
      List<String> temp = part.trim().split(' ');
      int count = int.parse(temp[0]);
      String type = temp[1];
      resultMap[type] = count;
    });

    return resultMap;
  }
}

class QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

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

class ProductItem {
  final String name;
  final String subtitle;
  int quantity;

  ProductItem({ this.name,  this.subtitle,  this.quantity});
}


void showProductListDialog(BuildContext context, String restaurantId, bool isDelivery, String selectedDate, String selectedTime) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return People_count_Dailog(restaurantId, isDelivery, selectedDate, selectedTime);
    },
  );
}
