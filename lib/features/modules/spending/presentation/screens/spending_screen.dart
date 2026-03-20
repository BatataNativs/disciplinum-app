import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter/services.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/features/modules/spending/presentation/widgets/spending_header_widget.dart';
import 'package:disciplinum/features/modules/spending/presentation/widgets/spending_segmented_control.dart';
import 'package:disciplinum/features/modules/spending/presentation/widgets/spending_tab_content.dart';
import 'package:disciplinum/features/modules/spending/presentation/widgets/spending_actions_widget.dart';

class SpendingScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const SpendingScreen({super.key, this.heroTag});

  @override
  ConsumerState<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends ConsumerState<SpendingScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.spending);
  final List<String> _selectedApps = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

  // --- CONTROLADOR DE PÁGINA ---
  late PageController _pageController;
  int _selectedIndex = 0; // 0=Como Funciona, 1=Controlar gastos


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadAllPersistentData();
  }

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      // Carrega apps monitorados
      final apps = await ref.read(cloudSyncServiceProvider).loadUserNicheApps(nicheId: NicheId.spending);
      if (mounted) {
        setState(() {
          _selectedApps.clear();
          _selectedApps.addAll(apps.map((a) => a.appPackage));
        });
      }

      // Carrega status da gamificação
      final gamification = ref.read(gamificationServiceProvider);
      final isRunning = gamification.isModuleActive(NicheId.spending);
      if (mounted) {
        setState(() => _gamificationRunning = isRunning);
      }

      // Se tiver apps e o controller estiver ok, avança para Controle
      if (_selectedApps.isNotEmpty && _pageController.hasClients) {
        _pageController.animateToPage(1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      } else {
        setState(() => _selectedIndex = 1);
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

    await PermissionService.ensurePermissions(context, forceUsage: true);
    bool accessibilityGranted =
        await PermissionService.hasAccessibilityPermission();
    if (!accessibilityGranted) {
      return;
    }

    if (!mounted) return;

    final gamification = ref.read(gamificationServiceProvider);
    gamification.monitoredApps = Set<String>.from(_selectedApps);

    gamification.startMonitoringApps(
      nicheId: NicheId.spending,
      horarios: [],
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
    ref.read(cloudSyncServiceProvider).saveModuleStatus(
      nicheId: NicheId.spending,
      isActive: true,
    );
    ref.read(gamificationServiceProvider)
        .startModuleCycle(nicheId: NicheId.spending);
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

  Future<void> _desativarNichoMonitoramento() async {
    final confirmed = await DeactivateModuleDialog.show(
      context: context,
      nicheId: NicheId.spending,
      customMessage:
          'Ao desativar o módulo, seu progresso e estatísticas serão reiniciados.\n\nDeseja continuar?',
    );

    if (confirmed != true) return;
    if (!mounted) return;

    HapticFeedback.heavyImpact();
    final gamification = ref.read(gamificationServiceProvider);
    gamification.stopMonitoringApps();

    _resetMedalsForModule(
      notificationTitle: 'Módulo Desativado 🛑',
      notificationBody:
          'O módulo foi desativado e todos os dados de estatística e gamificação foram resetados.',
      deactivate: true,
    );

    if (!mounted) return;
    setState(() {
      _gamificationRunning = false;
      _selectedIndex = 0;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
    }
    ref.read(cloudSyncServiceProvider).saveModuleStatus(
      nicheId: NicheId.spending,
      isActive: false,
    );

    if (!mounted) return;
    SnackBarHelper.showError(
      context,
      'Módulo desativado',
    );
  }

  void _resetMedalsForModule({
    String? notificationTitle,
    String? notificationBody,
    bool sendNotification = true,
    bool deactivate = false,
  }) {
    final gamification = ref.read(gamificationServiceProvider);
    gamification.resetMedals(
      NicheId.spending,
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

              await ref.read(cloudSyncServiceProvider).removeAllAppsForNiche(
                nicheId: NicheId.spending,
              );
              for (var pkg in apps) {
                await ref.read(cloudSyncServiceProvider).addUserNicheApp(
                  nicheId: NicheId.spending,
                  package: pkg,
                );
              }
            },
            nicheId: NicheId.spending,
          ),
        ),
      ),
    );

    if (!mounted) return;

    // Se tiver apps e o controller estiver ok, avança para Controle
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

  void _removeSelectedApp(String package) async {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedApps.remove(package);
    });
    await ref.read(cloudSyncServiceProvider).removeUserNicheApp(
      nicheId: NicheId.spending,
      package: package,
    );
    // Se o módulo estiver rodando, atualizar o serviço de monitoramento
    if (_gamificationRunning) {
      if (!mounted) return;
      final gamification = ref.read(gamificationServiceProvider);
      gamification.monitoredApps = Set<String>.from(_selectedApps);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loadingData) {
      return Scaffold(
        appBar: AppBar(title: Text(_niche.name), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Header Row
              SpendingHeaderWidget(
                niche: _niche,
                onBackPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: SpendingSegmentedControl(
                          selectedIndex: _selectedIndex,
                          pageController: _pageController,
                          onIndexChanged: (index) {
                            if (_pageController.hasClients) {
                              _pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutQuad);
                            } else {
                              setState(() => _selectedIndex = index);
                            }
                          },
                        )),

                    // --- PAGEVIEW ---
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        children: [
                          // 0: Como Funciona
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                SpendingTabContent(
                                  tabIndex: 0,
                                  isDark: isDark,
                                  selectedApps: _selectedApps,
                                  onRemoveApp: _removeSelectedApp,
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          // 1: Controlar Gastos
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                SpendingTabContent(
                                  tabIndex: 1,
                                  isDark: isDark,
                                  selectedApps: _selectedApps,
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
              SpendingActionsWidget(
                selectedIndex: _selectedIndex,
                isDark: isDark,
                gamificationRunning: _gamificationRunning,
                pageController: _pageController,
                onOpenSelectApps: _openSelectApps,
                onShowControlGastosMenu: () {},
                onShowStatisticsMenu: () {},
                onToggleModule: _gamificationRunning
                    ? _desativarNichoMonitoramento
                    : _ativarNichoMonitoramento,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
