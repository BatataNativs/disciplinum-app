import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/shared/widgets/dialogs/permission_dialog.dart';
import 'package:disciplinum/features/modules/diet/presentation/screens/diet_notifications_screen.dart';
import 'package:disciplinum/features/modules/diet/presentation/screens/meal_streak_screen.dart';
import 'package:disciplinum/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:disciplinum/features/modules/diet/presentation/providers/meal_tracking_provider.dart';
import 'package:disciplinum/features/modules/diet/gamification/presentation/providers/diet_gamification_provider.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/features/modules/diet/presentation/widgets/my_progress_diet.dart' as diet_progress;
import 'package:disciplinum/features/modules/diet/gamification/presentation/widgets/diet_celebration_widget.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/shared/widgets/common/module_screen_header.dart';

class DietSettingsScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const DietSettingsScreen({super.key, this.heroTag});

  @override
  ConsumerState<DietSettingsScreen> createState() => _DietSettingsScreenState();
}

class _DietSettingsScreenState extends ConsumerState<DietSettingsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.diet);
  final List<TimeOfDay> _times = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

  // Função para determinar período do dia
  String _getDayPeriod(int hour) {
    if (hour >= 0 && hour < 6) {
      return 'Madrugada';
    } else if (hour >= 6 && hour < 12) {
      return 'Manhã';
    } else if (hour >= 12 && hour < 18) {
      return 'Tarde';
    } else {
      return 'Noite';
    }
  }

  // Função para organizar horários por período
  Map<String, List<TimeOfDay>> _organizeTimesByPeriod() {
    final Map<String, List<TimeOfDay>> periodMap = {
      'Manhã': [],
      'Tarde': [],
      'Noite': [],
      'Madrugada': [],
    };

    for (final time in _times) {
      final period = _getDayPeriod(time.hour);
      periodMap[period]!.add(time);
    }

    // Ordenar horários dentro de cada período
    for (final period in periodMap.keys) {
      periodMap[period]!.sort((a, b) => a.hour.compareTo(b.hour));
    }

    return periodMap;
  }

  // --- CONTROLADOR DE PÁGINA ---
  late PageController _pageController;
  int _selectedIndex = 0; // 0=Manter dieta, 1=Como funciona

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0); // Garante que inicie na aba "Manter dieta"
    _loadAllPersistentData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- HARDCODED TEXTS FOR DIET ---

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      final nId = _niche.nicheId;
      final userTimes =
          await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(nicheId: nId.id + 100);

      final times = userTimes
          .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
          .toList();

      // Carrega estado do novo sistema de gamificação
      final gamificationState = ref.read(dietGamificationNotifierProvider);
      final isModuleActive = gamificationState.isModuleActive;

      if (mounted) {
        setState(() {
          _times.clear();
          _times.addAll(times);
          _gamificationRunning = isModuleActive;
          _loadingData = false;
        });

        if (_gamificationRunning) {
          final granted = await NotificationService.requestPermission();
          if (granted != true) {
            setState(() => _gamificationRunning = false);
          }
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar dados', error: e);
      if (mounted) {
        setState(() {
          _loadingData = false;
        });
      }
    } finally {
      _isLoadingData = false;
    }
  }

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();

    // VALIDAÇÃO: Verificar se configurou pelo menos um horário
    if (_times.isEmpty) {
      EnhancedSnackBarHelper.showWarning(
        context,
        "Configure pelo menos um horário de refeição.",
      );
      return;
    }

    // Diet module is mostly notification based (schedule), but logic check permission too
    // For consistency we check notification perms.

    final granted = await NotificationService.requestPermission();

    if (!mounted) return;

    if (granted == true) {
      _startGamificationCycle();
    } else {
      _showNotificationSettingsDialog();
    }
  }

  void _startGamificationCycle() {
    HapticFeedback.heavyImpact();
    setState(() {
      _gamificationRunning = true;
    });
    ref.read(cloudSyncServiceProvider).saveModuleStatus(
      nicheId: _niche.nicheId,
      isModuleActive: true,
    );
    // Usando novo sistema de gamificação - CORRETO: usar .notifier
    final gamificationNotifier = ref.read(dietGamificationNotifierProvider.notifier);
    // Ativa o módulo no novo sistema de gamificação
    LoggerService.instance.i('Diet: Módulo ativado com novo sistema de gamificação');
    gamificationNotifier.activateModule();
  }

  Future<void> _showNotificationSettingsDialog() async {
    context.showNotificationPermissionDialog(
      onOpenSettings: () => NotificationService.openNotificationSettings(),
    );
  }

  void _desativarNichoMonitoramento() async {
    // Usando novo sistema de gamificação - CORRETO: usar .notifier para métodos
    final gamificationNotifier = ref.read(dietGamificationNotifierProvider.notifier);
    final confirmed = await DeactivateModuleDialog.show(
      context: context,
      nicheId: NicheId.diet,
      customMessage: "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado. Deseja continuar?",
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      
      // Desativa o módulo no novo sistema de gamificação
      LoggerService.instance.i('Diet: Desativando módulo com novo sistema de gamificação');
      await gamificationNotifier.deactivateModule();
      
      // Reseta o progresso (preserva apenas insígnia Madeira)
      LoggerService.instance.i('Diet: Resetando progresso (preservando Madeira)');
      await gamificationNotifier.resetProgress();

      // Limpa todas as refeições do dia atual (conforme documentação)
      LoggerService.instance.i('Diet: Limpando refeições do dia atual');
      final mealTrackingNotifier = ref.read(mealTrackingProvider.notifier);
      await mealTrackingNotifier.clearTodayMeals();

      setState(() {
        _gamificationRunning = false;
        _selectedIndex = 0;
      });

      await ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(nicheId: _niche.id + 100);
      await ref.read(cloudSyncServiceProvider).saveModuleStatus(
          nicheId: _niche.nicheId, isModuleActive: false);

      if (mounted) {
        setState(() {
          _times.clear();
          _gamificationRunning = false;
          _selectedIndex = 0;
        });

        if (_pageController.hasClients) {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic);
        }

        EnhancedSnackBarHelper.showError(
          context,
          "Módulo desativado",
        );
      }
    }
  }

  Future<void> _openScheduleManager() async {
    HapticFeedback.selectionClick();
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          args: ScheduleScreenArgs(
            maxSlots: 8,
            initialTimes: List.from(_times),
            onChanged: (times) async {
              setState(() {
                _times
                  ..clear()
                  ..addAll(times);
              });

              await ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(
                nicheId: _niche.id + 100,
              );
              for (var t in times) {
                await ref.read(cloudSyncServiceProvider).addUserNicheTime(
                  nicheId: _niche.id + 100,
                  hour: t.hour,
                  minute: t.minute,
                );
              }

              // Update gamification if module active
              if (mounted) {
                // Usando novo sistema de gamificação para notificações
                final gamificationState = ref.read(dietGamificationNotifierProvider);
                if (_gamificationRunning && gamificationState.gamification != null) {
                  LoggerService.instance.i('Diet: Atualizando notificações');
                }
              }
            },
            nicheId: _niche.id + 100,
          ),
        ),
      ),
    );
  }

  Future<void> _removeSchedule(TimeOfDay time) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _times.remove(time);
    });

    await ref.read(cloudSyncServiceProvider).removeUserNicheTime(
      nicheId: _niche.id + 100,
      hour: time.hour,
      minute: time.minute,
    );

    if (mounted) {
      // Usando novo sistema de gamificação
      final gamificationState = ref.read(dietGamificationNotifierProvider);
      if (gamificationState.gamification != null) {
        LoggerService.instance.i('Diet: Horário removido, verificando estado');
      }
      
      EnhancedSnackBarHelper.showInfo(
          context,
          'Horário removido: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_niche.name),
          centerTitle: true,
        ),
        body: Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest,
          highlightColor: colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 60, width: double.infinity, color: Colors.white),
                const SizedBox(height: 16),
                Container(height: 20, width: 200, color: Colors.white),
                const SizedBox(height: 8),
                Container(
                    height: 40, width: double.infinity, color: Colors.white),
                const SizedBox(height: 16),
                Container(
                    height: 50, width: double.infinity, color: Colors.white),
              ],
            ),
          ),
        ),
      );
    }

    return DietCelebrationWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
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
          child: SafeArea(
            child: Column(
              children: [
                // Header padrão como outros módulos
                ModuleScreenHeader(
                  title: _niche.name,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: _buildSegmentedControl(),
                      ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          children: [
                          // TAB 0: Manter dieta (módulo)
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildTabContent(0),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          // TAB 1: Como funciona
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildTabContent(1),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Botões apenas na aba 0 (Manter dieta)
              if (_selectedIndex == 0)
                _buildActionButtons(),
            ],
          ),
        ),
      ),
    )
  );
  }

  Widget _buildSegmentedControl() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: _selectedIndex == 0 ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ) : null,
                  color: _selectedIndex == 0 ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Manter dieta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.3,
                      color: _selectedIndex == 0 ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: _selectedIndex == 1 ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ) : null,
                  color: _selectedIndex == 1 ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Como funciona',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.3,
                      color: _selectedIndex == 1 ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (index) {
      case 0:
        // 0: Manter dieta (módulo)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com stats
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  final gamificationState = ref.watch(dietGamificationNotifierProvider);
                  final totalMeals = _times.length;
                  final streakDays = gamificationState.currentStreak;
                  
                  return Row(
                    children: [
                      _buildStatCard('$totalMeals', 'Refeições', const Color(0xFF8B5CF6), Icons.restaurant_rounded),
                      const SizedBox(width: 12),
                      _buildStatCard('$streakDays', 'Dias', const Color(0xFF10B981), Icons.local_fire_department_rounded),
                      const SizedBox(width: 12),
                      _buildStatCard('$totalMeals', 'Ativos', const Color(0xFFF59E0B), Icons.calendar_today_rounded),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Seção de horários
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Horários de Refeição',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openScheduleManager,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add,
                            color: const Color(0xFF8B5CF6),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_times.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: const Color(0xFF6B7280),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Nenhum horário configurado',
                              style: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._organizeTimesByPeriod().entries.map((entry) {
                      if (entry.value.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: entry.value.map((time) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8B5CF6),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _removeSchedule(time),
                                      child: Icon(
                                        Icons.close,
                                        color: const Color(0xFF8B5CF6),
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Seção de estatísticas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estatísticas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListActionTile(
                    icon: Icons.bar_chart,
                    label: 'Registro de Refeições',
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealStreakScreen(scheduledTimes: _times),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        // 1: Como funciona
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Como Funciona',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHowItWorksItem(
                    '1. Configure seus horários',
                    'Defina os horários das suas refeições diárias.',
                    Icons.schedule,
                  ),
                  const SizedBox(height: 12),
                  _buildHowItWorksItem(
                    '2. Receba notificações',
                    'Seja lembrado 30 minutos antes de cada refeição.',
                    Icons.notifications,
                  ),
                  const SizedBox(height: 12),
                  _buildHowItWorksItem(
                    '3. Confirme suas refeições',
                    'Marque se fez a refeição no horário correto.',
                    Icons.check_circle,
                  ),
                  const SizedBox(height: 12),
                  _buildHowItWorksItem(
                    '4. Acompanhe seu progresso',
                    'Veja suas estatísticas e conquistas.',
                    Icons.trending_up,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gamificação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGamificationItem(
                    '🪵 Madeira',
                    'Início da Jornada',
                    'Ative o módulo',
                  ),
                  const SizedBox(height: 8),
                  _buildGamificationItem(
                    '🥈 Ferro',
                    'Primeiro Dia',
                    '1 dia cumprindo horários',
                  ),
                  const SizedBox(height: 8),
                  _buildGamificationItem(
                    '🥈 Alumínio',
                    'Dois Dias',
                    '2 dias seguidos',
                  ),
                  const SizedBox(height: 8),
                  _buildGamificationItem(
                    '🥇 Latão',
                    'Quatro Dias',
                    '4 dias seguidos',
                  ),
                  const SizedBox(height: 8),
                  _buildGamificationItem(
                    '🥉 Bronze',
                    'Oito Dias',
                    '8 dias seguidos',
                  ),
                  const SizedBox(height: 8),
                  _buildGamificationItem(
                    '🥈 Prata',
                    'Doze Dias',
                    '12 dias seguidos',
                  ),
                  const SizedBox(height: 8),
                  _buildGamificationItem(
                    '🥇 Ouro',
                    'Dezoito Dias',
                    '18 dias seguidos',
                  ),
                  const SizedBox(height: 8),
                  _buildGamificationItem(
                    '💎 Diamante',
                    'Vinte e Seis Dias',
                    '26 dias seguidos',
                  ),
                  const SizedBox(height: 8),
                  _buildGamificationItem(
                    '🎱 Disciplinum',
                    'Trinta Dias',
                    '30 dias seguidos',
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF8B5CF6),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGamificationItem(String emoji, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Botão principal de ativar/desativar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _gamificationRunning ? _desativarNichoMonitoramento() : _ativarNichoMonitoramento(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gamificationRunning ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _gamificationRunning ? 'Desativar Módulo' : 'Ativar Módulo',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Botões secundários
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DietNotificationsScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Notificações'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => diet_progress.MyProgressDiet(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Conquistas'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
