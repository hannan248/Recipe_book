import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _favorites = [];
  bool _isLoading = true;

  List<String> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();
    final User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await _firestore.collection('favorites').doc(user.uid).get();
      if (snapshot.exists) {
        _favorites = List<String>.from(snapshot.get('items'));
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(String item) async {
    final User? user = _auth.currentUser;
    if (user != null && !_favorites.contains(item)) {
      _favorites.add(item);
      await _firestore.collection('favorites').doc(user.uid).set({'items': _favorites});
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String item) async {
    final User? user = _auth.currentUser;
    if (user != null && _favorites.contains(item)) {
      _favorites.remove(item);
      await _firestore.collection('favorites').doc(user.uid).set({'items': _favorites});
      notifyListeners();
    }
  }

  bool isFavorite(String item) {
    return _favorites.contains(item);
  }
}
