import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/elements/DrawerWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shimmer/shimmer.dart'; // Add this import
import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../controllers/favorite_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/FavoriteGridItemWidget.dart';
import '../elements/FavoriteListItemWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/translation_widget.dart';
import '../repository/user_repository.dart';

class FavoritesWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  FavoritesWidget({Key? key, this.parentScaffoldKey}) : super(key: key);

  @override
  _FavoritesWidgetState createState() => _FavoritesWidgetState();
}

class _FavoritesWidgetState extends StateMVC<FavoritesWidget> {
  String layout = 'grid';

  FavoriteController? _con;

  _FavoritesWidgetState() : super(FavoriteController()) {
    _con = controller as FavoriteController?;
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[kPrimaryColororange, kPrimaryColorLiteorange],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 70.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con!.scaffoldKey,
      drawer: DrawerWidget(),
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return new IconButton(
              icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
              onPressed: () => Scaffold.of(context).openDrawer());
        }),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).favorites,
          style:
          Theme.of(context).textTheme.headline6!.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: currentUser.value.apiToken == null
          ? PermissionDeniedWidget()
          : RefreshIndicator(
        onRefresh: _con!.refreshFavorites,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                padding: EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: Theme.of(context).focusColor.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12, left: 0),
                      child: Icon(Icons.search,
                          color: mainColor(1)),
                    ),
                    Expanded(
                      child: TranslationWidget(
                        message: "Search for kitchen or foods",
                        fromLanguage: "English",
                        toLanguage: "English",
                        builder: (translatedMessage) => TextField(
                          decoration: InputDecoration(
                            hintText: translatedMessage,
                            hintStyle: Theme.of(context)
                                .textTheme
                                .caption
                                !.merge(TextStyle(fontSize: 14)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            _con!.searchFavorites(value);
                          },
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              !.merge(TextStyle(fontSize: 14)),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.favorite,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    S.of(context).favorite_foods,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[],
                  ),
                ),
              ),
              _con!.isLoading
                  ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: GridView.count(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  primary: false,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  crossAxisCount:
                  MediaQuery.of(context).orientation ==
                      Orientation.portrait
                      ? 2
                      : 4,
                  children: List.generate(8, (index) {
                    return Container(
                      color: Colors.white,
                    );
                  }),
                ),
              )
                  : _con!.favorites.isEmpty
                  ? Container(
                height: MediaQuery.of(context).size.height * .6,
                child: Center(
                  child: Text(
                    "No Currently Favorites items",
                    style: TextStyle(
                        foreground: Paint()
                          ..shader = linearGradient,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              )
                  : Offstage(
                offstage: this.layout != 'grid',
                child: GridView.count(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  primary: false,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  crossAxisCount:
                  MediaQuery.of(context).orientation ==
                      Orientation.portrait
                      ? 2
                      : 4,
                  children: List.generate(
                      _con!.favorites.length, (index) {
                    return FavoriteGridItemWidget(
                      heroTag: 'favorites_grid',
                      favorite:
                      _con!.favorites.elementAt(index),
                      onRemoveFavorite: _handleRemoveFavorite,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _handleRemoveFavorite(String p1) {
    _con!.favorites.clear();
    _con!.listenForFavorites(message: "");
  }
}
