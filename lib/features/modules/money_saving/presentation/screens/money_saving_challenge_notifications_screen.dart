import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/notifications/presentation/widgets/notification_message_editor.dart';
import 'package:disciplinum/core/di/providers.dart';

class MoneySavingChallengeNotificationsScreen extends ConsumerStatefulWidget {
  const MoneySavingChallengeNotificationsScreen({super.key});

  @override
  ConsumerState<MoneySavingChallengeNotificationsScreen> createState() =>
      _MoneySavingChallengeNotificationsScreenState();
}

class _MoneySavingChallengeNotificationsScreenState
    extends ConsumerState<MoneySavingChallengeNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.moneySavingChallenge);
  late final MoneySavingChallengeService _service;

  MoneySavingChallengeModel? _challenge;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = MoneySavingChallengeService(IsarPreferencesRepository(IsarService.instance.database));
    _loadData();
  }

  Future<void> _loadData() async {
    final challenge = await _service.getActiveChallenge();
    if (mounted) {
      setState(() {
        _challenge = challenge;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings(MoneySavingChallengeModel newChallenge) async {
    setState(() => _challenge = newChallenge);
    await _service.saveChallenge(newChallenge);

    // Agenda as notificações nativas
    if (mounted) {
      await ref.read(gamificationServiceProvider).scheduleChallengeNotification();
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

                    // Seção: Lembretes do Desafio
                    _buildSectionHeader(
                      title: 'Lembretes do Desafio',
                      subtitle: 'Configure lembretes para te motivar a poupar',
                      icon: Icons.savings_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildSchedulingSection(isDark),
                    const SizedBox(height: 8),

                    // Como funciona - Desafio
                    _buildMinimalInfoCard(
                      description:
                          'Configure lembretes para te motivar a poupar! As notificações são opcionais e servem apenas como incentivo.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildMinimalInfoCard(
                      description:
                          'Lembre-se: este é um tracker manual. As marcações no grid devem refletir seus depósitos reais na vida real, em instituições financeiras de sua escolha, conforme você os informa no app.',
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

  Widget _buildSchedulingSection(bool isDark) {
    if (_challenge == null) return const SizedBox();

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frequência de lembretes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _challenge!.notifFrequency,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items: const [
              DropdownMenuItem(value: 'disabled', child: Text('Desativado')),
              DropdownMenuItem(value: 'diario', child: Text('Diariamente')),
              DropdownMenuItem(value: 'semanal', child: Text('Semanalmente')),
              DropdownMenuItem(value: 'mensal', child: Text('Mensalmente')),
            ],
            onChanged: (value) {
              if (value != null) {
                _updateSettings(_challenge!.copyWith(notifFrequency: value));
              }
            },
          ),
          if (_challenge!.notifFrequency != 'disabled') ...[
            const SizedBox(height: 16),
            const Text(
              'Horário',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: isDark ? Colors.white24 : Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_challenge!.notifTime,
                        style: const TextStyle(fontSize: 16)),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
          ],
          if (_challenge!.notifFrequency == 'semanal') ...[
            const SizedBox(height: 16),
            const Text(
              'Dia da semana',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _challenge!.notifDayOfWeek,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Segunda-feira')),
                DropdownMenuItem(value: 2, child: Text('Terça-feira')),
                DropdownMenuItem(value: 3, child: Text('Quarta-feira')),
                DropdownMenuItem(value: 4, child: Text('Quinta-feira')),
                DropdownMenuItem(value: 5, child: Text('Sexta-feira')),
                DropdownMenuItem(value: 6, child: Text('Sábado')),
                DropdownMenuItem(value: 7, child: Text('Domingo')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(_challenge!.copyWith(notifDayOfWeek: value));
                }
              },
            ),
          ],
          if (_challenge!.notifFrequency == 'mensal') ...[
            const SizedBox(height: 16),
            const Text(
              'Dia do mês',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _challenge!.notifDayOfMonth,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: List.generate(28, (index) => index + 1).map((day) {
                return DropdownMenuItem(value: day, child: Text('Dia $day'));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(_challenge!.copyWith(notifDayOfMonth: value));
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final parts = _challenge!.notifTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final newTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _updateSettings(_challenge!.copyWith(notifTime: newTime));
    }
  }
}
