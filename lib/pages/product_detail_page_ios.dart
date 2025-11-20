import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/product.dart';

class ProductDetailPageIOS extends StatelessWidget {
  final int productId;

  const ProductDetailPageIOS({super.key, required this.productId});

  void _shareProduct(BuildContext context, Product product) {
    final String message = "Regarde ce produit incroyable : ${product.title} à seulement ${product.formattedPrice} !";
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailViewmodel()..fetchProductDetail(productId),
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Détail du Produit'),
          trailing: Consumer<ProductDetailViewmodel>(
            builder: (context, viewModel, child) {
              if (viewModel.product == null) return const SizedBox();
              return CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.share),
                onPressed: () => _shareProduct(context, viewModel.product!),
              );
            },
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Zone de contenu scrollable
              Expanded(
                child: Consumer<ProductDetailViewmodel>(
                  builder: (context, viewmodel, child) {
                    if (viewmodel.isLoading) {
                      return const Center(child: CupertinoActivityIndicator(radius: 15));
                    } else if (viewmodel.errorMessage != null) {
                      return Center(
                        child: Text(
                          viewmodel.errorMessage!,
                          style: const TextStyle(color: CupertinoColors.systemRed),
                        ),
                      );
                    } else if (viewmodel.product != null) {
                      final product = viewmodel.product!;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image sur fond blanc arrondi
                            Container(
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: CachedNetworkImage(
                                  imageUrl: product.image,
                                  placeholder: (context, url) => const CupertinoActivityIndicator(),
                                  errorWidget: (context, url, error) => const Icon(CupertinoIcons.exclamationmark_circle, color: CupertinoColors.systemRed),
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Titre
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.black,
                                decoration: TextDecoration.none, // Important hors de Material
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Prix
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                color: CupertinoColors.activeGreen,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Description
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: CupertinoColors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.black,
                                decoration: TextDecoration.none,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: Text('Produit non trouvé'));
                    }
                  },
                ),
              ),

              // Bouton d'action en bas (Style iOS sticky button)
              Consumer<ProductDetailViewmodel>(
                builder: (context, viewModel, child) {
                  final product = viewModel.product;
                  final cart = Provider.of<CartViewModel>(context, listen: false);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border(top: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: product == null
                            ? null
                            : () {
                                cart.addToCart(product);
                                // Feedback style iOS (Alert Dialog) car pas de SnackBar natif
                                showCupertinoDialog(
                                  context: context,
                                  builder: (ctx) => CupertinoAlertDialog(
                                    title: const Text("Ajouté !"),
                                    content: Text("${product.title} a été ajouté au panier."),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text('OK'),
                                        onPressed: () => Navigator.pop(ctx),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        child: const Text('Ajouter au panier'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}