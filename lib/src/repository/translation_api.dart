import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class TranslationApi {
  static final _apiKey = 'AIzaSyC6S1xsKzq1R_-x3FnIP_29NQ3Gup2IBv4';

  static Future<String> translate(String message, String toLanguageCode) async {
    //// print("https://translation.googleapis.com/language/translate/v2?target=$toLanguageCode&key=$_apiKey&q=$message");
   // final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?target=$toLanguageCode&key=$_apiKey&q=$message');  (Live API)
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?target=$toLanguageCode&key=1234&q=$message');
    final response = await http.post(url
    );

    if (response.statusCode == 200) {
      //// print("DS>>> translate: is api called?");
      final body = json.decode(response.body);
      final translations = body['data']['translations'] as List;
      final translation = translations.first;
      //// print("DS>>> translate: is api called?"+ HtmlUnescape().convert(translation['translatedText']));
      return HtmlUnescape().convert(translation['translatedText']);
    } else {
      throw Exception();
    }
  }

  static Future<String> translate2(
      String message, String fromLanguageCode, String toLanguageCode) async {
    final translation = await GoogleTranslator().translate(
      message,
      from: fromLanguageCode,
      to: toLanguageCode,
    );

    return translation.text;
  }
}
