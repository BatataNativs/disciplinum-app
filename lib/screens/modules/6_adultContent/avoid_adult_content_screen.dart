import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:disciplinum/screens/modules/6_adultContent/avoid_adult_content_notifications_screen.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/screens/select_apps_screen.dart';
import 'package:disciplinum/widgets/6_adultContent/my_progress_adult_content.dart';
import 'package:disciplinum/utils/app_info_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/utils/snackbar_helper.dart';

class AvoidAdultContentScreen extends StatefulWidget {
  final String? heroTag;
  const AvoidAdultContentScreen({super.key, this.heroTag});

  @override
  State<AvoidAdultContentScreen> createState() =>
      _AvoidAdultContentScreenState();
}

class _AvoidAdultContentScreenState extends State<AvoidAdultContentScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.adultContent);
  final List<String> _selectedApps = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

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

  String _getIntroText() {
    return 'Aplicativos a serem monitorados:';
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
          _loadingData = false;
        });

        if (_gamificationRunning) {
          final gamification =
              Provider.of<GamificationService>(context, listen: false);
          gamification.monitoredApps = List.from(_selectedApps);

          bool usageGranted = await UsageStats.checkUsagePermission() ?? false;
          if (!mounted) return;

          if (usageGranted) {
            gamification.startMonitoringApps(nicheId: nicheId, horarios: []);
          } else {
            setState(() => _gamificationRunning = false);
          }
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
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

    await CloudSyncService.removeUserNicheApp(
      nicheId: _niche.id,
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
        "Primeiro, deve-se selecionar apps a monitorar..",
      );
      return;
    }

    bool usageGranted = await UsageStats.checkUsagePermission() ?? false;
    if (!usageGranted) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Permissão Necessária"),
            content: const Text(
              "Para monitorar se você está usando os apps selecionados, precisamos de acesso às estatísticas de uso. Toque em Configurar e ative o Disciplinum na lista.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                },
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(ctx);
                  UsageStats.grantUsagePermission();
                },
                child: const Text("Configurar"),
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
    gamification.startMonitoringApps(nicheId: _niche.id, horarios: []);

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
    CloudSyncService.saveModuleStatus(nicheId: _niche.id, isActive: true);
    Provider.of<GamificationService>(context, listen: false)
        .startModuleCycle(nicheId: _niche.id);
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Desativar módulo?"),
        content: const Text(
          "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado. Deseja continuar?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sim, desativar e zerar"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      final gamification =
          Provider.of<GamificationService>(context, listen: false);
      gamification.stopMonitoringApps();

      _resetMedalsForModule(
        notificationTitle: 'Módulo Desativado 🛑',
        notificationBody:
            'O módulo foi desativado e todos os dados de estatística e gamificação foram resetados.',
        deactivate: true,
      );

      setState(() {
        _gamificationRunning = false;
        _selectedIndex = 0;
      });

      if (_pageController.hasClients) {
        _pageController.animateToPage(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      }
    }
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

              await CloudSyncService.removeAllAppsForNiche(nicheId: _niche.id);
              for (var pkg in apps) {
                await CloudSyncService.addUserNicheApp(
                    nicheId: _niche.id, package: pkg);
              }
            },
            nicheId: _niche.id,
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
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildTabContent(0),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
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
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTabActions(0),
                    )
                  : _buildBottomButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> options = ['Como funciona', 'Evitar conteúdo adulto'];

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
        return Column(
          children: [
            _buildInfoCard(
              isDark,
              icon: Icons.settings_outlined,
              title: "Em Selecionar apps, escolha os aplicativos a monitorar",
              content:
                  "Selecione os apps de conteúdo adulto que você deseja monitorar. Após selecionar, ative o módulo para começar.",
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              isDark,
              icon: Icons.notifications_outlined,
              title: "Em Notificações, configure lembretes",
              content:
                  "Defina horários para receber lembretes motivacionais que te ajudem a manter a disciplina.",
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              isDark,
              icon: Icons.bar_chart_rounded,
              title: "Em Estatísticas, acompanhe sua evolução",
              content:
                  "Visualize quantos dias você está sem acessar conteúdo adulto e acompanhe sua disciplina.",
            ),
          ],
        );
      case 1:
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
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoCard(
    bool isDark, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabActions(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (index) {
      case 0:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: _buildActionButton(
            icon: Icons.rocket_launch_rounded,
            label: "Começar",
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: () {
              if (_pageController.hasClients) {
                _pageController.animateToPage(1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic);
              }
            },
          ),
        );
      case 1:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: _buildActionButton(
            icon: Icons.apps_rounded,
            label: "Selecionar aplicativos",
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: _openSelectApps,
          ),
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
                child: _buildActionButton(
                  icon: Icons.touch_app_outlined,
                  label: "Selecionar apps",
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _openSelectApps,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.notifications_outlined,
                  label: "Notificações",
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AvoidAdultContentNotificationsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: "Estatísticas",
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _showStatisticsMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: _gamificationRunning
                      ? Icons.power_settings_new
                      : Icons.power_off,
                  label: _gamificationRunning
                      ? "Desativar Módulo"
                      : "Ativar Módulo",
                  color: _gamificationRunning ? Colors.red : Colors.green,
                  isDark: isDark,
                  isDestructive: _gamificationRunning,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
            _buildMenuTile(
              icon: Icons.bar_chart_rounded,
              label: "Conquistas",
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyProgressAdultContent()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: isDark ? Colors.white30 : Colors.black26,
        ),
        onTap: onTap,
      ),
    );
  }
}
