import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:food_delivery_app/src/models/kitchen_detail_response.dart';

import '../models/favourite_model.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/favorite.dart';
import '../models/filter.dart';
import '../models/food.dart';
import '../models/kitchain_details.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Food>> getTrendingFoods(Address myLocation) async {
  Uri uri = Helper.getUri('api/foods');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  //_queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  _queryParams['kitchenType'] = "1";
  _queryParams['kitchenList'] = "true";
  if (!myLocation.isUnknown()) {
    _queryParams['myLon'] = myLocation.longitude.toString();
    _queryParams['myLat'] = myLocation.latitude.toString();

  }
  _queryParams.addAll(filter.toQuery());
  _queryParams.remove('searchJoin');
  uri = uri.replace(queryParameters: _queryParams);
  // // print('Request URL gettrendingdinein: ${uri.toString()}'); // // print the formed request URL
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Food.fromJSON(data);
    });
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Food.fromJSON({}));
  }
}

Future<Stream<Food>> getTrendingFoodsforDelivery(Address myLocation) async {
  Uri uri = Helper.getUri('api/foods');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  //_queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  _queryParams['kitchenType'] = "2";
  _queryParams['kitchenList'] = "true";
  if (!myLocation.isUnknown()) {
    _queryParams['myLon'] = myLocation.longitude.toString();
    _queryParams['myLat'] = myLocation.latitude.toString();

  }
  _queryParams.addAll(filter.toQuery());
  _queryParams.remove('searchJoin');
  uri = uri.replace(queryParameters: _queryParams);
  // // print('Request URL gettrendingdelivery: ${uri.toString()}'); // // print the formed request URL
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Food.fromJSON(data);
    });
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Food.fromJSON({}));
  }
}


/*Future<Stream<Food>> getTrendingFoods(Address address) async {
  Uri uri = Helper.getUri('api/foods');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  filter.delivery = false;
  filter.open = false;
  //_queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }
  _queryParams.addAll(filter.toQuery());
  _queryParams.remove('searchJoin');

  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    // // print the request
    final request = http.Request('get', uri);
    // // print('Trending Request: ${request.method} ${request.url}');

    final response = await http.Response.fromStream(streamedRest);
    // // print the response
    // // print('Trending Response: ${response.statusCode} ${response.body}');

   *//* // Create a new StreamController
    StreamController<Food> foodStreamController = StreamController<Food>();

    // Listen to the stream
    streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Food.fromJSON(data);
    }).listen((food) {
      // Add each food item to the stream controller
      foodStreamController.add(food);
    }, onError: (error) {
      // Handle any errors that occur during the stream
      foodStreamController.addError(error);
    }, onDone: () {
      // Close the stream controller when the stream is done
      foodStreamController.close();
    });

    // Return the stream from the stream controller
    return foodStreamController.stream;*//*

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Food.fromJSON(data);
    });
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Food.fromJSON({}));
  }
}*/

Future<Stream<Food>> getFood(String foodId) async {
  Uri uri = Helper.getUri('api/foods/$foodId');
  uri = uri.replace(queryParameters: {'with': 'nutrition;restaurant;category;extras;extraGroups;foodReviews;foodReviews.user'});
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) {
      return Food.fromJSON(data);
    });
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Food.fromJSON({}));
  }
}

Future<Stream<Food>> searchFoods(String search, Address address) async {
  Uri uri = Helper.getUri('api/foods');
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
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Food.fromJSON(data);
    });
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Food.fromJSON({}));
  }
}

Future<Map<String, dynamic>> getFoodsByCategory(categoryId, int limit, int offset) async {
  // // print("categoryId"+categoryId);
  Uri uri = Helper.getUri('api/foods');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  _queryParams['with'] = 'restaurant';
  _queryParams['searchJoin'] = 'and';
  _queryParams['category'] = '$categoryId';
  _queryParams['limit'] = '$limit';
  _queryParams['offset'] = '$offset';
 // _queryParams = filter.toQuery(oldQuery: _queryParams);
  uri = uri.replace(queryParameters: _queryParams);

    print(uri);
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    // // print(streamedRest.request);
    try {
      final response = await streamedRest.stream.bytesToString().then(
          json.decode);

      List<Food> foods = (response['data'] as List)
          .map((data) => Food.fromJSON(data))
          .toList();


      return {
        'data': foods,
        'message': response['message'] ?? '',
      };
    }

    // final response = await streamedRest.stream.transform(utf8.decoder).transform(json.decoder).cast() as Map<String, dynamic>;
    //
    // return {
    //   'data': (response['data'] ).map((data) => Food.fromJSON(data)).toList(),
    //   'message': response['message'] ?? '',
    // };

  catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return {
      'data': [Food.fromJSON({})],
      'message': 'An error occurred',
    };
  }
}


Future<Stream<Food>> getFoodsByCategoryAndRestaurant(categoryId, restaurantId) async {
  Uri uri = Helper.getUri('api/foods');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  _queryParams['with'] = 'restaurant';
  _queryParams['search'] = 'category_id:$categoryId&restaurant_id=$restaurantId';
  //_queryParams = filter.toQuery(oldQuery: _queryParams);

  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    // // print('Request URL1: ${uri.toString()}'); // // print the request URL
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Food.fromJSON(data);
    });
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Food.fromJSON({}));
  }
}

