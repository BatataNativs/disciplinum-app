import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Widget Lojinha para recompensas e gamificação
/// Widget reutilizável para todos os módulos
class Lojinha extends StatelessWidget {
  final NicheId? nicheId;
  final String? customTitle;

  const Lojinha({
    super.key,
    this.nicheId,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customTitle ?? 'Lojinha'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Lojinha em desenvolvimento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Em breve você poderá resgatar recompensas aqui!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
