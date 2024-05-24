import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/favorite.dart';
import '../models/favourite_model.dart';
import '../repository/food_repository.dart';

class FavoriteController extends ControllerMVC {
  List<FavouriteModel> favorites = <FavouriteModel>[];
  List<FavouriteModel> originalFavorites = <FavouriteModel>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  FavoriteController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForFavorites();
  }

  Future<String> listenForFavorites({String message}) async {
    /*final Stream<FavouriteModel> stream = await getFavorites();
    stream.listen((FavouriteModel _favorite) {
      setState(() {
        favorites.add(_favorite);
        // print("DS>> fav "+_favorite.name.toString());
      });
    }, onError: (a) {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });*/
    final Map<String, dynamic> response = await getFavorites();

    if (response['success']) {
      // If success is true, update the state with the received data
      List<FavouriteModel> favouritesData = (response['data'] as List)
          .map((item) => FavouriteModel.fromJson(item))
          .toList();

      setState(() {
        originalFavorites = favouritesData;
        favorites.addAll(favouritesData);
     //   // print("DS>> fav ${favouritesData.map((fav) => fav.name).join(', ')}");
      });
    } else {
      // If success is false, show an error message
      /*ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(response['message'] ?? 'An error occurred'),
      ));
*/
      return response['message'];
    }

    if (message != null && message != "") {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(message),
      ));
    }
  }
  void searchFavorites(String query) {
    if (query.isNotEmpty) {
      setState(() {
        favorites = originalFavorites
            .where((favorite) =>
        favorite.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      //  print(originalFavorites.length);
      });
    } else {
      setState(() {
        favorites = List.from(originalFavorites);
      });
    }
    void clearSearch() {
      setState(() {
        favorites = List.from(originalFavorites);
      });
    }
  }

  Future<void> refreshFavorites() async {
    favorites.clear();
    listenForFavorites(message: S.of(state.context).favorites_refreshed_successfuly);
  }
}
