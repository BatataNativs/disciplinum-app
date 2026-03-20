import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/controllers/money_saving_challenge_controller.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/challenge_header_widget.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/savings_grid_widget.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/savings_stats_widget.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/savings_actions_widget.dart';

/// Tela Money Saving Challenge com Riverpod
class MoneySavingChallengeScreenRiverpod extends ConsumerWidget {
  final String? heroTag;
  
  const MoneySavingChallengeScreenRiverpod({super.key, this.heroTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentState = ref.watch(moneySavingChallengeControllerProvider);
    final niche = NicheRepository.getById(NicheId.moneySavingChallenge);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Desafio da Poupança'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: currentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, ref, currentState, niche),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, MoneySavingChallengeState state, Niche niche) {
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro: ${state.error}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(moneySavingChallengeControllerProvider.notifier).clearError();
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.challengeData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.savings, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Nenhum desafio encontrado. Toque para configurar.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(moneySavingChallengeControllerProvider.notifier).loadChallengeData();
                },
                child: const Text('Carregar Dados'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações do desafio
          ChallengeHeaderWidget(challenge: state.challengeData!),
          
          const SizedBox(height: 16),
          
          // Grid de progresso
          SavingsGridWidget(challenge: state.challengeData!),
          
          const SizedBox(height: 16),
          
          // Estatísticas
          SavingsStatsWidget(challenge: state.challengeData!),
          
          const SizedBox(height: 16),
          
          // Ações
          SavingsActionsWidget()
        ],
      ),
    );
  }

}
