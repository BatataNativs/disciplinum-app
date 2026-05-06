import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/common/niche.dart';

/// Widget de header da tela Stop Smoking
class StopSmokingHeaderWidget extends StatelessWidget {
  final Niche niche;
  final VoidCallback onBackPressed;

  const StopSmokingHeaderWidget({
    super.key,
    required this.niche,
    required this.onBackPressed,
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
