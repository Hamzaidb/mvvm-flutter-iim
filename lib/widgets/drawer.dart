import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'install_button.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 0, 0, 0)),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => context.go('/'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.orange),
            title: const Text('Catalogue'),
            onTap: () => context.go('/products'),
          ),
          const Divider(),
          const InstallButton(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text('Mon Profil'),
            onTap: () => context.go('/profile'),
          ),
      
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Se déconnecter'),
            onTap: () {
              context.pop(); // Ferme le drawer
              Provider.of<AppAuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
    );
  }
}