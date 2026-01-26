import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/screens/modules/2_bingeEating/binge_eating_notifications_screen.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/screens/select_apps_screen.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:disciplinum/widgets/niche_details/niche_header.dart';
import 'package:disciplinum/widgets/niche_details/niche_info_section.dart';
import 'package:disciplinum/widgets/niche_details/niche_content_apps.dart';
import 'package:disciplinum/widgets/2_bingeEating/my_progress_binge_eating.dart';
import 'package:disciplinum/utils/app_info_helper.dart';

class BingeEatingScreen extends StatefulWidget {
  const BingeEatingScreen({super.key});

  @override
  State<BingeEatingScreen> createState() => _BingeEatingScreenState();
}

class _BingeEatingScreenState extends State<BingeEatingScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.bingeEating);
  final List<String> _selectedApps = [];
  final List<AppDisplayInfo> _appDisplayInfos = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

  // --- CONTROLADOR DE PÁGINA ---
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadAllPersistentData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- HARDCODED TEXTS AND LOGIC FOR BINGE EATING ---
  String _getModuleHintText() {
    return 'Este módulo te ajuda a conter a compulsão alimentar, '
        'te enviando notificação de alerta se você abrir apps de delivery selecionados enquanto o módulo estiver ativado.'
        'Se realmente precisar usar um desses apps, considere pausar temporariamente '
        'as notificações (lá nas Configurações) para não perder seu progresso, '
        'ainda mantendo o módulo ativado enquanto isso.';
  }

  String _getIntroText() {
    return 'Escolha seus apps de delivery:';
  }

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      final nicheId = _niche.id;

      final userApps =
          await CloudSyncService.loadUserNicheApps(nicheId: nicheId);
      final status = await CloudSyncService.loadModuleStatus(nicheId);

      final apps = userApps.map((a) => a.appPackage).toList();

      if (mounted) {
        setState(() {
          _selectedApps.clear();
          _selectedApps.addAll(apps);
          _gamificationRunning = status?.isActive ?? false;
        });

        // Pre-carregar informações dos apps para evitar flickers
        final infos = await gatherAppDisplayInfo(_selectedApps);
        if (mounted) {
          setState(() {
            _appDisplayInfos.clear();
            _appDisplayInfos.addAll(infos);
            _loadingData = false;
          });

          if (_gamificationRunning) {
            final gamification =
                Provider.of<GamificationService>(context, listen: false);
            gamification.monitoredApps = List.from(_selectedApps);

            bool usageGranted =
                await UsageStats.checkUsagePermission() ?? false;

            if (!mounted) return;

            if (usageGranted) {
              gamification.startMonitoringApps(
                nicheId: nicheId,
                horarios: [], // Binge eating only uses apps
              );
            } else {
              setState(() => _gamificationRunning = false);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
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
      _appDisplayInfos.removeWhere((element) => element.package == packageName);
    });

    await CloudSyncService.removeUserNicheApp(
      nicheId: _niche.id,
      package: packageName,
    );

    final label = await getAppLabel(packageName) ?? packageName;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('App removido: $label'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();

    if (_selectedApps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Primeiro, deve-se selecionar apps a monitorar..',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    bool usageGranted = await UsageStats.checkUsagePermission() ?? false;
    if (!usageGranted) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Permissão Necessária'),
            content: const Text(
              'Para monitorar se você está usando os apps selecionados para ser gatilho de notificações, precisamos de acesso às estatísticas de uso.\n\nToque em "Configurar" e ative o Disciplinum na lista.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(ctx);
                  UsageStats.grantUsagePermission();
                },
                child: const Text('Configurar'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.monitoredApps = List.from(_selectedApps);

    gamification.startMonitoringApps(
      nicheId: _niche.id,
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
    CloudSyncService.saveModuleStatus(
      nicheId: _niche.id,
      isActive: true,
    );
    Provider.of<GamificationService>(context, listen: false)
        .startModuleCycle(nicheId: _niche.id);
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

  void _desativarNichoMonitoramento() {
    HapticFeedback.heavyImpact();
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.stopMonitoringApps();

    // Reset progress and deactivate the module in one go
    _resetMedalsForModule(
      notificationTitle: 'Progresso reiniciado neste módulo',
      notificationBody:
          'Você desativou o módulo ${_niche.name}. Se reativar no futuro, '
          'seu progresso começará novamente do zero.',
      deactivate: true,
    );

    setState(() => _gamificationRunning = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Módulo desativado — Você não receberá mais alertas'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetMedalsForModule({
    String? notificationTitle,
    String? notificationBody,
    bool sendNotification = true,
    bool deactivate = false,
  }) {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.resetMedals(
      _niche.id,
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

              final infos = await gatherAppDisplayInfo(apps);
              if (mounted) {
                setState(() {
                  _appDisplayInfos.clear();
                  _appDisplayInfos.addAll(infos);
                });
              }

              await CloudSyncService.removeAllAppsForNiche(
                nicheId: _niche.id,
              );
              for (var pkg in apps) {
                await CloudSyncService.addUserNicheApp(
                  nicheId: _niche.id,
                  package: pkg,
                );
              }
            },
            nicheId: _niche.id,
          ),
        ),
      ),
    );

    // Se tiver apps e o controller estiver ok, avança para ativar
    if (_selectedApps.isNotEmpty) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      } else {
        setState(() => _selectedIndex = 2);
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
        appBar: AppBar(
          title: Text(_niche.name),
          centerTitle: true,
        ),
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
              // Header Custom
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
                            fontSize: 18,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: NicheHeader(
                        niche: _niche,
                        showBackground: false,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSegmentedControl(),
                    ),
                    const SizedBox(height: 32),

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
                                _buildTabContent(0),
                                const SizedBox(height: 24),
                                _buildTabActions(0),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                          // 1: Apps
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildTabContent(1),
                                const SizedBox(height: 24),
                                _buildTabActions(1),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                          // 2: Ativar
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildTabContent(2),
                                const SizedBox(height: 24),
                                _buildTabActions(2),
                                const SizedBox(height: 40),
                              ],
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
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> options = ['Como Funciona', 'Apps', 'Ativar'];

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                // Verificação de segurança + Animação rápida (250ms)
                if (_pageController.hasClients) {
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutQuad);
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOutQuart,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color.fromARGB(255, 57, 92, 208)
                          : const Color.fromARGB(255, 18, 189, 211))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (isDark
                                    ? const Color.fromARGB(255, 57, 92, 208)
                                    : const Color.fromARGB(255, 10, 223, 219))
                                .withValues(alpha: 0.3),
                            blurRadius: 10,
                          )
                        ]
                      : [],
                ),
                child: Text(
                  options[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return Column(
          children: [
            NicheInfoSection(hintText: _getModuleHintText()),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
          ],
        );
      case 1:
        return NicheContentApps(
          selectedApps: _selectedApps,
          appDisplayInfos: _appDisplayInfos,
          introText: _getIntroText(),
          onAdd: _openSelectApps,
          onRemove: (pkg) => _removeSelectedApp(pkg),
        );
      case 2:
        return Column(
          children: [
            if (_gamificationRunning) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyProgressBingeEating()),
                        );
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF395CC8),
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF395CC8)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Meu progresso',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const BingeEatingNotificationsScreen()),
                        );
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white24
                                    : Colors.grey[400]!,
                          ),
                        ),
                        child: Text(
                          'Notificações',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else ...[
              const Icon(Icons.do_not_disturb_on_rounded,
                  size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Módulo desativado",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              const Text(
                "Ative o módulo para começar a usá-lo e para criar seu progresso.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTabActions(int index) {
    switch (index) {
      // --- BOTÃO COMEÇAR (ABA 0) ---
      case 0:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: GlowingButton(
            text: 'Começar',
            color: const Color.fromARGB(255, 57, 92, 208),
            onPressed: () {
              if (_pageController.hasClients) {
                _pageController.animateToPage(1, // Vai para "Apps"
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic);
              }
            },
            borderRadius: 18,
          ),
        );
      case 1:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: GlowingButton(
            text: 'Selecionar aplicativos',
            color: const Color.fromARGB(255, 57, 92, 208),
            onPressed: _openSelectApps,
            borderRadius: 18,
          ),
        );
      case 2:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: GlowingButton(
            text: _gamificationRunning ? 'Desativar Módulo' : 'Ativar Módulo',
            color: _gamificationRunning
                ? const Color.fromARGB(255, 239, 68, 68)
                : const Color.fromARGB(255, 16, 185, 129),
            onPressed: _gamificationRunning
                ? _desativarNichoMonitoramento
                : _ativarNichoMonitoramento,
            borderRadius: 18,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
