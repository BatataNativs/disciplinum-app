import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/screens/binge_eating_notifications_screen.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/my_progress_binge_eating.dart' as binge_eating_progress;
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:disciplinum/core/utils/app_info_helper.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_header_widget.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_segmented_control.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_tab_content.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_actions_widget.dart';
import 'dart:async';

class BingeEatingScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const BingeEatingScreen({super.key, this.heroTag});

  @override
  ConsumerState<BingeEatingScreen> createState() => _BingeEatingScreenState();
}

class _BingeEatingScreenState extends ConsumerState<BingeEatingScreen>
    with WidgetsBindingObserver {
  final Niche _niche = NicheRepository.getById(NicheId.bingeEating);
  final List<String> _selectedApps = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

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
  }

  @override
  void didUpdateWidget(BingeEatingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }



  
  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      final nicheId = _niche.nicheId;
      final userApps =
          await ref.read(cloudSyncServiceProvider).loadUserNicheApps(nicheId: nicheId);
      final status = await ref.read(cloudSyncServiceProvider).loadModuleStatus(nicheId);
      final apps = userApps.map((a) => a.appPackage).toList();

      if (mounted) {
        setState(() {
          _selectedApps.clear();
          _selectedApps.addAll(apps);
          _gamificationRunning = status?.isActive ?? false;
          _loadingData = false;
        });

        if (_gamificationRunning) {
          final gamification = ref.read(gamificationServiceProvider.notifier);

          bool accessibilityGranted =
              await PermissionService.hasAccessibilityPermission();
          if (!mounted) return;

          if (accessibilityGranted) {
            gamification.startMonitoringApps(
              nicheId: _niche.nicheId.id,
              apps: _selectedApps,
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

  void _removeSelectedApp(String packageName) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedApps.remove(packageName);
    });

    await ref.read(cloudSyncServiceProvider).removeUserNicheApp(
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
        "Primeiro, selecione os apps que deseja monitorar.",
      );
      return;
    }

    // NOVO: Verificar permissão de sobreposição primeiro
    bool overlayGranted = await PermissionService.ensureOverlayPermissionForModule(
      context,
      NicheId.bingeEating,
    );
    
    if (!overlayGranted) {
      // Usuário clicou "Depois" - desativar módulo e mostrar snackbar
      if (mounted) {
        EnhancedSnackBarHelper.showInfo(
          context,
          'Você precisa conceder a permissão de sobreposição para ativar o módulo de Comer Compulsivamente.',
        );
      }
      return;
    }

    if (!mounted) return;
    await PermissionService.ensurePermissions(context, forceUsage: true);
    bool accessibilityGranted =
        await PermissionService.hasAccessibilityPermission();
    if (!accessibilityGranted) return;

    if (!mounted) return;

    final gamification = ref.read(gamificationServiceProvider.notifier);
    gamification.startMonitoringApps(
      nicheId: _niche.nicheId.id,
      apps: _selectedApps,
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
    ref.read(cloudSyncServiceProvider).saveModuleStatus(nicheId: _niche.nicheId, isActive: true);
    ref.read(gamificationServiceProvider.notifier).startModuleCycle(_niche.nicheId.id);
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
    final gamification = ref.read(gamificationServiceProvider.notifier);
    final confirmed = await DeactivateModuleDialog.showWithService(
      context: context,
      gamificationService: gamification,
      nicheId: NicheId.bingeEating,
      customMessage: "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado. Deseja continuar?",
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      
      // Para o ciclo da gamificação primeiro
      gamification.stopModuleCycle(NicheId.bingeEating.id);
      
      _resetMedalsForModule();

      // Força atualização do estado da gamificação
      final gamificationStatus = ref.read(gamificationServiceProvider.notifier).getModuleStatus(NicheId.bingeEating.id);

      setState(() {
        _gamificationRunning = gamificationStatus;
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

  void _resetMedalsForModule() {
    final gamification = ref.read(gamificationServiceProvider.notifier);
    gamification.resetMedals(
      _niche.nicheId.id,
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

              await ref.read(cloudSyncServiceProvider).removeAllAppsForNiche(nicheId: _niche.nicheId);
              for (var pkg in apps) {
                await ref.read(cloudSyncServiceProvider).addUserNicheApp(
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
              BingeEatingHeaderWidget(
                niche: _niche,
                onBackPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: BingeEatingSegmentedControl(
                        selectedIndex: _selectedIndex,
                        onIndexChanged: (index) {
                          HapticFeedback.lightImpact();
                          if (_pageController.hasClients) {
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
                      ),
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
                                BingeEatingTabContent(
                                  tabIndex: 0,
                                  selectedApps: _selectedApps,
                                  onGetAppInfo: gatherAppDisplayInfo,
                                  onRemoveApp: _removeSelectedApp,
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                BingeEatingTabContent(
                                  tabIndex: 1,
                                  selectedApps: _selectedApps,
                                  onGetAppInfo: gatherAppDisplayInfo,
                                  onRemoveApp: _removeSelectedApp,
                                ),
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
                      child: BingeEatingActionsWidget(
                        selectedIndex: _selectedIndex,
                        isDark: isDark,
                        pageController: _pageController,
                        onSelectApps: _openSelectApps,
                        onNotifications: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BingeEatingNotificationsScreen(),
                            ),
                          ).then((_) {
                            // Reload não necessário mais - sem check-in
                          });
                        },
                        onStatistics: _showStatisticsMenu,
                        gamificationRunning: _gamificationRunning,
                        onToggleModule: _gamificationRunning
                            ? _desativarNichoMonitoramento
                            : _ativarNichoMonitoramento,
                      ),
                    )
                  : BingeEatingActionsWidget(
                      selectedIndex: _selectedIndex,
                      isDark: isDark,
                      pageController: _pageController,
                      onSelectApps: _openSelectApps,
                      onNotifications: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BingeEatingNotificationsScreen(),
                          ),
                        ).then((_) {
                            // Reload não necessário mais - sem check-in
                        });
                      },
                      onStatistics: _showStatisticsMenu,
                      gamificationRunning: _gamificationRunning,
                      onToggleModule: _gamificationRunning
                          ? _desativarNichoMonitoramento
                          : _ativarNichoMonitoramento,
                    ),
            ],
          ),
        ),
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
              icon: Icons.bar_chart_rounded,
              label: "Conquistas",
              color: Colors.blue,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const binge_eating_progress.MyProgressBingeEating()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
