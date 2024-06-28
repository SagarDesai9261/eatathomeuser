import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';

import '../../generated/l10n.dart';
import '../elements/SearchWidget.dart';
import '../helpers/app_config.dart' as config;
import '../repository/settings_repository.dart' as settingsRepo;

class SearchBarWidget extends StatefulWidget {
  final ValueChanged onClickFilter;
  final bool isDinein ;
  final int enjoy;
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  const SearchBarWidget({Key? key, required this.onClickFilter,required this.isDinein, required this.parentScaffoldKey,required this.enjoy}) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  String defaultLanguage = "";

  @override
  void initState() {
    getCurrentDefaultLanguage();

    super.initState();
  }

  getCurrentDefaultLanguage() async {
    settingsRepo.getDefaultLanguageName().then((_langCode){
      print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });

    });
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(SearchModal(isDinein: widget.isDinein,enjoy: widget.enjoy));
      },
      child: Container(
        padding: EdgeInsets.all(9),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: Theme.of(context).focusColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(4)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 0),
              child: Icon(Icons.search, color: config.Colors().mainColor(1)),
            ),
            Expanded(
              child: /*Text(
                S.of(context).search_for_kitchen_or_foods,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .merge(TextStyle(fontSize: 14)),
              )*/
              TranslationWidget(
                message: "Search for kitchen or foods",
                fromLanguage: "English",
                toLanguage: defaultLanguage,
                builder: (translatedMessage) => Text(
                    translatedMessage,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        !.merge(TextStyle(fontSize: 14))
                ),
              ),
            ),
            SizedBox(width: 8),
            // InkWell(
            //   onTap: () {
            //     onClickFilter('e');
            //   },
            //   child: Container(
            //     padding: const EdgeInsets.only(
            //         right: 10, left: 10, top: 5, bottom: 5),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.all(Radius.circular(5)),
            //       color: Theme.of(context).focusColor.withOpacity(0.1),
            //     ),
            //     child: Wrap(
            //       crossAxisAlignment: WrapCrossAlignment.center,
            //       spacing: 4,
            //       children: [
            //         // Text(
            //         //   S.of(context).filter,
            //         //   style: TextStyle(color: Theme.of(context).hintColor),
            //         // ),
            //         // Icon(
            //         //   Icons.filter_list,
            //         //   color: Theme.of(context).hintColor,
            //         //   size: 21,
            //         // ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
