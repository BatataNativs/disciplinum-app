import 'package:flutter/material.dart';
import '../../models/niche.dart';

class NicheHeader extends StatelessWidget {
  final Niche niche;
  final bool showBackground;

  const NicheHeader({
    super.key,
    required this.niche,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          Hero(
            tag: 'app_logo',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: showBackground
                  ? BoxDecoration(
                      color: (isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 255, 255, 255))
                          .withValues(
                              alpha: 0.8), // cor do círculo de fundo do ícone
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Image.asset(
                niche.iconPath,
                height: 64, // altura do ícone do módulo
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            niche.name,
            style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isDark
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(
                        255, 31, 41, 55)), // cor do nome do módulo
          ),
        ],
      ),
    );
  }
}
