import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';

// Imports de vos modèles et viewmodels
import '../viewmodels/products_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/product.dart'; 
import '../widgets/drawer.dart';

// --- PAGE PRINCIPALE ---

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              // En-tête avec Panier (Plus de recherche ici)
              HomeHeader(onMenuClick: () => _scaffoldKey.currentState?.openDrawer()),
              
              const SizedBox(height: 10),
              
              // Bannière Promo
              const DiscountBanner(),
              
              // Catégories Dynamiques (API)
              const Categories(),
                            
              const SizedBox(height: 20),
              
              // Produits Populaires (API)
              const PopularProducts(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- COMPOSANTS ---

class HomeHeader extends StatelessWidget {
  final VoidCallback onMenuClick;

  const HomeHeader({Key? key, required this.onMenuClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // On écoute le panier pour le badge
    final cartCount = context.watch<CartViewModel>().totalCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton Menu à gauche
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: onMenuClick,
          ),
          
          // On utilise un Spacer pour pousser les icônes à droite
          // ou on peut centrer un titre ici si voulu
          const Spacer(), 

          // Bouton Panier Connecté
          IconBtnWithCounter(
            svgSrc: cartIcon,
            numOfitem: cartCount, //  Dynamique
            press: () => context.go('/cart'), //  Navigation
          ),
          
          const SizedBox(width: 8),
          
      
        ],
      ),
    );
  }
}


class IconBtnWithCounter extends StatelessWidget {
  const IconBtnWithCounter({
    Key? key,
    required this.svgSrc,
    this.numOfitem = 0,
    required this.press,
  }) : super(key: key);

  final String svgSrc;
  final int numOfitem;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF979797).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.string(svgSrc),
          ),
          if (numOfitem != 0)
            Positioned(
              top: -3,
              right: 0,
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4848),
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.5, color: Colors.white),
                ),
                child: Center(
                  child: Text(
                    "$numOfitem",
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) return const SizedBox();

        // On ignore "Tous" pour n'afficher que les catégories spécifiques
        final categories = viewModel.categories.where((c) => c != 'Tous').toList();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            // On génère une carte pour chaque catégorie
            children: List.generate(
              categories.length,
              (index) => CategoryCard(
                icon: _getIconForCategory(categories[index]), //  Choix dynamique
                text: categories[index].toUpperCase(),
                press: () {
                  viewModel.filterByCategory(categories[index]);
                  context.go('/products');
                },
              ),
            ),
          ),
        );
      },
    );
  }

  //  Méthode qui associe le nom de la catégorie (API) à l'icône SVG
  String _getIconForCategory(String category) {
    switch (category) {
      case 'electronics':
        return electronicsIcon;
      case 'jewelery':
        return jeweleryIcon;
      case "men's clothing":
        return menClothingIcon;
      case "women's clothing":
        return womenClothingIcon;
      default:
        return discoverIcon; // Icône par défaut
    }
  }
}
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.press,
  }) : super(key: key);

  final String icon, text;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: SizedBox(
        width: 55, // Largeur fixe pour alignement
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECDF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.string(icon),
            ),
            const SizedBox(height: 5),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10))
          ],
        ),
      ),
    );
  }
}


