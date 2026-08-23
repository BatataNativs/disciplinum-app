import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Barra/Grid de 4 ferramentas essenciais para lidar com a vontade de fumar
class SmokingToolsBar extends StatelessWidget {
  final VoidCallback onOpenBreathing;
  final VoidCallback onOpenDiary;
  final VoidCallback onOpenSos;
  final VoidCallback onOpenTriggers;

  const SmokingToolsBar({
    super.key,
    required this.onOpenBreathing,
    required this.onOpenDiary,
    required this.onOpenSos,
    required this.onOpenTriggers,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lidar com a Vontade',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),

        // Grid 2x2 de Ferramentas
        Row(
          children: [
            // 1. Respirar
            Expanded(
              child: _buildToolCard(
                context,
                title: 'Respirar',
                subtitle: 'Exercício guiado',
                icon: Icons.air_rounded,
                color: const Color(0xFF06B6D4), // Ciano / Menta
                onTap: onOpenBreathing,
              ),
            ),
            const SizedBox(width: 10),
            // 2. Diário
            Expanded(
              child: _buildToolCard(
                context,
                title: 'Diário',
                subtitle: 'Desabafo privado',
                icon: Icons.edit_note_rounded,
                color: const Color(0xFF8B5CF6), // Roxo / Violeta
                onTap: onOpenDiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 3. SOS Vontade
            Expanded(
              child: _buildToolCard(
                context,
                title: 'SOS Vontade',
                subtitle: 'Modo emergência',
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFF97316), // Laranja vibrante
                isHighlight: true,
                onTap: onOpenSos,
              ),
            ),
            const SizedBox(width: 10),
            // 4. Gatilhos
            Expanded(
              child: _buildToolCard(
                context,
                title: 'Gatilhos',
                subtitle: 'Padrões de hábito',
                icon: Icons.insights_rounded,
                color: const Color(0xFF10B981), // Esmeralda
                onTap: onOpenTriggers,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isHighlight = false,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: isHighlight
                ? color.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlight
                  ? color.withValues(alpha: 0.4)
                  : colorScheme.outline.withValues(alpha: 0.08),
              width: isHighlight ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

