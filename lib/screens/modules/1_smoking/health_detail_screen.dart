import 'package:flutter/material.dart';
import 'package:disciplinum/models/1_smoking/smoking_settings_model.dart';
import 'package:disciplinum/widgets/1_smoking/health_timeline_card.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:provider/provider.dart';

class HealthDetailScreen extends StatelessWidget {
  final SmokingSettingsModel settings;

  const HealthDetailScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gamification = Provider.of<GamificationService>(context);
    final isActive = gamification.isModuleActive(NicheId.smoking);
    final effectiveDuration = isActive ? settings.timeSmokeFree : Duration.zero;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark
                  ? const Color.fromARGB(255, 0, 0, 0)
                  : const Color.fromARGB(255, 230, 235, 255),
              isDark
                  ? const Color.fromARGB(255, 10, 15, 30)
                  : const Color.fromARGB(255, 255, 255, 255)
            ],
          ),
        ),
        child: SafeArea(
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
                          color: isDark ? Colors.white : Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Melhorias na Saúde',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87),
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
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Ao parar de fumar, seu corpo começa a se recuperar imediatamente. '
                          'Esses marcos representam melhorias reais na sua saúde.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
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
      ),
    );
  }
}
