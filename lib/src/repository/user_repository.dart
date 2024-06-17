import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../elements/email_verification.dart';
import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/credit_card.dart';
import '../models/user.dart' as userModel;
import '../repository/user_repository.dart' as userRepo;

ValueNotifier<userModel.User> currentUser = new ValueNotifier(userModel.User());

Future<userModel.User> login(userModel.User user, BuildContext context) async {
  print("sdsdsdsf ====>   " + user.deviceToken);
  final String url = '${GlobalConfiguration().getValue('api_base_url')}login';
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  print(url);
  print({HttpHeaders.contentTypeHeader: 'application/json'});
  print(json.encode(user.toMap()));
  if (response.statusCode == 200 ||
      json.decode(response.body)["success"] == true) {
    print(json.decode(response.body));
    print(json.decode(response.body)["data"]["email_verified"]);
    print(json.decode(response.body)["data"]["email_verified"].runtimeType);
    print(json.decode(response.body)["data"]["email_verified"] == "0");

    if (json.decode(response.body)["data"]["email_verified"] == "0") {
      print("calling");
      resendOtp(user.email).then((value) {
        if (value == "resend") {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VerificationScreen2(
                    email: user.email,
                  )));
        }
      });
    }

    if (json.decode(response.body)["data"]["email_verified"] == "1") {
      //  print("DS>>>"+userModel.User.fromJSON(json.decode(response.body)['data']).name);
      setCurrentUser(response.body);
      // print(response.body + "f4d5s4f5");

      currentUser.value =
          userModel.User.fromJSON(json.decode(response.body)['data']);
      // print(json.decode(response.body)['data']["custom_fields"]["address"]["value"]);
      print(currentUser.value.name);
    }

    // print(currentUser.value.bio);
    //   print(currentUser.value.latitude.toString() + currentUser.value.longitude.toString()+ currentUser.value.country);
  } else {
    Fluttertoast.showToast(msg: "${jsonDecode(response.body)["message"]}");

    if (jsonDecode(response.body)["message"] == "Invalid Credenitials") {
      return null;
    } else {
      // throw new Exception(response.body);
    }
    //  print(jsonDecode(response.body)["message"]);
    // if(jsonDecode(response.body)["message"]){}
  }
  print(currentUser.value.name);
  return currentUser.value;
}

Future<void> saveRestoreId(String restoreId) async {
  final String url = 'https://eatathome.in/app/api/save-restorid';
  print(url);
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${currentUser.value.apiToken}',
    },
    body: jsonEncode({'restoreid': restoreId}),
  );
  print(response.body);
  if (response.statusCode == 200 ||
      json.decode(response.body)["success"] == true) {
    // Request was successful
    setCurrentUser(response.body);
    currentUser.value =
        userModel.User.fromJSON(json.decode(response.body)['data']);
  } else {
    // Handle error
    print('Failed to save Restore ID: ${response.statusCode}');
    print('Error: ${response.body}');
  }
}

Future<String> register(userModel.User user) async {
  // print("DS>>> I am here");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}register';
  final client = new http.Client();
  final requestBody = json.encode(user.toMap());

  // print("Full Request: POST $url");
  // print("Headers: {${HttpHeaders.contentTypeHeader}: 'application/json'}");
  // print("Body: $requestBody");

  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: requestBody,
  );
  // print("DS>>> I am here"+response.body);
  print("object" + response.body.toString());
  Map<String, dynamic> message = json.decode(response.body);
  if (response.statusCode == 200 || message["success"] == true) {
    // print("DS>> Registration Succesful");
    print(message["message"]);
    //setCurrentUser(response.body);
    return "Register";
    //currentUser.value = userModel.User.fromJSON(json.decode(response.body)['data']);
  } else {
    print(message["message"]);
    Fluttertoast.showToast(msg: message["message"]);
    return "not register";
    // throw new Exception(response.body);
  }
  return "not register";
}

