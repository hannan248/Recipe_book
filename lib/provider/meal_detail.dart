
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_book/model/detail_meal.dart';

class MealProvider with ChangeNotifier {
  DetailMeal? _detailMeal;
  bool _isLoading = false;

  DetailMeal? get detailMeal => _detailMeal;
  bool get isLoading => _isLoading;

  Future<void> fetchMeals(String mealName) async {
    _isLoading = true;
    notifyListeners();

    final url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=$mealName';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _detailMeal = DetailMeal.fromJson(data);
      } else {
        throw Exception('Failed to load meals');
      }
    } catch (error) {
      print(error);
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
