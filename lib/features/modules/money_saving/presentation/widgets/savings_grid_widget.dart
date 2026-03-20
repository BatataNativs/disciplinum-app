import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving_challenge/domain/entities/money_saving_challenge_model.dart';

/// Widget de grade de progresso do desafio de poupança
class SavingsGridWidget extends StatelessWidget {
  final MoneySavingChallengeModel challenge;

  const SavingsGridWidget({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Grade de Progresso',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: challenge.cellValues.length,
          itemBuilder: (context, index) {
            final value = challenge.cellValues[index];
            final isMarked = challenge.markedCells.contains(index);
            final progress = (value / challenge.targetAmount) * 100;
            
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMarked ? _getProgressColor(progress) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'R\$ ${value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return Colors.green;
    if (progress >= 75) return Colors.blue;
    if (progress >= 50) return Colors.orange;
    if (progress >= 25) return Colors.yellow;
    return Colors.red;
  }
}
