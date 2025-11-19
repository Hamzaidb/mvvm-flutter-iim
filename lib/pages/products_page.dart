import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/products_viewmodel.dart';
import '../models/product.dart';
import '../widgets/drawer.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}
// Le _ ici rend la classe d'état privée au fichier
// Elle étend State<ProductsPage> : c’est le state associé au widget ProductsPage.
// C’est ici qu’on gère le cycle de vie et les données locales à l’écran.
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
      // Ici on dit : "Je veux écouter ProductsViewModel"
      // => Dès que notifyListeners() est appelé dans le ViewModel,
      //    ce builder sera reconstruit automatiquement.
      body: Consumer<ProductsViewModel>(
        // Consumer c'est un genre de await de widget
        // builder = fonction qui décrit quoi afficher selon l’état du ViewModel
        // context = contexte Flutter habituel
        // viewModel = instance de ProductsViewModel (accès à products, isLoading, etc.)
        // child = widget statique (non utilisé ici, mais utile si on veut éviter de rebuild un widget lourd)
        builder: (context, viewModel, child) {

          // 1️⃣ Cas où les données sont en train de charger
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(), // → affiche un loader
            );
          }

          // 2️⃣ Cas où une erreur est survenue
          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red), // icône d’erreur
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage), // affiche le message d’erreur du ViewModel
                  const SizedBox(height: 16),
                  ElevatedButton(
                    // si l’utilisateur clique : on relance loadProducts()
                    onPressed: () => viewModel.loadProducts(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // 3️⃣ Cas où les données ont bien été chargées
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.products.length, // longueur de la liste des produits
            itemBuilder: (context, index) {
              final product = viewModel.products[index]; // on récupère un produit de la liste

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [

                      // 🖼️ Image du produit (avec cache et gestion erreur)
                      CachedNetworkImage(
                        imageUrl: product.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // ℹ️ Infos du produit (titre, prix, étoiles)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // titre du produit
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

                            // prix formaté
                            Text(
                              product.formattedPrice,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // affichage des étoiles
                            Text(
                              product.starsDisplay,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}