Future<KitchenDetailResponse> getFoodsByCategoryAndKitchen(categoryId, restaurantId) async {

  DateTime now = DateTime.now();
  String todayDate = "${now.year}-${now.month}-${now.day}";

  Uri uri = Helper.getUri('api/kitchens/$restaurantId');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  _queryParams['with'] = 'foods';
  _queryParams['date'] = '$todayDate';
  //_queryParams['category'] = categoryId;
  if(categoryId != null)
   _queryParams['category'] = '$categoryId';
  //_queryParams = filter.toQuery(oldQuery: _queryParams);

  uri = uri.replace(queryParameters: _queryParams);
   print('Request URL getFoodsByCategoryAndKitchen: ${uri.toString()}');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);

      if(responseData["success"] == false){
        print("=>>=>>111");
        return KitchenDetailResponse(
          success: false,
          message: 'No Data Available',
          data: {},
        );
      }
      KitchenDetailResponse foodResponse = KitchenDetailResponse.fromJson(responseData);
      return foodResponse;
    } else {
      // Handle error if the API request is not successful
      throw Exception('Failed to load food data');
    }

}


Future<Stream<Favorite>> isFavoriteFood(String foodId) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}favorites/exist?${_apiToken}food_id=$foodId&user_id=${_user.id}';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getObjectData(data)).map((data) => Favorite.fromJSON(data));
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Favorite.fromJSON({}));
  }
}

Future<Map<String, dynamic>> getFavorites() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    //return Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  /*final String url =
      '${GlobalConfiguration().getValue('api_base_url')}favorites?${_apiToken}with=food;user;extras&search=user_id:${_user.id}&searchFields=user_id:=';*/
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}favorites?${_apiToken}';
  final client = new http.Client();

  // // print the request URL before sending
   print('Request URL: $url');
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  /*try {
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) {
      // // print the response data
      // // print('Response Data: $data');
      return Helper.getData(data);
    }).expand((data) => (data as List))
        .map((data) => FavouriteModel.fromJson(data));
  } */ try {
    final responseStream = streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder);

    final responseData = await responseStream.first as Map<String, dynamic>;
    // // print the complete response data
    // // print('Complete Response Data: $responseData');

    // You can handle the success and failure cases based on responseData
    return responseData;
  } catch (e) {
   /* // // print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new FavouriteModel.fromJson({}));*/
  }
}

Future<Favorite> addFavorite(Favorite favorite) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Favorite();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  favorite.userId = _user.id;
  final String url = '${GlobalConfiguration().getValue('api_base_url')}favorites?$_apiToken';
  try {
    final client = new http.Client();
    final response = await client.post(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(favorite.toMap()),
    );
    return Favorite.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: url).toString());
    return Favorite.fromJSON({});
  }
}

Future<Favorite> removeFavorite(Favorite favorite) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Favorite();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}favorites/${favorite.id}?$_apiToken';
  try {
    final client = new http.Client();
    final response = await client.delete(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return Favorite.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: url).toString());
    return Favorite.fromJSON({});
  }
}

Future<Stream<Food>> getFoodsOfRestaurant(String restaurantId, {List<String> categories}) async {
  Uri uri = Helper.getUri('api/foods/categories');
  Map<String, dynamic> query = {
    'with': 'restaurant;category;extras;foodReviews',
    'search': 'restaurant_id:$restaurantId',
    'searchFields': 'restaurant_id:=',
  };

  if (categories != null && categories.isNotEmpty) {
    query['categories[]'] = categories;
  }
  uri = uri.replace(queryParameters: query);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Food.fromJSON(data);
    });
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Food.fromJSON({}));
  }
}

///DS Get Idividual Food Restuarant Wise

Future<List<Food>> getIndividualFoodsOfRestaurant(String restaurantId) async {
  Uri uri = Helper.getUri('api/restaurants/' + restaurantId);
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('GET', uri));

    final response = await streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .first; // Only take the first item from the stream

    // // print('Response of food for ind: $response'); // // print the response before processing

    final responseData = Helper.getData(response);
    final foodList = responseData['food'] as List<dynamic>;

    return foodList.map((data) => Food.fromJSON(data)).toList();
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return [];
  }
}




///////////////////////////////////////////////
Future<Stream<Food>> getTrendingFoodsOfRestaurant(String restaurantId) async {
  Uri uri = Helper.getUri('api/foods');
  uri = uri.replace(queryParameters: {
    'with': 'category;extras;foodReviews',
    'search': 'restaurant_id:$restaurantId;featured:1',
    'searchFields': 'restaurant_id:=;featured:=',
    'searchJoin': 'and',
  });
  // TODO Trending foods only
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Food.fromJSON(data);
    });
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Food.fromJSON({}));
  }
}

