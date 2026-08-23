import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';

/// Seção "Como Funciona" reutilizável para módulos
class HowItWorksSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final List<InfoCardData> infoCards;

  const HowItWorksSection({
    super.key,
    required this.onGetStarted,
    required this.infoCards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: infoCards.map((card) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NicheInfoCard(
                    icon: card.icon,
                    title: card.title,
                    content: card.content,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Nota sobre privacidade e backup
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.teal.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.teal, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Privacidade Local-First: seus dados ficam salvos apenas no seu aparelho por padrão. Para segurança ou troca de dispositivo, faça Backup (local ou na nuvem) na tela de Perfil.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ModernStartButton(
            icon: Icons.rocket_launch_rounded,
            label: 'Entendi!',
            color: const Color(0xFF6366F1),
            onTap: onGetStarted,
          ),
        ),
      ],
    );
  }
}

/// Dados para os cards de informação
class InfoCardData {
  final IconData icon;
  final String title;
  final String content;

  const InfoCardData({
    required this.icon,
    required this.title,
    required this.content,
  });
}
