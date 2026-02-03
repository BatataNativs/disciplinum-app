import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';

class MyProgressProcrastination extends StatelessWidget {
  const MyProgressProcrastination({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gamification = Provider.of<GamificationService>(context);
    final days =
        gamification.diasConsecutivosByModule[NicheId.procrastination] ?? 0;
    final isActive = gamification.isModuleActive(NicheId.procrastination);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Progresso'),
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigoAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.task_alt_rounded,
                          size: 64,
                          color: Colors.indigoAccent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isActive ? '$days dias de foco' : 'Módulo desativado',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? const Color.fromARGB(255, 105, 139, 240)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getMedalText(days),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Estatísticas adicionais podem ser adicionadas aqui
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMedalText(int days) {
    if (days >= 10) {
      return '💎 Você é um mestre da produtividade! Alcançou o nível Diamante.';
    }
    if (days >= 7) {
      return '🥇 Medalha de Ouro! Sua disciplina é admirável. Faltam ${10 - days} dias para o Diamante.';
    }
    if (days >= 5) {
      return '🥈 Medalha de Prata! Você está vencendo a procrastinação. Faltam ${7 - days} dias para o Ouro.';
    }
    if (days >= 3) {
      return '🥉 Medalha de Bronze! Um ótimo começo. Faltam ${5 - days} dias para a Prata.';
    }
    return 'Complete todas as suas tarefas diárias para ganhar sua primeira medalha (Bronze)! Faltam ${3 - days} dias.';
  }
}
