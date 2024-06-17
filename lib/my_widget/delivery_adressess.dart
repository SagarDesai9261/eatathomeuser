import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../src/provider.dart';
import '../src/repository/user_repository.dart';
import '../utils/color.dart';
class Delivery_address_seelction extends StatefulWidget {
  // Delivery_address_seelction({super.key});

  @override
  State<Delivery_address_seelction> createState() => _Delivery_address_seelctionState();
}

class _Delivery_address_seelctionState extends State<Delivery_address_seelction> {
  Future<List<dynamic>> fetchDeliveryAddresses(int userId) async {
    final String url = 'https://eatathome.in/app/api/delivery_addresses?user_id=$userId';
    print(url);
    print(currentUser.value.apiToken);
    try {
      final http.Response response = await http.get(Uri.parse(url)
        ,
        headers: {'Content-Type': 'application/json',  'Authorization': 'Bearer ${currentUser.value.apiToken}',},

      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success']) {
          return responseBody['data'];
        } else {
          throw Exception('Failed to fetch delivery addresses: ${responseBody['message']}');
        }
      } else {
        throw Exception('Failed to connect to the server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  Future<List<dynamic>> deleteDeliveryaddress(int addresid) async {
    final String url = 'https://eatathome.in/app/api/delivery_addresses/$addresid';


    try {
      final http.Response response = await http.delete(Uri.parse(url),
        headers: {'Content-Type': 'application/json',  'Authorization': 'Bearer ${currentUser.value.apiToken}',},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success']) {
          setState(() {
          });
          return responseBody['data'];
        } else {
          throw Exception('Failed to fetch delivery addresses: ${responseBody['message']}');
        }
      } else {
        throw Exception('Failed to connect to the server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:   SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  IconButton(onPressed: (){
                    Navigator.of(context).pop();
                  }, icon: Icon(Icons.arrow_back)),
                  Text("Select the Delivery Location",style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ),),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Card(
                color: Colors.grey[200],
                elevation: 0,
                margin: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                /*    GestureDetector(
                      onTap: () {
                        context
                            .read<Add_the_address>()
                            .set_selected_location(
                            Provider.of<Add_the_address>(
                                context,
                                listen: false)
                                .currentlocation,
                            Provider.of<Add_the_address>(
                                context,
                                listen: false)
                                .currentlocationLatlong);
                        context
                            .read<Add_the_address>()
                            .address_split();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.my_location_outlined, color: Colors.redAccent),
                            SizedBox(width: 15),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Use Current Location',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .7,
                                  child: Text(
                                    Provider.of<Add_the_address>(context).currentlocation,
                                    maxLines: 2,
                                    softWrap: true,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(height: 1, color: Colors.grey),
                    ),*/
                    GestureDetector(
                      onTap: () async {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MapScreen()));

                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.redAccent),
                            SizedBox(width: 15),
                            Text(
                              'Add Address',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            FutureBuilder<List<dynamic>>(
              future: fetchDeliveryAddresses(int.parse(currentUser.value.id)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('No delivery addresses found.'));
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return Center(child: Text('No delivery addresses found.'));
                } else {
                  final addresses = snapshot.data;
                  return SingleChildScrollView(
                    child: Column(
                      children: addresses.map((address) {
                        IconData icon;
                        if (address['address_type'] == 'Home') {
                          icon = Icons.home;
                        } else if (address['address_type'] == 'Work') {
                          icon = Icons.work;
                        } else if (address['address_type'] == 'Office') {
                          icon = Icons.business; // using 'business' icon for 'Office'
                        } else {
                          icon = Icons.location_on; // default icon
                        }
                        return Column(

                          children: [
                            //  Text("Delivers To"),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                child: ListTile(
                                  onTap: ()async{
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString("delivery_address_id", address["id"].toString());
                                    print(address["address"]);

                                    Navigator.of(context).pop({"Address":address["address"],"id":address["id"]});
                                  },
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: (){
                                      showDialog(
                                        context:
                                        context,
                                        builder:
                                            (BuildContext context) {
                                          return AlertDialog(
                                            content: Text("Are you sure you want to delete this address?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(); // Close the dialog
                                                },
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(color: Colors.redAccent),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      kPrimaryColororange,
                                                      kPrimaryColorLiteorange
                                                    ],
                                                  ),
                                                ),
                                                child: MaterialButton(
                                                  onPressed: () {
                                                    //   _showAddressDialog();

                                                    deleteDeliveryaddress(address["id"]);
                                                    //Provider.of<Add_the_address>(context, listen: false).remove_address(addr);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.shade200,
                                    child: Icon(icon, color: Colors.black),
                                  ),
                                  subtitle: Text(""),
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(address['address_type'] ?? 'N/A',style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),),
                                      SizedBox(height: 3,),
                                      Text(address['address'] ?? 'N/A'),
                                      SizedBox(height: 3,),
                                      Text( 'Phone Number: ${address['address_conact'] ?? 'N/A'}',style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )),


                                    ],
                                  ),
                                  isThreeLine: true,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),

          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  /*final LatLng initialLocation;
  final Function(LatLng, String) onLocationSelected;

  MapScreen({ this.onLocationSelected, this.initialLocation});*/

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  LatLng selectedLocation;
  Marker selectedMarker;
  String address;
  bool isLoading = true;
  String seletedlocationmarker;
  String selectedlocationcity;
  String selectedAddressType = "home";
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    //  selectedLocation = LatLng(0.0, 0.0);

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    geolocator.Position position;

    try {
      position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );
    } catch (e) {
      print("Error getting current location: $e");
    }

    if (position != null && selectedLocation== null) {
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });
    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back_outlined,color: Colors.black,)),
        title: Text(
          "Confirm delivery location",style: TextStyle(color: Colors.black,fontSize: 16),
        ),
      ),
      bottomNavigationBar:  Container(
        margin: EdgeInsets.only(bottom: 10,left: 10,right: 10),

        width:
        MediaQuery.of(context).size.width *.9,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                kPrimaryColororange,
                kPrimaryColorLiteorange
              ],
            ),
          ),
          child: MaterialButton(
            onPressed: () {
              //   _showAddressDialog();
              _showBottomSheet(context,address,selectedLocation);
              /*  widget.onLocationSelected(selectedLocation, "selectedAddress");
              Navigator.pop(context);*/
            },
            child: Text('Select the Address',style: TextStyle(color: Colors.white),),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: FutureBuilder(
              future: _getCurrentLocation(),
              builder: (context, snapshot) {
                if (isLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.deepOrangeAccent,),
                  );
                } else {
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: selectedLocation,
                      zoom: 15.0,
                    ),
                    onMapCreated: (controller) {
                      setState(() {
                        mapController = controller;
                      });
                    },
                    myLocationEnabled: true,
                    onTap: (latLng) {
                      _updateSelectedLocation(latLng);
                    },
                    markers: Set<Marker>.from(selectedMarker != null ? [selectedMarker] : []),
                  );
                }
              },
            ),
          ),

          if (address != null)
            ListTile(
              leading: Icon(Icons.location_on_rounded,color: Colors.redAccent,size: 40,),
              title: Text(seletedlocationmarker ?? ""),
              subtitle: Text(selectedlocationcity ??""),
            )
        ],
      ),
    );
  }
  void _showBottomSheet(BuildContext context, String Address,LatLng selectLatlng) {
    // Calculate the height needed for the content
    double contentHeight = 480.0; // Base height for the dialog content
    TextEditingController name = TextEditingController();
    TextEditingController contact = TextEditingController();
    TextEditingController flat = TextEditingController();
    TextEditingController addresscontroller = TextEditingController();
    addresscontroller.text = Address;

    String selectedAddressType = 'Home'; // To hold the selected address type

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Form(
            key: formkey,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -50.0,
                        left: MediaQuery.of(context).size.width / 2 - 15.0,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: CircleAvatar(
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                            backgroundColor: Colors.black54,
                            maxRadius: 15.0,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Container(
                          height: contentHeight > 500 ? 500 : contentHeight + 50,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(244, 246, 251, .9),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Enter complete address',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Text("Save address as *"),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    AddressTypeBox(
                                      title: 'Home',
                                      isSelected: selectedAddressType == 'Home',
                                      onTap: () {
                                        setState(() {
                                          selectedAddressType = 'Home';
                                        });

                                        /*  Navigator.of(context).pop();
                                          _showBottomSheet(context, Address);*/
                                      },
                                    ),
                                    AddressTypeBox(
                                      title: 'Work',
                                      isSelected: selectedAddressType == 'Work',
                                      onTap: () {
                                        setState(() {
                                          selectedAddressType = 'Work';
                                        });
                                      },
                                    ),
                                    AddressTypeBox(
                                      title: 'Hotel',
                                      isSelected: selectedAddressType == 'Hotel',
                                      onTap: () {
                                        setState(() {
                                          selectedAddressType = 'Hotel';
                                        });
                                      },
                                    ),
                                    AddressTypeBox(
                                      title: 'Other',
                                      isSelected: selectedAddressType == 'Other',
                                      onTap: () {
                                        setState(() {
                                          selectedAddressType = 'Other';
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: name,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Receiver Name is Required";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Receiver Name',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.redAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: contact,
                                  decoration: InputDecoration(
                                    focusColor: Colors.redAccent,
                                    labelText: 'Receiver Contact',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value){
                                    if(value.isEmpty){
                                      return "Receiver Contact is Required";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.phone,
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: flat,
                                  decoration: InputDecoration(
                                    labelText: 'Flat/House No./Floor/Building',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value){
                                    if(value.isEmpty){
                                      return "Flat/House No./Floor/Building is Required";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: addresscontroller,
                                  validator: (value){
                                    if(value.isEmpty){
                                      return "Address is Required";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Address',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  height: 40,
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                        colors: [
                                          kPrimaryColororange,
                                          kPrimaryColorLiteorange
                                        ],
                                      ),
                                    ),
                                    child: MaterialButton(
                                      onPressed: () async{
                                        if(!formkey.currentState.validate()){
                                          print('Name: ${name.text}');
                                          print('Contact: ${contact.text}');
                                          print('Flat: ${flat.text}');
                                          print('Address: ${addresscontroller.text}');
                                          print('Address Type: ${selectLatlng.latitude} ${selectLatlng.longitude}');
                                          Navigator.of(context).pop();
                                        }
                                        // Add your save address logic here
                                        addDeliveryAddress(
                                            description: "",
                                            name: name.text,
                                            contact: contact.text,
                                            flatNumber: flat.text,
                                            address: addresscontroller.text,
                                            addressType: selectedAddressType,
                                            latitude: selectedLocation.latitude,
                                            longitude: selectedLocation.longitude,
                                            userId: int.parse(currentUser.value.id,
                                            ),
                                            isDefault: true

                                        );




                                      },
                                      child: Text('Save Address',style: TextStyle(color: Colors.white),),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        );
      },
    );
  }

  Future<Map<String, dynamic>> addDeliveryAddress({
    String description,
    String name,
    String contact,
    String addressType,
    String flatNumber,
    String address,
    double latitude,
    double longitude,
    bool isDefault,
    int userId,
  }) async {
    const String url = 'https://eatathome.in/app/api/delivery_addresses';

    final Map<String, dynamic> requestBody = {
      'description': description,
      'name': name,
      'address_conact': contact,
      'address_type': addressType,
      'flat_number': flatNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'user_id': userId,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json',  'Authorization': 'Bearer ${currentUser.value.apiToken}',},
        body: jsonEncode(requestBody),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success']) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Delivery_address_seelction()));
          return responseBody;
        } else {
          throw Exception('Failed to save delivery address: ${responseBody['message']}');
        }
      } else {
        throw Exception('Failed to connect to the server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  void _updateSelectedLocation(LatLng latLng) {
    final Marker marker = Marker(
      markerId: MarkerId('selected-location'),
      position: latLng,
      infoWindow: InfoWindow(title: 'Selected Location'),
    );

    mapController?.animateCamera(CameraUpdate.newLatLng(latLng));

    setState(() {

      selectedLocation = latLng;
      selectedMarker = marker;

      print(selectedLocation.latitude);
      _showAddressDialog();
    });
  }
  Widget box(BuildContext context,String title) {
    return GestureDetector(
      onTap: () {
        // Add your logic to handle address type selection
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
  Future<void> _showAddressDialog() async {
    if (selectedLocation == null) {
      return;
    }

    try {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        selectedLocation.latitude,
        selectedLocation.longitude,
      );

      if (placemarks.isNotEmpty) {
        String selectedAddress =
            '${placemarks.first.name} ${placemarks.first.subLocality} , ${placemarks.first.locality}, ${placemarks.first.administrativeArea}';

        //  widget.onLocationSelected(selectedLocation, selectedAddress);
        print(placemarks.first);
        print(selectedAddress);
        setState(() {
          seletedlocationmarker = '${placemarks.first.street} ${placemarks.first.thoroughfare} ';
          selectedlocationcity = ' ${placemarks.first.subLocality} \n ${placemarks.first.locality} - ${placemarks.first.postalCode}, ${placemarks.first.administrativeArea}';
          address = selectedAddress;
        });
        // Navigator.of(context).pop();
      } else {
        setState(() {
          address = 'No address found';
        });
      }
    } catch (e) {
      setState(() {
        address = 'Error getting address';
      });
    }
  }
}
class AddressTypeBox extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const AddressTypeBox({
    this.title,
    this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.redAccent : Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, color: isSelected ? Colors.redAccent : Colors.black),
        ),
      ),
    );
  }
}