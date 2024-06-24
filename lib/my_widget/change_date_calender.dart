import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/elements/DrawerWidget.dart';
import 'package:food_delivery_app/src/elements/TimePickerDialog.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import 'package:table_calendar/table_calendar.dart';

import '../src/models/coupons.dart';
import '../src/models/food.dart';
import '../src/models/restaurant.dart';
import '../src/pages/dinein_summary_page.dart';
import '../utils/color.dart';
import 'package:intl/intl.dart';

import '../src/repository/settings_repository.dart' as settingRepo;

class Change_calender extends StatefulWidget {
  Restaurant restaurant;
  String selectedDate, selectedPeople, selectedTime, fromTime, toTime;
  List<Food> selectedFoodList;
  String default_tax;
  int total;
  List<Map<String,dynamic>>  fooditems;
  Coupon selectedCoupon;
 /* String restaurantId;
  bool isDelivery;*/
  Change_calender(  this.total,
      this.restaurant,
      this.selectedPeople,
      this.selectedDate,
      this.selectedTime,
      this.fromTime,
      this.toTime,
      this.selectedFoodList,
      this.default_tax,
      this.fooditems,
      this.selectedCoupon
      );


  @override
  _Change_calenderState createState() => _Change_calenderState();
}

class _Change_calenderState extends State<Change_calender> {
  DateTime _selectedDate = DateTime.now();
  DateTime _firstDay = DateTime(2024, 1, 1);
  DateTime _lastDay = DateTime(2030, 12, 31);
  DateTime _focusedDay = DateTime.now();
  List<Restaurant> restaurantsList;
  String heroTag;
  String defaultLanguage;

  @override
  void initState() {
    super.initState();
    if (widget.selectedDate != null) {
      _selectedDate = DateTime.parse(widget.selectedDate);
    }
    _firstDay = DateTime(2024, 1, 1);
    _lastDay = DateTime(2030, 12, 31);
    _focusedDay = _selectedDate;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        automaticallyImplyLeading: false,

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
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: new Icon(Icons.calendar_month,
                    color: Theme.of(context).hintColor),
              ),
              /*Text("Select Dates", style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)))*/
              TranslationWidget(
                message:  "Select Dates",
                fromLanguage: "English",
                toLanguage: defaultLanguage,
                builder: (translatedMessage) => Text(
                  translatedMessage,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    letterSpacing: 1.3,
                    fontSize: 18,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: LinearProgressIndicator(
              value: 0.33,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColororange.withOpacity(0.7)),
            ),
          ),
          SizedBox(height: 15,),
          SizedBox(
            width:  MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/2.7,
            child: TableCalendar(

              shouldFillViewport: true,
              rowHeight: 30,
              firstDay: _firstDay,
              lastDay: _lastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (date) {
                return isSameDay(_selectedDate, date);
              },
              onDaySelected: (date, _) {
                setState(() {
                  _selectedDate = date;
                });

              },
              enabledDayPredicate: (date) {
                return !date.isBefore(DateTime.now().subtract(Duration(days: 1))); // Disable only past dates
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                TextStyle(fontSize: 18, ),
                leftChevronIcon: Icon(Icons.chevron_left,color: kPrimaryColorLiteorange, ),
                rightChevronIcon: Icon(Icons.chevron_right,color: kPrimaryColorLiteorange,),
              ),
              calendarStyle: CalendarStyle(
                canMarkersOverflow: false,
                cellPadding: EdgeInsets.all(0),
                cellMargin: EdgeInsets.all(0),
                selectedDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                  ),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColororange, kPrimaryColorLiteorange],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ElevatedButton(
                onPressed: () {
                  //todo
                  // Parse the datetime string into a DateTime object
                  DateTime datetime = DateTime.parse(_selectedDate.toString());

                  // Format the DateTime object to obtain the date portion
                  // String date = DateFormat('yyyy-MM-dd').format(datetime);
                  String date = DateFormat('dd MMM').format(datetime);

                  //     print(date);  // Output: 2023-06-21
                  //   print("DS>> selected date:  "+_selectedDate.toString());
                  if(_selectedDate.toString().isNotEmpty){
                    //Navigator.pop(context);
                  //  showTimePickerDialog(context, widget.restaurantId, widget.isDelivery, _selectedDate.toString());
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DineInSummaryPage(widget.total,widget.restaurant,widget.selectedPeople,_selectedDate.toString(),widget.selectedTime,widget.fromTime,widget.toTime,widget.selectedFoodList,widget.default_tax,[],widget.fooditems,widget.selectedCoupon)
                      ),
                    );
                  }

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: /*Text(
                  "Add",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                )*/
                TranslationWidget(
                  message:  "Add",
                  fromLanguage: "English",
                  toLanguage: defaultLanguage,
                  builder: (translatedMessage) => Text(
                    translatedMessage,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style:  TextStyle(
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
    );
  }
}

