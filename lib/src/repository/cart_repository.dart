import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Map<String, dynamic>> getCart() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return {'success': false, 'message': 'User not authenticated'};
  }

  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}carts?${_apiToken}with=food;food.restaurant;extras&search=user_id:${_user.id}&searchFields=user_id:=';
  print('DS>>>>> Cart Request URL: $url');

  final client = http.Client();
  final response = await client.get(Uri.parse(url));

  //print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = json.decode(response.body);

    return jsonData;
  } else {
    print('Error: ${response.statusCode}');
    return {'success': false, 'message': 'Failed to retrieve carts'};
  }
}
Future<Map<String, dynamic>> getcartfromAddress() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString("delivery_address_id");
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return {'success': false, 'message': 'User not authenticated'};
  }

  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}carts?${_apiToken}with=food;food.restaurant;extras&search=user_id:${_user.id}&searchFields=user_id:=&delivery_address_id=$id';
  print('DS>>>>> Cart Request URL: $url');

  final client = http.Client();
  final response = await client.get(Uri.parse(url));

  //print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = json.decode(response.body);

    return jsonData;
  } else {
    print('Error: ${response.statusCode}');
    return {'success': false, 'message': 'Failed to retrieve carts'};
  }
}


Future<Stream<int>> getCartCount() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(0);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts/count?${_apiToken}search=user_id:${_user.id}&searchFields=user_id:=';
  print(url);
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map(
        (data) => Helper.getIntData(data as Map<String,dynamic>),
      );
}

Future<Cart> addCart(Cart cart, bool reset) async {
  // print("DS>> : cart has value?"+cart.food.name);
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Cart();
  }
  Map<String, dynamic> decodedJSON = {};
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String _resetParam = 'reset=${reset ? 1 : 0}';
  cart.userId = _user.id;
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts?$_apiToken&$_resetParam';
  final client = new http.Client();
  print(url);
  // // print the request details
 //  print('Request URL: $url');
  // print('Request Body cart: ${json.encode(cart.toMap())}');

  print(cart.toMap());
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(cart.toMap()),
  );

  // print(json.decode(response.request.toString()));
    decodedJSON = json.decode(response.body)['data'] as Map<String, dynamic>;

  return Cart.fromJSON(decodedJSON);
}

Future<Cart> updateCart(Cart cart) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Cart();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  cart.userId = _user.id;
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts/${cart.id}?$_apiToken';

  final client = new http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(cart.toMap()),
  );
  print(json.decode(response.body)['data']);
  return Cart.fromJSON(json.decode(response.body)['data']);
}

Future<bool> removeCart(Cart cart) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return false;
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts/${cart.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.delete(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  return Helper.getBoolData(json.decode(response.body));
}

Future<bool> removeAllCart() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return false;
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts/remove-all';
  print(url);
  print(_apiToken);
  final client = new http.Client();
  final response = await client.get(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${_user.apiToken}',
    },
  );
  print(response.body);
  return getBoolsData(json.decode(response.body));
}
bool getBoolsData(Map<String, dynamic> data) {
  return (data['data']["deleted"] as bool) ?? false;
}