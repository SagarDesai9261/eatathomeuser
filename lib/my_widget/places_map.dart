/*
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Place Autocomplete',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlaceAutocomplete(),
    );
  }
}

class PlaceAutocomplete extends StatefulWidget {
  @override
  _PlaceAutocompleteState createState() => _PlaceAutocompleteState();
}

class _PlaceAutocompleteState extends State<PlaceAutocomplete> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapsPlaces _places =
  GoogleMapsPlaces(apiKey: "AIzaSyDHYg5QGkHv2wy_Ef5lOfExkmjF3JnB-3k");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Autocomplete'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a place',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchController.text = value;
                });
                // You can add more logic here if needed
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _places.autocomplete(_searchController.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  PlacesAutocompleteResponse placesResponse = snapshot.data;
                  print(placesResponse.status);
                  return ListView.builder(
                    itemCount: placesResponse.predictions.length,
                    itemBuilder: (context, index) {
                      Prediction prediction =
                      placesResponse.predictions[index];
                      return ListTile(
                        title: Text(prediction.description),
                        onTap: () {
                          // Handle tap on a prediction
                          // For example, you can use the place ID to fetch place details
                          print('Selected Place ID: ${prediction.placeId}');
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
*/
