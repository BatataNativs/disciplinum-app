import 'package:flutter/material.dart';

class AppBlockerScreen extends StatelessWidget {
  const AppBlockerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloqueio de Apps'),
      ),
      body: const Center(
        child: Text('Configurações de Bloqueio em Breve.'),
      ),
    );
  }
}
