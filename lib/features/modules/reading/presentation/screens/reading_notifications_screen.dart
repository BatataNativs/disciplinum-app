import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/schedule/presentation/screens/schedule_screen.dart';

class ReadingNotificationsScreen extends ConsumerStatefulWidget {
  const ReadingNotificationsScreen({super.key});

  @override
  ConsumerState<ReadingNotificationsScreen> createState() =>
      _ReadingNotificationsScreenState();
}

class _ReadingNotificationsScreenState
    extends ConsumerState<ReadingNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.reading);
  int _reminderCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final reminderTimes =
        await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(nicheId: _niche.id);

    if (mounted) {
      setState(() {
        _reminderCount = reminderTimes.length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Notificações',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: colorScheme.onSurface,
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção: Lembrete Diário
                    _buildSectionHeader(
                      title: 'Lembrete Diário',
                      subtitle: 'Configure seus horários de acompanhamento',
                      icon: Icons.menu_book_rounded,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildReminderCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6),
                const Color(0xFF2563EB),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        // Abre diretamente o seletor de horas (ScheduleScreen carrega horários automaticamente)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScheduleScreen(
              args: ScheduleScreenArgs(
                nicheId: _niche.nicheId.id, // ID 9
                maxSlots: 1,
                title: 'Lembrete Diário',
                initialTimes: [], // ScheduleScreen carrega automaticamente
                onChanged: (times) {
                  // Salva os novos horários
                  ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(
                      nicheId: _niche.id);
                  for (final time in times) {
                    ref.read(cloudSyncServiceProvider).addUserNicheTime(
                      nicheId: _niche.id,
                      hour: time.hour,
                      minute: time.minute,
                      phrase: '📚 Hora da leitura diária! Mantenha sua mente ativa.',
                    );
                  }
                  // Reagendar notificações localmente
                  NotificationService.scheduleNotification(
                    id: _niche.id + 1000,
                    title: '📚 Hora da leitura!',
                    body: 'Mantenha sua mente ativa com leitura diária.',
                    scheduledDate: DateTime.now().add(const Duration(minutes: 1)),
                  );
                  // Atualiza o contador
                  _loadCount();
                },
              ),
            ),
          ),
        ).then((_) {
          // Força atualização ao voltar do ScheduleScreen
          _loadCount();
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withValues(alpha: 0.05),
              Colors.purple.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.purple.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple,
                        Colors.purple.shade700,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configurar Horário',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Defina um horário para ser lembrado de seguir com seu hábito de leitura diária',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.purple,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.tertiary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: Colors.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _reminderCount > 0
                        ? '$_reminderCount horário configurado'
                        : 'Nenhum horário configurado',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _reminderCount > 0
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
