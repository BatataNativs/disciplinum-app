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
import 'package:disciplinum/shared/widgets/dialogs/permission_dialog.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/my_progress_binge_eating.dart' as binge_eating_progress;
import 'package:disciplinum/features/modules/binge_eating/gamification/presentation/widgets/binge_eating_celebration_widget.dart';
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:disciplinum/core/utils/app_info_helper.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_header_widget.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_segmented_control.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_tab_content.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_actions_widget.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service_local.dart';
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
  int _selectedIndex = 0; // 0=Compulsão alimentar, 1=Como funciona

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: 0); // Garante que inicie na aba "Compulsão alimentar"
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
          _gamificationRunning = status?.isModuleActive ?? false;
          _loadingData = false;
        });

        if (_gamificationRunning) {
          // Monitoramento é gerenciado pelo AppLock via bingeEatingServiceIsarProvider
          bool accessibilityGranted =
              await PermissionService.hasAccessibilityPermission();
          if (!mounted) return;

          if (accessibilityGranted) {
            // AppLock ativado via config do BingeEatingServiceIsar
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

    // Usando provider local do BingeEating
    final bingeEatingService = ref.read(bingeEatingServiceIsarProvider);
    
    // Ativa o AppLock para os apps selecionados
    final config = await bingeEatingService.getConfig();
    final updatedConfig = config.copyWith(
      isModuleActive: true,
      enableAppLock: true,
      monitoredApps: _selectedApps,
    );
    await bingeEatingService.saveConfig(updatedConfig);

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
    ref.read(cloudSyncServiceProvider).saveModuleStatus(nicheId: _niche.nicheId, isModuleActive: true);
    // Inicia o ciclo de gamificação local
    final bingeEatingService = ref.read(bingeEatingServiceIsarProvider);
    // Ativa notificações se configurado
    bingeEatingService.getConfig().then((config) {
      if (config.enableNotifications) {
        // Agenda notificação de lembrete
        LoggerService.instance.i('Notificações habilitadas para BingeEating');
      }
    });
  }

  Future<void> _showNotificationSettingsDialog() async {
    context.showNotificationPermissionDialog(
      onOpenSettings: () => NotificationService.openNotificationSettings(),
    );
  }

  Future<void> _desativarNichoMonitoramento() async {
    // Usando provider local do BingeEating
    final bingeEatingService = ref.read(bingeEatingServiceIsarProvider);
    final confirmed = await DeactivateModuleDialog.show(
      context: context,
      nicheId: NicheId.bingeEating,
      customMessage: "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado. Deseja continuar?",
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      
      // Desativa o AppLock e o módulo
      final config = await bingeEatingService.getConfig();
      final updatedConfig = config.copyWith(
        isModuleActive: false,
        enableAppLock: false,
        monitoredApps: [],
      );
      await bingeEatingService.saveConfig(updatedConfig);
      
      _resetMedalsForModule();

      // Obtém o estado atual do módulo
      final gamificationStatus = updatedConfig.isModuleActive;

      setState(() {
        _gamificationRunning = gamificationStatus;
        _selectedIndex = 0;
      });

      // Sincronizar com a nuvem
      ref.read(cloudSyncServiceProvider).saveModuleStatus(
        nicheId: NicheId.bingeEating,
        isModuleActive: false,
      );

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
    // Usando provider local do BingeEating
    final bingeEatingService = ref.read(bingeEatingServiceIsarProvider);
    // Reseta as configurações para o estado inicial
    bingeEatingService.getConfig().then((config) async {
      final resetConfig = BingeEatingConfig(
        isModuleActive: false,
        enableAppLock: false,
        monitoredApps: [],
        triggerFoods: [],
        copingStrategies: [],
      );
      await bingeEatingService.saveConfig(resetConfig);
      LoggerService.instance.i('BingeEating: Dados resetados');
    });
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
    final colorScheme = Theme.of(context).colorScheme;

    if (_loadingData) {
      return Scaffold(
        appBar: AppBar(title: Text(_niche.name), centerTitle: true),
        body: Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest,
          highlightColor: colorScheme.surface,
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

    return BingeEatingCelebrationWidget(
      child: Scaffold(
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
                          // 1: Como funciona
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                // Container roxo com degradê
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.restaurant_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Como Funciona',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Controle a compulsão alimentar com inteligência',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Cards de instruções
                                _buildInstructionCard(
                                  Icons.psychology_rounded,
                                  '1. Identifique Gatilhos',
                                  'Reconheça os gatilhos emocionais ou situacionais que desencadeiam episódios de compulsão alimentar.',
                                  Colors.purple,
                                ),
                                _buildInstructionCard(
                                  Icons.block_rounded,
                                  '2. Bloqueie Apps',
                                  'Use o bloqueio inteligente para impedir acesso a aplicativos de delivery e comida durante períodos críticos.',
                                  Colors.purple,
                                ),
                                _buildInstructionCard(
                                  Icons.notifications_active_rounded,
                                  '3. Configure Alertas',
                                  'Receba notificações personalizadas para lembrá-lo de suas estratégias e mantê-lo motivado.',
                                  Colors.purple,
                                ),
                                _buildInstructionCard(
                                  Icons.emoji_emotions_rounded,
                                  '4. Acompanhe Progresso',
                                  'Monitore seus padrões, visualize estatísticas e celebre cada vitória contra a compulsão alimentar.',
                                  Colors.purple,
                                ),
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
      ),
    );
  }



  void _showStatisticsMenu() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas e Opções',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ListActionTile(
              icon: Icons.bar_chart_rounded,
              label: "Conquistas",
              color: Colors.blue,
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

  // Card de instrução
  Widget _buildInstructionCard(IconData icon, String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
