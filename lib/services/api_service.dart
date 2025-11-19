import 'dart:convert';                         // Permet de transformer du JSON <-> objets Dart (json.encode/json.decode)
import 'package:http/http.dart' as http;       // Package officiel pour faire des requêtes HTTP (GET, POST, etc.)
import '../models/product.dart';               // Import du modèle Product (on en a besoin pour transformer la réponse JSON en objets)

class ApiService {                             // Classe service qui centralise les appels API
  static const String baseUrl = 'https://fakestoreapi.com';
  // URL de base de ton API (constante car elle ne change pas)

  // Méthode pour récupérer tous les produits
  Future<List<Product>> fetchProducts() async {
    // Retourne un Future qui contiendra plus tard une liste de Product

    try {                                      // On essaye (et on attrape les erreurs avec le catch plus bas)
      final response = await http.get(         // On fait une requête HTTP GET (asynchrone donc on met await)
        Uri.parse('$baseUrl/products'),        // On construit l’URL complète → https://fakestoreapi.com/products
        headers: {'Content-Type': 'application/json'},
        // On précise qu’on attend du JSON en réponse
      ).timeout(const Duration(seconds: 10));  // Si la requête dure plus de 10 secondes → TimeoutException

      if (response.statusCode == 200) {        // Si le serveur répond OK (200)
        final List<dynamic> jsonData = json.decode(response.body);
        // On décode le corps de la réponse (string JSON) en une liste dynamique (List<dynamic>)

        return jsonData
            .map((json) => Product.fromJson(json))
            .toList();
        // On transforme chaque objet JSON de la liste en Product grâce à fromJson
        // Puis on renvoie la liste de Product
      } else {                                 // Si le serveur répond avec un code ≠ 200 (erreur)
        throw Exception('Erreur serveur : ${response.statusCode}');
        // On jette une exception explicite
      }
    } catch (e) {                              // Si une erreur est attrapée (réseau, timeout, parse…)
      throw Exception('Impossible de charger les produits : $e');
      // On jette une nouvelle exception avec un message plus clair
    }
  }
}