import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InterestProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserInterests(String userId, List<String> interests) async {
    try {
      await _firestore
          .collection('interest')
          .doc(userId)
          .set({'interests': interests}, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      print("Error saving interests: $e");
      throw e;
    }
  }

  Future<List<String>> getUserInterests(String userId) async {
    try {
      final doc = await _firestore.collection('interest').doc(userId).get();
      if (doc.exists) {
        return List<String>.from(doc.data()?['interests'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print("Error retrieving interests: $e");
      throw e;
    }
  }

}
