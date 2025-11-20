import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AppAuthProvider() {
    // Écoute les changements d'état Firebase (connexion/déconnexion)
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // Prévient le routeur qu'il faut rafraîchir
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      // 1. Déclencher le flux d'authentification Google (fenêtre native)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Si l'utilisateur annule la fenêtre, on arrête tout
      if (googleUser == null) return;

      // 2. Obtenir les détails d'authentification (tokens)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Créer un identifiant unique pour Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Se connecter à Firebase avec ces identifiants
      await _firebaseAuth.signInWithCredential(credential);
      
    } catch (e) {
      print("Erreur Google Sign-In: $e");
      rethrow; // On renvoie l'erreur pour l'afficher dans l'UI si besoin
    }
  }

  // Méthode de déconnexion accessible partout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}