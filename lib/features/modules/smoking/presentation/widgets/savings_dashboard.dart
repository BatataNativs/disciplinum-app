import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/features/modules/smoking/gamification/presentation/providers/smoking_gamification_provider.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class SavingsDashboard extends ConsumerWidget {
  final SmokingSettingsModel settings;
  final bool compact;
  final bool isActive;

  const SavingsDashboard({
    super.key,
    required this.settings,
    this.compact = false,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // Usar dados do gamification state para economia real
    final gamificationNotifier = ref.watch(smokingGamificationNotifierProvider);
    final gamificationState = gamificationNotifier.gamification;
    
    LoggerService.instance.d('💰 SavingsDashboard: dailyCost=${gamificationState?.dailyCost}, consecutiveDays=${gamificationState?.consecutivePositiveDays}');
    
    // Se o módulo não estiver rodando, a economia atual "ativa" é zero.
    final saved = isActive && gamificationState != null
        ? (gamificationState.dailyCost * gamificationState.consecutivePositiveDays)
        : 0.0;
    
    final dailyCost = gamificationState?.dailyCost ?? 0.0;
    final monthly = dailyCost * 30;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Economia",
              style: TextStyle(
                  color: Colors.white70, fontSize: compact ? 12 : 16)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              currencyFormat.format(saved),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 22 : 36,
                  fontWeight: FontWeight.bold),
            ),
          ),
          if (compact) ...[
            const SizedBox(height: 8),
            Text(
              "Mensal: ${currencyFormat.format(monthly)}",
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              "Economia mensal estimada: ${currencyFormat.format(monthly)}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ]
        ],
      ),
    );
  }
}
