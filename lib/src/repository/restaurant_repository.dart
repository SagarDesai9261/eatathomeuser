import 'dart:convert';
import 'dart:io';

import 'package:food_delivery_app/src/models/add_to_favourite_model.dart';
import 'package:food_delivery_app/src/models/home_model.dart';
import 'package:food_delivery_app/src/models/remove_from_favourite.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/filter.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../repository/user_repository.dart';
import 'package:location/location.dart';


Future<Stream<Restaurant>> getNearRestaurants(Address myLocation, Address areaLocation) async {
  Uri uri = Helper.getUri('api/restaurants');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  _queryParams['limit'] = '6';
  _queryParams['kitchenType'] = "1";
  _queryParams['kitchenList'] = "true";
  if (!myLocation.isUnknown() && !areaLocation.isUnknown()) {
    _queryParams['myLon'] = myLocation.longitude.toString();
    _queryParams['myLat'] = myLocation.latitude.toString();
    _queryParams['areaLon'] = areaLocation.longitude.toString();
    _queryParams['areaLat'] = areaLocation.latitude.toString();


  }
  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  // print('Request URL gettopRestaurantsdinein: ${uri.toString()}'); // // print the formed request URL
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Restaurant.fromJSON(data);
    });
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Restaurant.fromJSON({}));
  }
}

Future<Stream<Restaurant>> getNearRestaurantsforDelivery(Address myLocation, Address areaLocation) async {
  Uri uri = Helper.getUri('api/restaurants');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  _queryParams['limit'] = '6';
  _queryParams['kitchenType'] = "2";
  _queryParams['kitchenList'] = "true";
  if (!myLocation.isUnknown() && !areaLocation.isUnknown()) {
    _queryParams['myLon'] = myLocation.longitude.toString();
    _queryParams['myLat'] = myLocation.latitude.toString();
    _queryParams['areaLon'] = areaLocation.longitude.toString();
    _queryParams['areaLat'] = areaLocation.latitude.toString();


  }
  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  // print('Request URL gettopRestaurantsdelivery: ${uri.toString()}'); // // print the formed request URL
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Restaurant.fromJSON(data);
    });
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Restaurant.fromJSON({}));
  }
}

Future<Stream<Restaurant>> getAllRestaurants(String kitchenType, String todayDate, String numberOfPerson, String category, {int limit = 8, int offset = 0}) async {
  Uri uri = Helper.getUri('api/restaurants');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  String latitude = prefs.getDouble("selected_lat").toString();
  String longitude = prefs.getDouble("selected_lng").toString();
  String permission = prefs.getString("permission");
  // print("current permission  + ${permission} ");
  //_queryParams['limit'] = '6';
  _queryParams['kitchenList'] = 'true';
  _queryParams['kitchenType'] = kitchenType;
  _queryParams['DeliveryDate'] = todayDate;
  _queryParams['numberOfPerson'] = numberOfPerson;
  _queryParams['category'] = category;
  if(permission == "LocationPermission.always" || permission == "LocationPermission.whileInUse"){
    // print("$latitude ----- $longitude");
    _queryParams['myLat'] = latitude;
    _queryParams['myLon'] = longitude;
    _queryParams['areaLat'] = latitude;
    _queryParams['areaLon'] = longitude;
  }
  _queryParams['limit'] = '$limit';
  _queryParams['offset'] = '$offset';
  _queryParams.addAll(filter.toQuery());
  _queryParams.remove('searchJoin');
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    print("DS>>> Request delivery: "+uri.toString());
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Restaurant.fromJSON(data);
    });
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Restaurant.fromJSON({}));
  }
}

Future<Stream<Restaurant>> getPopularRestaurants(Address myLocation) async {
  Uri uri = Helper.getUri('api/restaurants');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  _queryParams['limit'] = '6';
  _queryParams['popular'] = 'all';
  _queryParams['kitchenType'] = "1";
  _queryParams['kitchenList'] = "true";
  if (!myLocation.isUnknown()) {
    _queryParams['myLon'] = myLocation.longitude.toString();
    _queryParams['myLat'] = myLocation.latitude.toString();
  }
  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);

  // print('Request URL getPopularRestaurants: ${uri.toString()}'); // // print the formed request URL
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Restaurant.fromJSON(data);
    });
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Restaurant.fromJSON({}));
  }
}

