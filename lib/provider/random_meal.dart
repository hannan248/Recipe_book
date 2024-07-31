import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/detail_meal.dart';

class RandomMealProvider with ChangeNotifier {
  final String _baseUrl = 'https://www.themealdb.com/api/json/v1/1/random.php';

  Future<List<Meals>> fetchMeals() async {
    List<Meals> allMeals = [];

    try {
      for (int i = 0; i < 6; i++) {
        final response = await http.get(Uri.parse(_baseUrl));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final detailMeal = DetailMeal.fromJson(data);

          if (detailMeal.meals != null && detailMeal.meals!.isNotEmpty) {
            allMeals.add(detailMeal.meals!.first);
          } else {
            throw Exception('No meals found in the response');
          }
        } else {
          throw Exception('Failed to load meals');
        }
      }


      allMeals = allMeals.toSet().toList();

      if (allMeals.length < 6) {
        throw Exception('Not enough unique meals found');
      }

      return allMeals;
    } catch (e) {
      throw Exception('An error occurred: $e');
    }

  }

}