Future<Stream<Food>> getFeaturedFoodsOfRestaurant(String restaurantId) async {
  Uri uri = Helper.getUri('api/foods');
  uri = uri.replace(queryParameters: {
    'with': 'category;extras;foodReviews',
    'search': 'restaurant_id:$restaurantId;featured:1',
    'searchFields': 'restaurant_id:=;featured:=',
    'searchJoin': 'and',
  });
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Food.fromJSON(data);
    });
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Food.fromJSON({}));
  }
}

Future<Review> addFoodReview(Review review, Food food) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}food_reviews';
  final client = new http.Client();
  review.user = userRepo.currentUser.value;
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(review.ofFoodToMap(food)),
    );
    if (response.statusCode == 200) {
      return Review.fromJSON(json.decode(response.body)['data']);
    } else {
      // // print(CustomTrace(StackTrace.current, message: response.body).toString());
      return Review.fromJSON({});
    }
  } catch (e) {
    // // print(CustomTrace(StackTrace.current, message: url).toString());
    return Review.fromJSON({});
  }
}

Future<List<Restaurant>> getKetchainDetails() async
{
  final Uri uri = Uri.parse('https://comeeathome.com/app/api/kitchen-details?kitchen=14&kitchenType=1&date=23-12-2023');

  // Adding parameters to the request
  // final Map<String, String> queryParams = {
  //   'param1': param1,
  //   'param2': param2,
  //   // Add more parameters as needed
  // };
  // final Uri uriWithParams = uri.replace(queryParameters: queryParams);

  final response = await http.get(Uri.parse(uri.toString()));
  if (response.statusCode == 200) {
    // Parse the response data
    final jsonData = json.decode(response.body);

    // Assuming jsonData is a list of restaurants
    List<Restaurant> restaurants = [];
    for (var item in jsonData) {
      restaurants.add(Restaurant.fromJson(item));
    }

    return restaurants;
  } else {
    throw Exception('Failed to load restaurants');
  }
}
Future<List<FoodItem>> getFoodsByCategoryAndKitchenlist(int categoryId, String restaurantId,{int limit = 2, int offset = 0}) async {
  DateTime now = DateTime.now();
  String todayDate = "${now.year}-${now.month}-${now.day}";

  Uri uri = Helper.getUri('api/kitchens/$restaurantId');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  _queryParams['with'] = 'foods';
  _queryParams['date'] = '$todayDate';
  _queryParams['category'] = '$categoryId'; // Ensure categoryId is converted to string
  _queryParams['limit']= '$limit';
  _queryParams['offset'] = '$offset';
  uri = uri.replace(queryParameters: _queryParams);
  print('Request URL getFoodsByCategoryAndKitchen: ${uri.toString()}');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    //print(responseData);

    if (responseData["success"] == false) {
    //  print("=>>=>>111");
      // Return an empty list when no data is available
      return [];
    }

    // Find the key associated with the list of food items
    String foodItemsKey;
    responseData['data'].forEach((key, value) {
      if (value is List<dynamic>) {
        foodItemsKey = key;
      }
    });

    // Extract food items from the data object
    List<dynamic> foodItemsJson = responseData['data'][foodItemsKey];
    print(foodItemsJson);
    // Parse the list of food items
    List<FoodItem> foodItems = foodItemsJson.map((item) => FoodItem.fromJson(item)).toList();
    return foodItems;
  } else {
    // Handle error if the API request is not successful
    throw Exception('Failed to load food data');
  }
}

Future<FoodItem> getFoodsByCategoryAndKitchenData(String restaurantId, {int limit = 1, int offset = 0}) async {
  DateTime now = DateTime.now();
  String todayDate = "${now.year}-${now.month}-${now.day}";

  Uri uri = Helper.getUri('api/kitchens/$restaurantId');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  _queryParams['with'] = 'foods';
  _queryParams['date'] = '$todayDate';
  //_queryParams['category'] = '$categoryId'; // Ensure categoryId is converted to string
  _queryParams['limit'] = '$limit';
  _queryParams['offset'] = '$offset';
  uri = uri.replace(queryParameters: _queryParams);
  print('Request URL getFoodsByCategoryAndKitchen: ${uri.toString()}');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    print(responseData);

    if (responseData["success"] == false) {
      print("=>>=>>111");
      // Return an empty list when no data is available
      return FoodItem();
    }
    Map<String,dynamic> data = {};
    print(responseData["data"].runtimeType);
    var key ;
    if(responseData["data"].runtimeType.toString() == "List<dynamic>"){
       data = responseData["data"][0];
       print(data);
      var keys = data.keys;

      keys.forEach((element) {
       // print(element);
        key = element;
      });
    }
    else{
      data = responseData["data"];
      var keys = data.keys;

      keys.forEach((element) {
       // print(element);
        key = element;
      });
    }

    /// List jsondata = data.values;
   // print(key);
    // Extract food items from the data object
    FoodItem foodItemsJson = FoodItem.fromJson(data[key]);


    print(foodItemsJson);
    // Parse the list of food items
    //List<FoodItem> foodItems = foodItemsJson.map((item) => FoodItem.fromJson(item)).toList();
    return foodItemsJson;
  } else {
    // Handle error if the API request is not successful
    throw Exception('Failed to load food data');
  }
}
