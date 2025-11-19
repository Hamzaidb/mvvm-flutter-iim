import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// 🔥 AJOUT : Provider pour MVVM
import 'package:provider/provider.dart';

// ViewModels imports
import 'viewmodels/products_viewmodel.dart';

// Pages imports
import 'pages/home_page.dart';
import 'pages/second_page.dart';
import 'pages/third_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/products_page.dart'; // 🔥 AJOUT : Nouvelle page produits

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
      ],
      child: MaterialApp(
        title: 'ShopFlutter E-commerce',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const MyHomePage(),
          '/second': (_) => const SecondPage(),
          '/third': (_) => const ThirdPage(),
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          // 🔥 AJOUT : Route vers la page produits
          '/products': (_) => const ProductsPage(),
        },
      ),
    );
  }
}