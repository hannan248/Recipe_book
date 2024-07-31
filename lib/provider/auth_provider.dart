import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _user = _auth.currentUser;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
        });
        _user = user;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('The email address is already in use by another account.');
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = 'Sign in failed: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else {
        errorMessage = 'Failed to send password reset email: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> hasUserInterests(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('interest')
          .doc(userId)
          .get();
      return docSnapshot.exists;
    } catch (e) {
      throw Exception('Error checking user interests: $e');
    }
  }

  Future<String> getUserDetail(String userId) async {
    try {
      final doc = await _firestore.collection("users").doc(userId).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? 'No name found';
      } else {
        return 'User does not exist';
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      return 'Error fetching user details';
    }
  }
}
