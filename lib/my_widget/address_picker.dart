import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart' as geolocator;

import '../utils/color.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Scaffold(
        body: CarouselSlider(
          options: CarouselOptions(height: 400.0,padEnds: true,pageSnapping: true
          ),
          items: [1, 2, 3, 4, 5].map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                  ),
                  child: Text(
                    'text $i',
                    style: TextStyle(fontSize: 16.0),
                  ),
                );
              },
            );
          }).toList(),
        ),
      )
      ,
    );
  }
}

class ProfileUpdateDialog extends StatefulWidget {
  @override
  _ProfileUpdateDialogState createState() => _ProfileUpdateDialogState();
}

class _ProfileUpdateDialogState extends State<ProfileUpdateDialog> {
  String name = '';
  String email = '';
  String address = '';
  LatLng selectedLocation = LatLng(0,0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showUpdateProfileDialog();
          },
          child: Text('Update Profile'),
        ),
      ),
    );
  }

  Future<void> _showUpdateProfileDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController addressController = TextEditingController();

    // Set initial values in the dialog
    nameController.text = name;
    emailController.text = email;
    addressController.text = address;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Profile'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              GestureDetector(
                onTap: () async {
                  // Open the map for address selection
                  LatLng resultLocation = await _openAddressSelectionMap();

                  if (resultLocation != null) {
                    // Get the address from the selected location
                    String selectedAddress = await _getAddressFromLocation(resultLocation);

                    // Update the address text field
                    addressController.text = selectedAddress;

                    // Update the selected location
                    selectedLocation = resultLocation;
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'Address'),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            MaterialButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            MaterialButton(
              child: Text('Update'),
              onPressed: () {
                // Update the profile information
                setState(() {
                  name = nameController.text;
                  email = emailController.text;
                  address = addressController.text;
                });

                // Close the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<LatLng> _openAddressSelectionMap() async {
    LatLng? resultLocation;
    String resultAddress;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapScreen(
          initialLocation: selectedLocation,
          onLocationSelected: (location, address) {
            resultLocation = location;
            resultAddress = address;
          },
        );
      },
    );

    return resultLocation!;
  }

  Future<String> _getAddressFromLocation(LatLng location) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        return '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}';
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error getting address';
    }
  }
}

class MapScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng, String)? onLocationSelected;

  MapScreen({ this.onLocationSelected, this.initialLocation});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  Marker? selectedMarker;
  String? address;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  //  selectedLocation = LatLng(0.0, 0.0);

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    geolocator.Position? position;

    try {
      position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );
    } catch (e) {
      print("Error getting current location: $e");
    }

    if (position != null) {
      setState(() {
        selectedLocation = LatLng(position!.latitude, position!.longitude);
      });
    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Expanded(
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
                      target: widget.initialLocation ?? selectedLocation!,
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
          SizedBox(
            width:
            MediaQuery.of(context).size.width / 2,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    kPrimaryColororange,
                    kPrimaryColorLiteorange
                  ],
                ),
              ),
              child: MaterialButton(
                onPressed: () {
                  _showAddressDialog();
                },
                child: Text('Select the Address',style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
          if (address != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Address: $address\nLatLong: $selectedLocation'),
            ),
        ],
      ),
    );
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
      widget.onLocationSelected!(selectedLocation!, "selectedAddress");
      print(selectedLocation!.latitude);
    });
  }

  Future<void> _showAddressDialog() async {
    if (selectedLocation == null) {
      return;
    }

    try {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        selectedLocation!.latitude,
        selectedLocation!.longitude,
      );

      if (placemarks.isNotEmpty) {
        String selectedAddress =
            '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}';
      //  widget.onLocationSelected(selectedLocation, selectedAddress);
        print(selectedAddress);
        Navigator.of(context).pop();
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

