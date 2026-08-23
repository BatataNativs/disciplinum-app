import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/core/di/providers.dart';
import '../widgets/health_timeline_card.dart';

class HealthDetailScreen extends ConsumerWidget {
  final SmokingSettingsModel settings;

  const HealthDetailScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    // Usando provider local do Smoking
    final smokingState = ref.watch(stopSmokingControllerProvider);
    final isModuleActive = smokingState.smokingData?.isModuleActive ?? false;
    final effectiveDuration = isModuleActive ? settings.timeSmokeFree : Duration.zero;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Melhorias na Saúde',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      HealthTimelineCard(
                        settings: settings,
                        timeSmokeFree: effectiveDuration,
                      ),
                      const SizedBox(height: 24),
                      // Info text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Ao parar de fumar, seu corpo começa a se recuperar imediatamente. '
                          'Esses marcos representam melhorias reais na sua saúde.',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