Future<String> verifyOtp(String email, String code, String type) async {
  final url = Uri.parse('https://eatathome.in/app/api/verify-code');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    'email': email,
    'code': code,
    'type': type,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Handle successful response
      print('OTP verified successfully');
      // You can parse the response body if needed
      final responseBody = jsonDecode(response.body);
      setCurrentUser(response.body);
      currentUser.value =
          userModel.User.fromJSON(json.decode(response.body)['data']);

      print(responseBody);
      return "Verify";
    } else {
      // Handle error response
      print('Failed to verify OTP: ${response.statusCode}');
      print(response.body);
      return "not Verify";
    }
  } catch (e) {
    return " not Verify";
    // Handle network or other errors
    print('Error verifying OTP: $e');
  }
}

Future<String> resendOtp(String email) async {
  final url =
      Uri.parse('https://eatathome.in/app/api/resend-verification-code');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    'email': email,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      // Handle successful response

      // You can parse the response body if needed
      /*  final responseBody = jsonDecode(response.body);
      currentUser.value = userModel.User.fromJSON(json.decode(response.body)['data']);
*/
      //  print(responseBody);
      return "resend";
    } else {
      // Handle error response
      print('Failed to verify OTP: ${response.statusCode}');
      print(response.body);
      return "not resend";
    }
  } catch (e) {
    return " not Verify";
    // Handle network or other errors
    print('Error verifying OTP: $e');
  }
}

Future<bool> resetPassword(userModel.User user) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}send_reset_link_email';
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    throw new Exception(response.body);
  }
}

Future<void> logout() async {
  currentUser.value = new userModel.User();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('current_user');
}

void setCurrentUser(jsonString) async {
  if (json.decode(jsonString)['data'] != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'current_user', json.encode(json.decode(jsonString)['data']));
  }
}

Future<void> setCreditCard(CreditCard creditCard) async {
  if (creditCard != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('credit_card', json.encode(creditCard.toMap()));
  }
}

Future<userModel.User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
    currentUser.value =
        userModel.User.fromJSON(json.decode(await prefs.get('current_user')));
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<CreditCard> getCreditCard() async {
  CreditCard _creditCard = new CreditCard();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('credit_card')) {
    _creditCard =
        CreditCard.fromJSON(json.decode(await prefs.get('credit_card')));
  }
  return _creditCard;
}

Future<userModel.User> update(userModel.User user, File identityFile) async {
  final String _apiToken = 'api_token=${currentUser.value.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}users/${currentUser.value.id}?$_apiToken';
  final client = http.Client();
  print(url);
  // Prepare request
  var request = http.MultipartRequest('POST', Uri.parse(url));

  // Add user details to the request
  request.fields['name'] = user.name;
  request.fields['email'] = user.email;
  request.fields['phone'] = user.phone;
  request.fields['address'] = user.address;
  request.fields['bio'] = user.bio;
  request.fields['latitude'] = user.latitude.toString();
  request.fields['longitude'] = user.longitude.toString();
  request.fields['country'] = user.country;

  // Add identity file to the request
  if (identityFile != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'identity',
        identityFile.path,
      ),
    );
  }

  // Send the request
  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);
  print(response.body);
  // Process response
  if (response.statusCode == 200) {
    print(response.body);
    setCurrentUser(response.body);
    currentUser.value =
        userModel.User.fromJSON(json.decode(response.body)['data']);
    print(currentUser.value.image.url);
    return currentUser.value;
  } else {
    throw Exception('Failed to update user: ${response.reasonPhrase}');
  }
}

Future<Stream<Address>> getAddresses() async {
  userModel.User _user = currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$_apiToken&search=user_id:${_user.id}&searchFields=user_id:=&orderBy=updated_at&sortedBy=desc';
  // print(url);
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Address.fromJSON(data);
  });
}

Future<Address> addAddress(Address address) async {
  userModel.User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$_apiToken';
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(address.toMap()),
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}

Future<Address> updateAddress(Address address) async {
  userModel.User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(address.toMap()),
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}

Future<Address> removeDeliveryAddress(Address address) async {
  userModel.User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.delete(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}
