import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/shared/widgets/progress/my_progress_widgets.dart';
import 'package:disciplinum/features/modules/diet/presentation/screens/diet_notifications_screen.dart';
import 'package:disciplinum/features/modules/diet/presentation/screens/meal_streak_screen.dart';
import 'package:disciplinum/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/shared/widgets/buttons/niche_action_button.dart';

class DietSettingsScreen extends StatefulWidget {
  final String? heroTag;
  const DietSettingsScreen({super.key, this.heroTag});

  @override
  State<DietSettingsScreen> createState() => _DietSettingsScreenState();
}

class _DietSettingsScreenState extends State<DietSettingsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.diet);
  final List<TimeOfDay> _times = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

  // --- CONTROLADOR DE PÁGINA ---
  late PageController _pageController;
  int _selectedIndex = 0; // 0=Como Funciona, 1=Ativar

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
          await CloudSyncService.loadUserNicheTimes(nicheId: nId.id);
      final status = await CloudSyncService.loadModuleStatus(nId);

      final times = userTimes
          .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
          .toList();

      if (mounted) {
        setState(() {
          _times.clear();
          _times.addAll(times);
          _gamificationRunning = status?.isActive ?? false;
          _loadingData = false;
        });

        if (_gamificationRunning) {
          final gamification =
              Provider.of<GamificationService>(context, listen: false);
          gamification.scheduleByModule[nId] = List.from(_times);

          final granted = await NotificationService.requestPermission();
          if (granted == true) {
            gamification.startMonitoringApps(
              nicheId: nId,
              horarios: _times,
            );
          } else {
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

    final gamification =
        Provider.of<GamificationService>(context, listen: false);

    gamification.startMonitoringApps(
      nicheId: _niche.nicheId,
      horarios: _times,
    );

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
    CloudSyncService.saveModuleStatus(
      nicheId: _niche.nicheId,
      isActive: true,
    );
    Provider.of<GamificationService>(context, listen: false)
        .startModuleCycle(nicheId: _niche.nicheId);
  }

  Future<void> _showNotificationSettingsDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão necessária'),
        content: const Text(
          'Para receber notificações do Disciplinum, habilite as notificações do app nas configurações do Android.',
        ),
        actions: [
          TextButton(
            child: const Text('Abrir configurações'),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              NotificationService.openNotificationSettings();
            },
          ),
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _desativarNichoMonitoramento() async {
    final confirmed = await DeactivateModuleDialog.show(
      context: context,
      nicheId: NicheId.diet,
      customMessage: "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado.\n\nDeseja continuar?",
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      final gamification =
          Provider.of<GamificationService>(context, listen: false);

      // Reset medals and deactivate
      gamification.resetMedals(
        _niche.nicheId,
        notificationTitle: 'Módulo Desativado 🛑',
        notificationBody:
            'O módulo foi desativado e todos os dados de estatística e gamificação foram resetados.',
        deactivate: true,
      );

      await CloudSyncService.removeAllTimesForNiche(nicheId: _niche.id + 100);
      await CloudSyncService.saveModuleStatus(
          nicheId: _niche.nicheId, isActive: false);

      if (mounted) {
        setState(() {
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

              await CloudSyncService.removeAllTimesForNiche(
                nicheId: _niche.id + 100,
              );
              for (var t in times) {
                await CloudSyncService.addUserNicheTime(
                  nicheId: _niche.id + 100,
                  hour: t.hour,
                  minute: t.minute,
                );
              }

              // Update gamification if module active
              if (mounted) {
                final gamification =
                    Provider.of<GamificationService>(context, listen: false);
                if (gamification.isModuleActive(_niche.nicheId)) {
                  gamification.scheduleByModule[_niche.nicheId] = List.from(_times);
                  gamification.startMonitoringApps(
                    nicheId: _niche.nicheId,
                    horarios: _times,
                  );
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

    await CloudSyncService.removeUserNicheTime(
      nicheId: _niche.id + 100,
      hour: time.hour,
      minute: time.minute,
    );

    if (mounted) {
      final gamification =
          Provider.of<GamificationService>(context, listen: false);
      if (gamification.isModuleActive(_niche.nicheId)) {
        gamification.scheduleByModule[_niche.nicheId] = List.from(_times);
        gamification.startMonitoringApps(
          nicheId: _niche.nicheId,
          horarios: _times,
        );
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
    final isDark = theme.brightness == Brightness.dark;

    if (_loadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_niche.name),
          centerTitle: true,
        ),
        body: Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark
                  ? const Color.fromARGB(255, 0, 0, 0)
                  : const Color.fromARGB(255, 230, 235, 255),
              isDark
                  ? const Color.fromARGB(255, 10, 15, 30)
                  : const Color.fromARGB(255, 255, 255, 255)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _niche.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
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
                          // TAB 0: Como Funciona
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildTabContent(0),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          // TAB 1: Horários
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
              _selectedIndex == 0
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTabActions(0),
                    )
                  : _buildBottomButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> options = ['Como funciona', 'Manter dieta'];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (_pageController.hasClients) {
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutQuad);
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFF6366F1).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  options[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black45),
                    letterSpacing: isSelected ? 0.3 : 0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (index) {
      case 0:
        return Column(
          children: [
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.schedule,
              title: 'Preencha seus horários de refeições',
              content:
                  'Defina os horários para que possamos te lembrar de manter o foco na sua dieta e registrar suas refeições.',
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.notifications_outlined,
              title: 'Em "Notificações", configure lembretes',
              content:
                  'Defina horários para ser lembrado de manter o foco na sua dieta e registrar suas refeições, respondendo às notificações se fez/fará ou não a refeição.',
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.bar_chart_rounded,
              title: 'Em "Estatísticas", veja seu progresso',
              content:
                  'Acompanhe o registro de refeições e visualize seu progresso geral do módulo.',
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Após preencher seus horários de refeições, ative o módulo para iniciar sua jornada de alimentação com regularidade.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            Text(
              'Seus horários de refeições:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (_times.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.schedule,
                        size: 40,
                        color: isDark ? Colors.white24 : Colors.black12),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum horário definido',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF6366F1),
                      ),
                    ),
                    onDeleted: () => _removeSchedule(time),
                    deleteIconColor: isDark
                        ? Colors.white70
                        : const Color(0xFF6366F1).withValues(alpha: 0.7),
                    backgroundColor:
                        (isDark ? Colors.white : const Color(0xFF6366F1))
                            .withValues(alpha: 0.1),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            const Text(
              'ATENÇÃO: Este módulo vai te notificar 30 min antes do horário definido. Pra dar tempo de preparar ou esquentar sua refeição',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }


  Widget _buildTabActions(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (index) {
      case 0:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: NicheActionButton(
            icon: Icons.rocket_launch_rounded,
            label: 'Começar',
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: () {
              if (_pageController.hasClients) {
                _pageController.animateToPage(1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic);
              }
            },
          ),
        );
      case 1:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: NicheActionButton(
            icon: Icons.schedule_rounded,
            label: 'Gerenciar horários',
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DietNotificationsScreen()),
              ).then((_) => _loadAllPersistentData());
            },
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: NicheActionButton(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Horários',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: () {
                    _openScheduleManager();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NicheActionButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DietNotificationsScreen(),
                      ),
                    ).then((_) => _loadAllPersistentData());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NicheActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estatísticas',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _showStatisticsMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NicheActionButton(
                  icon: _gamificationRunning
                      ? Icons.power_settings_new
                      : Icons.power_off,
                  label: _gamificationRunning
                      ? 'Desativar Módulo'
                      : 'Ativar Módulo',
                  color: _gamificationRunning ? Colors.red : Colors.green,
                  isDark: isDark,
                  isDestructive: _gamificationRunning,
                  onTap: _gamificationRunning
                      ? _desativarNichoMonitoramento
                      : _ativarNichoMonitoramento,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showStatisticsMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListActionTile(
              icon: Icons.restaurant_rounded,
              label: 'Registro de refeições',
              color: Colors.green,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealStreakScreen(scheduledTimes: _times),
                  ),
                );
              },
            ),
            ListActionTile(
              icon: Icons.bar_chart_rounded,
              label: 'Conquistas',
              color: Colors.blue,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProgressDiet()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
