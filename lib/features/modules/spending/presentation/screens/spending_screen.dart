import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service_local.dart';
import 'package:disciplinum/features/modules/spending/presentation/screens/spending_time_settings_screen.dart';
import 'package:disciplinum/features/modules/spending/presentation/screens/spending_control_break_screen.dart';
import 'package:disciplinum/features/modules/spending/presentation/screens/fixed_bills_stats_screen.dart';
import 'package:disciplinum/features/modules/spending/presentation/screens/fixed_expenses_screen.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/dialogs/permission_dialog.dart';
import 'package:disciplinum/shared/widgets/common/module_screen_header.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/features/modules/spending/gamification/presentation/providers/spending_gamification_provider.dart';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_sync_service.dart';
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';

class SpendingScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const SpendingScreen({super.key, this.heroTag});

  @override
  ConsumerState<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends ConsumerState<SpendingScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.spending);
  final List<String> _selectedApps = [];
  bool _isModuleActive = false;
  bool _isLoadingData = false;
  bool _isLoadingAppIcons = false;
  final Map<String, Uint8List?> _appIcons = {};
  final Map<String, bool> _appIconLoadStatus = {};

  late PageController _pageController;
  int _selectedIndex = 0;

  String get _userId => Supabase.instance.client.auth.currentUser?.id ?? 'guest_user';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadAllPersistentData();
    _loadAppIcons();
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
        'com.mercadolibre',
        'com.amazon.mShop.android.shopping',
        'com.shopee.br',
        'com.zzkko',
        'com.alibaba.aliexpresshd',
        'br.com.magazineluiza',
        'br.com.americanas.mais',
        'com.novapontocom.casasbahia',
      ];
      for (final packageName in commonApps) {
        try {
          final icon = await InstalledAppService().getAppIcon(packageName);
          if (mounted) {
            setState(() {
              _appIcons[packageName] = icon;
              _appIconLoadStatus[packageName] = true;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _appIconLoadStatus[packageName] = true;
            });
          }
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar ícones dos apps e-commerce', error: e);
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
      final service = SpendingServiceLocal.instance;
      final config = await service.getOrCreateConfig(_userId);
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
          LoggerService.instance.i('Spending: AppLock ativado para ${_selectedApps.length} apps');
        } else {
          setState(() => _isModuleActive = false);
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar dados do Spending', error: e);
    } finally {
      _isLoadingData = false;
    }
  }

  Future<void> _toggleModule() async {
    HapticFeedback.mediumImpact();
    if (_isModuleActive) {
      final shouldDeactivate = await showDialog<bool>(
        context: context,
        builder: (context) => DeactivateModuleDialog(
          nicheId: NicheId.spending,
          customMessage: "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado. Deseja continuar?",
        ),
      );
      if (shouldDeactivate == true && mounted) {
        try {
          HapticFeedback.heavyImpact();
          await SpendingServiceLocal.instance.deactivateModule(_userId);
          await _resetGamification();
          await AppLockSyncService.instance.syncAllConfigs();
          setState(() => _isModuleActive = false);
          if (mounted) {
            EnhancedSnackBarHelper.showWarning(context, 'Módulo desativado');
          }
        } catch (e) {
          LoggerService.instance.e('Erro ao desativar módulo Spending', error: e);
        }
      }
    } else {
      if (_selectedApps.isEmpty) {
        EnhancedSnackBarHelper.showInfo(context, "Primeiro, selecione os apps que deseja monitorar.");
        return;
      }
      bool accessibilityGranted = await PermissionService.hasAccessibilityPermission();
      if (!accessibilityGranted) {
        _showPermissionRequiredDialog();
        return;
      }
      try {
        HapticFeedback.lightImpact();
        await SpendingServiceLocal.instance.activateModule(_userId);
        for (final app in _selectedApps) {
          await SpendingServiceLocal.instance.addMonitoredApp(_userId, app);
        }
        await AppLockSyncService.instance.syncAllConfigs();
        setState(() => _isModuleActive = true);
        if (mounted) {
          EnhancedSnackBarHelper.showSuccess(context, 'Módulo ativado com sucesso!');
        }
      } catch (e) {
        LoggerService.instance.e('Erro ao ativar módulo Spending', error: e);
      }
    }
  }

  Future<void> _resetGamification() async {
    try {
      final notifier = ref.read(spendingGamificationNotifierProvider.notifier);
      await notifier.resetProgress();
      LoggerService.instance.i('Gamificação do Spending resetada');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar gamificação Spending', error: e);
    }
  }

  Future<void> _showPermissionRequiredDialog() async {
    final result = await context.showAccessibilityPermissionDialog(
      title: 'Permissão Necessária',
      message: 'O Controle de Gastos precisa de acesso à Acessibilidade para monitorar os apps.\n\nIsso permite que o app detecte quando você abre apps de e-commerce e mostre a tela de bloqueio.',
      onOpenSettings: () => PermissionService.openAccessibilitySettings(),
    );
    if (result == true && mounted) {
      setState(() {
        _selectedIndex = 0;
      });
      if (_pageController.hasClients) {
        _pageController.animateToPage(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
      }
    }
  }

  int _getCurrentStreak() {
    return ref.watch(spendingStreakProvider);
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
              final config = await SpendingServiceLocal.instance.getOrCreateConfig(_userId);
              config.monitoredApps = apps;
              await SpendingServiceLocal.instance.saveConfig(config);
            },
            nicheId: NicheId.spending,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(spendingGamificationNotifierProvider);

    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
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
              ModuleScreenHeader(title: _niche.name),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            child: Column(
                              children: [
                                _buildTabContent(0, state),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
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
              if (_selectedIndex == 0) _buildActionButtons(),
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
              onTap: () => _pageController.animateToPage(0,
                  duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: _selectedIndex == 0
                      ? const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        )
                      : null,
                  color: _selectedIndex == 0 ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Controle de Gastos',
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
              onTap: () => _pageController.animateToPage(1,
                  duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: _selectedIndex == 1
                      ? const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        )
                      : null,
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

  Widget _buildTabContent(int index, SpendingGamificationState state) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (index) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              child: Row(
                children: [
                  _buildStatCard('${_selectedApps.length}', 'Apps', const Color(0xFF8B5CF6),
                      Icons.shopping_bag_rounded,
                      isCompact: true),
                  const SizedBox(width: 8),
                  _buildStatCard(
                      _isModuleActive ? 'Ativo' : 'Inativo',
                      'Status',
                      _isModuleActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      _isModuleActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                      isCompact: true),
                  const SizedBox(width: 8),
                  _buildStatCard('${_getCurrentStreak()}', 'Dias', const Color(0xFFF59E0B),
                      Icons.calendar_today_rounded,
                      isCompact: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  'assets/modules/spending/spending_screen_asset.png',
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
                            const Text('Imagem não disponível'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Apps para Bloqueio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedApps.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_outlined,
                          size: 32, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      const Text(
                        'Toque em Selecionar Apps para adicionar',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
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
                                  Icons.shopping_bag_outlined,
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
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _openSelectApps,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Selecionar Apps'),
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
            _buildCommonAppsSection(),
          ],
        );
      case 1:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 28),
                  SizedBox(height: 8),
                  Text(
                    'Como Funciona',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Controle seus gastos e compras por impulso com inteligência',
                    style: TextStyle(
                        fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInstructionCard(
              Icons.shopping_bag_rounded,
              '1. Escolha os Apps de Compra',
              'Selecione os aplicativos de e-commerce e lojas onde você costuma gastar mais por impulso.',
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            _buildInstructionCard(
              Icons.timer_outlined,
              '2. Defina os Horários',
              'Configure janelas permitidas ou bloqueie-os completamente em horários de vulnerabilidade.',
              const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 12),
            _buildInstructionCard(
              Icons.lock_outline,
              '3. Bloqueio Inteligente',
              'Ao tentar abrir um app monitorado fora dos horários, a tela de bloqueio premium do Disciplinum agirá.',
              const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 12),
            _buildInstructionCard(
              Icons.coffee_outlined,
              '4. Quebras de Controle',
              'Consiga quebras de controle permanecendo disciplinado e use-as para compras urgentes sem quebrar seu progresso.',
              const Color(0xFFEF4444),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

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
                      fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon,
      {bool isCompact = false}) {
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
              style: TextStyle(fontSize: isCompact ? 10 : 12, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonAppsSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final commonApps = [
      {'name': 'Mercado Livre', 'package': 'com.mercadolibre'},
      {'name': 'Amazon Shopping', 'package': 'com.amazon.mShop.android.shopping'},
      {'name': 'Shopee', 'package': 'com.shopee.br'},
      {'name': 'Shein', 'package': 'com.zzkko'},
      {'name': 'AliExpress', 'package': 'com.alibaba.aliexpresshd'},
      {'name': 'Magalu', 'package': 'br.com.magazineluiza'},
      {'name': 'Americanas', 'package': 'br.com.americanas.mais'},
      {'name': 'Casas Bahia', 'package': 'com.novapontocom.casasbahia'},
    ];

    final installedApps = commonApps.where((app) {
      final packageName = app['package'] as String;
      return _appIcons[packageName] != null;
    }).toList();

    if (installedApps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Apps instalados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    try {
                      final service = SpendingServiceLocal.instance;
                      if (isSelected) {
                        await service.removeMonitoredApp(_userId, packageName);
                      } else {
                        await service.addMonitoredApp(_userId, packageName);
                      }
                    } catch (e) {
                      LoggerService.instance.e('Erro ao persistir app $packageName', error: e);
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
      ],
    );
  }

  Widget _buildActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SpendingTimeSettingsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      MaterialPageRoute(builder: (_) => const SpendingControlBreakScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_cafe, size: 20),
                      SizedBox(width: 2),
                      Text('Quebra de Controle'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _showStatsMenu,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  MaterialPageRoute(builder: (_) => const FixedBillsStatsScreen()),
                );
              },
            ),
            ListActionTile(
              icon: Icons.credit_card_rounded,
              label: 'Gerenciar Gastos Fixos',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FixedExpensesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
