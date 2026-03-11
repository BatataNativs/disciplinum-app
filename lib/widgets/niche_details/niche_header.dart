import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/common/niche.dart';

class NicheHeader extends StatelessWidget {
  final Niche niche;
  final bool showBackground;
  final String? heroTag;

  const NicheHeader({
    super.key,
    required this.niche,
    this.showBackground = true,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Hero(
        tag: heroTag ?? 'niche_icon_${niche.id}',
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
            height: 120, // Aumentado para melhor visibilidade interna
          ),
        ),
      ),
    );
  }
}
