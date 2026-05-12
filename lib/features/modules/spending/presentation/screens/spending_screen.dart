import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter/services.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/shared/widgets/dialogs/permission_dialog.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/features/modules/spending/presentation/widgets/spending_header_widget.dart';
import 'package:disciplinum/features/modules/spending/presentation/widgets/spending_segmented_control.dart';
import 'package:disciplinum/features/modules/spending/presentation/widgets/spending_tab_content.dart';
import 'package:disciplinum/features/modules/spending/presentation/widgets/spending_actions_widget.dart';
import 'package:disciplinum/features/modules/spending/gamification/presentation/providers/spending_gamification_provider.dart';
import 'package:disciplinum/features/modules/spending/gamification/presentation/widgets/spending_celebration_widget.dart';

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
  int _selectedIndex = 0; // 0=Controlar gastos, 1=Como Funciona


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0); // Garante que inicie na aba "Controlar Gastos"
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
      final isRunning = moduleState?.isModuleActive ?? false;
      LoggerService.instance.i('SpendingScreen: Controller ativo: $isRunning');
      
      if (mounted) {
        setState(() => _gamificationRunning = isRunning);
      }

      // Mantém o usuário na aba atual - não força mudança para Controle
      if (_selectedApps.isNotEmpty && _pageController.hasClients && _selectedIndex == 1) {
        // Usuário está na aba "Como Funciona" com apps selecionados
        // Permanece na aba atual, usuário pode navegar livremente
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

    // Se a permissão foi concedida, garantir navegação para tela 0
    if (mounted) {
      setState(() {
        _selectedIndex = 0; // Garante que volte para tela 0
      });
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      }
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
      _selectedIndex = 0; // Garante que volte para tela 0
    });
    
    // Navega para a tela 0 (Controlar gastos)
    if (_pageController.hasClients) {
      _pageController.animateToPage(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
    }
    
    ref.read(cloudSyncServiceProvider).saveModuleStatus(
      nicheId: NicheId.spending,
      isModuleActive: true,
    );
    // Ativa o notifier do Spending
    final notifier = ref.read(spendingGamificationNotifierProvider.notifier);
    await notifier.activateModule();
  }

  Future<void> _showNotificationSettingsDialog() async {
    final result = await context.showNotificationPermissionDialog(
      onOpenSettings: () => NotificationService.openNotificationSettings(),
    );
    
    // Após retornar das configurações, navegar para tela 0
    if (result == true && mounted) {
      setState(() {
        _selectedIndex = 0; // Garante que volte para tela 0
      });
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      }
    }
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
      isModuleActive: false,
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
  
    final colorScheme = Theme.of(context).colorScheme;

    if (_loadingData) {
      LoggerService.instance.i('SpendingScreen: Mostrando loading');
      return Scaffold(
        appBar: AppBar(title: Text(_niche.name), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return SpendingCelebrationWidget(
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
                          LoggerService.instance.i('SpendingScreen: PageView mudou para página $index (Controlar Gastos=0, Como Funciona=1)');
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        children: [
                          // 0: Controlar Gastos (módulo)
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                SpendingTabContent(
                                  tabIndex: 0,
                                  colorScheme: colorScheme,
                                  selectedApps: _selectedApps,
                                  onRemoveApp: _removeSelectedApp,
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          // 1: Como Funciona
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
                                        Icons.shopping_cart_rounded,
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
                                        'Controle seus gastos com inteligência',
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
                                  Icons.credit_card_rounded,
                                  '1. Selecione Apps de Compras',
                                  'Escolha aplicativos de e-commerce, delivery e serviços que você quer controlar seus gastos.',
                                  Colors.orange,
                                ),
                                _buildInstructionCard(
                                  Icons.trending_up_rounded,
                                  '2. Acompanhe em Tempo Real',
                                  'Visualize seus gastos diários, semanais e mensais com gráficos detalhados e relatórios.',
                                  Colors.orange,
                                ),
                                _buildInstructionCard(
                                  Icons.notifications_active_rounded,
                                  '3. Alertas Personalizados',
                                  'Receba notificações quando atingir limites de gastos ou para lembrar de metas financeiras.',
                                  Colors.orange,
                                ),
                                _buildInstructionCard(
                                  Icons.insights_rounded,
                                  '4. Análise de Padrões',
                                  'Entenda seus hábitos de consumo, identifique onde pode economizar e melhore seu controle financeiro.',
                                  Colors.orange,
                                ),
                                const SizedBox(height: 20),
                                // Botão Começar Agora
                                ElevatedButton(
                                  onPressed: () {
                                    _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5CF6),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Começar Agora',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
              Center(
                child: SpendingActionsWidget(
                  selectedIndex: _selectedIndex,
                  colorScheme: colorScheme,
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
