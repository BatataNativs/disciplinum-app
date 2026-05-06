import 'package:flutter/material.dart';

class ChallengeCell extends StatelessWidget {
  final int index;
  final double value;
  final bool isMarked;
  final int gridSize;
  final ValueChanged<int> onTap;

  const ChallengeCell({
    super.key,
    required this.index,
    required this.value,
    required this.isMarked,
    required this.gridSize,
    required this.onTap,
  });

  static const LinearGradient _markedGradient = LinearGradient(
    colors: [
      Color(0xFF10B981), // Emerald 500
      Color(0xFF059669), // Emerald 600
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    // Gradiente escuro premium para células não marcadas
    final unMarkedGradient = LinearGradient(
      colors: [
        const Color(0xFF2C2C2E), // Cinza escuro
        const Color(0xFF1C1C1E), // Quase preto
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isMarked ? _markedGradient : unMarkedGradient,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (isMarked)
              // Brilho externo sutil para marcada
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              )
            else
              // Efeito de relevo sutil para não marcada
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            if (!isMarked)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                offset: const Offset(-1, -1),
                blurRadius: 2,
              ),
          ],
          border: Border.all(
            color: isMarked
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.05),
            width: isMarked ? 1.0 : 0.5,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: isMarked ? FontWeight.w900 : FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
