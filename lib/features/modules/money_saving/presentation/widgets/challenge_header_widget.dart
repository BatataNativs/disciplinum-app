import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';

/// Widget de cabeçalho com informações do desafio
class ChallengeHeaderWidget extends StatelessWidget {
  final MoneySavingChallengeModel challenge;

  const ChallengeHeaderWidget({
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
              'Desafio Atual',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Título:', challenge.title),
            _buildInfoRow('Meta:', 'R\$ ${challenge.targetAmount.toStringAsFixed(2)}'),
            _buildInfoRow('Período:', _getPeriodText(challenge.periodValue)),
            _buildInfoRow('Status:', challenge.isActive ? 'Ativo' : 'Inativo'),
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

  String _getPeriodText(int periodValue) {
    switch (periodValue) {
      case 1: return 'Diário';
      case 7: return 'Semanal';
      case 30: return 'Mensal';
      default: return 'Personalizado';
    }
  }
}
