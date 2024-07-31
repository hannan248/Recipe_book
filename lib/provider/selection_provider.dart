import 'package:flutter/material.dart';

class SelectionProvider with ChangeNotifier {
  int? _selectedIndex=0;

  int? get selectedIndex => _selectedIndex;

  void selectItem(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
