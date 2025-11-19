import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/cart_viewmodel.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailViewmodel()..fetchProductDetail(productId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détail du Produit'),
        ),
        body: Consumer<ProductDetailViewmodel>(
          builder: (context, viewmodel, child) {
            if (viewmodel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewmodel.errorMessage != null) {
              return Center(child: Text(viewmodel.errorMessage!));
            } else if (viewmodel.product != null) {
              final product = viewmodel.product!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.image,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      height: 200,
                    ),
                    const SizedBox(height: 16),
                    Text(product.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, color: Colors.green)),
                    const SizedBox(height: 16),
                    Text(product.description),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Produit non trouvé'));
            }
          },
        ),
        
        floatingActionButton: Consumer<CartViewModel>(
        builder: (context, cart, child) {
          final product = Provider.of<ProductDetailViewmodel>(context, listen: false).product;

         return FloatingActionButton.extended(
            onPressed: product == null 
                ? null // Si le produit charge encore, bouton désactivé
                : () {
                    cart.addToCart(product); // 🔥 Action d'ajout
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.title} ajouté au panier !'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'ANNULER',
                          onPressed: () => cart.removeFromCart(product),
                        ),
                      ),
                    );
                  },
            label: const Text('Ajouter au panier'),
            icon: const Icon(Icons.add_shopping_cart),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          );
        }
        ,)
      ),
       
    );
  }
}