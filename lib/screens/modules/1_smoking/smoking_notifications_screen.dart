import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/niche_id.dart';
import '../../../models/niche.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import '../../../screens/schedule_screen.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'frases_motivacionais.dart';
import 'package:disciplinum/widgets/notifications/notification_message_editor.dart';

class SmokingNotificationsScreen extends StatefulWidget {
  const SmokingNotificationsScreen({super.key});

  @override
  State<SmokingNotificationsScreen> createState() =>
      _SmokingNotificationsScreenState();
}

class _SmokingNotificationsScreenState
    extends State<SmokingNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.smoking);
  int _checkInCount = 0;
  int _motivationCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final checkInTimes =
        await CloudSyncService.loadUserNicheTimes(nicheId: _niche.id.id);
    final motivationTimes =
        await CloudSyncService.loadUserNicheTimes(nicheId: _niche.id.id + 100);

    if (mounted) {
      setState(() {
        _checkInCount = checkInTimes.length;
        _motivationCount = motivationTimes.length;
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
          title: const Text('Notificações'),
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
                    NotificationMessageEditor(nicheId: _niche.id),
                    const SizedBox(height: 24),
                    _buildSettingsCard(
                      title: 'Check-in Diário',
                      description: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Receba uma notificação para registrar se você resistiu ao hábito hoje. ',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'Permite 1 horário.',
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
                      count: _checkInCount,
                      max: 1,
                      onTap: () => _openSchedule(isMotivation: false),
                      leadingWidget: Image.asset(
                        'assets/icons/checkindiario.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsCard(
                      title: 'Frases Motivacionais',
                      description: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Receba lembretes automáticos nos horários que você mais sente vontade de fumar. ',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'Permite até 8 horários.',
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
                      count: _motivationCount,
                      max: 8,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const FrasesMotivacionaisScreen()),
                        ).then((_) => _loadCounts());
                      },
                      leadingWidget: Container(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/icons/frasesmotivacionais.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      color: Colors.orangeAccent,
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

  Future<void> _openSchedule({required bool isMotivation}) async {
    final nicheId = isMotivation ? _niche.id.id + 100 : _niche.id.id;
    final maxSlots = isMotivation ? 8 : 1;
    final title =
        isMotivation ? 'Horários de Motivação' : 'Horário de Check-in';

    final initialItems =
        await CloudSyncService.loadUserNicheTimes(nicheId: nicheId);
    final initialTimes = initialItems
        .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
        .toList();

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          args: ScheduleScreenArgs(
            nicheId: nicheId,
            maxSlots: maxSlots,
            title: title,
            initialTimes: initialTimes,
            onChanged: (times) {
              _loadCounts();
              // Notifica o GamificationService para recarregar
              Provider.of<GamificationService>(context, listen: false)
                  .restoreMonitoringSession();
            },
          ),
        ),
      ),
    );
  }
}
