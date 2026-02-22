import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/7_moneySavingChallenge/money_saving_challenge_service.dart';

class MoneySavingChallengeAboutContributionsScreen extends StatelessWidget {
  const MoneySavingChallengeAboutContributionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MoneySavingChallengeService>(context);
    final challenges = service.challengesList;

    // Mapa para contar a frequência de cada valor de aporte marcado
    Map<double, int> contributionFrequency = {};
    int totalContributionsCount = 0;

    for (var c in challenges) {
      for (int index in c.markedCells) {
        if (index < c.cellValues.length) {
          double val = c.cellValues[index];
          contributionFrequency[val] = (contributionFrequency[val] ?? 0) + 1;
          totalContributionsCount++;
        }
      }
    }

    // Transformar em lista e ordenar por frequência (decrescente)
    var sortedFrequencies = contributionFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    String currency = challenges.isNotEmpty ? challenges.first.currency : 'R\$';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Sobre os Aportes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumo de Aportes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.insights_rounded,
                      color: const Color(0xFF10B981), size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Total de Aportes Realizados',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  Text(
                    '$totalContributionsCount',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Aportes mais frequentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estes são os valores que você consegue guardar com mais regularidade.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(height: 24),

            if (sortedFrequencies.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'Nenhum aporte registrado ainda.',
                    style: TextStyle(
                        color: isDark ? Colors.white30 : Colors.black38),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedFrequencies.length,
                itemBuilder: (context, index) {
                  final entry = sortedFrequencies[index];
                  final double value = entry.key;
                  final int count = entry.value;
                  final double percentage =
                      (count / totalContributionsCount) * 100;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      title: Text(
                        '$currency ${value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '$count aportes realizados',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          Text(
                            'do total',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white30 : Colors.black26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
