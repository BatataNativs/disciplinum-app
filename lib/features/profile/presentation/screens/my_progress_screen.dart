import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';

// Import das telas de progresso de cada módulo
// Módulos com widgets específicos de progresso
import 'package:disciplinum/features/modules/smoking/presentation/widgets/my_progress_smoking.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/my_progress_binge_eating.dart';
import 'package:disciplinum/features/modules/diet/presentation/widgets/my_progress_diet.dart';
import 'package:disciplinum/features/modules/spending/presentation/widgets/my_progress_spending.dart';
import 'package:disciplinum/features/modules/adult_content/presentation/widgets/my_progress_adult_content.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/my_progress_money_saving_challenge.dart';
import 'package:disciplinum/features/modules/procrastination/presentation/widgets/my_progress_procrastination.dart';
import 'package:disciplinum/features/modules/reading/presentation/widgets/my_progress_reading.dart';
// Tela de progresso específica do módulo Focus
import 'package:disciplinum/features/modules/focus/presentation/widgets/my_progress_focus.dart';

class MyProgressScreen extends ConsumerWidget {
  const MyProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);
    
    // Usar providers locais existentes para obter progresso
    final activeModules = ref.watch(activeModulesProvider);
    final niches = NicheRepository.getAll();

    // Lógica para obter o primeiro nome
    String fullName = authState.userProfile?['name'] ?? 'Usuário';
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
                      // Usar providers locais para obter dados reais
                      final isActive = activeModules.contains(niche.nicheId);
                      final dias = isActive ? 1 : 0; // Simplificado - cada módulo teria seu próprio provider

                      return _buildProgressCard(
                        context: context,
                        niche: niche,
                        dias: dias,
                        isActive: isActive,
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
              child: niche.isEmojiIcon
                  ? Center(
                      child: Text(
                        niche.iconPath,
                        style: const TextStyle(fontSize: 48),
                      ),
                    )
                  : Image.asset(
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

    switch (niche.nicheId) {
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
      case NicheId.digitalDetox:
        // TODO: Implementar MyProgressDigitalDetox na FASE 8
        detailScreen = Scaffold(
          appBar: AppBar(title: const Text('Meu Progresso - Jejum Digital')),
          body: const Center(child: Text('Em breve')),
        );
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => detailScreen),
    );
  }
}
