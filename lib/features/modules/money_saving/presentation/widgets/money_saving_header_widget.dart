import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';

class MoneySavingHeaderWidget extends StatelessWidget {
  final Niche niche;
  final MoneySavingChallengeModel? challenge;
  final VoidCallback onBackPressed;

  const MoneySavingHeaderWidget({
    super.key,
    required this.niche,
    required this.onBackPressed,
    this.challenge,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  niche.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (challenge != null)
                  Text(
                    challenge!.title,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
