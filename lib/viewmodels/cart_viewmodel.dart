import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartViewModel extends ChangeNotifier {
  final List<Product> _cartItems = [];

  List<Product> get cartItems => List.unmodifiable(_cartItems);

  void addToCart(Product product) {
    _cartItems.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  void clearItem(Product product) {
    _cartItems.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.price);
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  int get totalCount {
    return _cartItems.length;
  }



}