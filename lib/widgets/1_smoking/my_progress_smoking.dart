import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';

class MyProgressSmoking extends StatelessWidget {
  const MyProgressSmoking({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gamification = Provider.of<GamificationService>(context);
    final dias = gamification.diasConsecutivosByModule[NicheId.smoking] ?? 0;
    final isActive = gamification.isModuleActive(NicheId.smoking);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parar de Fumar'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
              isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                NeonCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icons/niche_cigarro.png',
                        height: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isActive ? '$dias dias sem fumar' : 'Módulo desativado',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? const Color.fromARGB(255, 105, 139, 240)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getMedalText(dias),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMedalText(int dias) {
    if (dias >= 10) return '💎 Você alcançou o nível Diamante!';
    if (dias >= 7) {
      return '🥇 Medalha de Ouro! Faltam ${10 - dias} dias para Diamante.';
    }
    if (dias >= 5) {
      return '🥈 Medalha de Prata! Faltam ${7 - dias} dias para Ouro.';
    }
    if (dias >= 3) {
      return '🥉 Medalha de Bronze! Faltam ${5 - dias} dias para Prata.';
    }
    return 'Faltam ${3 - dias} dias para sua primeira medalha (Bronze).';
  }
}
