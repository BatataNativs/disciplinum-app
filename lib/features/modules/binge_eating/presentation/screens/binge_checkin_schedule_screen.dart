import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/widgets/cards/neon_card.dart';
import 'package:disciplinum/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';

class BingeCheckinScheduleScreen extends ConsumerStatefulWidget {
  const BingeCheckinScheduleScreen({super.key});

  @override
  ConsumerState<BingeCheckinScheduleScreen> createState() => _BingeCheckinScheduleScreenState();
}

class _BingeCheckinScheduleScreenState extends ConsumerState<BingeCheckinScheduleScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.bingeEating);
  int _checkinCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    // Niche ID + 100 para check-in diário
    final checkinTimes =
        await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(nicheId: _niche.id + 200);

    if (mounted) {
      setState(() {
        _checkinCount = checkinTimes.length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
            isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Check-in Diário'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSettingsCard(
                      title: 'Check-in Diário',
                      description: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Receba lembretes diários para registrar se você resistiu às tentações de delivery. ',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'Permite até 3 horários.',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      count: _checkinCount,
                      max: 3,
                      onTap: _openSchedule,
                      leadingWidget: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.no_food_rounded,
                          size: 40,
                          color: Colors.green,
                        ),
                      ),
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    NicheInfoCard(
                      isDark: isDark,
                      icon: Icons.info_outline,
                      color: Colors.green,
                      title: 'Como funciona?',
                      content:
                          'Você receberá uma notificação diária nos horários configurados com duas opções de resposta rápida:\n\n• "Resisti às tentações" - Registra um dia de sucesso\n• "Não resisti" - Reseta suas estatísticas',
                    ),
                  ],
                ),
              ),
      ),
    );
  }


  Widget _buildSettingsCard({
    required String title,
    required Widget description,
    required int count,
    required int max,
    required VoidCallback onTap,
    required Widget leadingWidget,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NeonCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          leadingWidget,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                description,
                const SizedBox(height: 8),
                Text(
                  count > 0
                      ? '$count horário(s) configurado(s)'
                      : 'Nenhum horário configurado',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: count > 0
                        ? color
                        : isDark
                            ? Colors.white
                            : const Color.fromARGB(181, 69, 69, 69),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Future<void> _openSchedule() async {
    if (!mounted) return;

    // Salva o context antes da operação assíncrona
    final navigatorContext = context;

    // Carrega horários existentes
    final existingTimes = await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(nicheId: _niche.id + 200);

    if (!mounted) return;

    // Verifica se o context ainda é válido antes de usar
    if (!navigatorContext.mounted) return;

    await Navigator.push(
      navigatorContext,
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          args: ScheduleScreenArgs(
            nicheId: _niche.id + 200, // ID específico para check-in
            maxSlots: 3,
            title: 'Check-in Diário',
            initialTimes: existingTimes.map((t) => TimeOfDay(hour: t.hour, minute: t.minute)).toList(),
            onChanged: (times) {
              // Salva os novos horários
              ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(nicheId: _niche.id + 200);
              for (final time in times) {
                ref.read(cloudSyncServiceProvider).addUserNicheTime(
                  nicheId: _niche.id + 200,
                  hour: time.hour,
                  minute: time.minute,
                  phrase: 'Você resistiu às tentações de delivery hoje?',
                );
              }
            },
          ),
        ),
      ),
    );
    _loadCounts();
  }
}
