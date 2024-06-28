import 'package:flutter/material.dart';

class CollectedData extends ChangeNotifier {
  String? _selectedDate;
  String? _selectedSession;
  String? _selectedPeople;

  String get date => _selectedDate!;
  String get session => _selectedSession!;
  String get people => _selectedPeople!;

  String? category_id = null;

  set_category(cat_id){
    category_id = cat_id;
    notifyListeners();
  }

  void updateDate(String newData) {
    _selectedDate = newData;
    notifyListeners();
  }

  void updateSession(String newData) {
    _selectedSession = newData;
    notifyListeners();
  }

  void updatePeople(String newData) {
    _selectedPeople = newData;
    notifyListeners();
  }
}