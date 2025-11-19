import 'package:flutter/foundation.dart';             // Fournit ChangeNotifier (mécanisme pour notifier l’UI des changements)
import '../models/product.dart';                      // Import du modèle Product
import '../services/api_service.dart';                // Import du service qui gère les appels API

class ProductsViewModel extends ChangeNotifier {      // ViewModel qui gère l’état des produits et notifie l’UI extends ChangeNotifier pour pouvoir utiliser notifyListeners et pour alerter l'ui du changement des données
  final ApiService _apiService = ApiService();        // Instance privée du service API (utilisée pour fetch les données)

  // --------------------
  // États des données
  // --------------------
  List<Product> _products = [];                       // Liste privée de produits (données récupérées depuis l’API)
  bool _isLoading = false;                            // Indique si un chargement est en cours (true = spinner affiché)
  String _errorMessage = '';                          // Message d’erreur (chaîne vide = pas d’erreur)

  // Getters publics
  List<Product> get products => _products;            // Expose la liste en lecture seule (pas de setter public)
  bool get isLoading => _isLoading;                   // Expose l’état de chargement à l’UI
  String get errorMessage => _errorMessage;           // Expose le dernier message d’erreur
  bool get hasError => _errorMessage.isNotEmpty;      // Pratique : vrai s’il y a un message d’erreur non vide

  // Constructeur - chargement automatique
  ProductsViewModel() {                               // Constructeur du ViewModel
    loadProducts();                                   // Déclenche un premier chargement (attention au double fetch, voir note)
  }

  // Chargement des produits
  Future<void> loadProducts() async {                 // Méthode asynchrone : charge et met à jour l’état
    if (_isLoading) return;                           // Garde-fou : si un fetch est déjà en cours, on sort

    _isLoading = true;                                // Passe en mode "chargement…"
    _errorMessage = '';                               // Réinitialise l’erreur précédente
    notifyListeners();                                // Notifie l’UI (pour afficher le spinner par ex.)

    try {
      _products = await _apiService.fetchProducts();  // Appel réseau (await) : récupère les produits via le service
    } catch (error) {
      _errorMessage = 'Impossible de charger les produits'; // En cas d’échec : fixe un message d’erreur pour l’UI
    }

    _isLoading = false;                               // Fin du chargement (réussi ou non)
    notifyListeners();                                // Notifie l’UI (masquer le spinner, afficher liste ou erreur)
  }
}