Future<Stream<Restaurant>> getPopularRestaurantsforDelivery(Address myLocation) async {
  Uri uri = Helper.getUri('api/restaurants');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  _queryParams['limit'] = '6';
  _queryParams['popular'] = 'all';
  _queryParams['kitchenType'] = "1";
  _queryParams['kitchenList'] = "true";
  if (!myLocation.isUnknown()) {
    _queryParams['myLon'] = myLocation.longitude.toString();
    _queryParams['myLat'] = myLocation.latitude.toString();
  }
  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  // print('Request URL getPopularRestaurants delivery: ${uri.toString()}'); // // print the formed request URL
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Restaurant.fromJSON(data);
    });
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Restaurant.fromJSON({}));
  }
}
Future<Stream<Map<String, dynamic>>> searchKitchen(String search) async {
  Uri uri = Helper.getUri('api/kitchen-search');
  Map<String, dynamic> _queryParams = {};
  _queryParams['search'] = '$search';
  // _queryParams['searchFields'] = 'name:like;description:like';
  _queryParams['limit'] = '5';
  // if (!address.isUnknown()) {
  //   _queryParams['myLon'] = address.longitude.toString();
  //   _queryParams['myLat'] = address.latitude.toString();
  //   _queryParams['areaLon'] = address.longitude.toString();
  //   _queryParams['areaLat'] = address.latitude.toString();
  // }
  // print(_queryParams);
  uri = uri.replace(queryParameters: _queryParams);
   print(uri);

  try {
    final client = http.Client();
    final streamedResponse = await client.send(http.Request('get', Uri.parse( Uri.decodeComponent( uri.toString()))));

    return streamedResponse.stream.transform(utf8.decoder).transform(json.decoder).map((data) {
      return Helper.getData(data);
    });
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return Stream.value({'success': false, 'data': {'kitchens': [], 'foods': []}});
  }
}
Future<Stream<RestaurantModel>> searchRestaurants(String search, Address address) async {
  Uri uri = Helper.getUri('api/restaurants');
  Map<String, dynamic> _queryParams = {};
  _queryParams['search'] = 'name:$search;description:$search';
  _queryParams['searchFields'] = 'name:like;description:like';
  _queryParams['limit'] = '5';
  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }
  uri = uri.replace(queryParameters: _queryParams);
  // print(uri);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return RestaurantModel.fromJson(data);
    });
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new RestaurantModel.fromJson({}));
  }
}

Future<Stream<Restaurant>> getRestaurant(String id, Address address) async {
  Uri uri = Helper.getUri('api/restaurants/$id');
  Map<String, dynamic> _queryParams = {};
  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }
  _queryParams['with'] = 'users';
  uri = uri.replace(queryParameters: _queryParams);
  print(uri);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) => Restaurant.fromJSON(data));
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Restaurant.fromJSON({}));
  }
}

Future<Stream<Review>> getRestaurantReviews(String id) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}restaurant_reviews?with=user&search=restaurant_id:$id';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    // print("DONNE"+url);
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Review.fromJSON(data);
    });
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Review.fromJSON({}));
  }
}

Future<Stream<Review>> getRecentReviews() async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}restaurant_reviews?orderBy=updated_at&sortedBy=desc&limit=3&with=user';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Review.fromJSON(data);
    });
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Review.fromJSON({}));
  }
}

Future<Review> addRestaurantReview(Review review, Restaurant restaurant) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}restaurant_reviews';
  final client = new http.Client();
  review.user = currentUser.value;
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(review.ofRestaurantToMap(restaurant)),
    );
    if (response.statusCode == 200) {
      return Review.fromJSON(json.decode(response.body)['data']);
    } else {
      // print(CustomTrace(StackTrace.current, message: response.body).toString());
      return Review.fromJSON({});
    }
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: url).toString());
    return Review.fromJSON({});
  }
}

Future<AddToFavouriteModel> addRestaurantToFavourite(String restaurantId, String userId, String apiToken) async {
  Uri uri = Helper.getUri('api/favorites');
  Map<String, dynamic> _queryParams = {'restaurant_id':restaurantId, 'user_id': userId,};
  // print("Bearer: "+apiToken+ "restaurant id: "+restaurantId+" userid: "+userId);
  uri = uri.replace(queryParameters: _queryParams);
  final bearerToken = apiToken;

  final url = Uri.parse('$uri');
  final headers = {'Authorization': 'Bearer $bearerToken'};

  // // print request
  // print('Request: ${url.toString()}');
  // print('Headers: $headers');
  final response = await http.post(url, headers: headers);
  // print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    // Parse the response using the model classes
    final apiResponse = AddToFavouriteModel.fromJson(jsonResponse);
    final success = apiResponse.success;
    final data = apiResponse.data;
    final message = apiResponse.message;
    return apiResponse;
  } else {
    // print('Request failed with status: ${response.statusCode}');
  }
}

