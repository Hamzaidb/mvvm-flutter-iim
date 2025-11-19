import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import 'cart_viewmodel.dart'; // Pour accéder à la classe CartItem

class OrdersViewModel extends ChangeNotifier {
  List<Order> _orders = [];
  List<Order> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  OrdersViewModel() {
    loadOrders();
  }

  // Charger l'historique depuis le téléphone
  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('orders')) return;

    final String ordersString = prefs.getString('orders')!;
    final List<dynamic> ordersJson = json.decode(ordersString);
    _orders = ordersJson.map((json) => Order.fromJson(json)).toList();
    notifyListeners();
  }

  // 🔥 MOCK PAIEMENT + CRÉATION COMMANDE
  Future<bool> addOrder(List<CartItem> cartItems, double total) async {
    _isLoading = true;
    notifyListeners();

    // ⏳ MOCK : On simule un délai réseau de 2 secondes (Stripe/PayPal)
    await Future.delayed(const Duration(seconds: 2));

    try {
      final newOrder = Order(
        id: 'CMD-${DateTime.now().millisecondsSinceEpoch}',
        totalAmount: total,
        date: DateTime.now(),
        items: cartItems.map((ci) => OrderItem(
          product: ci.product, 
          quantity: ci.quantity
        )).toList(),
      );

      _orders.insert(0, newOrder); // Ajout en haut de la liste

      // Sauvegarde locale
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(_orders.map((e) => e.toJson()).toList());
      await prefs.setString('orders', encodedData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}