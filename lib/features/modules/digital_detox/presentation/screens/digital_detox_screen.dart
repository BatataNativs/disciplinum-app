import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/providers/digital_detox_providers.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/shared/widgets/dialogs/permission_dialog.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/screens/digital_detox_time_settings_screen.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/screens/digital_detox_limits_screen.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/screens/digital_detox_fasting_breaks_screen.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/screens/my_progress_digital_detox.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/common/module_screen_header.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/services/digital_detox_gamification_service.dart';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_sync_service.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/repositories/digital_detox_gamification_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/gamification/domain/entities/digital_detox_gamification_entity.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/di/providers.dart';

class DigitalDetoxScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const DigitalDetoxScreen({super.key, this.heroTag});

  @override
  ConsumerState<DigitalDetoxScreen> createState() => _DigitalDetoxScreenState();
}

class _DigitalDetoxScreenState extends ConsumerState<DigitalDetoxScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.digitalDetox);
  final List<String> _selectedApps = [];
  bool _isModuleActive = false;
  bool _isLoadingData = false;
  bool _isLoadingAppIcons = false;
  // ignore: prefer_final_fields
  Map<String, Uint8List?> _appIcons = {};
  // ignore: prefer_final_fields
  Map<String, bool> _appIconLoadStatus = {};

  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadAllPersistentData();
    _loadAppIcons(); // Carregar ícones reais em background
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAppIcons() async {
    if (_isLoadingAppIcons) return;
    
    setState(() => _isLoadingAppIcons = true);
    
    try {
      final commonApps = [
        'com.instagram.android',
        'com.facebook.katana',
        'com.zhiliaoapp.musically',
        'com.snapchat.android',
        'com.twitter.android',
        'com.whatsapp',
        'com.google.android.youtube',
        'com.discord',
        'com.pinterest',
        'com.linkedin.android',
        'com.reddit.frontpage',
        'org.telegram.messenger', // Package name correto
        'com.twitch.android',
      ];
      
      for (final packageName in commonApps) {
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
      LoggerService.instance.e('Erro ao carregar ícones dos apps', error: e);
    } finally {
      if (mounted) {
        setState(() => _isLoadingAppIcons = false);
      }
    }
  }

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final service = ref.read(digitalDetoxServiceLocalProvider);
      
      // Carregar dados locais sem depender de cloud sync
      final config = await service.getOrCreateConfig(userId);
      final apps = config.monitoredApps;

      if (mounted) {
        setState(() {
          _selectedApps.clear();
          _selectedApps.addAll(apps);
          _isModuleActive = config.isModuleActive;
        });
      }

      
      if (_isModuleActive) {
        bool accessibilityGranted = await PermissionService.hasAccessibilityPermission();
        if (!mounted) return;

        if (accessibilityGranted) {
          ref.read(digitalDetoxServiceLocalProvider);
          LoggerService.instance.i('Jejum Digital: AppLock ativado para ${_selectedApps.length} apps');
        } else {
          setState(() => _isModuleActive = false);
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar dados', error: e);
    } finally {
      _isLoadingData = false;
    }
  }

  
  Future<void> _toggleModule() async {
    HapticFeedback.mediumImpact();

    if (_isModuleActive) {
      // Desativar módulo
      final shouldDeactivate = await showDialog<bool>(
        context: context,
        builder: (context) => DeactivateModuleDialog(
          nicheId: NicheId.digitalDetox,
          customMessage: "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado. Deseja continuar?",
        ),
      );

      if (shouldDeactivate == true && mounted) {
        try {
          HapticFeedback.heavyImpact();

          final userId = ref.read(digitalDetoxCurrentUserIdProvider);
          await ref.read(digitalDetoxServiceLocalProvider).deactivateModule(userId);

          // Resetar gamificação mantendo apenas insígnia Madeira
          await _resetGamification();

          // Sincronizar configurações com camada nativa Android
          await AppLockSyncService.instance.syncAllConfigs();

          // Invalidar activeModulesProvider para atualizar home screen
          ref.invalidate(activeModulesProvider);

          setState(() => _isModuleActive = false);

          if (mounted) {
            EnhancedSnackBarHelper.showWarning(context, 'Módulo desativado');
          }
        } catch (e) {
          LoggerService.instance.e('Erro ao desativar módulo', error: e);
        }
      }
    } else {
      // Ativar módulo
      if (_selectedApps.isEmpty) {
        EnhancedSnackBarHelper.showInfo(
          context,
          "Primeiro, selecione os apps que deseja monitorar.",
        );
        return;
      }

      bool accessibilityGranted = await PermissionService.hasAccessibilityPermission();

      if (!accessibilityGranted) {
        _showPermissionRequiredDialog();
        return;
      }

      try {
        HapticFeedback.lightImpact();

        final userId = ref.read(digitalDetoxCurrentUserIdProvider);
        await ref.read(digitalDetoxServiceLocalProvider).activateModule(userId);

        for (final app in _selectedApps) {
          await ref.read(digitalDetoxServiceLocalProvider).addMonitoredApp(userId, app);
        }

        // Sincronizar configurações com camada nativa Android
        await AppLockSyncService.instance.syncAllConfigs();

        // Invalidar activeModulesProvider para atualizar home screen
        ref.invalidate(activeModulesProvider);

        setState(() => _isModuleActive = true);

        if (mounted) {
          EnhancedSnackBarHelper.showSuccess(context, 'Módulo ativado com sucesso!');
        }
      } catch (e) {
        LoggerService.instance.e('Erro ao ativar módulo', error: e);
      }
    }
  }

  Future<void> _resetGamification() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final repository = DigitalDetoxGamificationRepository(
        ObjectBoxService.instance.store.box<DigitalDetoxGamificationEntity>()
      );
      final service = DigitalDetoxGamificationService(repository);
      
      // Resetar streak e medalhas, mantendo apenas insígnia Madeira
      await service.resetStreak(userId);
      
      LoggerService.instance.i('Gamificação do Jejum Digital resetada, mantendo insígnia Madeira');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar gamificação', error: e);
    }
  }

  
  
  
  Future<void> _showPermissionRequiredDialog() async {
    final result = await context.showAccessibilityPermissionDialog(
      title: 'Permissão Necessária',
      message: 'O Jejum Digital precisa de acesso à Acessibilidade para monitorar os apps.\n\nIsso permite que o app detecte quando você abre apps de redes sociais e mostre a tela de bloqueio.',
      onOpenSettings: () => PermissionService.openAccessibilitySettings(),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userId = ref.watch(digitalDetoxCurrentUserIdProvider);
    final state = ref.watch(digitalDetoxNotifierProvider(userId));

    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
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
                          // TAB 0: Jejum Digital (módulo)
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildTabContent(0, state),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          // TAB 1: Como funciona
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildTabContent(1, state),
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
              // Botões apenas na aba 0 (Jejum Digital)
              if (_selectedIndex == 0)
                _buildActionButtons(state),
            ],
          ),
        ),
      ),
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
                    'Jejum Digital',
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

  Widget _buildTabContent(int index, DigitalDetoxState state) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (index) {
      case 0:
        // 0: Jejum Digital (módulo)
        return Column(
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
                  final isActive = _isModuleActive;
                  
                  return Row(
                    children: [
                      _buildStatCard('$totalApps', 'Apps', const Color(0xFF8B5CF6), Icons.phone_android_rounded, isCompact: true),
                      const SizedBox(width: 8),
                      _buildStatCard(isActive ? 'Ativo' : 'Inativo', 'Status', isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444), isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded, isCompact: true),
                      const SizedBox(width: 8),
                      _buildStatCard('${_getCurrentStreak()}', 'Dias', const Color(0xFFF59E0B), Icons.calendar_today_rounded, isCompact: true),
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
                  'assets/modules/jejum_digital/digital_detox_screen_asset.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
            
            // Apps para Jejum - Grid de Ícones
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Apps para Jejum',
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
                  children: _selectedApps.map((app) {
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
                        child: _appIcons[app] != null
                            ? Image.memory(
                                _appIcons[app]!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: colorScheme.primaryContainer,
                                child: Icon(
                                  _getAppIcon(app),
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
            
            // Botão para selecionar mais apps
            if (_isModuleActive)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Aqui você pode adicionar navegação para tela de seleção de apps
                    // Por enquanto, vamos mostrar os apps comuns
                  },
                  icon: Icon(Icons.add_circle_outline, size: 20),
                  label: Text('Selecionar Apps'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Apps comuns
            _buildCommonAppsSection(),
            
            const SizedBox(height: 20),
            
            // Seu perfil de uso
            _buildUsageProfileSection(),
            
            const SizedBox(height: 12),
            
          ],
        );
      case 1:
        // 1: Como funciona
        return Column(
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
                    Icons.phone_android_rounded,
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
                    'Controle o uso de redes sociais com inteligência',
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
              Icons.select_all,
              '1. Selecione os Apps',
              'Escolha os apps de redes sociais que você quer controlar (Instagram, TikTok, Facebook, etc.).',
              const Color(0xFF10B981),
            ),
            
            const SizedBox(height: 12),
            
            _buildInstructionCard(
              Icons.play_circle_outline,
              '2. Inicie o Jejum',
              'Ative o módulo para começar a monitorar. Você precisa conceder permissão de Acessibilidade.',
              const Color(0xFFF59E0B),
            ),
            
            const SizedBox(height: 12),
            
            _buildInstructionCard(
              Icons.block,
              '3. Tela de Bloqueio',
              'Quando tentar abrir um app monitorado, uma tela de bloqueio aparecerá.',
              const Color(0xFF8B5CF6),
            ),
            
            const SizedBox(height: 12),
            
            _buildInstructionCard(
              Icons.emoji_events,
              '4. Ganhe Recompensas',
              'A cada 7 dias disciplinados, você ganha 1 "Quebra de Jejum"!',
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
        );
      default:
        return const SizedBox.shrink();
    }
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

  Widget _buildActionButtons(DigitalDetoxState state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linha principal: Config. Horários | Quebras de Jejum
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DigitalDetoxTimeSettingsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, size: 20),
                      SizedBox(width: 2),
                      Text('Config. Horários'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DigitalDetoxFastingBreaksScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_cafe, size: 20),
                      SizedBox(width: 2),
                      Text('Quebras de Jejum'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Linha inferior: Estatísticas | Ativar/Desativar módulo
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _showStatsMenu,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart_rounded, size: 20),
                      SizedBox(width: 2),
                      Text('Estatísticas'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _toggleModule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isModuleActive ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isModuleActive ? Icons.power_settings_new : Icons.power_off,
                        size: 20,
                      ),
                      const SizedBox(width: 2),
                      Text(_isModuleActive ? 'Desativar módulo' : 'Ativar módulo'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatsMenu() {
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
              label: 'Estatísticas de uso',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DigitalDetoxStatsScreen()),
                );
              },
            ),
            ListActionTile(
              icon: Icons.emoji_events_rounded,
              label: 'Conquistas',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DigitalDetoxProgressScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonAppsSection() {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Lista de apps comuns para verificar
    final commonApps = [
      {'name': 'Instagram', 'package': 'com.instagram.android'},
      {'name': 'Facebook', 'package': 'com.facebook.katana'},
      {'name': 'TikTok', 'package': 'com.zhiliaoapp.musically'},
      {'name': 'Snapchat', 'package': 'com.snapchat.android'},
      {'name': 'Twitter/X', 'package': 'com.twitter.android'},
      {'name': 'WhatsApp', 'package': 'com.whatsapp'},
      {'name': 'YouTube', 'package': 'com.google.android.youtube'},
      {'name': 'Discord', 'package': 'com.discord'},
      {'name': 'Pinterest', 'package': 'com.pinterest'},
      {'name': 'LinkedIn', 'package': 'com.linkedin.android'},
      {'name': 'Reddit', 'package': 'com.reddit.frontpage'},
      {'name': 'Telegram', 'package': 'org.telegram.messenger'}, // Package name correto
      {'name': 'Twitch', 'package': 'com.twitch.android'},
    ];
    
    // Filtrar apenas apps que estão instalados (têm ícone real)
    final installedApps = commonApps.where((app) {
      final packageName = app['package'] as String;
      final hasIcon = _appIcons[packageName] != null;
      LoggerService.instance.i('🔍 App ${app['name']} ($packageName): ${hasIcon ? "INSTALADO" : "NÃO INSTALADO"}');
      return hasIcon; // Apenas se tiver ícone real
    }).toList();
    
    LoggerService.instance.i('📊 Total de apps comuns: ${commonApps.length}, Apps instalados: ${installedApps.length}');
    
    // Se não tiver nenhum app instalado, não mostrar a seção
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
                  if (!_isModuleActive) {
                    setState(() {
                      if (isSelected) {
                        _selectedApps.remove(packageName);
                      } else {
                        _selectedApps.add(packageName);
                      }
                    });
                    
                    // Persistir imediatamente a mudança nos apps monitorados
                    try {
                      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
                      final service = ref.read(digitalDetoxServiceLocalProvider);
                      
                      if (isSelected) {
                        // Remover app da persistência
                        await service.removeMonitoredApp(userId, packageName);
                        LoggerService.instance.i('App removido da persistência: $packageName');
                      } else {
                        // Adicionar app à persistência
                        await service.addMonitoredApp(userId, packageName);
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
                      // Ícone real do app (já filtramos apenas apps instalados)
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
        if (!_isModuleActive && _selectedApps.isNotEmpty)
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

  Widget _buildUsageProfileSection() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Seu perfil de uso',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedApps.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.phone_android_rounded, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Apps monitorados: ${_selectedApps.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${_isModuleActive ? "Ativo" : "Inativo"}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isModuleActive ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Limite diário: 60 minutos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Nenhum app configurado',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  int _getCurrentStreak() {
    // Se o módulo não está ativo, não inicializar gamificação
    if (!_isModuleActive) return 0;
    
    try {
      // Acessar o serviço de gamificação diretamente
      final store = ObjectBoxService.instance.store;
      final box = store.box<DigitalDetoxGamificationEntity>();
      final gamificationService = DigitalDetoxGamificationService(
        DigitalDetoxGamificationRepository(box)
      );
      
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final gamification = gamificationService.initializeGamification(userId);
      
      return gamification.currentStreak;
    } catch (e) {
      LoggerService.instance.e('Erro ao obter streak atual', error: e);
      return 0;
    }
  }

  IconData _getAppIcon(String packageName) {
    // Retornar ícone baseado no package name
    switch (packageName) {
      case 'com.instagram.android':
        return Icons.camera_alt;
      case 'com.facebook.katana':
        return Icons.facebook;
      case 'com.zhiliaoapp.musically':
        return Icons.music_video;
      case 'com.snapchat.android':
        return Icons.snapchat;
      case 'com.twitter.android':
        return Icons.alternate_email;
      case 'com.whatsapp':
        return Icons.message;
      case 'com.google.android.youtube':
        return Icons.play_circle;
      case 'com.discord':
        return Icons.discord;
      case 'com.pinterest':
        return Icons.push_pin;
      case 'com.linkedin.android':
        return Icons.work;
      case 'com.reddit.frontpage':
        return Icons.forum;
      case 'com.telegram.messenger':
        return Icons.send;
      case 'com.twitch.android':
        return Icons.live_tv;
      default:
        return Icons.phone_android;
    }
  }

  }
