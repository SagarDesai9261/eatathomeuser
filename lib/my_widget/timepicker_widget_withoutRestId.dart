import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/my_widget/personList_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/elements/DrawerWidget.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import 'package:food_delivery_app/utils/color.dart';
import '../src/repository/settings_repository.dart' as settingRepo;

class TimePickerDialogWithoutRestaurant extends StatefulWidget {
  //String restaurantId;
  //bool isDelivery;
  String selectedDate;

  TimePickerDialogWithoutRestaurant(this.selectedDate);

  @override
  State<TimePickerDialogWithoutRestaurant> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialogWithoutRestaurant> {
  TimeOfDay? selectedTime;
  String formattedTime = "", selectedSession = "";
  String defaultLanguage = "";

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay.now();
    getCurrentDefaultLanguage();
  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode){
      print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });

    });
  }

  // void _showTimePickerDialog(BuildContext context) async {
  //   final TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: selectedTime,
  //     builder: (BuildContext context, Widget child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           primaryColor: const Color(0xffc73c1b),
  //           accentColor: const Color(0xffc73c1b),
  //           colorScheme: ColorScheme.light(primary: const Color(0xffc73c1b)),
  //           buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
  //         ),
  //         child: child,
  //       );
  //     },
  //   );
  //
  //   if (pickedTime != null && pickedTime != selectedTime) {
  //     setState(() {
  //       selectedTime = pickedTime;
  //     });
  //     formattedTime = pickedTime.format(context);
  // //    print(formattedTime); // Output: 12:40
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
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
      body: Container(
        // height: MediaQuery.of(context).size.height /1.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                //width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: new Icon(Icons.alarm, color: Theme.of(context).hintColor), onPressed: () {  },
                    ),
                    /*Text(
                      "Pick a Session",
                      style: TextStyle(letterSpacing: 1.3,fontSize: 18,
                        color:  Theme.of(context).hintColor,),
                    )*/
                    TranslationWidget(
                      message:  "Pick a Session",
                      fromLanguage: "English",
                      toLanguage: defaultLanguage,
                      builder: (translatedMessage) => Text(
                        translatedMessage,
                        style: TextStyle(
                          letterSpacing: 1.3,
                          fontSize: 18,
                          color: Theme.of(context).hintColor,
                        ),
                      ),),
                  ],
                ),
              ),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: LinearProgressIndicator(
                  value: 0.66,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColororange.withOpacity(0.7)),
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    elevation: 3,
                    child: Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.height / 4.5,
                        decoration: selectedSession == "Breakfast" ? BoxDecoration(
                          border: Border.all(
                            color: kPrimaryColororange, // Set the border color
                            width: 2.0, // Set the border width
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ) : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4.0),
                          child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSession = "Breakfast";
                                  });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    /*selectedSession == 'Breakfast' ? SvgPicture.asset(
                                      "assets/img/breakfast2.svg",
                                      height: 75,
                                      width: 75,
                                    ) :*/ SvgPicture.asset(
                                      "assets/img/breakfast1.svg",
                                      height: 55,
                                      width: 55,
                                    ),
                                    SizedBox(height: 6), // Add some space between the image and text
                                    /*Text(
                                      'Breakfast',
                                      style: TextStyle(
                                        fontSize: 16, // Adjust the font size as needed
                                        color: selectedSession == 'Breakfast'
                                            ? kFBBlue
                                            : kFBBlue,
                                      ),
                                    )*/
                                     Text(
                                        "Breakfast",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: selectedSession == 'Breakfast'
                                              ? kFBBlue
                                              : kFBBlue,
                                        ),
                                      ),
                                  ],
                                ),
                              )),
                        )),
                  ),
                  Card(
                    elevation: 3,
                    child: Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.height / 4.5,
                        decoration: selectedSession == "Lunch" ? BoxDecoration(
                          border: Border.all(
                            color: kPrimaryColororange, // Set the border color
                            width: 2.0, // Set the border width
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ) : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4.0),
                          child: Center(
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSession = "Lunch";
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      /*selectedSession == 'Lunch'
                                          ? SvgPicture.asset(
                                        "assets/img/lunch_a.svg",
                                        height: 50,
                                        width: 40,
                                      )
                                          :*/SvgPicture.asset(
                                        "assets/img/lunch.svg",
                                        height: 55,
                                        width: 55,
                                      ),
                                      SizedBox(height: 6),  // Add some space between the image and text
                                      /*Text(
                                        'Lunch',
                                        style: TextStyle(
                                          fontSize: 16, // Adjust the font size as needed
                                          color: selectedSession == 'Lunch'
                                              ? kFBBlue
                                              : kFBBlue,
                                        ),
                                      )*/
                                      Text(
                                        "Lunch",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: selectedSession == 'Lunch'
                                              ? kFBBlue
                                              : kFBBlue,
                                        ),
                                      ),
                                    ],
                                  ))),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    elevation: 3,
                    child: Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.height / 4.5,
                        decoration: selectedSession == "Snacks" ? BoxDecoration(
                          border: Border.all(
                            color: kPrimaryColororange, // Set the border color
                            width: 2.0, // Set the border width
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ) : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 4.0),
                          child: Center(
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSession = "Snacks";
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      /*selectedSession == 'Snacks' ? SvgPicture.asset(
                                        "assets/img/snacks_a.svg",
                                        height: 50,
                                        width: 40,
                                      ):*/ SvgPicture.asset(
                                        "assets/img/snacks.svg",
                                        height: 55,
                                        width: 55,
                                      ),
                                      SizedBox(height: 6),  // Add some space between the image and text
                                      /*Text(
                                        'Snacks',
                                        style: TextStyle(
                                          fontSize: 16, // Adjust the font size as needed
                                          color: selectedSession == 'Snacks'
                                              ? kFBBlue
                                              : kFBBlue,
                                        ),
                                      )*/
                                      Text(
                                        "Snacks",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: selectedSession == 'Snacks'
                                              ? kFBBlue
                                              : kFBBlue,
                                        ),
                                      ),

                                    ],
                                  ))),
                        )),
                  ),
                  Card(
                    elevation: 3,
                    child: Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.height / 4.5,
                        decoration: selectedSession == "Dinner" ? BoxDecoration(
                          border: Border.all(
                            color: kPrimaryColororange, // Set the border color
                            width: 2.0, // Set the border width
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ) : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4.0),
                          child: Center(
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSession = "Dinner";
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      /*selectedSession == 'Dinner' ? SvgPicture.asset(
                                        "assets/img/dinner2_a.svg",
                                        height:50,
                                        width: 40,
                                      ) :*/ SvgPicture.asset(
                                        "assets/img/dinner2.svg",
                                        height:55,
                                        width: 55,
                                      ) ,
                                      SizedBox(height: 6), // Add some space between the image and text
                                      /*Text(
                                        'Dinner',
                                        style: TextStyle(
                                          fontSize: 16, // Adjust the font size as needed
                                          color: selectedSession == 'Dinner'
                                              ? kFBBlue
                                              : kFBBlue,
                                        ),
                                      )*/
                                      Text(
                                        "Dinner",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: selectedSession == 'Dinner'
                                              ? kFBBlue
                                              : kFBBlue,
                                        ),
                                      ),
                                    ],
                                  ))),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100.0),
                child: GestureDetector(
                    onTap: () {
                      if (selectedSession.isNotEmpty) {
                       /* if(mounted){
                          Navigator.of(context, rootNavigator: true).pop();
                        }*/
                      /*showProductListDialogWithoutRestaurant(
                      context,
                      //widget.restaurantId,
                      //widget.isDelivery,
                      widget.selectedDate,
                      selectedSession);*/
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) =>
                      PeopleCountDailogWidgetWithoutRestId(widget.selectedDate,
                      selectedSession)
                      ),
                      );
                    }
                    },
                    child: Container(
                      width:double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Center(
                          child: /*Text(
                            "Done",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          )*/
                          TranslationWidget(
                            message:  "Done",
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[kPrimaryColororange, kPrimaryColorLiteorange],
  ).createShader(Rect.fromLTWH(0.0, 0.5, 50.0, 70.0));
}

void showTimePickerDialogWithoutRestId(
    BuildContext context, String date) {
  //print("DS>> ##" + isDelivery.toString());
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return TimePickerDialogWithoutRestaurant( date);
    },
  );
}
