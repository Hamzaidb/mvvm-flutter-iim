import 'package:flutter/foundation.dart';
import '../models/product.dart';

// 📦 Nouvelle classe pour gérer le couple (Produit + Quantité)
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  // Prix total de cette ligne (ex: 2 x 50€ = 100€)
  double get totalAmount => product.price * quantity;
}

class CartViewModel extends ChangeNotifier {
  // On utilise une Map pour retrouver facilement un produit par son ID
  // Clé = ID du produit, Valeur = CartItem
  final Map<int, CartItem> _items = {};

  // On transforme la Map en Liste pour l'affichage facile dans la vue
  List<CartItem> get items => _items.values.toList();

  // ➕ Ajouter (Adapté : incrémente si existe déjà, sinon crée)
  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  // ➖ Retirer une unité (Adapté : décrémente, ou supprime si qté=1)
  // J'ai renommé removeFromCart -> removeSingleItem pour être plus précis
  void removeSingleItem(Product product) {
    if (!_items.containsKey(product.id)) return;

    if (_items[product.id]!.quantity > 1) {
      _items[product.id]!.quantity--;
    } else {
      _items.remove(product.id);
    }
    notifyListeners();
  }

  // 🗑️ Supprimer totalement la ligne (Adapté de clearItem)
  void deleteItem(Product product) {
    _items.remove(product.id);
    notifyListeners();
  }

  // 💰 Prix total (Adapté : prend en compte les quantités)
  double get totalPrice {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.totalAmount;
    });
    return total;
  }

  // 🧹 Vider tout (Inchangé)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // 🔢 Nombre total d'articles (Adapté : somme des quantités)
  int get totalCount {
    var count = 0;
    _items.forEach((key, item) {
      count += item.quantity;
    });
    return count;
  }
}