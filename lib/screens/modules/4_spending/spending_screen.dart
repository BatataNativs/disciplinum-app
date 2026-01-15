import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:usage_stats/usage_stats.dart';

import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/screens/select_apps_screen.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/widgets/profile/lojinha.dart';
import 'package:disciplinum/widgets/niche_details/niche_header.dart';
import 'package:disciplinum/widgets/niche_details/niche_info_section.dart';

import 'package:disciplinum/utils/app_info_helper.dart';

class SpendingScreen extends StatefulWidget {
  const SpendingScreen({super.key});

  @override
  State<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.spending);
  final List<String> _selectedApps = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;
  int _selectedIndex = 0; // 0=Como Funciona, 1=Apps, 2=Ativar

  @override
  void initState() {
    super.initState();
    _loadAllPersistentData();
  }

  // --- HARDCODED TEXTS FOR SPENDING ---
  String _getModuleHintText() {
    return 'Este módulo te ajuda a controlar gastos, enviando alertas ao abrir '
        'apps de compras e de delivery selecionados. '
        'Se precisar usar um desses apps por necessidade real, pause as '
        'notificações temporariamente (em Configurações) para não perder seu progresso, '
        'podendo manter o módulo ativado.';
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
            gamification.startMonitoringApps(
              nicheId: nicheId,
              horarios: [],
            );
          } else {
            setState(() => _gamificationRunning = false);
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

    _resetMedalsForModule(
      notificationTitle: 'Progresso reiniciado neste módulo',
      notificationBody:
          'Você desativou o módulo ${_niche.name}. Se reativar no futuro, '
          'seu progresso começará novamente do zero.',
    );

    setState(() => _gamificationRunning = false);
    CloudSyncService.saveModuleStatus(
      nicheId: _niche.id,
      isActive: false,
    );

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
  }) {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.resetMedals(
      _niche.id,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      sendNotification: sendNotification,
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
    setState(() {});
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
                setState(() => _selectedIndex = index);
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
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMedalProgress(
      {required Color primaryColor, required Color secondaryColor}) {
    final gamification = Provider.of<GamificationService>(context);
    final nicheId = _niche.id;
    final diasConsecutivos =
        gamification.diasConsecutivosByModule[nicheId] ?? 0;

    String text;
    Color color = primaryColor;

    if (diasConsecutivos >= 10) {
      text = 'Parabéns! Você alcançou a medalha de Diamante (Nível Máximo)! 💎';
      color = Colors.blueAccent;
    } else if (diasConsecutivos >= 7) {
      text =
          'Sua medalha atual é de Ouro 🥇. Faltam ${10 - diasConsecutivos} dias para a medalha de Diamante 💎.';
    } else if (diasConsecutivos >= 5) {
      text =
          'Sua medalha atual é de Prata 🥈. Faltam ${7 - diasConsecutivos} dias para a medalha de Ouro 🥇.';
    } else if (diasConsecutivos >= 3) {
      text =
          'Sua medalha atual é de Bronze 🥉. Faltam ${5 - diasConsecutivos} dias para a medalha de Prata 🥈.';
    } else {
      text =
          'Sem medalhas ainda. Faltam ${3 - diasConsecutivos} dias para a medalha de Bronze 🥉.';
    }

    return NeonCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.military_tech_outlined, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                'Como anda seu progresso:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (diasConsecutivos % 3) / 3,
              backgroundColor: secondaryColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          children: [
            NicheInfoSection(hintText: _getModuleHintText()),
            const SizedBox(height: 24),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apps Monitorados:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedApps.isEmpty)
              NeonCard(
                padding: const EdgeInsets.all(12),
                child: const Center(
                  child: Text(
                    'Nenhum app de compras selecionado.',
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
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;

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
      case 2:
      default:
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          children: [
            if (_gamificationRunning) ...[
              _buildMedalProgress(
                primaryColor: isDark ? Colors.white70 : const Color(0xFF6366F1),
                secondaryColor: isDark
                    ? Colors.white70.withValues(alpha: 0.8)
                    : const Color(0xFF6366F1).withValues(alpha: 0.6),
              ),
              const SizedBox(height: 24),
            ],
            _buildNotificationMessageSection(context),
            const SizedBox(height: 24),
          ],
        );
    }
  }

  Widget _buildTabActions() {
    switch (_selectedIndex) {
      case 1:
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: GlowingButton(
            text: 'Selecionar/Adicionar apps',
            onPressed: _openSelectApps,
            color: const Color(0xFF6366F1),
            borderRadius: 18,
          ),
        );
      case 2:
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: GlowingButton(
            text: _gamificationRunning
                ? 'Desativar Monitoramento'
                : 'Ativar Monitoramento',
            color: _gamificationRunning
                ? Colors.redAccent
                : const Color.fromARGB(255, 16, 165, 53),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    if (_loadingData) {
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      NicheHeader(niche: _niche),
                      const SizedBox(height: 24),
                      _buildSegmentedControl(),
                      const SizedBox(height: 32),
                      _buildTabContent(),
                      const SizedBox(height: 32),
                      _buildTabActions(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationMessageSection(BuildContext context) {
    final iap = Provider.of<IapService>(context);
    final gamification = Provider.of<GamificationService>(context);
    final currentMsg = getModuleMessage(_niche.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717), // Anthracite
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mensagem de Alerta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              if (!iap.isCustomNotifUnlocked)
                const Icon(Icons.lock_outline, size: 16, color: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentMsg,
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (iap.isCustomNotifUnlocked) {
                  _openEditMessageDialog(context, gamification);
                } else {
                  _showPremiumFeatureDialog();
                }
              },
              label: Text(
                iap.isCustomNotifUnlocked
                    ? 'Editar Mensagem'
                    : 'Personalizar 🔓',
                style: const TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumFeatureDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recurso pago 💰'),
        content: const Text(
          'A personalização de mensagens é um recurso pago. '
          '\nDeseja conhecer nossa lojinha?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                builder: (_) => const Lojinha(),
              );
            },
            child: const Text('Ir para Lojinha'),
          ),
        ],
      ),
    );
  }

  void _openEditMessageDialog(
      BuildContext context, GamificationService gamification) {
    final controller = TextEditingController(text: getModuleMessage(_niche.id));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Mensagem'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Digite sua mensagem personalizada...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await gamification.setCustomMessage(_niche.id, controller.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mensagem atualizada!')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
