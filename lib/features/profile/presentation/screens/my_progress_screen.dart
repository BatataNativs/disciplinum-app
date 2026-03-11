import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

// Import das telas de progresso de cada módulo
import 'package:disciplinum/widgets/1_smoking/my_progress_smoking.dart';
import 'package:disciplinum/widgets/2_bingeEating/my_progress_binge_eating.dart';
import 'package:disciplinum/widgets/3_diet/my_progress_diet.dart';
import 'package:disciplinum/widgets/4_spending/my_progress_spending.dart';
import 'package:disciplinum/widgets/5_focus/my_progress_focus.dart';
import 'package:disciplinum/widgets/6_adultContent/my_progress_adult_content.dart';
import 'package:disciplinum/widgets/7_moneySavingChallenge/my_progress_money_saving_challenge.dart';
import 'package:disciplinum/widgets/8_procrastination/my_progress_procrastination.dart';
import 'package:disciplinum/widgets/9_reading/my_progress_reading.dart';

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
        title: const Text('Conquistas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SAUDAÇÃO
                Text(
                  'Olá, $firstName!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Acompanhe suas conquistas em cada módulo:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 30, 30, 40),
              Color.fromARGB(255, 15, 15, 20),
            ],
          ),
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone do módulo (Aumentado e sem container circular)
            Expanded(
              child: Image.asset(
                niche.iconPath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            // Nome do módulo
            Text(
              niche.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Status Ativado/Desativado
            Text(
              isActive ? 'Ativado' : 'Desativado',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.greenAccent : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProgressDetail(BuildContext context, Niche niche) {
    late final Widget detailScreen;

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
      case NicheId.moneySavingChallenge:
        detailScreen = const MyProgressMoneySavingChallenge();
        break;
      case NicheId.procrastination:
        detailScreen = const MyProgressProcrastination();
        break;
      case NicheId.reading:
        detailScreen = const MyProgressReading();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => detailScreen),
    );
  }
}
