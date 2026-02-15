import 'package:flutter/material.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/7_moneySavingChallenge/money_saving_challenge_model.dart';
import 'package:disciplinum/services/7_moneySavingChallenge/money_saving_challenge_service.dart';
import 'package:disciplinum/widgets/notifications/notification_message_editor.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';

class MoneySavingChallengeNotificationsScreen extends StatefulWidget {
  const MoneySavingChallengeNotificationsScreen({super.key});

  @override
  State<MoneySavingChallengeNotificationsScreen> createState() =>
      _MoneySavingChallengeNotificationsScreenState();
}

class _MoneySavingChallengeNotificationsScreenState
    extends State<MoneySavingChallengeNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.moneySavingChallenge);
  final MoneySavingChallengeService _service = MoneySavingChallengeService();

  MoneySavingChallengeModel? _challenge;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
    await GamificationService.instance.scheduleChallengeNotification();
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
                    _buildSchedulingSection(isDark),
                    const SizedBox(height: 24),
                    const Text(
                      'Como funciona?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.savings_rounded,
                                  color: theme.colorScheme.primary, size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Configure lembretes para te motivar a poupar! As notificações são opcionais e servem apenas como incentivo.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.touch_app_rounded,
                                  color: theme.colorScheme.secondary, size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Lembre-se: este é um tracker manual. As marcações no grid refletem seus depósitos reais na vida real.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSchedulingSection(bool isDark) {
    if (_challenge == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
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
