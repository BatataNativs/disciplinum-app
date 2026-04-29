import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/smoking/presentation/controllers/stop_smoking_controller.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/features/modules/smoking/presentation/notifiers/smoking_gamification_notifier.dart' as smoking;

/// Widget de formulário de configuração do Smoking
class SmokingSetupForm extends ConsumerWidget {
  final SmokingSettingsModel? initialSettings;
  final Function(SmokingSettingsModel) onSave;

  const SmokingSetupForm({
    super.key,
    required this.onSave,
    this.initialSettings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentState = ref.watch(stopSmokingControllerProvider);
    final gamificationState = ref.watch(smoking.smokingGamificationNotifierProvider);
    final isModuleActive = gamificationState.isModuleActive;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações Iniciais',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Preço por maço
            TextFormField(
              initialValue: isModuleActive 
                  ? gamificationState.gamification?.packCost.toString() ?? '0.00'
                  : (initialSettings?.packPrice.toString() ?? '0.00'),
              keyboardType: TextInputType.number,
              enabled: !isModuleActive,
              style: isModuleActive 
                  ? TextStyle(color: Colors.grey.shade600)
                  : null,
              decoration: InputDecoration(
                labelText: 'Preço por Maço',
                border: const OutlineInputBorder(),
                filled: isModuleActive,
                fillColor: isModuleActive ? Colors.grey.shade100 : null,
              ),
            ),
            const SizedBox(height: 16),
            
            // Maços por dia
            TextFormField(
              initialValue: isModuleActive 
                  ? (gamificationState.gamification?.dailyCost ?? 0.0).toString()
                  : (initialSettings?.packsPerDay.toString() ?? '1'),
              keyboardType: TextInputType.number,
              enabled: !isModuleActive,
              style: isModuleActive 
                  ? TextStyle(color: Colors.grey.shade600)
                  : null,
              decoration: InputDecoration(
                labelText: 'Custo Diário',
                border: const OutlineInputBorder(),
                filled: isModuleActive,
                fillColor: isModuleActive ? Colors.grey.shade100 : null,
              ),
            ),
            const SizedBox(height: 16),
            
            // Moeda
            TextFormField(
              initialValue: initialSettings?.currency ?? 'BRL',
              enabled: !isModuleActive,
              style: isModuleActive 
                  ? TextStyle(color: Colors.grey.shade600)
                  : null,
              decoration: InputDecoration(
                labelText: 'Moeda',
                border: const OutlineInputBorder(),
                filled: isModuleActive,
                fillColor: isModuleActive ? Colors.grey.shade100 : null,
              ),
            ),
            const SizedBox(height: 24),
            
            // Botão salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (currentState.smokingData != null) {
                    final packPrice = double.tryParse(_getPackPriceValue()) ?? 0.00;
                    final packsPerDay = int.tryParse(_getPacksPerDayValue()) ?? 1;
                    
                    final updatedSettings = currentState.smokingData?.copyWith(
                      dailyCigarettes: packsPerDay * 20,
                      pricePerPack: packPrice,
                      cigarettesPerPack: 20,
                      startDate: currentState.smokingData?.startDate ?? DateTime.now(),
                    ) ?? SmokingSettingsModel(
                      dailyCigarettes: packsPerDay * 20,
                      pricePerPack: packPrice,
                      cigarettesPerPack: 20,
                      startDate: DateTime.now(),
                    );
                    
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Configurações Atuais'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Início: ${currentState.smokingData?.quitDate}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Maços por dia: ${currentState.smokingData?.packsPerDay}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Preço por maço: ${currentState.smokingData?.packPrice}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Moeda: ${currentState.smokingData?.currency}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onSave(updatedSettings);
                              },
                              child: const Text('Salvar Configurações'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Salvar Configurações'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPackPriceValue() {
    // Obter valor do campo de preço
    return ''; // Implementação real obteria o valor do controller
  }

  String _getPacksPerDayValue() {
    // Obter valor do campo de maços por dia
    return ''; // Implementação real obteria o valor do controller
  }
}
