import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Imports de vos pages
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/products_page.dart';
import 'pages/second_page.dart';
import 'pages/third_page.dart';
import 'providers/auth_provider.dart';
import 'pages/product_detail_page.dart';
import 'pages/cart_page.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider, // 🔥 Le routeur écoute les changements d'auth
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // 🔒 LOGIQUE DU GUARD (Sécurité)
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      // Si pas connecté et qu'on essaie d'aller ailleurs que login/register -> Login
      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      // Si connecté et qu'on est sur login/register -> Accueil
      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return '/';
      }

      // Sinon, on laisse passer
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MyHomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsPage(),
        // Plus tard, vous ajouterez ici la sous-route pour le détail : /products/:id
        routes: [
          GoRoute(
            path: ':id',
            builder: (context,state) {
              final id = int.tryParse(state.pathParameters['id']!);
              if (id == null) {
                return const Scaffold(
                  body: Center(child: Text('ID de produit invalide')),
                );
              }
              return ProductDetailPage(productId: id);
            }
          ),
        ],
      ),
      GoRoute(
        path: '/second',
        builder: (context, state) => const SecondPage(),
      ),
      GoRoute(
        path: '/third',
        builder: (context, state) => const ThirdPage(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
    ],
  );
}