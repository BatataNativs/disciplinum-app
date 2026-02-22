import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/7_moneySavingChallenge/money_saving_challenge_service.dart';
import 'package:disciplinum/models/7_moneySavingChallenge/money_saving_challenge_model.dart';

class MoneySavingChallengeTotalContributionsScreen extends StatelessWidget {
  const MoneySavingChallengeTotalContributionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MoneySavingChallengeService>(context);
    final challenges = service.challengesList;

    double totalGeneralSaved = 0;
    List<MoneySavingChallengeModel> completedChallenges = [];

    for (var c in challenges) {
      totalGeneralSaved += c.totalSaved;
      if (c.isComplete) {
        completedChallenges.add(c);
      }
    }

    String currency = challenges.isNotEmpty ? challenges.first.currency : 'R\$';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Total Geral Guardado'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Card de Total Geral
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1),
                    const Color(0xFF4F46E5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Economia Consolidada',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    child: Text(
                      '$currency ${totalGeneralSaved.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🎉 Parabéns pelo progresso!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Seção de Desafios Concluídos
            Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Desafios Concluídos (${completedChallenges.length})',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (completedChallenges.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Você ainda não completou nenhum desafio.\nContinue firme e poupe agora mesmo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 14,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedChallenges.length,
                itemBuilder: (context, index) {
                  final c = completedChallenges[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF10B981).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Text('💰', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                '${c.currency} ${c.targetAmount.toStringAsFixed(2)} poupados!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF10B981)),
                      ],
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
