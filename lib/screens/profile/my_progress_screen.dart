import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';

// Import das telas de progresso de cada módulo
import 'package:disciplinum/widgets/1_smoking/my_progress_smoking.dart';
import 'package:disciplinum/widgets/2_bingeEating/my_progress_binge_eating.dart';
import 'package:disciplinum/widgets/3_diet/my_progress_diet.dart';
import 'package:disciplinum/widgets/4_spending/my_progress_spending.dart';
import 'package:disciplinum/widgets/5_focus/my_progress_focus.dart';
import 'package:disciplinum/widgets/6_adultContent/my_progress_adult_content.dart';

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
              isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SAUDAÇÃO
                Text(
                  'Olá, $firstName! 📊',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Acompanhe seu progresso em cada módulo:',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                // GRID DE CARDS
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: niches.length,
                    itemBuilder: (context, index) {
                      final niche = niches[index];
                      final dias =
                          gamification.diasConsecutivosByModule[niche.id] ?? 0;
                      final isActive = gamification.isModuleActive(niche.id);

                      return _buildProgressCard(
                        context: context,
                        niche: niche,
                        dias: dias,
                        isActive: isActive,
                        isDark: isDark,
                        onTap: () => _navigateToProgressDetail(context, niche),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required BuildContext context,
    required Niche niche,
    required int dias,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone do módulo
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                niche.iconPath,
                height: 28,
                width: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 6),
            // Nome do módulo (truncado)
            SizedBox(
              height: 32,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  niche.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Dias ou status
            Text(
              isActive ? '$dias dias' : 'Desativado',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? (isDark ? Colors.greenAccent : Colors.green)
                    : Colors.grey,
              ),
            ),
            // Espaço reservado para Medalha (para manter alinhamento)
            SizedBox(
              height: 24,
              child: (isActive && dias >= 3)
                  ? Center(
                      child: Text(
                        _getMedalEmoji(dias),
                        style: const TextStyle(fontSize: 14),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProgressDetail(BuildContext context, Niche niche) {
    Widget? detailScreen;

    switch (niche.id) {
      case NicheId.smoking:
        detailScreen = const MyProgressSmoking();
        break;
      case NicheId.bingeEating:
        detailScreen = const MyProgressBingeEating();
        break;
      case NicheId.diet:
        detailScreen = const MyProgressDiet();
        break;
      case NicheId.spending:
        detailScreen = const MyProgressSpending();
        break;
      case NicheId.focus:
        detailScreen = const MyProgressFocus();
        break;
      case NicheId.adultContent:
        detailScreen = const MyProgressAdultContent();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => detailScreen!),
    );
  }

  String _getMedalEmoji(int dias) {
    if (dias >= 10) return '💎';
    if (dias >= 7) return '🥇';
    if (dias >= 5) return '🥈';
    if (dias >= 3) return '🥉';
    return '';
  }
}
