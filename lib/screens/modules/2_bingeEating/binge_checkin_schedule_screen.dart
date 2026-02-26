import 'package:flutter/material.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/screens/schedule_screen.dart';

class BingeCheckinScheduleScreen extends StatefulWidget {
  const BingeCheckinScheduleScreen({super.key});

  @override
  State<BingeCheckinScheduleScreen> createState() => _BingeCheckinScheduleScreenState();
}

class _BingeCheckinScheduleScreenState extends State<BingeCheckinScheduleScreen> {
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
        await CloudSyncService.loadUserNicheTimes(nicheId: _niche.id.id + 200);

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
                    _buildInfoCard(isDark),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline, color: Colors.green, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            'Como funciona?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você receberá uma notificação diária nos horários configurados com duas opções de resposta rápida:\n\n• "Resisti às tentações" - Registra um dia de sucesso\n• "Não resisti" - Reseta suas estatísticas',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.6,
            ),
          ),
        ],
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
    final existingTimes = await CloudSyncService.loadUserNicheTimes(nicheId: _niche.id.id + 200);

    if (!mounted) return;

    // Verifica se o context ainda é válido antes de usar
    if (!navigatorContext.mounted) return;

    await Navigator.push(
      navigatorContext,
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          args: ScheduleScreenArgs(
            nicheId: _niche.id.id + 200, // ID específico para check-in
            maxSlots: 3,
            title: 'Check-in Diário',
            initialTimes: existingTimes.map((t) => TimeOfDay(hour: t.hour, minute: t.minute)).toList(),
            onChanged: (times) {
              // Salva os novos horários
              CloudSyncService.removeAllTimesForNiche(nicheId: _niche.id.id + 200);
              for (final time in times) {
                CloudSyncService.addUserNicheTime(
                  nicheId: _niche.id.id + 200,
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
