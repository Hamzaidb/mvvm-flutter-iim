import 'package:flutter/material.dart';
import '../widgets/drawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Drawer Demo')),
      // drawer : le menu à gauche qui va nous permettre de naviguer entre les pages
      drawer: const AppDrawer(),
      body: const Center(child: Text('Welcome to Flutter Drawer Demo')),
    );
  }
}