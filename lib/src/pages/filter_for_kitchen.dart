import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/cuisine.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/home_controller.dart';

class KitchenFilter extends StatefulWidget {
  List<Cuisine> cuisineListhere = <Cuisine>[];
 // HomeController _con = HomeController();

 /* KitchenFilter({Key key, this.cuisineListhere})
      : super(key: key);*/
  @override
  _KitchenFilterState createState() => _KitchenFilterState();
}
class _KitchenFilterState extends StateMVC<KitchenFilter> {

  HomeController _con = HomeController();
  _KitchenFilterState() : super(HomeController()) {

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  //  widget._con.listenForCuisine();

   /* setState(() {
      print("DS>> Am i here?");
      widget.cuisineListhere = widget._con.cuisineList;
    });*/
 //  print("DS>>> list " + widget._con.cuisineList.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    print("DS>>> cuisine list size: " +
        _con.cuisineList.length.toString());
    return RefreshIndicator(
      onRefresh: _con.refreshHome,
      child: Scaffold(
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Select Cuisine"),
                ElevatedButton(onPressed: () {
                  print("DS>>> cuisine list size: " +
                  _con.cuisineList.length.toString());
                  _openDialog(context, _con.cuisineList);
                }, child: Text("Select Cuisine"))

              ],
            ),
          ),
        ),
      ),
    );
  }

List<int> selectedCuisines = [];
List<String> selectedLocation = [];

void toggleCuisine(int cuisineId) {
  if (selectedCuisines.contains(cuisineId)) {
    setState(() {
      selectedCuisines.remove(cuisineId);
    });
  } else {
    setState(() {
      selectedCuisines.add(cuisineId);
    });
  }
}

void toggleLocation(String location) {
  if (selectedLocation.contains(location)) {
    setState(() {
      selectedLocation.remove(location);
    });
  } else {
    setState(() {
      selectedLocation.add(location);
    });
  }
}

  _openDialog(
      BuildContext context,
      List<Cuisine> cuisineList
      ) {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          title: Column(
            children: [
              Text('Select Cuisine'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  height: 34,
                  margin: EdgeInsets.only(right: 8, left: 8, top: 8),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.8),
                        spreadRadius: -8,
                        blurRadius: 10,
                        // offset: Offset(0, 3), // changes the shadow position
                      ),
                    ],
                  ),
                  child: TextField(
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                        prefixIcon: Icon(Icons.search)),
                  ),
                ),
              ),
              StatefulBuilder(builder: (context, setState) {
                return Container(
                  margin: EdgeInsets.all(0),
                  // padding: EdgeInsets.all(),

                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  child: ListView.builder(
                    itemCount: cuisineList.length,
                    itemBuilder: (context, index) => CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      title: Text(
                        cuisineList[index].name,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                      value: cuisineList[index].selected,
                      onChanged: (value) {
                        setState(() {
                          print("DS>>> selected " +
                              value.toString() +
                              "index " +
                              cuisineList[index].id.toString());
                          cuisineList[index].selected =
                              value!; // Update the state of the selected cuisine
                          toggleCuisine(int.parse(cuisineList[index].id));
                        });
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {

                    filterWithCuisine("delivery");

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Apply'),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            )
          ],
        );
      },
    );
  }

filterWithCuisine(String fromDineInorDelivery){
  //List<int> selectedCuisineIds = [];
  for(int i = 0; i<selectedCuisines.length; i++){
    print(""+selectedCuisines[i].toString());
  }
  // Construct the query parameter string for selected cuisines
  String cuisinesQueryParam = selectedCuisines
      .map((cuisineId) => 'cuisines[]=$cuisineId')
      .join('&');
  print("cuisineParam "+cuisinesQueryParam);
  _con.fetchKitchensWithCuisine(cuisinesQueryParam, fromDineInorDelivery);
  _con.listenForCategories();
  _con.refreshHome();
}
}
