import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/schedule/presentation/screens/schedule_screen.dart';

class BingeEatingNotificationsScreen extends ConsumerStatefulWidget {
  const BingeEatingNotificationsScreen({super.key});

  @override
  ConsumerState<BingeEatingNotificationsScreen> createState() =>
      _BingeEatingNotificationsScreenState();
}

class _BingeEatingNotificationsScreenState
    extends ConsumerState<BingeEatingNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.bingeEating);
  int _checkinCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    // Carrega horários de check-in (ID + 200)
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
                    // Seção: Check-in Diário
                    _buildSectionHeader(
                      title: 'Check-in Diário',
                      subtitle: 'Configure seus horários de acompanhamento',
                      icon: Icons.no_food_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildCheckinCard(),
                    const SizedBox(height: 8),

                    // Como funciona - Check-in
                    _buildMinimalInfoCard(
                      description:
                          'Receba notificação diária no horário configurado. Responda "Resisti às tentações" para registrar seu progresso ou "Não resisti" para resetar as estatísticas.',
                    ),
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
  }) {
    final colorScheme = Theme.of(context).colorScheme;
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

  Widget _buildMinimalInfoCard({
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 12,
          color: const Color(0xFF64748B),
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildCheckinCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        // Abre diretamente o seletor de horas (ScheduleScreen carrega horários automaticamente)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScheduleScreen(
              args: ScheduleScreenArgs(
                nicheId: _niche.id + 200, // ID específico para check-in
                maxSlots: 3,
                title: 'Check-in Diário',
                initialTimes: [], // ScheduleScreen carrega automaticamente
                onChanged: (times) async {
                  // Salva os novos horários
                  ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(
                      nicheId: _niche.id + 200);
                  for (final time in times) {
                    ref.read(cloudSyncServiceProvider).addUserNicheTime(
                      nicheId: _niche.id + 200,
                      hour: time.hour,
                      minute: time.minute,
                      phrase: 'Você resistiu às tentações de delivery hoje?',
                    );
                  }
                  // Reagendar notificações localmente
                  NotificationService.scheduleNotification(
                    id: _niche.id + 2000,
                    title: '🥗 Check-in de alimentação!',
                    body: 'Você resistiu às tentações de delivery hoje?',
                    scheduledDate: DateTime.now().add(const Duration(minutes: 1)),
                  );
                  // Atualiza o contador
                  _loadCounts();
                },
              ),
            ),
          ),
        ).then((_) {
          // Força atualização ao voltar do ScheduleScreen
          _loadCounts();
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.withValues(alpha: 0.05),
              Colors.green.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.15),
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
                        Colors.green,
                        Colors.green.shade700,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.no_food_rounded,
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
                        'Configure horário para seu \ncheck-in diário',
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
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _checkinCount > 0
                        ? '$_checkinCount horário configurado'
                        : 'Nenhum horário configurado',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _checkinCount > 0
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.7),
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
