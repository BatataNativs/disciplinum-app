import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/common/niche.dart';

/// Widget de header da tela Stop Smoking
class StopSmokingHeaderWidget extends StatelessWidget {
  final Niche niche;
  final VoidCallback onBackPressed;
  final VoidCallback? onHelpPressed;

  const StopSmokingHeaderWidget({
    super.key,
    required this.niche,
    required this.onBackPressed,
    this.onHelpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface,
            ),
            onPressed: onBackPressed,
          ),
          Expanded(
            child: Text(
              niche.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (onHelpPressed != null)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.question_mark_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              tooltip: 'Como funciona',
              onPressed: onHelpPressed,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
