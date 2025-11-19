import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductDetailViewmodel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Product? _product;
  bool _isLoading = false;
  String? _errorMessage;

  Product? get product => _product;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProductDetail(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _product = await _apiService.fetchProductById(productId);
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement du produit : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

