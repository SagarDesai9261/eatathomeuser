import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/favorite.dart';
import '../models/favourite_model.dart';
import '../repository/food_repository.dart';

class FavoriteController extends ControllerMVC {
  List<FavouriteModel> favorites = <FavouriteModel>[];
  List<FavouriteModel> originalFavorites = <FavouriteModel>[];
  GlobalKey<ScaffoldState>? scaffoldKey;
  bool isLoading = false;

  FavoriteController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForFavorites();
  }

  Future<String?> listenForFavorites({String? message}) async {
   // setState(() {
      isLoading = true;
      print("calling function");
  //  });
    print("calling function11");
    final Map<String, dynamic> response = await getFavorites();

    if (response['success']) {
      List<FavouriteModel> favouritesData = (response['data'] as List)
          .map((item) => FavouriteModel.fromJson(item))
          .toList();
      isLoading = false;
      setState(() {

        originalFavorites = favouritesData;
        favorites.addAll(favouritesData);

      });
    } else {
      isLoading = false;
      setState(() {
        isLoading = false;
      });
      return response['message'];
    }

    if (message != null && message != "") {
      ScaffoldMessenger.of(scaffoldKey!.currentContext!!).showSnackBar(SnackBar(
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
      });
    } else {
      setState(() {
        favorites = List.from(originalFavorites);
      });
    }
  }

  void clearSearch() {
    setState(() {
      favorites = List.from(originalFavorites);
    });
  }

  Future<void> refreshFavorites() async {
    favorites.clear();
    listenForFavorites(message: S.of(state!.context).favorites_refreshed_successfuly);
  }
}
