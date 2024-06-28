import 'dart:convert';

import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/cuisine.dart';
import '../models/location.dart';
import '../models/slide.dart';

Future<Stream<Slide>> getSlides() async {
  Uri uri = Helper.getUri('api/slides');
  Map<String, dynamic> _queryParams = {
    'with': 'food;restaurant',
    'search': 'enabled:1',
    'orderBy': 'order',
    'sortedBy': 'asc',
  };
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data  as Map<String,dynamic>))
        .expand((data) => (data as List))
        .map((data) => Slide.fromJSON(data));
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Slide.fromJSON({}));
  }
}

/*Future<List<Cuisine>> fetchCuisine() async {
  final response = await http.get(Uri.parse('https://example.com/api/data'));

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);

    List<Cuisine> myDataList = responseData.map((data) => Cuisine.fromJSON(data)).toList();

    return myDataList;
  } else {
    throw Exception('Failed to load data from API');
  }
}*/

Future<Stream<Cuisine>> fetchCuisine() async {
  Uri uri = Helper.getUri('api/cuisines');
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data as Map<String,dynamic>))
        .expand((data) => (data as List))
        .map((data) => Cuisine.fromJSON(data));
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Cuisine.fromJSON({}));
  }
}

Future<Stream<LocationModel>> fetchLocation() async {
  Uri uri = Helper.getUri('api/restaurants/locations');
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data as Map<String,dynamic>))
        .expand((data) => (data as List))
        .map((data) => LocationModel.fromJson(data));
  } catch (e) {
    // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new LocationModel.fromJson({}));
  }
}
