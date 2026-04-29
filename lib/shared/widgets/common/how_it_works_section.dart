import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';

/// Seção "Como Funciona" reutilizável para módulos
class HowItWorksSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onGetStarted;
  final List<InfoCardData> infoCards;

  const HowItWorksSection({
    super.key,
    required this.isDark,
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
                    isDark: isDark,
                    icon: card.icon,
                    title: card.title,
                    content: card.content,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ModernStartButton(
            icon: Icons.rocket_launch_rounded,
            label: 'Entendi!',
            color: const Color(0xFF6366F1),
            isDark: isDark,
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
