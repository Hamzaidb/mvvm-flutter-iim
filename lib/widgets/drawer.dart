import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => context.go('/'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.orange),
            title: const Text('Produits'),
            onTap: () => context.go('/products'),
          ),
          ListTile(
            leading: const Icon(Icons.pages),
            title: const Text('Second Page'),
            onTap: () => context.go('/second'),
          ),
          ListTile(
            leading: const Icon(Icons.pages),
            title: const Text('Third Page'),
            onTap: () => context.go('/third'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Se déconnecter'),
            onTap: () {
              context.pop(); // Ferme le drawer
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
    );
  }
}