import 'package:flutter/material.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';

class NicheInfoSection extends StatelessWidget {
  final String hintText;

  const NicheInfoSection({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return NeonCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: isDark
                    ? Colors.white70
                    : const Color(0xFF6366F1), // cor do ícone de info
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Como funciona',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFFFFFFFF)
                        : const Color(
                            0xFF1F2937)), // cor do título "Como funciona"
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hintText,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: isDark
                  ? const Color(0xFFFFFFFF).withValues(alpha: 0.7)
                  : const Color(0xFF1F2937)
                      .withValues(alpha: 0.7), // cor do texto explicativo
            ),
          ),
        ],
      ),
    );
  }
}
