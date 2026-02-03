import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/screens/schedule_screen.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/widgets/notifications/notification_message_editor.dart';

class ProcrastinationNotificationsScreen extends StatefulWidget {
  const ProcrastinationNotificationsScreen({super.key});

  @override
  State<ProcrastinationNotificationsScreen> createState() =>
      _ProcrastinationNotificationsScreenState();
}

class _ProcrastinationNotificationsScreenState
    extends State<ProcrastinationNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.procrastination);
  int _checkInCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final checkInTimes =
        await CloudSyncService.loadUserNicheTimes(nicheId: _niche.id.id);

    if (mounted) {
      setState(() {
        _checkInCount = checkInTimes.length;
        _isLoading = false;
      });
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
                  children: [
                    // Editor de Mensagem (Padrão do App)
                    NotificationMessageEditor(nicheId: _niche.id),
                    const SizedBox(height: 32),

                    // Seletor de Horário
                    _buildSettingsCard(
                      title: 'Lembrete Diário',
                      description: const Text(
                        "Defina um horário para o Disciplinum te lembrar de checar seus itens agendados:",
                        style: TextStyle(fontSize: 13),
                      ),
                      count: _checkInCount,
                      onTap: _openSchedule,
                      icon: Icons.access_time_filled_rounded,
                      color: const Color(0xFF6366F1),
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
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NeonCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                      ? 'Horário configurado'
                      : 'Nenhum horário configurado',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: count > 0
                        ? color
                        : (isDark ? Colors.white60 : Colors.black45),
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
    final nicheId = _niche.id.id; // ID 8

    final initialItems =
        await CloudSyncService.loadUserNicheTimes(nicheId: nicheId);
    final initialTimes = initialItems
        .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
        .toList();

    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          args: ScheduleScreenArgs(
            nicheId: nicheId,
            maxSlots: 1,
            title: 'Lembrete Diário',
            initialTimes: initialTimes,
            onChanged: (times) {
              _loadCount();
              // Notifica o GamificationService para recarregar e reagendar
              Provider.of<GamificationService>(context, listen: false)
                  .restoreMonitoringSession();
            },
          ),
        ),
      ),
    );
  }
}
