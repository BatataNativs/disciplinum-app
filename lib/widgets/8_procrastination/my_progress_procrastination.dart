import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/screens/modules/8_procrastination/procrastination_stats_screen.dart';
import 'package:disciplinum/screens/modules/8_procrastination/completed_lists_screen.dart';

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
                // Botão de Estatísticas de Desprocrastinação
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProcrastinationStatsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pie_chart,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 12),
                        const Text(
                          'Ver Estatísticas de Desprocrastinação',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Botão de Listas Concluídas
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CompletedListsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50),
                          const Color(0xFF8BC34A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.checklist_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: Text(
                            'Listas concluídas sem nenhum atraso',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
