import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vraiauth/viewmodels/cart_viewmodel.dart';
import 'providers/auth_provider.dart';
import 'router.dart';

// ViewModels imports
import 'viewmodels/products_viewmodel.dart';

/* Pages imports
import 'pages/home_page.dart';
import 'pages/second_page.dart';
import 'pages/third_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/products_page.dart'; // 🔥 AJOUT : Nouvelle page produits
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 🧠 CONFIGURATION MVVM : Tous les ViewModels disponibles dans l'app
      providers: [
        // 🛍️ ViewModel des produits (MVVM)
        ChangeNotifierProvider(create: (_) => ProductsViewModel()),
        // 🔥 Autres ViewModels à ajouter plus tard (auth, panier, etc.)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ProxyProvider<AuthProvider, AppRouter>(
          update: (_, authProvider, __) => AppRouter(authProvider),
        ),
      ],
      child: Builder(
        builder: (context) {
        final GoRouter router = Provider.of<AppRouter>(context).router;

        return MaterialApp.router(
          title: 'ShopFlutter E-commerce',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
          ),
          routerConfig: router,
        );
          
        },
      ),
    );
  }
}