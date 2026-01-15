import 'package:flutter/material.dart';
import '../../utils/app_info_helper.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';

class NicheContentFocus extends StatelessWidget {
  final List<String> selectedApps;
  final TimeOfDay? focusStart;
  final TimeOfDay? focusEnd;
  final VoidCallback onSelectApps;
  final Function(String) onRemoveApp;
  final VoidCallback onPickInterval;
  final VoidCallback onRemoveInterval;

  const NicheContentFocus({
    super.key,
    required this.selectedApps,
    required this.focusStart,
    required this.focusEnd,
    required this.onSelectApps,
    required this.onRemoveApp,
    required this.onPickInterval,
    required this.onRemoveInterval,
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
            Icon(Icons.psychology_outlined,
                size: 20,
                color: isDark
                    ? const Color(0xFFFFFFFF)
                    : const Color(
                        0xFF1F2937)), // cor do ícone de inspiração/foco
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Selecione apps que possam te distrair\n enquanto pretende ficar focado:',
                  style: textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? const Color(0xFFFFFFFF)
                          : const Color(
                              0xFF1F2937))), // cor do texto de instrução
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (selectedApps.isEmpty)
          NeonCard(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text('Nenhum app selecionado ainda.',
                  style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white60
                          : Colors.black54)), // cor do texto de estado vazio
            ),
          )
        else
          FutureBuilder<List<AppDisplayInfo>>(
            future: gatherAppDisplayInfo(selectedApps),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final infos = snapshot.data!;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: infos.map((info) {
                  return InputChip(
                    visualDensity: VisualDensity.compact,
                    avatar: info.icon != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(info.icon!),
                            backgroundColor: Colors.transparent,
                          )
                        : null,
                    label: Text(info.label ?? info.package,
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white
                                : (isDark
                                    ? Colors.white70
                                    : const Color(
                                        0xFF6366F1)))), // cor do texto do chip
                    onDeleted: () => onRemoveApp(info.package),
                    deleteIconColor: isDark
                        ? Colors.white70
                        : (isDark ? Colors.white70 : const Color(0xFF6366F1))
                            .withValues(alpha: 0.7), // cor do ícone de remover
                    backgroundColor: (isDark
                            ? Colors.white
                            : (isDark
                                ? Colors.white70
                                : const Color(0xFF6366F1)))
                        .withValues(alpha: 0.1), // cor de fundo do chip
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  );
                }).toList(),
              );
            },
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: GlowingButton(
            text: 'Selecionar/Adicionar apps',
            onPressed: onSelectApps,
            color: const Color(0xFF6366F1), // cor do botão de selecionar
            borderRadius: 18,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.timer_outlined,
                size: 20,
                color: isDark
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color(0xFF1F2937)), // cor do ícone de cronômetro
            const SizedBox(width: 8),
            Text('Intervalo que pretende ficar\n sem acessar esses apps:',
                style: textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color(
                            0xFF1F2937))), // cor do título do intervalo
          ],
        ),
        const SizedBox(height: 8),
        NeonCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (focusStart == null || focusEnd == null)
                Text('Nenhum intervalo definido.',
                    style: textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white60
                            : Colors
                                .black54)) // cor do estado vazio do intervalo
              else ...[
                Text(
                  'Das ${_formatTime(focusStart!)} até ${_formatTime(focusEnd!)}',
                  style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(
                              255, 31, 41, 55)), // cor do horário do intervalo
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: onRemoveInterval,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(
                              255, 31, 41, 55), // cor do botão X de remover
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: GlowingButton(
            text: 'Definir intervalo de foco',
            onPressed: onPickInterval,
            borderRadius: 18, // arredondamento do botão
          ),
        ),
      ],
    );
  }
}
