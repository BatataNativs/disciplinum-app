import 'package:flutter/material.dart';

class NicheActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const NicheActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final effectiveBackgroundColor = backgroundColor ??
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final effectiveBorderColor = borderColor ??
        colorScheme.outline.withValues(alpha: 0.25);
    final effectiveTextColor = textColor ??
        colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: effectiveBorderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: effectiveTextColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
