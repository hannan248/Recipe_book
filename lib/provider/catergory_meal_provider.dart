import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_book/model/meal.dart';

class CategoryMealProvider with ChangeNotifier {
  List<Meals> _meals = [];
  int _selectedIndex = -1;
  String _currentCategory = '';

  List<Meals> get meals => _meals;
  int get selectedIndex => _selectedIndex;
  String get currentCategory => _currentCategory;

  Future<void> fetchMeals(String category) async {
    _currentCategory = category;
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final mealData = Meal.fromJson(data);
      _meals = mealData.meals ?? [];
      notifyListeners();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  void selectItem(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
