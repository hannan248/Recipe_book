import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_book/model/catergory.dart';

class CategoryProvider with ChangeNotifier {
  List<Categories>? _categories;
  bool _isLoading = true;
  String _errorMessage = '';

  List<Categories>? get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    const url = 'https://www.themealdb.com/api/json/v1/1/categories.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categoryModel = CategoryModel.fromJson(data);
        _categories = categoryModel.categories;
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
