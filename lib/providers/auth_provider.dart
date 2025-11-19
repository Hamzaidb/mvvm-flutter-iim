import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Écoute les changements d'état Firebase (connexion/déconnexion)
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // Prévient le routeur qu'il faut rafraîchir
    });
  }

  // Méthode de déconnexion accessible partout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}