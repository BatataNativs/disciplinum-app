import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/cards/neon_card.dart';
import 'package:disciplinum/shared/widgets/common/glowing_button.dart';

class NicheContentSchedule extends StatelessWidget {
  final List<TimeOfDay> times;
  final VoidCallback onAdd;
  final Function(TimeOfDay) onRemove;

  const NicheContentSchedule({
    super.key,
    required this.times,
    required this.onAdd,
    required this.onRemove,
  });

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time_rounded,
                size: 20,
                color: isDark
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF1F2937)), // cor do ícone de relógio
            const SizedBox(width: 8),
            Text('Defina horários:',
                style: textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? const Color(0xFFFFFFFF)
                        : const Color(
                            0xFF1F2937))), // cor do título de horários
          ],
        ),
        const SizedBox(height: 12),
        if (times.isEmpty)
          NeonCard(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text('Nenhum horário definido ainda.',
                  style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white60
                          : Colors.black54)), // cor do texto de estado vazio
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: times.map((t) {
              return InputChip(
                visualDensity: VisualDensity.compact,
                label: Text(_formatTime(t),
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white
                            : (isDark
                                ? Colors.white70
                                : const Color(
                                    0xFF6366F1)))), // cor do texto do chip
                onDeleted: () => onRemove(t),
                deleteIconColor: isDark
                    ? Colors.white70
                    : (isDark ? Colors.white70 : const Color(0xFF6366F1))
                        .withValues(alpha: 0.7), // cor do ícone de remover chip
                backgroundColor: (isDark
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF6366F1)))
                    .withValues(alpha: 0.1), // cor de fundo do chip de horário
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: GlowingButton(
            text: '+ Adicionar horário',
            onPressed: onAdd,
            color: const Color(0xFF6366F1), // cor do botão de adicionar
            borderRadius: 18,
          ),
        ),
      ],
    );
  }
}
