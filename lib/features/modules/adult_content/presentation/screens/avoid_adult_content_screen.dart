import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/shared/widgets/dialogs/permission_dialog.dart';
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:disciplinum/features/modules/adult_content/presentation/widgets/my_progress_adult_content.dart' as adult_content_progress;
import 'package:disciplinum/features/modules/adult_content/gamification/presentation/widgets/adult_content_celebration_widget.dart';
import 'package:disciplinum/core/utils/app_info_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';

class AvoidAdultContentScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const AvoidAdultContentScreen({super.key, this.heroTag});

  @override
  ConsumerState<AvoidAdultContentScreen> createState() =>
      _AvoidAdultContentScreenState();
}

class _AvoidAdultContentScreenState extends ConsumerState<AvoidAdultContentScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.adultContent);
  final List<String> _selectedApps = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

  late PageController _pageController;
  int _selectedIndex = 0; // 0=Jejum 18+, 1=Como funciona

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0); // Garante que inicie na aba "Jejum 18+"
    _loadAllPersistentData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getIntroText() {
    return 'Aplicativos a serem monitorados:';
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
          // Lógica local de gamificação - usando provider local do AdultContent
          bool accessibilityGranted =
              await PermissionService.hasAccessibilityPermission();
          if (!mounted) return;

          if (accessibilityGranted) {
            // Usando provider local do AdultContent para ativar AppLock
            ref.read(adultContentServiceIsarProvider);
            // Ativa o AppLock para os apps selecionados
            LoggerService.instance.i('AdultContent: AppLock ativado para ${_selectedApps.length} apps');
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
      SnackBarHelper.showInfo(context, "App removido: $label");
    }
  }

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();

    if (_selectedApps.isEmpty) {
      SnackBarHelper.showInfo(
        context,
        "Primeiro, selecione os apps que deseja monitorar.",
      );
      return;
    }

    // NOVO: Verificar permissão de sobreposição primeiro
    bool overlayGranted = await PermissionService.ensureOverlayPermissionForModule(
      context,
      NicheId.adultContent,
    );
    
    if (!overlayGranted) {
      // Usuário clicou "Depois" - desativar módulo e mostrar snackbar
      if (mounted) {
        SnackBarHelper.showInfo(
          context,
          'Você precisa conceder a permissão de sobreposição para ativar o módulo de Jejum 18+.',
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

    // Usando provider local do AdultContent
    ref.read(adultContentServiceIsarProvider);
    // Inicia o AppLock para os apps selecionados
    LoggerService.instance.i('AdultContent: Iniciando monitoramento de ${_selectedApps.length} apps');

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
      nicheId: _niche.nicheId,
      isModuleActive: true,
    );
    // Usando provider local do AdultContent
    ref.read(adultContentServiceIsarProvider);
    LoggerService.instance.i('AdultContent: Ciclo de gamificação iniciado');
  }

  Future<void> _showNotificationSettingsDialog() async {
    context.showNotificationPermissionDialog(
      onOpenSettings: () => NotificationService.openNotificationSettings(),
    );
  }

  Future<void> _desativarNichoMonitoramento() async {
    // Usando provider local do AdultContent
    ref.read(adultContentServiceIsarProvider);
    final confirmed = await DeactivateModuleDialog.show(
      context: context,
      nicheId: NicheId.adultContent,
      customMessage: "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado. Deseja continuar?",
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      
      // Desativa o AppLock usando o provider local
      LoggerService.instance.i('AdultContent: Desativando módulo e AppLock');
      
      _resetMedalsForModule();

      // Obtém o estado atual do módulo via provider local
      final gamificationStatus = false; // Módulo desativado

      setState(() {
        _gamificationRunning = gamificationStatus;
        _selectedIndex = 0;
      });

      // Sincronizar com a nuvem
      ref.read(cloudSyncServiceProvider).saveModuleStatus(
        nicheId: NicheId.adultContent,
        isModuleActive: false,
      );

      if (_pageController.hasClients) {
        _pageController.animateToPage(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      }

      if (mounted) {
        SnackBarHelper.showWarning(context, 'Módulo desativado');
      }
    }
  }

  void _resetMedalsForModule() {
    // Usando provider local do AdultContent
    ref.read(adultContentServiceIsarProvider);
    LoggerService.instance.i('AdultContent: Resetando dados do módulo');
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
                nicheId: _niche.nicheId,
              );
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
    final colorScheme = theme.colorScheme;

    if (_loadingData) {
      return Scaffold(
        appBar: AppBar(title: Text(_niche.name), centerTitle: true),
        body: Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest,
          highlightColor: colorScheme.surfaceContainerHigh,
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

    return AdultContentCelebrationWidget(
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: colorScheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          _niche.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface),
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
                          // 0: Jejum 18+ (módulo)
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildTabContent(0),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          // 1: Como funciona
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
                  ? _buildBottomButtons()
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSegmentedControl() {
    final colorScheme = Theme.of(context).colorScheme;
    final List<String> options = ['Jejum 18+', 'Como funciona'];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                        : colorScheme.onSurface.withValues(alpha: 0.6),
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
    final colorScheme = Theme.of(context).colorScheme;
    switch (index) {
      case 0:
        // 0: Jejum 18+ (módulo)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getIntroText(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedApps.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
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
                                color: colorScheme.onSurface)),
                        onDeleted: () => _removeSelectedApp(info.package),
                        deleteIconColor: colorScheme.onSurface.withValues(alpha: 0.7),
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        );
      case 1:
        // 1: Como funciona
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Container roxo com degradê
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.block_rounded,
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
                      'Proteja-se contra conteúdo adulto com inteligência',
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
                Icons.security_rounded,
                '1. Bloqueio Inteligente',
                'Use tecnologia avançada para detectar e bloquear automaticamente conteúdo adulto em apps e navegadores.',
                Colors.red,
              ),
              _buildInstructionCard(
                Icons.schedule_rounded,
                '2. Agendamento Personalizado',
                'Defina horários específicos para bloqueio temporário, permitindo acesso em períodos seguros.',
                Colors.red,
              ),
              _buildInstructionCard(
                Icons.privacy_tip_rounded,
                '3. Modo Furtivo',
                'Ative o modo discreto que esconde o bloqueio, mantendo seu uso completamente privado e seguro.',
                Colors.red,
              ),
              _buildInstructionCard(
                Icons.insights_rounded,
                '4. Relatórios Detalhados',
                'Acompanhe tentativas de acesso, padrões de uso e eficácia do bloqueio através de estatísticas completas.',
                Colors.red,
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButtons() {
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
                  onPressed: _openSelectApps,
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
                      Icon(Icons.touch_app_outlined, size: 20),
                      SizedBox(width: 8),
                      Text("Selecionar apps"),
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
                  onPressed: _showStatisticsMenu,
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
                      SizedBox(width: 8),
                      Text("Estatísticas"),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _gamificationRunning
                      ? _desativarNichoMonitoramento
                      : _ativarNichoMonitoramento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gamificationRunning ? Colors.red : Colors.green,
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
                        _gamificationRunning
                            ? Icons.power_settings_new
                            : Icons.power_off,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(_gamificationRunning
                          ? "Desativar Módulo"
                          : "Ativar Módulo"),
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
                      builder: (_) => const adult_content_progress.MyProgressAdultContent()),
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
