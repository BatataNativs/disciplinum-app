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
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:disciplinum/features/modules/adult_content/presentation/widgets/my_progress_adult_content.dart' as adult_content_progress;
import 'package:disciplinum/core/utils/app_info_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';

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
  int _selectedIndex = 0; // 0=Evitar conteúdo adulto, 1=Como funciona

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0); // Garante que inicie na aba "Evitar conteúdo adulto"
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
          'Você precisa conceder a permissão de sobreposição para ativar o módulo de Conteúdo Adulto.',
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
                          // 0: Evitar conteúdo adulto (módulo)
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
                  ? _buildBottomButtons(isDark)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> options = ['Evitar conteúdo adulto', 'Como funciona'];

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
        // 0: Evitar conteúdo adulto (módulo)
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
          ],
        );
      case 1:
        // 1: Como funciona
        return Column(
          children: [
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.settings_outlined,
              title: "Em Selecionar apps, escolha os aplicativos a monitorar",
              content:
                  "Selecione os apps de conteúdo adulto que você deseja monitorar. Após selecionar, ative o módulo para começar.",
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.notifications_outlined,
              title: "Em Notificações, configure lembretes",
              content:
                  "Defina horários para receber lembretes motivacionais que te ajudem a manter a disciplina.",
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.bar_chart_rounded,
              title: "Em Estatísticas, acompanhe sua evolução",
              content:
                  "Visualize quantos dias você está sem acessar conteúdo adulto e acompanhe sua disciplina.",
            ),
          ],
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
                child: ModernStartButton(
                  icon: Icons.touch_app_outlined,
                  label: "Selecionar apps",
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _openSelectApps,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModernStartButton(
                  icon: Icons.bar_chart_rounded,
                  label: "Estatísticas",
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _showStatisticsMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: _gamificationRunning
                      ? Icons.power_settings_new
                      : Icons.power_off,
                  label: _gamificationRunning
                      ? "Desativar Módulo"
                      : "Ativar Módulo",
                  color: _gamificationRunning ? Colors.red : Colors.green,
                  isDark: isDark,
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
              "Estatisticas e Opcoes",
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
                      builder: (_) => const adult_content_progress.MyProgressAdultContent()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
