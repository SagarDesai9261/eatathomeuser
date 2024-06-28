import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import 'package:food_delivery_app/utils/CollectedData.dart';
import 'package:table_calendar/table_calendar.dart';

import '../src/models/restaurant.dart';
import '../src/models/route_argument.dart';
import '../src/pages/CardsCarouselWidgetHome.dart';
import '../utils/color.dart';
import 'package:provider/provider.dart';
import '../src/repository/settings_repository.dart' as settingRepo;

class PeopleCountDailogWidgetWithoutRestId extends StatefulWidget {
  //String restaurantId;
  //bool isDelivery;
  String selectedDate;
  String selectedTime;

  PeopleCountDailogWidgetWithoutRestId( this.selectedDate, this.selectedTime);

  @override
  _People_count_DailogState createState() => _People_count_DailogState();
}

class _People_count_DailogState extends State<PeopleCountDailogWidgetWithoutRestId> {
  List<ProductItem> _products = [
    ProductItem(name: 'Adults', subtitle: "Ages 13 or above",quantity: 0),
    ProductItem(name: 'Children',subtitle: 'Ages 2-12', quantity: 0),
    ProductItem(name: 'Infants',subtitle: "Under 2", quantity: 0),
    ProductItem(name: 'Pets',subtitle: 'Bringing a service animal?', quantity: 0),

  ];

  String selectedPeople = "";
  String defaultLanguage = "";
  List<Restaurant>? restaurantsList;
  String heroTag = "";
  void _incrementQuantity(int index) {
    setState(() {
      _products[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
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
    settingRepo.getDefaultLanguageName().then((_langCode){
      print("DS>> DefaultLanguageret "+_langCode);
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
                  icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
                  onPressed: () =>  Navigator.pop(context)
              );
            }
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: /*Text(
          "Schedule Dine-in",
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        )*/
        TranslationWidget(
          message:  "Schedule Dine-in",
          fromLanguage: "English",
          toLanguage: defaultLanguage,
          builder: (translatedMessage) => Text(
            translatedMessage,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.headline6!.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
      ),
        backgroundColor: Colors.white,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          //height: MediaQuery.of(context).size.height / 2.1,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(Icons.people_alt_outlined,color:Theme.of(context).hintColor ,),
                    Image.asset("assets/img/whoiscoming.png",height: 27,width: 27,),
                    SizedBox(width: 8,),
                    /*Text(
                      'Who’s coming?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 1.3,
                        fontSize: 18,
                        color:  Theme.of(context).hintColor,
                      ),
                    )*/
                    TranslationWidget(
                      message:  'Who’s coming?',
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(
                        translatedMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 1.3,
                          fontSize: 18,
                          color:  Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: LinearProgressIndicator(
                  value: 0.9,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColororange.withOpacity(0.7)),
                ),
              ),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ..._products
                          .map(
                            (product) => ListTile(

                          dense: true,
                          // isThreeLine: true,

                          title: /*Text(product.name)*/
                          TranslationWidget(
                            message:  product.name,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                            ),
                          ),
                          subtitle: /*Text(product.subtitle)*/
                          TranslationWidget(
                            message:  product.subtitle,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).hintColor),
                                  color: Colors.white,
                                ),
                                child: InkWell(
                                  onTap: () => _decrementQuantity(_products.indexOf(product)),
                                  child: Icon(
                                    Icons.remove,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ),
                              Container(
                                width: 50,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal:8.0),
                                    child: Text(product.quantity.toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                                  ),
                                ),
                              ),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).hintColor),
                                  color: Colors.white,
                                ),
                                child: InkWell(
                                  onTap: () => _incrementQuantity(_products.indexOf(product)),
                                  child: Icon(
                                    Icons.add,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      )
                          .toList(),
                      SizedBox(height: 16),

                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100.0),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 10,right: 10,),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      //todo
                  //    print("DS>> quantity: "+_products[0].quantity.toString());
                      // showProductListDialog(context);

                      if(_products[0].quantity.toString() == "0"){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Select the people who wants to dine in"),
                        ));
                      }
                      else{
                        StringBuffer stringBuffer = StringBuffer();

                        for (int i = 0; i < _products.length; i++) {
                          if(_products[i].quantity >0) {
                            stringBuffer.write(_products[i].quantity.toString());
                            stringBuffer.write(" ");
                            stringBuffer.write(_products[i].name);
                            // Add a separator if it's not the last element
                            if (i < _products.length - 1) {
                              stringBuffer.write(", ");
                            }
                          }
                        }

                        selectedPeople = stringBuffer.toString();

                     //   print("DS>> I am here"+selectedPeople);

                        /*if(mounted){
                          Navigator.of(context, rootNavigator: true).pop(selectedPeople);
                          //Navigator.pop(context, selectedPeople);
                        }*/
                        if(selectedPeople.isNotEmpty){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    KitchenList(selectedDate: widget.selectedDate,
                                        selectedTime: widget.selectedTime, selectedPeople: selectedPeople)
                            ),
                          );
                        }

                        /* setState(() {
                          Provider.of<CollectedData>(context, listen: false).updateDate(widget.selectedDate);
                          Provider.of<CollectedData>(context, listen: false).updateSession(widget.selectedTime);
                          Provider.of<CollectedData>(context, listen: false).updatePeople(selectedPeople);
                        });*/
                        // Close the PeoplePickerDialog
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: /*Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    )*/
                    TranslationWidget(
                      message:  "Next",
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
        )
    );
  }
}

class ProductItem {
  final String name;
  final String subtitle;
  int quantity;

  ProductItem({required this.name,required this.subtitle,required this.quantity});
}

void showProductListDialogWithoutRestaurant(BuildContext context, String selectedDate, String selectedTime) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PeopleCountDailogWidgetWithoutRestId( selectedDate, selectedTime);
    },
  );
}
