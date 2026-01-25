import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/screens/schedule_screen.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/widgets/notifications/notification_message_editor.dart';

class DietNotificationsScreen extends StatefulWidget {
  const DietNotificationsScreen({super.key});

  @override
  State<DietNotificationsScreen> createState() =>
      _DietNotificationsScreenState();
}

class _DietNotificationsScreenState extends State<DietNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.diet);
  final List<TimeOfDay> _times = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimes();
  }

  Future<void> _loadTimes() async {
    final userTimes =
        await CloudSyncService.loadUserNicheTimes(nicheId: _niche.id.id);

    if (mounted) {
      setState(() {
        _times.clear();
        _times.addAll(
            userTimes.map((t) => TimeOfDay(hour: t.hour, minute: t.minute)));
        _isLoading = false;
      });
    }
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _removeSchedule(TimeOfDay time) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _times.remove(time);
    });

    await CloudSyncService.removeUserNicheTime(
      nicheId: _niche.id.id,
      hour: time.hour,
      minute: time.minute,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Horário removido: ${_formatTime(time)}'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Update GamificationService if active
      _updateGamificationService();
    }
  }

  Future<void> _openSchedule() async {
    HapticFeedback.selectionClick();
    if (_niche.maxSlots == null) return;

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          args: ScheduleScreenArgs(
            maxSlots: 8, // Explicit 8 slots as requested
            initialTimes: List.from(_times),
            onChanged: (times) async {
              setState(() {
                _times
                  ..clear()
                  ..addAll(times);
              });

              await CloudSyncService.removeAllTimesForNiche(
                nicheId: _niche.id.id,
              );
              for (var t in times) {
                await CloudSyncService.addUserNicheTime(
                  nicheId: _niche.id.id,
                  hour: t.hour,
                  minute: t.minute,
                );
              }

              _updateGamificationService();
            },
            nicheId: _niche.id.id,
          ),
        ),
      ),
    );
  }

  void _updateGamificationService() {
    // If the module is running, update the schedule in the service
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    if (gamification.isModuleActive(_niche.id)) {
      gamification.scheduleByModule[_niche.id] = List.from(_times);
      gamification.startMonitoringApps(
        nicheId: _niche.id,
        horarios: _times,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotificationMessageEditor(nicheId: _niche.id),
                    const SizedBox(height: 24),
                    const Text(
                      "ATENÇÃO: Este módulo vai te notificar 30 min antes do horário definido. Pra dar tempo de preparar ou esquentar sua refeição",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Horários de Refeição (Máx 8):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_times.isEmpty)
                      NeonCard(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Text(
                            'Nenhum horário definido ainda.',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDark ? Colors.white60 : Colors.black54),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _times.map((time) {
                          return InputChip(
                            visualDensity: VisualDensity.compact,
                            label: Text(
                              _formatTime(time),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF6366F1),
                              ),
                            ),
                            onDeleted: () => _removeSchedule(time),
                            deleteIconColor: isDark
                                ? Colors.white70
                                : const Color(0xFF6366F1)
                                    .withValues(alpha: 0.7),
                            backgroundColor: (isDark
                                    ? Colors.white
                                    : const Color(0xFF6366F1))
                                .withValues(alpha: 0.1),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: GlowingButton(
                        text: 'Adicionar horários',
                        color: const Color.fromARGB(255, 57, 92, 208),
                        onPressed: _openSchedule,
                        borderRadius: 18,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
