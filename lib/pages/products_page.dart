import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/products_viewmodel.dart';
import '../widgets/drawer.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  
  // Controller pour le champ de recherche
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Consumer<CartViewModel>(
            builder: (context, cart, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
                      onPressed: () => context.go('/cart'),
                    ),
                    if (cart.totalCount > 0)
                      Positioned(
                        right: 3,
                        top: 3,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4848),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '${cart.totalCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<ProductsViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // 1. Barre de Recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF979797).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => viewModel.search(value),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: "Rechercher un produit...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.search('');
                            },
                          ) 
                        : null,
                    ),
                  ),
                ),
              ),

              // 2. Filtres
              if (!viewModel.isLoading && !viewModel.hasError)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: viewModel.categories.map((category) {
                      final isSelected = viewModel.selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(category.toUpperCase()),
                          selected: isSelected,
                          selectedColor: const Color(0xFFFF7643).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFFFF7643) : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFFF7643) : Colors.grey.shade300,
                          ),
                          onSelected: (bool selected) {
                             viewModel.filterByCategory(selected ? category : 'Tous');
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 10),

              // 3. Grille de Produits Responsive
              Expanded(
                child: Builder(builder: (context) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (viewModel.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 10),
                          Text(viewModel.errorMessage),
                          TextButton(onPressed: viewModel.loadProducts, child: const Text("Réessayer"))
                        ],
                      ),
                    );
                  }
                  if (viewModel.products.isEmpty) {
                    return const Center(child: Text("Aucun produit trouvé."));
                  }

                  //  CALCUL DU NOMBRE DE COLONNES RESPONSIVE
                  double screenWidth = MediaQuery.of(context).size.width;
                  int crossAxisCount = 2; // Par défaut (Mobile)

                  if (screenWidth > 1100) {
                    crossAxisCount = 5; // Grand écran / Desktop
                  } else if (screenWidth > 600) {
                    crossAxisCount = 3; // Tablette
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: viewModel.products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount, //  Utilisation de la valeur calculée
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: viewModel.products[index],
                        onPress: () => context.go('/products/${viewModel.products[index].id}'),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- Widget Carte Produit ---
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onPress;

  const ProductCard({
    super.key,
    required this.product,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image sur fond BLANC
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Hero(
                tag: product.id,
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          // Titre
          Text(
            product.title,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Prix et Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.formattedPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF7643),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF979797).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border, size: 12, color: Color(0xFFFF4848)),
              ),
            ],
          )
        ],
      ),
    );
  }
}