class PopularProducts extends StatelessWidget {
  const PopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Produits Populaires",
            press: () => context.go('/products'), // Voir tout
          ),
        ),
        const SizedBox(height: 20),
        Consumer<ProductsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) return const CircularProgressIndicator();
            
            final products = viewModel.products.take(10).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...List.generate(
                    products.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ProductCard(
                        product: products[index],
                        onPress: () => context.go('/products/${products[index].id}'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    this.width = 140,
    this.aspectRetio = 1.02,
    required this.product,
    required this.onPress,
  }) : super(key: key);

  final double width, aspectRetio;
  final Product product; 
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.02,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF979797).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                // Image réseau mise en cache
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${product.price.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF7643),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(
                      product.rating.rate.toString(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- COMPOSANT ---

class DiscountBanner extends StatelessWidget {
  const DiscountBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Récupération de l'utilisateur depuis le Provider
    final user = Provider.of<AppAuthProvider>(context).user;
    
    // 2. Logique pour le nom d'affichage
    String displayName = "Invité";
    if (user != null && user.email != null) {
      // Prend ce qui est avant le @ et met la première lettre en majuscule
      displayName = user.email!.split('@')[0];
      displayName = displayName[0].toUpperCase() + displayName.substring(1);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(color: Colors.white),
          children: [
            const TextSpan(text: "Bienvenue\n"),
            TextSpan(
              text: displayName, // Utilisation de la variable dynamique
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.title,
    required this.press,
  }) : super(key: key);

  final String title;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: press,
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text("Voir plus"),
        ),
      ],
    );
  }
}

const cartIcon =
    '''<svg width="22" height="18" viewBox="0 0 22 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M18.4524 16.6669C18.4524 17.403 17.8608 18 17.1302 18C16.3985 18 15.807 17.403 15.807 16.6669C15.807 15.9308 16.3985 15.3337 17.1302 15.3337C17.8608 15.3337 18.4524 15.9308 18.4524 16.6669ZM11.9556 16.6669C11.9556 17.403 11.3631 18 10.6324 18C9.90181 18 9.30921 17.403 9.30921 16.6669C9.30921 15.9308 9.90181 15.3337 10.6324 15.3337C11.3631 15.3337 11.9556 15.9308 11.9556 16.6669ZM20.7325 5.7508L18.9547 11.0865C18.6413 12.0275 17.7685 12.6591 16.7846 12.6591H10.512C9.53753 12.6591 8.66784 12.0369 8.34923 11.1095L6.30162 5.17154H20.3194C20.4616 5.17154 20.5903 5.23741 20.6733 5.35347C20.7563 5.47058 20.7771 5.61487 20.7325 5.7508ZM21.6831 4.62051C21.3697 4.18031 20.858 3.91682 20.3194 3.91682H5.86885L5.0002 1.40529C4.70961 0.564624 3.92087 0 3.03769 0H0.621652C0.278135 0 0 0.281266 0 0.62736C0 0.974499 0.278135 1.25472 0.621652 1.25472H3.03769C3.39158 1.25472 3.70812 1.48161 3.82435 1.8183L4.83311 4.73657C4.83622 4.74598 4.83934 4.75434 4.84245 4.76375L7.17339 11.5215C7.66531 12.9518 9.00721 13.9138 10.512 13.9138H16.7846C18.304 13.9138 19.6511 12.9383 20.1347 11.4859L21.9135 6.14917C22.0847 5.63369 21.9986 5.06175 21.6831 4.62051Z" fill="#7C7C7C"/>
</svg>
''';

// --- SVG ICONS (Gardés du modèle original) ---
// --- NOUVELLES ICÔNES CATÉGORIES ---

const electronicsIcon = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M15 2H6C4.89543 2 4 2.89543 4 4V20C4 21.1046 4.89543 22 6 22H18C19.1046 22 20 21.1046 20 20V7L15 2Z" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M14 2V8H20" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M12 18H12.01" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

const jeweleryIcon = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M6 3H18L22 9L12 22L2 9L6 3Z" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M11 3L8 9L12 22L16 9L13 3" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M2 9H22" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

const menClothingIcon = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M20.38 3.46L16 2L12 4L8 2L3.62 3.46C3.2 3.6 2.92 4 3 4.44L5 10L3 21H21L19 10L21 4.44C21.08 4 20.8 3.6 20.38 3.46Z" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M12 4V21" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

const womenClothingIcon = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 2L8 6H4L6 14H18L20 6H16L12 2Z" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M6 14L4 22H20L18 14" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M12 14V22" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

const discoverIcon = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 22C17.5228 22 22 17.5228 22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22Z" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M12 16L16 12L12 8" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M8 12H16" stroke="#FF7643" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';