import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../providers/auth_provider.dart';
import '../widgets/drawer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<AuthProvider>(context).user; // Utilisateur courant

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // 1. Section Info Utilisateur
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.blue[50],
            child: Row(
              children: [
                // Avatar avec l'initiale
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.blue[700],
                  child: Text(
                    user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                // Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email du compte', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Non connecté',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 2. Titre Historique des Commandes
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Historique des commandes',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 3. Liste des Commandes
          Expanded(
            child: Consumer<OrdersViewModel>(
              builder: (context, ordersVM, child) {
                // Cas vide
                if (ordersVM.orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Aucune commande pour le moment.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // Liste des commandes
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordersVM.orders.length,
                  itemBuilder: (context, index) {
                    final order = ordersVM.orders[index];
                    
                    // Formatage simple de la date
                    final date = "${order.date.day}/${order.date.month}/${order.date.year} à ${order.date.hour}:${order.date.minute.toString().padLeft(2, '0')}";

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.green),
                        ),
                        title: Text(
                          'Commande #${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}', 
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('$date • ${order.totalAmount.toStringAsFixed(2)} €'),
                        children: [
                          // Détail des produits dans l'accordéon
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: order.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text("x${item.quantity} ${item.product.title}")),
                                      Text("${(item.product.price * item.quantity).toStringAsFixed(2)} €"),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}