import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/screens/binge_eating_notifications_screen.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/screens/days_without_food_delivery.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:disciplinum/shared/widgets/progress/my_progress_widgets.dart';
import 'package:disciplinum/core/utils/app_info_helper.dart';
import 'package:disciplinum/core/storage/preferences_service.dart';
import 'package:disciplinum/shared/models/user_niche_time.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/shared/widgets/sections/niche_checkin_section.dart';
import 'package:disciplinum/shared/widgets/buttons/niche_action_button.dart';
import 'dart:async';

class BingeEatingScreen extends StatefulWidget {
  final String? heroTag;
  const BingeEatingScreen({super.key, this.heroTag});

  @override
  State<BingeEatingScreen> createState() => _BingeEatingScreenState();
}

class _BingeEatingScreenState extends State<BingeEatingScreen>
    with WidgetsBindingObserver {
  final Niche _niche = NicheRepository.getById(NicheId.bingeEating);
  final List<String> _selectedApps = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

  // Cache dos horários como no módulo Focus
  TimeOfDay? _checkinTime;

  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _loadAllPersistentData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Força atualização quando a app volta para o primeiro plano
      if (mounted) {
        _reloadCheckinData();
      }
    }
  }

  @override
  void didUpdateWidget(BingeEatingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Força atualização quando o widget é reconstruído (volta de outras telas)
    if (mounted) {
      _reloadCheckinData();
    }
  }

  Future<void> _reloadCheckinData() async {
    try {
      final isGuest = await PreferencesService.isGuestMode();
      final List<UserNicheTime> checkinTimes;

      if (isGuest) {
        checkinTimes = await PreferencesService.loadUserNicheTimes(
            nicheId: _niche.id + 200);
      } else {
        checkinTimes = await CloudSyncService.loadUserNicheTimes(
            nicheId: _niche.id + 200);
      }

      TimeOfDay? newCheckinTime;
      if (checkinTimes.isNotEmpty) {
        newCheckinTime = TimeOfDay(
            hour: checkinTimes[0].hour, minute: checkinTimes[0].minute);
      }

      // Só atualiza se realmente mudou
      if (_checkinTime != newCheckinTime) {
        if (mounted) {
          setState(() {
            _checkinTime = newCheckinTime;
          });
        }
      }
    } catch (e) {
      // Silenciosamente ignora erros de carregamento
    }
  }

  Future<void> _syncCheckInWithGamification(
      {bool onlySyncSchedules = false}) async {
    final isGuest = await PreferencesService.isGuestMode();
    final List<UserNicheTime> times;

    if (isGuest) {
      times = await PreferencesService.loadUserNicheTimes(
          nicheId: _niche.id + 200);
    } else {
      times = await CloudSyncService.loadUserNicheTimes(
          nicheId: _niche.id + 200);
    }
    if (!mounted) return;

    final gamification =
        Provider.of<GamificationService>(context, listen: false);

    gamification.scheduleByModule[_niche.nicheId] =
        times.map((t) => TimeOfDay(hour: t.hour, minute: t.minute)).toList();

    if (onlySyncSchedules) {
      if (_gamificationRunning) {
        await gamification.restoreMonitoringSession();
      }
      // Força atualização da UI quando apenas sincroniza horários
      if (mounted) {
        setState(() {});
      }
      return;
    }

    if (times.isNotEmpty && _gamificationRunning) {
      await PermissionService.ensurePermissions(context);
      gamification.startModuleCycle(nicheId: _niche.nicheId);

      if (!gamification.isGeneralMonitoringActive) {
        gamification.startMonitoringApps(
            nicheId: _niche.nicheId,
            horarios: gamification.scheduleByModule[_niche.nicheId]!);
      }
    }
  }

  String _getIntroText() {
    return 'Aplicativos monitorados:';
  }

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      final nicheId = _niche.nicheId;
      final userApps =
          await CloudSyncService.loadUserNicheApps(nicheId: nicheId);
      final status = await CloudSyncService.loadModuleStatus(nicheId);
      final apps = userApps.map((a) => a.appPackage).toList();

      if (mounted) {
        setState(() {
          _selectedApps.clear();
          _selectedApps.addAll(apps);
          _gamificationRunning = status?.isActive ?? false;
          _loadingData = false;
        });

        if (_gamificationRunning) {
          final gamification =
              Provider.of<GamificationService>(context, listen: false);
          gamification.monitoredApps = Set<String>.from(_selectedApps);

          bool accessibilityGranted =
              await PermissionService.hasAccessibilityPermission();
          if (!mounted) return;

          if (accessibilityGranted) {
            gamification.startMonitoringApps(nicheId: nicheId, horarios: []);
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

    // Sincroniza check-in com gamification como no módulo de Parar de Fumar
    _syncCheckInWithGamification(onlySyncSchedules: !_gamificationRunning);

    // Carrega horários de check-in como no módulo Focus
    await _reloadCheckinData();
  }

  void _removeSelectedApp(String packageName) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedApps.remove(packageName);
    });

    await CloudSyncService.removeUserNicheApp(
      nicheId: _niche.nicheId,
      package: packageName,
    );

    final label = await getAppLabel(packageName) ?? packageName;
    if (mounted) {
      EnhancedSnackBarHelper.showInfo(context, "App removido: $label");
    }
  }

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();

    if (_selectedApps.isEmpty) {
      EnhancedSnackBarHelper.showInfo(
        context,
        "Primeiro, deve-se selecionar apps a monitorar..",
      );
      return;
    }

    await PermissionService.ensurePermissions(context, forceUsage: true);
    bool accessibilityGranted =
        await PermissionService.hasAccessibilityPermission();
    if (!accessibilityGranted) {
      return;
    }

    if (!mounted) return;

    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.monitoredApps = Set<String>.from(_selectedApps);
    gamification.startMonitoringApps(nicheId: _niche.nicheId, horarios: []);

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
    CloudSyncService.saveModuleStatus(nicheId: _niche.nicheId, isActive: true);
    Provider.of<GamificationService>(context, listen: false)
        .startModuleCycle(nicheId: _niche.nicheId);
  }

  Future<void> _showNotificationSettingsDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permissão necessária"),
        content: const Text(
          "Para receber notificações do Disciplinum, habilite as notificações do app nas configurações do Android.",
        ),
        actions: [
          TextButton(
            child: const Text("Abrir configurações"),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              NotificationService.openNotificationSettings();
            },
          ),
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _desativarNichoMonitoramento() async {
    final confirmed = await DeactivateModuleDialog.show(
      context: context,
      nicheId: NicheId.bingeEating,
      customMessage: "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado. Deseja continuar?",
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      final gamification =
          Provider.of<GamificationService>(context, listen: false);
      gamification.stopMonitoringApps();

      _resetMedalsForModule(
        notificationTitle: 'Módulo Desativado 🛑',
        notificationBody:
            'O módulo foi desativado e todos os dados de estatística e gamificação foram resetados.',
        deactivate: true,
      );

      setState(() {
        _gamificationRunning = false;
        _selectedIndex = 0;
      });

      if (_pageController.hasClients) {
        _pageController.animateToPage(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      }

      if (mounted) {
        EnhancedSnackBarHelper.showWarning(context, 'Módulo desativado');
      }
    }
  }

  void _resetMedalsForModule({
    String? notificationTitle,
    String? notificationBody,
    bool sendNotification = true,
    bool deactivate = false,
  }) {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.resetMedals(
      _niche.nicheId,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      sendNotification: sendNotification,
      deactivate: deactivate,
    );
  }

  Future<void> _openSelectApps() async {
    HapticFeedback.selectionClick();
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectAppsScreen(
          args: SelectAppsScreenArgs(
            initiallySelected: List.from(_selectedApps),
            onSaved: (apps) async {
              setState(() {
                _selectedApps
                  ..clear()
                  ..addAll(apps);
              });

              await CloudSyncService.removeAllAppsForNiche(nicheId: _niche.nicheId);
              for (var pkg in apps) {
                await CloudSyncService.addUserNicheApp(
                    nicheId: _niche.nicheId, package: pkg);
              }
            },
            nicheId: _niche.nicheId,
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (_selectedApps.isNotEmpty) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      } else {
        setState(() => _selectedIndex = 1);
      }
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loadingData) {
      return Scaffold(
        appBar: AppBar(title: Text(_niche.name), centerTitle: true),
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
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildTabContent(0),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
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
    final List<String> options = ['Como funciona', 'Compulsão alimentar'];

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
                HapticFeedback.lightImpact();
                if (!isSelected) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutQuad,
                  );
                } else {
                  setState(() {
                    _selectedIndex = index;
                  });
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
              icon: Icons.settings_outlined,
              title: "Em Selecionar apps, escolha os aplicativos de delivery",
              content:
                  "Selecione os apps de delivery que você deseja monitorar. Após selecionar, ative o módulo para começar o monitoramento.",
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.notifications_outlined,
              title: "Em Notificações, configure lembretes",
              content:
                  "Defina horários para receber lembretes motivacionais que te ajudem a evitar pedidos por impulso.",
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.bar_chart_rounded,
              title: "Em Estatísticas, acompanhe seus ganhos",
              content:
                  "Visualize quantos dias você está sem pedir delivery e acompanhe sua evolução.",
            ),
          ],
        );
      case 1:
        // Força recarregar dados do check-in quando a aba Compulsão alimentar é exibida
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _reloadCheckinData();
        });
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getIntroText(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedApps.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "Nenhum app selecionado.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              )
            else
              FutureBuilder<List<AppDisplayInfo>>(
                future: gatherAppDisplayInfo(_selectedApps),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final infos = snapshot.data!;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: infos.map((info) {
                      return InputChip(
                        visualDensity: VisualDensity.compact,
                        avatar: info.icon != null
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(info.icon!),
                                backgroundColor: Colors.transparent,
                              )
                            : null,
                        label: Text(info.label ?? info.package,
                            style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF6366F1))),
                        onDeleted: () => _removeSelectedApp(info.package),
                        deleteIconColor: isDark
                            ? Colors.white70
                            : const Color(0xFF6366F1).withValues(alpha: 0.7),
                        backgroundColor:
                            (isDark ? Colors.white : const Color(0xFF6366F1))
                                .withValues(alpha: 0.1),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
                  );
                },
              ),
            const SizedBox(height: 24),
            NicheCheckinSection(
              checkinTime: _checkinTime,
              isDark: isDark,
              onDeleteTime: _showDeleteTimeDialog,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }



  void _showDeleteTimeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir horário?"),
        content: Text(
          "Deseja excluir o horário ${_checkinTime!.hour.toString().padLeft(2, '0')}:${_checkinTime!.minute.toString().padLeft(2, '0')} do seu check-in diário?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Não"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);

              final isGuest = await PreferencesService.isGuestMode();

              // Remove o horário específico
              if (isGuest) {
                await PreferencesService.removeUserNicheTime(
                  nicheId: _niche.id + 200,
                  hour: _checkinTime!.hour,
                  minute: _checkinTime!.minute,
                );
              } else {
                await CloudSyncService.removeUserNicheTime(
                  nicheId: _niche.id + 200,
                  hour: _checkinTime!.hour,
                  minute: _checkinTime!.minute,
                );
              }

              // Atualiza a variável de estado
              if (mounted) {
                setState(() {
                  _checkinTime = null;
                });
              }
            },
            child: const Text("Sim"),
          ),
        ],
      ),
    );
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
            label: "Começar",
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
            icon: Icons.apps_rounded,
            label: "Selecionar aplicativos",
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: _openSelectApps,
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
                  icon: Icons.touch_app_outlined,
                  label: "Selecionar apps",
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _openSelectApps,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NicheActionButton(
                  icon: Icons.notifications_outlined,
                  label: "Notificações",
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const BingeEatingNotificationsScreen(),
                      ),
                    ).then((_) {
                      // Força atualização do check-in ao voltar da tela de notificações
                      _reloadCheckinData();
                    });
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
                  label: "Estatísticas",
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
                      ? "Desativar Módulo"
                      : "Ativar Módulo",
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
              "Estatísticas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListActionTile(
              icon: Icons.no_food_rounded,
              label: "Dias sem pedir delivery",
              color: Colors.green,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DaysWithoutFoodDelivery()),
                );
              },
            ),
            ListActionTile(
              icon: Icons.bar_chart_rounded,
              label: "Conquistas",
              color: Colors.blue,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyProgressBingeEating()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
