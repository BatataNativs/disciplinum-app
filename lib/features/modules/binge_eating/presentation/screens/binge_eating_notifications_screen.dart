import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/notifications/presentation/widgets/notification_message_editor.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
            isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
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
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
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
                    // Seção: Texto da Notificação
                    _buildSectionHeader(
                      title: 'Texto da Notificação',
                      subtitle:
                          'Que chegará sempre que você abrir um dos apps selecionados para monitoramento com o módulo ativado.',
                      icon: Icons.message_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    NotificationMessageEditor(nicheId: _niche.nicheId),
                    const SizedBox(height: 8),

                    // Como funciona - Notificações
                    _buildMinimalInfoCard(
                      description:
                          'A notificação chegará automaticamente sempre que você abrir um dos aplicativos selecionados para monitoramento.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),

                    // Seção: Check-in Diário
                    _buildSectionHeader(
                      title: 'Check-in Diário',
                      subtitle: 'Configure seus horários de acompanhamento',
                      icon: Icons.no_food_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildCheckinCard(),
                    const SizedBox(height: 8),

                    // Como funciona - Check-in
                    _buildMinimalInfoCard(
                      description:
                          'Receba notificação diária no horário configurado. Responda "Resisti às tentações" para registrar seu progresso ou "Não resisti" para resetar as estatísticas.',
                      isDark: isDark,
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
    required bool isDark,
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
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
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
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                          color:
                              isDark ? Colors.white : const Color(0xFF1E293B),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Configure horário para seu \ncheck-in diário',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF64748B),
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
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.8),
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
                          ? Colors.black
                          : isDark
                              ? Colors.white70
                              : const Color(0xFF64748B),
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
