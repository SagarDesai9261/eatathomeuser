import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/translation_api.dart';
import 'translations.dart';

class TranslationWidget extends StatefulWidget {
  final String message;
  final String fromLanguage;
  final String toLanguage;
  final Widget Function(String translation) builder;

  const TranslationWidget({
    @required this.message,
    @required this.fromLanguage,
    @required this.toLanguage,
    @required this.builder,
    Key key,
  }) : super(key: key);

  @override
  _TranslationWidgetState createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
  String translation;

  @override
  Widget build(BuildContext context) {
    // final fromLanguageCode = Translations.getLanguageCode(widget.fromLanguage);
    //// print("DS>> toLanguage code: "+widget.toLanguage.toString());
    final toLanguageCode = Translations.getLanguageCode(widget.toLanguage);
    //// print("DS>> toLanguage code2 : "+toLanguageCode.toString());

    return FutureBuilder(
      future: TranslationApi.translate(widget.message, toLanguageCode),
      //future: TranslationApi.translate2(
      //    widget.message, fromLanguageCode, toLanguageCode),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return buildWaiting();
          default:
            if (snapshot.hasError) {
            //  print("error call for transation");
              translation = widget.message;
            } else {
              translation = snapshot.data;
             // print("DS>>> translate: "+translation);
            }
            return widget.builder(translation);
        }
      },
    );
  }

  Widget buildWaiting() =>
      translation == null ? Container() : widget.builder(translation);
}
