import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/models/niche.dart';

import 'package:disciplinum/widgets/home/neon_card.dart';

class MyProgressScreen extends StatelessWidget {
  const MyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);
    final gamification = Provider.of<GamificationService>(context);
    final niches = NicheRepository.getAll();

    // Lógica para obter o primeiro nome
    String fullName = authService.userProfile?['name'] ?? 'Usuário';
    String firstName = fullName.split(' ').first;
    if (firstName.isEmpty) firstName = 'Usuário';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Meu Progresso'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
              isDark ? Colors.black : const Color.fromARGB(255, 121, 148, 222)
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SAUDAÇÃO
              Text(
                'Olá, $firstName! 📊📈',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aqui é mostrado o quão disciplinado você está:',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // LISTA DE PROGRESSO POR MÓDULO
              ...niches.map((niche) {
                final dias =
                    gamification.diasConsecutivosByModule[niche.id] ?? 0;
                final maxMedal =
                    gamification.medalsByModule[niche.id] ?? 'Sem medalha';
                final isActive = gamification.isModuleActive(niche.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NeonCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                niche.iconPath,
                                height: 30,
                                width: 30,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    niche.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isActive
                                        ? '🔥 $dias dias consecutivos'
                                        : '⏸️ Módulo pausado',
                                    style: TextStyle(
                                      color: isActive
                                          ? (isDark
                                              ? Colors.greenAccent
                                              : Colors.green)
                                          : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (maxMedal.contains('Ouro') ||
                                maxMedal.contains('Prata') ||
                                maxMedal.contains('Bronze') ||
                                maxMedal.contains('Diamante'))
                              Tooltip(
                                message: 'Sua maior conquista: $maxMedal',
                                child: Text(
                                  _getMedalEmoji(maxMedal),
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (isActive) ...[
                          // Barra de progresso para a próxima medalha
                          _buildNextMedalProgress(context, dias, isDark),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextMedalProgress(BuildContext context, int dias, bool isDark) {
    int target = 0;
    String nextMedal = '';
    Color color = Colors.grey;

    if (dias < 3) {
      target = 3;
      nextMedal = 'Bronze';
      color = const Color(0xFFCD7F32);
    } else if (dias < 5) {
      target = 5;
      nextMedal = 'Prata';
      color = const Color(0xFFC0C0C0);
    } else if (dias < 7) {
      target = 7;
      nextMedal = 'Ouro';
      color = const Color(0xFFFFD700);
    } else if (dias < 10) {
      target = 10;
      nextMedal = 'Diamante';
      color = const Color(0xFFB9F2FF);
    } else {
      return Text(
        'Você é uma lenda! 💎 Nível Máximo!',
        style: TextStyle(
            color: isDark ? Colors.blueAccent : Colors.blue,
            fontWeight: FontWeight.bold),
      );
    }

    final int previousTarget = _getPreviousTarget(target);
    final double progress = (dias - previousTarget) / (target - previousTarget);
    final int diasRestantes = target - dias;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próxima: $nextMedal',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            Text(
              'Faltam $diasRestantes dias',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  int _getPreviousTarget(int target) {
    if (target == 3) return 0;
    if (target == 5) return 3;
    if (target == 7) return 5;
    if (target == 10) return 7;
    return 0;
  }

  String _getMedalEmoji(String medalName) {
    if (medalName.contains('Diamante')) return '💎';
    if (medalName.contains('Ouro')) return '🥇';
    if (medalName.contains('Prata')) return '🥈';
    if (medalName.contains('Bronze')) return '🥉';
    return '';
  }
}
