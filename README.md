# Guide Architecture Flutter - Pattern MVVM avec Provider

Ce guide explique comment structurer une application Flutter en utilisant le pattern **MVVM (Model-View-ViewModel)** avec **Provider** pour la gestion d'état.

##  Architecture générale

```
lib/
├── models/          # Modèles de données
├── services/        # Services (API, base de données, etc.)
├── viewmodels/      # ViewModels (logique métier)
├── views/           # Vues/Écrans
├── widgets/         # Composants réutilisables
└── main.dart
```

## Étape 1 : Créer le modèle de données

Le **modèle** représente la structure de vos données. Il contient uniquement les données et les méthodes pour les transformer.

### `models/product.dart`

```dart
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  // Conversion JSON → Objet Dart
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: Rating.fromJson(json['rating']),
    );
  }

  // Méthodes utilitaires pour l'affichage
  String get formattedPrice => '${price.toStringAsFixed(2)} €';
  String get starsDisplay => '⭐ ${rating.rate.toStringAsFixed(1)} (${rating.count})';
}

class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: (json['rate'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}
```

### 🎯 Points clés des modèles

- **Immutables** : tous les champs sont `final`
- **Factory constructors** : pour convertir JSON en objets Dart
- **Getters calculés** : pour formater les données d'affichage
- **Pas de logique métier** : juste des données et leur transformation

---

## Étape 2 : Créer le service API

Le **service** gère les interactions avec les sources de données externes (API, base de données, etc.).

### `services/api_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Impossible de charger les produits : $e');
    }
  }
}
```

### 🎯 Points clés des services

- **Responsabilité unique** : gestion des données externes
- **Gestion d'erreurs** : try/catch avec messages explicites
- **Timeout** : éviter les blocages sur réseau lent
- **Types de retour clairs** : `Future<List<Product>>`

---

## Étape 3 : Créer le ViewModel

Le **ViewModel** fait le lien entre les données (modèles/services) et la vue. Il gère l'état et la logique métier.

### `viewmodels/products_viewmodel.dart`

```dart
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // État privé
  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters publics (lecture seule)
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  // Chargement automatique à l'instanciation
  ProductsViewModel() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    // Éviter les appels multiples simultanés
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      _products = await _apiService.fetchProducts();
    } catch (error) {
      _setError('Impossible de charger les produits');
    }

    _setLoading(false);
  }

  // Méthodes privées pour gérer l'état
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
```

### 🎯 Points clés du ViewModel

- **Hérite de `ChangeNotifier`** : pour notifier l'UI des changements
- **État privé** : données encapsulées avec getters publics
- **`notifyListeners()`** : déclenche la reconstruction de l'UI
- **Gestion d'état claire** : loading, error, success
- **Méthodes privées** : pour organiser le code

---

## Étape 4 : Créer la vue

La **vue** affiche l'UI et réagit aux changements d'état du ViewModel.

### `views/products_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/products_viewmodel.dart';
import '../widgets/drawer.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Consumer<ProductsViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(viewModel);
        },
      ),
    );
  }

  Widget _buildBody(ProductsViewModel viewModel) {
    if (viewModel.isLoading) {
      return _buildLoadingState();
    }

    if (viewModel.hasError) {
      return _buildErrorState(viewModel);
    }

    return _buildSuccessState(viewModel);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des produits...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProductsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: viewModel.loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(ProductsViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.products.length,
      itemBuilder: (context, index) {
        final product = viewModel.products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product.image),
            const SizedBox(width: 16),
            Expanded(child: _buildProductInfo(product)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            product.category.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.formattedPrice,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          product.starsDisplay,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
```

### 🎯 Points clés de la vue

- **`Consumer<ProductsViewModel>`** : écoute les changements du ViewModel
- **États séparés** : méthodes dédiées pour loading/error/success
- **Widgets extraits** : code organisé et réutilisable
- **UI responsive** : gestion des erreurs d'image, texte débordant

---

## Étape 5 : Configuration dans main.dart

### `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/products_viewmodel.dart';
import 'views/products_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsViewModel()),
        // Ajouter d'autres ViewModels ici
      ],
      child: MaterialApp(
        title: 'Mon App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const ProductsPage(),
        routes: {
          '/products': (context) => const ProductsPage(),
        },
      ),
    );
  }
}
```

---

## 🎯 Avantages de cette architecture

### ✅ Séparation des responsabilités
- **Model** : structure des données
- **Service** : accès aux données
- **ViewModel** : logique métier et état
- **View** : affichage et interactions utilisateur

### ✅ Testabilité
- Chaque couche peut être testée indépendamment
- Mocking facile des services dans les tests

### ✅ Maintenabilité
- Code organisé et structuré
- Changements localisés (modifier l'API n'impacte que le service)

### ✅ Réactivité
- L'UI se met à jour automatiquement via `notifyListeners()`
- Pas de `setState()` manuel

---

## Dépendances nécessaires

Ajoutez dans votre `pubspec.yaml` :

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  http: ^1.1.0
  cached_network_image: ^3.3.0
```