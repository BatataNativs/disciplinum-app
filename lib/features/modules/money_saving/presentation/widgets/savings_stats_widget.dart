import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving_challenge/domain/entities/money_saving_challenge_model.dart';

/// Widget de estatísticas do desafio de poupança
class SavingsStatsWidget extends StatelessWidget {
  final MoneySavingChallengeModel challenge;

  const SavingsStatsWidget({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Economizado:', 'R\$ ${challenge.totalSaved.toStringAsFixed(2)}'),
            _buildInfoRow('Faltam:', 'R\$ ${(challenge.targetAmount - challenge.totalSaved).toStringAsFixed(2)}'),
            _buildInfoRow('Células Marcadas:', '${challenge.markedCells.length}/${challenge.cellValues.length}'),
            _buildInfoRow('Progresso:', '${(challenge.totalSaved / challenge.targetAmount * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
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
}
