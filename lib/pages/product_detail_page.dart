import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  void _shareProduct(BuildContext context, Product product) {
    // On construit le message à envoyer
    final String message = "Regarde ce produit incroyable : ${product.title} à seulement ${product.formattedPrice} !";
    
    // Lance le partage natif (Android/iOS)
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      //   On crée le ViewModel et on lance le chargement immédiatement (..fetchProductDetail)
      create: (_) => ProductDetailViewmodel()..fetchProductDetail(productId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détail du Produit'),
          actions: [Consumer<ProductDetailViewmodel>(
              builder: (context, viewModel, child) {
                // On n'affiche le bouton que si le produit est chargé
                if (viewModel.product == null) return const SizedBox();
                
                return IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareProduct(context, viewModel.product!),
                );
              },
            ),
          ],
        ),
        body: Consumer<ProductDetailViewmodel>(
          builder: (context, viewmodel, child) {
            // 1️⃣ État de chargement
            if (viewmodel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } 
            // 2️⃣ État d'erreur
            else if (viewmodel.errorMessage != null) {
              return Center(child: Text(viewmodel.errorMessage!));
            } 
            // 3️⃣ Affichage du produit
            else if (viewmodel.product != null) {
              final product = viewmodel.product!;
              return SingleChildScrollView( // Ajout du scroll pour les petits écrans
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(product.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, color: Colors.green)),
                    const SizedBox(height: 16),
                    const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(product.description),
                    const SizedBox(height: 80), // Espace pour ne pas que le texte soit caché par le bouton
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Produit non trouvé'));
            }
          },
        ),
        
        //   CORRECTION MAJEURE ICI :
        // On utilise Consumer<ProductDetailViewmodel> au lieu de CartViewModel.
        // Pourquoi ? Pour que le bouton se reconstruise quand le produit est chargé (quand isLoading passe à false).
        floatingActionButton: Consumer<ProductDetailViewmodel>(
          builder: (context, viewModel, child) {
            final product = viewModel.product;
            
            // On récupère le panier sans l'écouter (listen: false) car on veut juste appeler sa méthode addToCart
            final cart = Provider.of<CartViewModel>(context, listen: false);

            return FloatingActionButton.extended(
              onPressed: product == null 
                  ? null 
                  : () {
                      cart.addToCart(product);
                      
                      // Feedback visuel (SnackBar)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.title} ajouté au panier !'),
                          duration: const Duration(seconds: 1),
                          /*action: SnackBarAction(
                            label: 'ANNULER',
                            onPressed: () => cart.removeFromCart(product),
                          ),*/
                        ),
                      );
                    },
              label: const Text('Ajouter au panier'),
              icon: const Icon(Icons.add_shopping_cart),
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            );
          },
        ),
      ),
    );
  }
}