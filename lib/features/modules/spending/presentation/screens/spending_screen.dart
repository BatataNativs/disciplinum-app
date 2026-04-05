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
import 'package:disciplinum/features/modules/spending/gamification/presentation/providers/spending_gamification_provider.dart';

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
    _pageController = PageController(initialPage: 0); // Garante que inicie na aba "Como Funciona"
    LoggerService.instance.i('SpendingScreen: Iniciando com selectedIndex=$_selectedIndex, pageController inicializado');
    _loadAllPersistentData();
  }

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      LoggerService.instance.i('SpendingScreen: Iniciando carregamento de dados');
      
      // Carrega apps monitorados
      LoggerService.instance.i('SpendingScreen: Carregando apps monitorados');
      final apps = await ref.read(cloudSyncServiceProvider).loadUserNicheApps(nicheId: NicheId.spending);
      LoggerService.instance.i('SpendingScreen: ${apps.length} apps encontrados');
      
      if (mounted) {
        setState(() {
          _selectedApps.clear();
          _selectedApps.addAll(apps.map((a) => a.appPackage));
        });
      }

      // Carrega status do controller local do Spending
      LoggerService.instance.i('SpendingScreen: Carregando status do controller');
      // Usando provider local do Spending via gamification repository
      final spendingRepo = ref.read(moneySavingGamificationRepositoryProvider);
      final moduleState = await spendingRepo.getMoneySavingState();
      final isRunning = moduleState?.isActive ?? false;
      LoggerService.instance.i('SpendingScreen: Controller ativo: $isRunning');
      
      if (mounted) {
        setState(() => _gamificationRunning = isRunning);
      }

      // Mantém o usuário na aba atual - não força mudança para Controle
      if (_selectedApps.isNotEmpty && _pageController.hasClients && _selectedIndex == 0) {
        // Só avança para Controle se o usuário estiver na aba "Como Funciona" e quiser avançar
        // Isso permite que o usuário acesse ambas as abas livremente
      }
      
      LoggerService.instance.i('SpendingScreen: Dados carregados com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('SpendingScreen: Erro ao carregar dados', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _loadingData = false;
        });
      }
    } finally {
      _isLoadingData = false;
      if (mounted) {
        setState(() {
          _loadingData = false;
        });
      }
    }
  }

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();

    // NOVO: Verificar permissão de sobreposição primeiro
    bool overlayGranted = await PermissionService.ensureOverlayPermissionForModule(
      context,
      NicheId.spending,
    );
    
    if (!overlayGranted) {
      // Usuário clicou "Depois" - desativar módulo e mostrar snackbar
      if (mounted) {
        SnackBarHelper.showInfo(
          context,
          'Você precisa conceder a permissão de sobreposição para ativar o módulo de Controle de Gastos.',
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



    final granted = await NotificationService.requestPermission();

    if (!mounted) return;

    if (granted == true) {
      _startGamificationCycle();
    } else {
      _showNotificationSettingsDialog();
    }
  }

  Future<void> _startGamificationCycle() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _gamificationRunning = true;
    });
    ref.read(cloudSyncServiceProvider).saveModuleStatus(
      nicheId: NicheId.spending,
      isActive: true,
    );
    // Ativa o notifier do Spending
    final notifier = ref.read(spendingGamificationNotifierProvider.notifier);
    await notifier.activateModule();
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeactivateModuleDialog(
        nicheId: NicheId.spending,
        customMessage:
            'Ao desativar o módulo, seu progresso e estatísticas serão reiniciados.\n\nDeseja continuar?',
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    HapticFeedback.heavyImpact();
    
    // Desativa o notifier do Spending
    final notifier = ref.read(spendingGamificationNotifierProvider.notifier);
    await notifier.deactivateModule();

    _resetMedalsForModule(
      notificationTitle: 'Módulo Desativado 🛑',
      notificationBody: 'Seu progresso foi resetado',
      deactivate: true,
    );

    // Força atualização do estado local
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
    bool deactivate = false,
  }) {
    // Usar o notifier do Spending
    final notifier = ref.read(spendingGamificationNotifierProvider.notifier);
    notifier.resetProgress();
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

    // Permite que o usuário permaneça na aba atual após selecionar apps
    if (_selectedApps.isNotEmpty) {
      // Não força mudança de aba - permite acesso livre a ambas as abas
      setState(() {});
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
    // Se o módulo estiver rodando, as permissões/monitoramento são atualizadas via banco Isar
    if (_gamificationRunning) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    LoggerService.instance.i('SpendingScreen: Build chamado, loadingData=$_loadingData, isLoadingData=$_isLoadingData, selectedIndex=$_selectedIndex');
  
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loadingData) {
      LoggerService.instance.i('SpendingScreen: Mostrando loading');
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
                          LoggerService.instance.i('SpendingScreen: PageView mudou para página $index (Como Funciona=0, Controlar Gastos=1)');
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
              Center(
                child: SpendingActionsWidget(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
