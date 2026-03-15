import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';

class SavingsDashboard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    // Se o módulo não estiver rodando, a economia atual "ativa" é zero.
    final saved = isActive ? settings.moneySavedTotal : 0.0;

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
              "Mensal: ${currencyFormat.format(settings.monthlySavings)}",
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              "Economia mensal estimada: ${currencyFormat.format(settings.monthlySavings)}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ]
        ],
      ),
    );
  }
}
