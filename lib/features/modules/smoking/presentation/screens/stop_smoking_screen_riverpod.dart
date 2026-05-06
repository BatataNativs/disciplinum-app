import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/smoking/presentation/controllers/stop_smoking_controller.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';

/// Tela Stop Smoking com Riverpod
class StopSmokingScreenRiverpod extends ConsumerWidget {
  final String? heroTag;
  
  const StopSmokingScreenRiverpod({super.key, this.heroTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentState = ref.watch(stopSmokingControllerProvider);
    final niche = NicheRepository.getById(NicheId.smoking);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Parar de Fumar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: currentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, ref, currentState, niche),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, StopSmokingState state, Niche niche) {
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
                  ref.read(stopSmokingControllerProvider.notifier).clearError();
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.smokingData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smoke_free, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Nenhum dado encontrado. Toque para configurar.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(stopSmokingControllerProvider.notifier).loadSmokingData();
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
          NicheInfoCard(
            title: niche.name,
            icon: Icons.smoke_free,
            color: Colors.green,
            content: '''Status: ${state.smokingData?.isConfigured == true ? "Configurado" : "Não configurado"}

Início: ${_formatDate(state.smokingData!.startDate)}
Maços por dia: ${state.smokingData!.packsPerDay}
Preço por maço: ${state.smokingData!.packPrice}
Moeda: ${state.smokingData!.currency}''',
          ),
          const SizedBox(height: 24),
          // Seção de configurações
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configurações Atuais',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsInfo(context, state.smokingData!),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // Aqui você pode adicionar lógica para salvar
                          },
                          child: const Text('Salvar Configurações'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            ref.read(stopSmokingControllerProvider.notifier).resetSmokingData();
                          },
                          child: const Text('Resetar Dados'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsInfo(BuildContext context, SmokingSettingsModel settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Preço por Maço:', 'R\$ ${settings.packPrice.toStringAsFixed(2)}'),
        _buildInfoRow('Maços por Dia:', '${settings.packsPerDay}'),
        _buildInfoRow('Moeda:', settings.currency),
        if (settings.quitDate != null)
          _buildInfoRow('Data de Parada:', _formatDate(settings.quitDate!)),
        if (settings.lastPackPrice != null)
          _buildInfoRow('Último Preço:', 'R\$ ${settings.lastPackPrice!.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