Future<DeleteFromFavouriteModel> removeRestaurantFromFavourite(String favouriteId, String apiToken) async {
  Uri uri = Helper.getUri('api/favorites/${favouriteId}');
  Map<String, dynamic> _queryParams = {'restaurant_id':favouriteId};

  //uri = uri.replace(queryParameters: _queryParams);
  final bearerToken = apiToken;

  final url = Uri.parse('$uri');
  final headers = {'Authorization': 'Bearer $bearerToken'};

  final response = await http.delete( url, headers: headers);
   print("DS>>> Response: "+response.toString());
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    // Parse the response using the model classes
    final apiResponse = DeleteFromFavouriteModel.fromJson(jsonResponse);
    final success = apiResponse.success;
    final data = apiResponse.data;
    final message = apiResponse.message;
    return apiResponse;
  } else {
    // print('Request failed with status: ${response.statusCode}');
  }
}

Future<Map<String, dynamic>> fetchAllKitchens() async {


  // print("Fetch Kitchen is called ");
  //var location = new Location();
  SharedPreferences prefs =await  SharedPreferences.getInstance();
  String latitude = prefs.getDouble("selected_lat").toString();
  String longitude = prefs.getDouble("selected_lng").toString();
  String permission = prefs.getString("permission");
 print( prefs.getDouble("selected_lat"));
  // print("current permission  + ${permission} ");
/*  var location = new Location();
  location.requestService().then((value) async {
    location.getLocation().then((_locationData) async {
      // print(_locationData.latitude);
      // print(_locationData.longitude);
      String _addressName = await mapsUtil.getAddressName(new LatLng(_locationData?.latitude, _locationData?.longitude), setting.value.googleMapsKey);
      _address = Address.fromJSON({'address': _addressName, 'latitude': _locationData?.latitude, 'longitude': _locationData?.longitude});
      await changeCurrentLocation(_address);
      whenDone.complete(_address);
    }).timeout(Duration(seconds: 10), onTimeout: () async {
      await changeCurrentLocation(_address);
      whenDone.complete(_address);
      return null;
    }).catchError((e) {
    //  whenDone.complete(_address);
    });
  });*/
  //// print("Address latlong -- -----> ${Address().getLatLng()}");
  Uri uri = Helper.getUri('api/kitchens');
  Map<String, dynamic> _queryParams = {};
  _queryParams['with'] = 'active,popular';
  _queryParams['main_content'] = 'true';
  _queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  _queryParams['kitchenType'] = '1';
  _queryParams['kitchenList'] = 'true';
  if(permission == "LocationPermission.always" || permission == "LocationPermission.whileInUse"){
    // print("$latitude ----- $longitude");
 _queryParams['myLat'] = latitude;
  _queryParams['myLon'] = longitude;
  _queryParams['areaLat'] = latitude;
  _queryParams['areaLon'] = longitude;
  }
  _queryParams['popularKitchenType'] = '1';
 /* _queryParams['myLat'] = latitude;
  _queryParams['myLon'] = longitude;
  _queryParams['areaLat'] = latitude;
  _queryParams['areaLon'] = longitude;*/
  uri = uri.replace(queryParameters: _queryParams);

  // // print the constructed URL before making the request
  // print('Request URL dinein home: ${uri.toString()}');
  print(uri);
  final response = await http.get(uri);
 // print(response.body);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch kitchens');
  }
}

Future<Map<String, dynamic>> fetchAllKitchensDelivery() async {
  SharedPreferences prefs =await  SharedPreferences.getInstance();
  String latitude = prefs.getDouble("selected_lat").toString();
  String longitude = prefs.getDouble("selected_lng").toString();
  String permission = prefs.getString("permission");
  // print("current permission  + ${permission} ");
  Uri uri = Helper.getUri('api/kitchens');
  Map<String, dynamic> _queryParams = {};
  _queryParams['with'] = 'active,popular';
  _queryParams['main_content'] = 'true';
  _queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  _queryParams['kitchenType'] = '2';
  _queryParams['kitchenList'] = 'true';
  if(permission == "LocationPermission.always" || permission == "LocationPermission.whileInUse"){
    // print("$latitude ----- $longitude");
    _queryParams['myLat'] = latitude;
    _queryParams['myLon'] = longitude;
    _queryParams['areaLat'] = latitude;
    _queryParams['areaLon'] = longitude;
  }
  _queryParams['popularKitchenType'] = '2';
  uri = uri.replace(queryParameters: _queryParams);

  // // print the constructed URL before making the request
   print('Request URL delivery home: ${uri.toString()}');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch kitchens');
  }
}

