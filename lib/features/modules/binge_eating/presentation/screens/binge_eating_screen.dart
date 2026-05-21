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
import 'package:disciplinum/core/utils/app_info_helper.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_header_widget.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_segmented_control.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_tab_content.dart';
import 'package:disciplinum/features/modules/binge_eating/presentation/widgets/binge_eating_actions_widget.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service_local.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';
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
  bool _isLoadingAppIcons = false;
  final Map<String, Uint8List?> _appIcons = {};
  final Map<String, bool> _appIconLoadStatus = {};

  static const List<Map<String, String>> _commonDeliveryApps = [
    {'name': 'iFood', 'package': 'br.com.brainweb.ifood'},
    {'name': 'Rappi', 'package': 'com.grability.rappi'},
    {'name': 'Uber Eats', 'package': 'com.ubercab.eats'},
    {'name': 'Zé Delivery', 'package': 'com.cerveza.zedelivery'},
    {'name': 'AiQFome', 'package': 'com.aiqfome.cliente'},
    {'name': 'Delivery Much', 'package': 'com.deliverymuch.app'},
    {'name': 'Daki', 'package': 'com.daki'},
    {'name': 'Mercado Livre', 'package': 'br.com.mercadolivre'},
    {'name': 'McDonald\'s', 'package': 'com.mcdo.mcdonalds'},
    {'name': 'Burger King', 'package': 'burgerking.com.br.appandroid'},
    {'name': 'Habib\'s', 'package': 'com.habbibs.app'},
    {'name': 'KFC', 'package': 'com.kfc.kfcapp'},
    {'name': 'Subway', 'package': 'com.subway.mobile.subwayapp03'},
    {'name': 'Pizza Hut', 'package': 'com.pizzahut.mobile'},
    {'name': 'Domino\'s', 'package': 'com.Dominos'},
    {'name': 'Spoleto', 'package': 'com.spoleto.app'},
    {'name': 'Giraffas', 'package': 'com.giraffas.brasil'},
    {'name': '99Food', 'package': 'com.xiaojukeji.didi.brazil.customer'},
  ];

  late PageController _pageController;
  int _selectedIndex = 0; // 0=Compulsão alimentar, 1=Como funciona

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: 0); // Garante que inicie na aba "Compulsão alimentar"
    _loadAllPersistentData();
    _loadAppIcons(); // Carregar ícones de apps de delivery em background
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
      final service = ref.read(bingeEatingServiceLocalProvider);
      
      // Carregar dados locais como no Digital Detox
      final config = await service.getConfig();
      final apps = config.monitoredApps;

      if (mounted) {
        setState(() {
          _selectedApps.clear();
          _selectedApps.addAll(apps);
          _gamificationRunning = config.isModuleActive;
          _loadingData = false; // Dados carregados, sair do shimmer
        });
      }

      
      if (_gamificationRunning) {
        bool accessibilityGranted = await PermissionService.hasAccessibilityPermission();
        if (!mounted) return;

        if (accessibilityGranted) {
          ref.read(bingeEatingServiceLocalProvider);
          LoggerService.instance.i('Binge Eating: AppLock ativado para ${_selectedApps.length} apps');
        } else {
          setState(() => _gamificationRunning = false);
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar dados', error: e);
      if (mounted) {
        setState(() => _loadingData = false); // Sair do shimmer mesmo em caso de erro
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

    // Persistir remoção localmente (fonte de verdade ao reabrir o módulo)
    try {
      final bingeEatingService = ref.read(bingeEatingServiceLocalProvider);
      await bingeEatingService.removeMonitoredApp(packageName);
      LoggerService.instance.i('App removido da persistência local: $packageName');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover app do config local: $packageName', error: e);
    }

    final label = await getAppLabel(packageName) ?? packageName;
    if (mounted) {
      EnhancedSnackBarHelper.showInfo(context, "App removido: $label");
    }
  }

  Future<void> _loadAppIcons() async {
    if (_isLoadingAppIcons) return;
    
    setState(() => _isLoadingAppIcons = true);
    
    try {
      // Apps de delivery e comida comuns no Brasil
      for (final app in _commonDeliveryApps) {
        final packageName = app['package']!;
        try {
          LoggerService.instance.i('🔍 Tentando carregar ícone para: $packageName');
          final icon = await InstalledAppService().getAppIcon(packageName);
          LoggerService.instance.i('✅ Ícone carregado para $packageName: ${icon != null ? 'SUCESSO' : 'NULL'}');
          if (mounted) {
            setState(() {
              _appIcons[packageName] = icon;
              _appIconLoadStatus[packageName] = true;
            });
          }
        } catch (e) {
          LoggerService.instance.e('❌ Erro ao carregar ícone para $packageName: $e');
          if (mounted) {
            setState(() {
              _appIconLoadStatus[packageName] = true; // Marca como carregado mesmo com erro
            });
          }
        }
      }
    } catch (e) {
      LoggerService.instance.e('❌ Erro geral ao carregar ícones: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingAppIcons = false);
      }
    }
  }

  Future<void> _ativarNichoMonitoramento() async {
    LoggerService.instance.i('DEBUG: _ativarNichoMonitoramento() chamado');
    HapticFeedback.mediumImpact();

    if (_selectedApps.isEmpty) {
      LoggerService.instance.w('DEBUG: Nenhum app selecionado');
      EnhancedSnackBarHelper.showInfo(
        context,
        "Primeiro, selecione os apps que deseja monitorar.",
      );
      return;
    }
    LoggerService.instance.i('DEBUG: Apps selecionados: ${_selectedApps.length}');

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
    await PermissionService.ensurePermissions(
      context,
      forceUsage: true,
      nicheId: NicheId.bingeEating,
    );
    bool accessibilityGranted =
        await PermissionService.hasAccessibilityPermission();
    if (!accessibilityGranted) return;

    if (!mounted) return;

    // Usando provider local do BingeEating
    final bingeEatingService = ref.read(bingeEatingServiceLocalProvider);
    
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
      _selectedIndex = 0; // Garante que volte para tela 0
    });
    
    // Navega para a tela 0 (Compulsão alimentar)
    if (_pageController.hasClients) {
      _pageController.animateToPage(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
    }
    
    ref.read(cloudSyncServiceProvider).saveModuleStatus(nicheId: _niche.nicheId, isModuleActive: true);
    // Inicia o ciclo de gamificação local
    final bingeEatingService = ref.read(bingeEatingServiceLocalProvider);
    // Ativa notificações se configurado
    bingeEatingService.getConfig().then((config) {
      if (config.enableNotifications) {
        // Agenda notificação de lembrete
        LoggerService.instance.i('Notificações habilitadas para BingeEating');
      }
    });
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
    // Usando provider local do BingeEating
    final bingeEatingService = ref.read(bingeEatingServiceLocalProvider);
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
    final bingeEatingService = ref.read(bingeEatingServiceLocalProvider);
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header com stats (reduzido)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
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
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final totalApps = _selectedApps.length;
                                      final isActive = _gamificationRunning;
                                      
                                      return Row(
                                        children: [
                                          _buildStatCard('$totalApps', 'Apps', const Color(0xFF8B5CF6), Icons.phone_android_rounded, isCompact: true),
                                          const SizedBox(width: 8),
                                          _buildStatCard(isActive ? 'Ativo' : 'Inativo', 'Status', isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444), isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded, isCompact: true),
                                          const SizedBox(width: 8),
                                          _buildStatCard('0', 'Dias', const Color(0xFFF59E0B), Icons.calendar_today_rounded, isCompact: true),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Imagem ilustrativa
                                Container(
                                  width: double.infinity,
                                  height: 180,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      'assets/modules/binge_eating/binge_eating_screen_asset.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        final colorScheme = Theme.of(context).colorScheme;
                                        return Container(
                                          color: colorScheme.surfaceContainerHighest,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image_not_supported,
                                                  size: 48,
                                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Imagem não disponível',
                                                  style: TextStyle(
                                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Apps selecionados - Grid de Ícones
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    'Apps selecionados',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Grid de ícones dos apps selecionados
                                if (_selectedApps.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    height: 120,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colorScheme.outline.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.touch_app_outlined,
                                              size: 32,
                                              color: colorScheme.onSurface.withValues(alpha: 0.4)),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Toque nos ícones abaixo para adicionar apps',
                                            style: TextStyle(
                                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colorScheme.outline.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: _selectedApps.map((packageName) {
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.08),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: _appIcons[packageName] != null
                                                ? Image.memory(
                                                    _appIcons[packageName]!,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: colorScheme.primaryContainer,
                                                    child: Icon(
                                                      Icons.fastfood,
                                                      size: 28,
                                                      color: colorScheme.primary,
                                                    ),
                                                  ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                
                                const SizedBox(height: 20),
                                
                                // Apps de delivery instalados
                                _buildDeliveryAppsSection(),
                                
                                const SizedBox(height: 20),
                                
                                // Seção de controle (substituindo BingeEatingTabContent)
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
                                // Header
                                Container(
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
                                  const Color(0xFF10B981),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                _buildInstructionCard(
                                  Icons.block_rounded,
                                  '2. Bloqueie Apps',
                                  'Use o bloqueio inteligente para impedir acesso a aplicativos de delivery e comida durante períodos críticos.',
                                  const Color(0xFFF59E0B),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                _buildInstructionCard(
                                  Icons.notifications_active_rounded,
                                  '3. Configure Alertas',
                                  'Receba notificações personalizadas para lembrá-lo de suas estratégias e mantê-lo motivado.',
                                  const Color(0xFF8B5CF6),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                _buildInstructionCard(
                                  Icons.emoji_events,
                                  '4. Ganhe Recompensas',
                                  'A cada dia disciplinado, você ganha medalhas e acompanha seu progresso contra a compulsão alimentar.',
                                  const Color(0xFFEF4444),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Botão de ação
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () => _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B5CF6),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                    child: const Text(
                                      'Começar Agora',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
              _selectedIndex == 0
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: BingeEatingActionsWidget(
                        selectedIndex: _selectedIndex,
                        pageController: _pageController,
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

  Widget _buildDeliveryAppsSection() {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Filtrar apenas apps que estão instalados (têm ícone real), igual ao Digital Detox
    final installedApps = _commonDeliveryApps.where((app) {
      final packageName = app['package'] as String;
      return _appIcons[packageName] != null;
    }).toList();

    // Se não tiver nenhum app instalado e os ícones ainda estão carregando, mostrar shimmer
    if (_isLoadingAppIcons && installedApps.isEmpty) {
      final shimmerScheme = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Apps instalados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: shimmerScheme.surfaceContainerHighest,
            highlightColor: shimmerScheme.surface,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(5, (_) => Container(
                width: 90,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              )),
            ),
          ),
        ],
      );
    }

    // Se não houver nenhum app de delivery instalado, ocultar a seção
    if (installedApps.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Apps instalados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: installedApps.map((app) {
              final packageName = app['package'] as String;
              final appName = app['name'] as String;
              final isSelected = _selectedApps.contains(packageName);
              
              return GestureDetector(
                onTap: () async {
                  if (!_gamificationRunning) {
                    setState(() {
                      if (isSelected) {
                        _selectedApps.remove(packageName);
                      } else {
                        _selectedApps.add(packageName);
                      }
                    });
                    
                    // Persistir imediatamente usando addMonitoredApp/removeMonitoredApp
                    // (igual ao Digital Detox)
                    try {
                      final bingeEatingService = ref.read(bingeEatingServiceLocalProvider);
                      if (isSelected) {
                        await bingeEatingService.removeMonitoredApp(packageName);
                        LoggerService.instance.i('App removido da persistência: $packageName');
                      } else {
                        await bingeEatingService.addMonitoredApp(packageName);
                        LoggerService.instance.i('App adicionado à persistência: $packageName');
                      }
                    } catch (e) {
                      LoggerService.instance.e('Erro ao persistir mudança no app $packageName', error: e);
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colorScheme.primary : colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone real do app (já filtramos apenas apps instalados com ícone real)
                      _appIconLoadStatus[packageName] == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                _appIcons[packageName]!,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                              ),
                            )
                          : SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color?>(
                                  isSelected ? Colors.white : colorScheme.primary,
                                ),
                              ),
                            ),
                      const SizedBox(width: 8),
                      Text(
                        appName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (!_gamificationRunning && _selectedApps.isNotEmpty)
          SizedBox(
            width: 100,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _selectedApps.clear());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text(
                'Limpar',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  // Card de estatística
  Widget _buildStatCard(String value, String label, Color color, IconData icon, {bool isCompact = false}) {
    return Expanded(
      child: Container(
        padding: isCompact ? const EdgeInsets.all(12) : const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: isCompact ? 16 : 20),
            SizedBox(height: isCompact ? 4 : 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isCompact ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: isCompact ? 10 : 12,
                color: const Color(0xFF6B7280),
              ),
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

}
