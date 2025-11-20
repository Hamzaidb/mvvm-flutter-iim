import 'package:flutter/material.dart';
import 'package:pwa_install/pwa_install.dart';

class InstallButton extends StatelessWidget {
  const InstallButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Si l'installation n'est pas possible (ex: déjà installé ou sur iPhone), on cache le bouton
    if (!PWAInstall().installPromptEnabled) {
      return const SizedBox.shrink(); 
    }

    return ListTile(
      leading: const Icon(Icons.download_rounded, color: Colors.green),
      title: const Text(
        'Installer l\'application',
        style: TextStyle(color: Color.fromARGB(255, 13, 88, 16), fontWeight: FontWeight.bold),
      ),
      onTap: () {
        // C'est ici qu'on déclenche l'action
        PWAInstall().promptInstall_(); 
      },
    );
  }
}