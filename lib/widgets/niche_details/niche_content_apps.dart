import 'package:flutter/material.dart';
import '../../utils/app_info_helper.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';

class NicheContentApps extends StatelessWidget {
  final List<String> selectedApps;
  final List<AppDisplayInfo>? appDisplayInfos;
  final String introText;
  final VoidCallback onAdd;
  final Function(String) onRemove;

  const NicheContentApps({
    super.key,
    required this.selectedApps,
    this.appDisplayInfos,
    required this.introText,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (introText.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.apps_rounded,
                  size: 20,
                  color: isDark
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF1F2937)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(introText,
                    style: textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF1F2937))),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (selectedApps.isEmpty)
          NeonCard(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text('Nenhum app selecionado ainda.',
                  style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54)),
            ),
          )
        else if (appDisplayInfos == null || appDisplayInfos!.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: appDisplayInfos!.map((info) {
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
                        color:
                            isDark ? Colors.white : const Color(0xFF6366F1))),
                onDeleted: () => onRemove(info.package),
                deleteIconColor: isDark
                    ? Colors.white70
                    : const Color(0xFF6366F1).withValues(alpha: 0.7),
                backgroundColor:
                    (isDark ? Colors.white : const Color(0xFF6366F1))
                        .withValues(alpha: 0.1),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
