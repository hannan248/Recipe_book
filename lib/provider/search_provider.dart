import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recipe_book/model/detail_meal.dart';  // Ensure this path is correct

class SearchProvider with ChangeNotifier {
  String _searchQuery = '';
  List<Meals> _results = [];
  Future<List<Meals>>? _futureResults;

  String get searchQuery => _searchQuery;
  List<Meals> get results => _results;
  Future<List<Meals>>? get futureResults => _futureResults;

  // Method to update search query and fetch new results
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _futureResults = _fetchResults();
    notifyListeners();
  }

  // Method to fetch results from API
  Future<List<Meals>> _fetchResults() async {
    final url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=$_searchQuery';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detailMeal = DetailMeal.fromJson(data);
        _results = detailMeal.meals ?? [];
        return _results;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
}
