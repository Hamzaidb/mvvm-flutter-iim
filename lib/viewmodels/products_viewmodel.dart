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

  //   NOUVEAUX ÉTATS POUR LE FILTRE
  String _searchQuery = '';
  String _selectedCategory = 'Tous';

  // Getters publics
  // MODIFIÉ : Retourne la liste filtrée au lieu de la liste brute
  List<Product> get products {
    return _products.where((product) {
      // 1. Filtre par texte (insensible à la casse)
      final matchesSearch = product.title.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // 2. Filtre par catégorie
      final matchesCategory = _selectedCategory == 'Tous' || product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }
                                                      // Expose la liste en lecture seule (pas de setter public)
  bool get isLoading => _isLoading;                   // Expose l’état de chargement à l’UI
  String get errorMessage => _errorMessage;           // Expose le dernier message d’erreur
  bool get hasError => _errorMessage.isNotEmpty;      // Pratique : vrai s’il y a un message d’erreur non vide

  //   GETTER CATÉGORIES : Extrait dynamiquement les catégories uniques
  List<String> get categories {
    if (_products.isEmpty) return ['Tous'];
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['Tous', ...cats];
  }
  
  String get selectedCategory => _selectedCategory;

  // Constructeur - chargement automatique
  ProductsViewModel() {                               // Constructeur du ViewModel
    loadProducts();                                   // Déclenche un premier chargement (attention au double fetch, voir note)
  }

  //   ACTIONS UTILISATEUR
  void search(String query) {
    _searchQuery = query;
    notifyListeners(); // Notifie l'UI pour rafraîchir la liste filtrée
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    notifyListeners(); // Notifie l'UI pour rafraîchir la liste filtrée
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