Future<Map<String, dynamic>> fetchAllKitchensWithCuisine(String cuisinesQueryParam,
    String fromDineInorDelivery) async {
  SharedPreferences prefs =await  SharedPreferences.getInstance();
  String latitude = prefs.getString("latitude");
  String longitude = prefs.getString("longitude");
  String permission = prefs.getString("permission");
  Uri uri = Helper.getUri('api/kitchens');
  Map<String, dynamic> _queryParams = {};
  _queryParams['with'] = 'active,popular';
  _queryParams['main_content'] = 'true';
  _queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  if(permission == "LocationPermission.always" || permission == "LocationPermission.whileInUse"){
    // print("$latitude ----- $longitude");
    _queryParams['myLat'] = latitude;
    _queryParams['myLon'] = longitude;
    _queryParams['areaLat'] = latitude;
    _queryParams['areaLon'] = longitude;
  }
  if(fromDineInorDelivery == "dine-in"){
    _queryParams['kitchenType'] = '1';
  }
  else if(fromDineInorDelivery == "delivery"){
    _queryParams['kitchenType'] = '2';
  }
 // print(cuisinesQueryParam);
  _queryParams['kitchenList'] = 'true';
  List<Map<String, String>> params = [];
  List<String> pairs = cuisinesQueryParam.split('&');
 // print(pairs);
  for (String pair in pairs) {
    List<String> keyValue = pair.split('=');

    if (keyValue.length == 2) {
      String key = keyValue[0];
      String value = keyValue[1];

      // Remove any square brackets from the key or value
      params.add({key:value});
    }
  }
  // print(params);
  for (Map<String, String> param in params) {
    _queryParams.addAll(param);
  }

  //_queryParams['kitchenList'] = Uri.decodeComponent('true&$cuisinesQueryParam');
  //// print(_queryParams);
  //uri = uri.replace(queryParameters: _queryParams);
  uri = uri.replace(queryParameters: _queryParams);
  // print(Uri.decodeComponent(uri.toString()));
  // // print the constructed URL before making the request
  // print('Request URL cuisuine: ${Uri.parse(Uri.decodeComponent(uri.toString()))}');

  final response = await http.get(Uri.parse(Uri.decodeComponent(uri.toString())));
  // print(json.decode(response.body));
  if (response.statusCode == 200) {
    // print(json.decode(response.body)["data"]);
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch kitchens');
  }
}

Future<Map<String, dynamic>> fetchAllKitchensWithLocation(String locationQueryParam,
    String fromDineInorDelivery) async {
  SharedPreferences prefs =await  SharedPreferences.getInstance();
  String latitude = prefs.getString("latitude");
  String longitude = prefs.getString("longitude");
  String permission = prefs.getString("permission");
  Uri uri = Helper.getUri('api/kitchens');
  Map<String, dynamic> _queryParams = {};
  _queryParams['with'] = 'active,popular';
  _queryParams['main_content'] = 'true';
  _queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  if(permission == "LocationPermission.always" || permission == "LocationPermission.whileInUse"){
    // print("$latitude ----- $longitude");
    _queryParams['myLat'] = latitude;
    _queryParams['myLon'] = longitude;
    _queryParams['areaLat'] = latitude;
    _queryParams['areaLon'] = longitude;
  }
  if(fromDineInorDelivery == "dine-in"){
    _queryParams['kitchenType'] = '1';
  }
  else if(fromDineInorDelivery == "delivery"){
    _queryParams['kitchenType'] = '2';
  }
  _queryParams['kitchenList'] = 'true&$locationQueryParam';
  uri = uri.replace(queryParameters: _queryParams);

  // // print the constructed URL before making the request
  // print('Request URL: ${Uri.parse(Uri.decodeComponent(uri.toString()))}');

  final response = await http.get(Uri.parse(Uri.decodeComponent(uri.toString())));
  // print(json.decode(response.body));
  if (response.statusCode == 200) {

    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch kitchens');
  }
}

/*
Future<Map<String, dynamic>> fetchAllKitchensWithCuisineForDelivery(String cuisinesQueryParam) async {
  Uri uri = Helper.getUri('api/kitchens');
  Map<String, dynamic> _queryParams = {};
  _queryParams['with'] = 'active,popular';
  _queryParams['main_content'] = 'true';
  _queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  _queryParams['kitchenType'] = '2';
  _queryParams['kitchenList'] = 'true&$cuisinesQueryParam';
  uri = uri.replace(queryParameters: _queryParams);

  // // print the constructed URL before making the request
  // print('Request URL: ${uri.toString()}');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch kitchens');
  }
}

Future<Map<String, dynamic>> fetchAllKitchensWithLocationForDelivery(String locationQueryParam) async {
  Uri uri = Helper.getUri('api/kitchens');
  Map<String, dynamic> _queryParams = {};
  _queryParams['with'] = 'active,popular';
  _queryParams['main_content'] = 'true';
  _queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  _queryParams['kitchenType'] = '2';
  _queryParams['kitchenList'] = 'true&$locationQueryParam';
  uri = uri.replace(queryParameters: _queryParams);

  // // print the constructed URL before making the request
  // print('Request URL: ${uri.toString()}');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch kitchens');
  }
}*/
