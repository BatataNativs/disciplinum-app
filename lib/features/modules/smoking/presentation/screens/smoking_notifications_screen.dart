import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/schedule/presentation/screens/schedule_screen.dart';

/// Tela de notificações motivacionais para o módulo Smoking
/// Frases adaptadas automaticamente baseadas no tempo sem fumar
class SmokingNotificationsScreen extends ConsumerStatefulWidget {
  const SmokingNotificationsScreen({super.key});

  @override
  ConsumerState<SmokingNotificationsScreen> createState() =>
      _SmokingNotificationsScreenState();
}

class _SmokingNotificationsScreenState
    extends ConsumerState<SmokingNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.smoking);
  
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  int _reminderCount = 0;
  int _daysWithoutSmoking = 0;

  // Key para persistência local
  static const String _notificationsEnabledKey = 'smoking_notifications_enabled';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefsRepo = ref.read(objectboxPreferencesRepositoryProvider);
      final prefsService = ref.read(preferencesServiceProvider);
      
      // Carregar estado das notificações
      final enabled = await prefsRepo.getBool(_notificationsEnabledKey) ?? true;
      
      // Calcular dias sem fumar baseado nas configurações do Smoking
      int days = 0;
      final smokingSettings = await prefsService.getSmokingSettings();
      if (smokingSettings != null && smokingSettings.quitDate != null) {
        days = DateTime.now().difference(smokingSettings.quitDate!).inDays;
      }
      
      // Carregar horários configurados
      final isGuest = await prefsService.isGuestMode();
      final times = isGuest
          ? await prefsService.loadUserNicheTimes(nicheId: _niche.id)
          : await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(
              nicheId: _niche.id);

      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
          _daysWithoutSmoking = days;
          _reminderCount = times.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar dados de notificações', error: e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    HapticFeedback.lightImpact();
    
    final prefsRepo = ref.read(objectboxPreferencesRepositoryProvider);
    await prefsRepo.setBool(_notificationsEnabledKey, enabled);
    
    if (!enabled) {
      // Cancelar todas as notificações do módulo
      await _cancelAllNotifications();
    } else if (_reminderCount > 0) {
      // Reagendar notificações existentes
      await _rescheduleNotifications();
    }
    
    if (mounted) {
      setState(() => _notificationsEnabled = enabled);
    }
  }

  Future<void> _cancelAllNotifications() async {
    // Cancelar notificações de lembrete (IDs 1001-1008)
    for (int i = 1; i <= 8; i++) {
      await NotificationService.cancelNotification(1000 + i);
    }
    
    // Cancelar notificação de check-in (ID 1000)
    await NotificationService.cancelNotification(1000);
  }

  Future<void> _rescheduleNotifications() async {
    // Reagendar notificações baseadas nos horários salvos
    final prefsService = ref.read(preferencesServiceProvider);
    final isGuest = await prefsService.isGuestMode();
    final times = isGuest
        ? await prefsService.loadUserNicheTimes(nicheId: _niche.id)
        : await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(
            nicheId: _niche.id);
    
    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      final phrase = _getMotivationalPhraseForTime(time.hour);
      
      await NotificationService.scheduleDailyNotification(
        id: 1001 + i,
        time: TimeOfDay(hour: time.hour, minute: time.minute),
        title: 'Disciplinum 🚭',
        body: phrase,
      );
    }
  }

  /// Gera frase motivacional baseada na hora e no tempo sem fumar
  String _getMotivationalPhraseForTime(int hour) {
    final phrases = _getPhrasesByCategory();
    
    // Selecionar categoria baseada na hora do dia
    if (hour >= 6 && hour < 12) {
      // Manhã: saúde e motivação
      return phrases['health']![_daysWithoutSmoking % phrases['health']!.length];
    } else if (hour >= 12 && hour < 15) {
      // Almoço: economia
      return phrases['money']![_daysWithoutSmoking % phrases['money']!.length];
    } else if (hour >= 15 && hour < 18) {
      // Tarde: dicas práticas (horário de risco)
      return phrases['tips']![hour % phrases['tips']!.length];
    } else if (hour >= 18 && hour < 22) {
      // Noite: conquistas e marcos
      return _getMilestonePhrase();
    } else {
      // Madrugada: motivação geral
      return phrases['motivation']![_daysWithoutSmoking % phrases['motivation']!.length];
    }
  }

  /// Frase especial para marcos importantes
  String _getMilestonePhrase() {
    if (_daysWithoutSmoking == 0) {
      return 'O primeiro passo é o mais importante. Você já começou! 💪';
    } else if (_daysWithoutSmoking == 1) {
      return '🎉 24 horas sem fumar! Seu coração já está batendo mais lentamente.';
    } else if (_daysWithoutSmoking == 3) {
      return '🌟 3 dias! Seu organismo está 90% livre de nicotina.';
    } else if (_daysWithoutSmoking == 7) {
      return '🏆 1 semana! Seu paladar e olfato já estão mais aguçados.';
    } else if (_daysWithoutSmoking == 14) {
      return '🎊 2 semanas! Sua circulação sanguínea melhorou significativamente.';
    } else if (_daysWithoutSmoking == 30) {
      return '🌟 1 mês! Seus pulmões estão funcionando 30% melhor.';
    } else if (_daysWithoutSmoking == 90) {
      return '🏅 3 meses! Seu risco de ataque cardíaco diminuiu drasticamente.';
    } else if (_daysWithoutSmoking == 180) {
      return '🎖️ 6 meses! Você economizou muito e sua saúde agradece.';
    } else if (_daysWithoutSmoking == 365) {
      return '🎉 1 ANO SEM FUMAR! Você é um campeão! 🏆';
    } else if (_daysWithoutSmoking % 30 == 0) {
      return '🌟 ${_daysWithoutSmoking ~/ 30} meses sem fumar! Sua disciplina é inspiradora!';
    } else if (_daysWithoutSmoking % 7 == 0) {
      return '🎊 ${_daysWithoutSmoking ~/ 7} semanas! Cada dia é uma nova vitória!';
    } else {
      return '$_daysWithoutSmoking dias sem fumar! Você está indo muito bem! 💪';
    }
  }

  /// Todas as frases categorizadas
  Map<String, List<String>> _getPhrasesByCategory() {
    return {
      'health': [
        'Seu coração já está batendo mais lentamente. Continue assim! ❤️',
        'Seus pulmões estão se limpando a cada hora sem fumaça. 🫁',
        'Sua circulação sanguínea melhorou 30% desde que você parou. 💓',
        'O risco de ataque cardíaco já começou a diminuir. 📉',
        'Seu paladar e olfato estão voltando ao normal! 👃',
        'Sua pele está ficando mais saudável a cada dia. ✨',
        'Seu cabelo está ficando mais forte e brilhante. 💇',
        'Sua respiração está ficando mais fácil e profunda. 🌬️',
      ],
      'money': [
        'Cada cigarro não fumado é dinheiro no bolso! 💰',
        'Sua carteira agradece. Seu futuro também. 💵',
        'Economize para o que realmente importa para você. 🎯',
        'Dinheiro guardado é liberdade conquistada. 🏦',
        'Você está investindo na sua saúde e na sua riqueza. 📈',
        'Imagine o que pode comprar com o que economizou! 🎁',
        'Cada real economizado é uma vitória dupla. 🏆',
        'Seu futuro financeiro está mais seguro a cada dia. 📊',
      ],
      'tips': [
        'Beba um copo d\'água. A vontade passa em 3 minutos. 💧',
        'Respire fundo 3 vezes. Você está no controle. 🧘',
        'Mude de ambiente. Saiu de casa? Volte já. 🚪',
        'Ligue para alguém que te apoia. Você não está sozinho. 📞',
        'Faça uma caminhada de 5 minutos. Ar fresco ajuda. 🚶',
        'Mastigue um chiclete. Mantenha a boca ocupada. 🍬',
        'Conte até 10 lentamente. A crise vai passar. 🔢',
        'Lave o rosto com água fria. Revitalize-se. 💦',
        'Estique o corpo por 2 minutos. Sinta-se renovado. 🧘‍♂️',
        'Escreva 3 motivos pelos quais você parou. ✍️',
        'Ouça sua música favorita. Deixe o stress de lado. 🎵',
        'Coma uma fruta. Saúde em dobro. 🍎',
      ],
      'motivation': [
        'Você é mais forte que o cigarro. Prove isso hoje! 💪',
        'Cada dia sem fumar é uma vitória. Você está vencendo! 🏆',
        'Lembre-se do porquê começou. Você consegue! 🎯',
        'A vontade passa. Os benefícios ficam. ✨',
        'Disciplina é escolher entre o que quer agora e o quer mais. 🎖️',
        'Você já venceu tantos desafios. Esse também vai passar. 🌟',
        'Seu corpo está agradecendo a cada segundo. ❤️',
        'Você está construindo um futuro mais saudável. 🌅',
        'Cada dia é uma nova chance de ser melhor. ☀️',
        'A mudança é difícil, mas vale cada segundo. 💎',
        'Você é um exemplo de determinação. Continue! 🌟',
        'O impossível é só questão de persistência. 🚀',
      ],
    };
  }

  Future<void> _openScheduleScreen() async {
    if (!_notificationsEnabled) {
      _showEnableNotificationsDialog();
      return;
    }

    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          args: ScheduleScreenArgs(
            nicheId: _niche.nicheId.id,
            maxSlots: 8,
            title: 'Lembretes Motivacionais',
            initialTimes: [],
            onChanged: (times) async {
              // Salvar horários
              final prefs = ref.read(preferencesServiceProvider);
              final isGuest = await prefs.isGuestMode();
              
              // Limpar horários antigos
              if (isGuest) {
                await prefs.removeAllTimesForNiche(nicheId: _niche.id);
              } else {
                await ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(
                    nicheId: _niche.id);
              }
              
              // Salvar novos horários
              for (int i = 0; i < times.length; i++) {
                final time = times[i];
                final phrase = _getMotivationalPhraseForTime(time.hour);
                
                if (isGuest) {
                  await prefs.addUserNicheTime(
                    nicheId: _niche.id,
                    hour: time.hour,
                    minute: time.minute,
                  );
                } else {
                  await ref.read(cloudSyncServiceProvider).addUserNicheTime(
                    nicheId: _niche.id,
                    hour: time.hour,
                    minute: time.minute,
                  );
                }
                
                // Agendar notificação local
                if (_notificationsEnabled) {
                  await NotificationService.scheduleDailyNotification(
                    id: 1001 + i,
                    time: time,
                    title: 'Disciplinum 🚭',
                    body: phrase,
                  );
                }
              }
              
              // Cancelar notificações excedentes
              for (int i = times.length; i < 8; i++) {
                await NotificationService.cancelNotification(1001 + i);
              }
              
              _loadData();
            },
          ),
        ),
      ),
    );
    
    if (result != null) {
      _loadData();
    }
  }

  void _showEnableNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificações Desabilitadas'),
        content: const Text(
          'Para configurar horários de lembretes, primeiro habilite as notificações no interruptor acima.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle principal - Habilitar/Desabilitar
                    _buildToggleCard(),
                    const SizedBox(height: 24),

                    // Seção: Lembretes Motivacionais
                    _buildSectionHeader(
                      title: 'Lembretes Motivacionais',
                      subtitle: 'Até 8 horários por dia com frases inspiradoras',
                      icon: Icons.notifications_active_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildRemindersCard(),
                    const SizedBox(height: 24),

                    // Seção: Como Funciona
                    _buildSectionHeader(
                      title: 'Como Funciona',
                      subtitle: 'Frases adaptadas ao seu progresso',
                      icon: Icons.question_mark_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildHowItWorksCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildToggleCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _notificationsEnabled
              ? [
                  const Color(0xFF6366F1).withValues(alpha: 0.15),
                  const Color(0xFF6366F1).withValues(alpha: 0.05),
                ]
              : [
                  Colors.grey.withValues(alpha: 0.1),
                  Colors.grey.withValues(alpha: 0.02),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _notificationsEnabled
              ? const Color(0xFF6366F1).withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _notificationsEnabled
                    ? [
                        const Color(0xFF6366F1),
                        const Color(0xFF4F46E5),
                      ]
                    : [
                        Colors.grey,
                        Colors.grey.shade600,
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
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
                  _notificationsEnabled
                      ? 'Notificações Ativadas'
                      : 'Notificações Desativadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _notificationsEnabled
                      ? 'Você receberá lembretes motivacionais'
                      : 'Nenhuma notificação será enviada',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
          ),
        ],
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
                const Color(0xFF6366F1),
                const Color(0xFF4F46E5),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
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

  Widget _buildRemindersCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _notificationsEnabled ? _openScheduleScreen : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _notificationsEnabled
                ? [
                    const Color(0xFF6366F1).withValues(alpha: 0.08),
                    const Color(0xFF6366F1).withValues(alpha: 0.02),
                  ]
                : [
                    Colors.grey.withValues(alpha: 0.05),
                    Colors.grey.withValues(alpha: 0.02),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _notificationsEnabled
                ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            width: 1.5,
          ),
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
                      colors: _notificationsEnabled
                          ? [
                              const Color(0xFF6366F1),
                              const Color(0xFF4F46E5),
                            ]
                          : [
                              Colors.grey,
                              Colors.grey.shade600,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    color: _notificationsEnabled ? Colors.white : Colors.white70,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configurar Horários',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _notificationsEnabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _notificationsEnabled
                            ? 'Defina até 8 horários para receber frases motivacionais'
                            : 'Ative as notificações acima para configurar',
                        style: TextStyle(
                          fontSize: 14,
                          color: _notificationsEnabled
                              ? colorScheme.onSurface.withValues(alpha: 0.7)
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_notificationsEnabled)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: const Color(0xFF6366F1),
                      size: 16,
                    ),
                  ),
              ],
            ),
            if (_notificationsEnabled) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFF6366F1),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _reminderCount > 0
                            ? '$_reminderCount horário configurado'
                            : 'Nenhum horário configurado ainda',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _reminderCount > 0
                              ? const Color(0xFF6366F1)
                              : colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    final phrases = _getPhrasesByCategory();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureItem(
            icon: Icons.access_time_filled_rounded,
            title: 'Frases por Horário',
            description: 'Manhã: Saúde | Almoço: Economia | Tarde: Dicas | Noite: Conquistas',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.auto_awesome_rounded,
            title: 'Frases Personalizadas',
            description: 'Baseadas nos seus \$_daysWithoutSmoking dias sem fumar',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.celebration_rounded,
            title: 'Marcos Especiais',
            description: '1 dia, 3 dias, 1 semana, 1 mês... Cada conquista celebrada!',
          ),
          const Divider(height: 32),
          Text(
            'Exemplos de frases:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          ...[
            phrases['health']![0],
            phrases['money']![0],
            phrases['motivation']![0],
          ].map((phrase) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF6366F1),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phrase,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
