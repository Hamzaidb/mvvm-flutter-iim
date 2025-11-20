import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'dart:io' show Platform; // Pour détecter la plateforme
import 'package:flutter/foundation.dart' show kIsWeb; // Pour détecter le Web

// Imports de vos pages
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/products_page.dart';
import 'providers/auth_provider.dart';
import 'pages/product_detail_page.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/profile_page.dart';
import 'pages/product_detail_page_ios.dart';

class AppRouter {
  final AppAuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider, //  Le routeur écoute les changements d'auth
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
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id']!);
              if (id == null) {
                return const Scaffold(body: Center(child: Text('ID invalide')));
              }

              // Si on n'est pas sur le Web ET qu'on est sur iOS
              if (!kIsWeb && Platform.isIOS) {
                return ProductDetailPageIOS(productId: id);
              }
              // Sinon (Android, Web), on retourne la page Material standard
              return ProductDetailPage(productId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      )
    ],
  );
}