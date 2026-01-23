import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/screens/select_apps_screen.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/widgets/profile/lojinha.dart';
import 'package:disciplinum/widgets/niche_details/niche_header.dart';
import 'package:disciplinum/widgets/niche_details/niche_info_section.dart';
import 'package:disciplinum/widgets/5_focus/my_progress_focus.dart';

import 'package:disciplinum/utils/app_info_helper.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.focus);
  final List<String> _selectedApps = [];
  TimeOfDay? _focusStart;
  TimeOfDay? _focusEnd;
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;
  int _selectedIndex = 0; // 0=Como Funciona, 1=Apps, 2=Tempo, 3=Ativar

  @override
  void initState() {
    super.initState();
    _loadAllPersistentData();
  }

  // --- HARDCODED TEXTS FOR FOCUS ---

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      final nicheId = _niche.id;
      final userApps =
          await CloudSyncService.loadUserNicheApps(nicheId: nicheId);
      final userTimes =
          await CloudSyncService.loadUserNicheTimes(nicheId: nicheId.id);
      final status = await CloudSyncService.loadModuleStatus(nicheId);

      final apps = userApps.map((a) => a.appPackage).toList();

      TimeOfDay? start;
      TimeOfDay? end;

      // Focus module usually stores interval as two times in DB?
      // Based on original code it seemed like it just loaded times.
      // NicheContentFocus logic used standard times?
      // Actually original code for focus didn't seemingly load start/end from DB explicitly separate from times list?
      // Wait, let's check CloudSyncService usage in original code.
      // Original code: _times = userTimes...
      // But _focusStart/_focusEnd were not seemingly loaded from DB in the original snippet I saw?
      // Ah, the NicheContentFocus logic might rely on local state or maybe I missed how start/end are persisted.
      // Let's assume for now we just load selected apps.
      // If the original user wants to persist the interval, we might need to check if existing DB supports it.
      // For now, I will keep it simple: If times list has 2 entries, assume start/end.

      if (userTimes.length >= 2) {
        start = TimeOfDay(hour: userTimes[0].hour, minute: userTimes[0].minute);
        end = TimeOfDay(hour: userTimes[1].hour, minute: userTimes[1].minute);
      }

      if (mounted) {
        setState(() {
          _selectedApps.clear();
          _selectedApps.addAll(apps);
          _focusStart = start;
          _focusEnd = end;
          _gamificationRunning = status?.isActive ?? false;
          _loadingData = false;
        });

        if (_gamificationRunning) {
          final gamification =
              Provider.of<GamificationService>(context, listen: false);
          gamification.monitoredApps = List.from(_selectedApps);

          bool usageGranted = await PermissionService.hasUsagePermission();

          if (!mounted) return;

          if (usageGranted) {
            TimeOfDayRange? range;
            if (_focusStart != null && _focusEnd != null) {
              range = TimeOfDayRange(start: _focusStart!, end: _focusEnd!);
            }
            gamification.startMonitoringApps(
                nicheId: nicheId, horarios: [], intervaloFoco: range);
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

    await PermissionService.ensurePermissions(context);
    bool usageGranted = await PermissionService.hasUsagePermission();
    if (!usageGranted) {
      return; // O diálogo já foi mostrado pelo ensurePermissions
    }

    if (!mounted) return;

    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.monitoredApps = List.from(_selectedApps);

    TimeOfDayRange? range;
    if (_focusStart != null && _focusEnd != null) {
      range = TimeOfDayRange(start: _focusStart!, end: _focusEnd!);
    }

    gamification.startMonitoringApps(
        nicheId: _niche.id, horarios: [], intervaloFoco: range);

    if (!mounted) return;

    bool granted = await NotificationService.requestPermission();
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
      deactivate: true,
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

  Future<void> _pickFocusInterval() async {
    HapticFeedback.selectionClick();
    final now = TimeOfDay.now();

    final start = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (start == null) return;
    if (!mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: start,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (end == null) return;
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _focusStart = start;
      _focusEnd = end;
    });

    // Save to DB (Quick hack: save as UserNicheTimes, index 0=start, 1=end)
    await CloudSyncService.removeAllTimesForNiche(nicheId: _niche.id.id);
    await CloudSyncService.addUserNicheTime(
      nicheId: _niche.id.id,
      hour: start.hour,
      minute: start.minute,
    );
    await CloudSyncService.addUserNicheTime(
      nicheId: _niche.id.id,
      hour: end.hour,
      minute: end.minute,
    );
  }

  void _removeFocusInterval() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _focusStart = null;
      _focusEnd = null;
    });

    await CloudSyncService.removeAllTimesForNiche(nicheId: _niche.id.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Intervalo de foco removido'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> options = ['Como Funciona', 'Apps', 'Tempo', 'Ativar'];

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
                    fontSize: 11,
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

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _getModuleHintText() {
    return 'Selecione apps que costumam te distrair (como redes sociais, jogos, etc.) e defina um intervalo de foco.\n'
        'Durante esse tempo, se você abrir esses apps, será alertado para fechá-los em até 30 segundos. Caso contrário, seu progresso será resetado.';
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
              'Apps Selecionados:',
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
                    'Nenhum app selecionado ainda.',
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intervalo de Foco:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            NeonCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_focusStart == null || _focusEnd == null)
                    Text('Nenhum intervalo definido.',
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54))
                  else ...[
                    Text(
                      'Das ${_formatTime(_focusStart!)} até ${_formatTime(_focusEnd!)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _removeFocusInterval,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: isDark ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      case 3:
      default:
        return Column(
          children: [
            if (_gamificationRunning) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyProgressFocus()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF395CC8),
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF395CC8).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Ver meu progresso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (!_gamificationRunning) ...[
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
              const SizedBox(height: 24),
            ] else ...[
              _buildNotificationMessageSection(context),
              const SizedBox(height: 24),
            ],
          ],
        );
    }
  }

  Widget _buildTabActions() {
    switch (_selectedIndex) {
      case 1: // Apps
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
      case 2: // Interval
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: GlowingButton(
            text: 'Definir intervalo',
            onPressed: _pickFocusInterval,
            color: const Color(0xFF6366F1),
            borderRadius: 18,
          ),
        );
      case 3: // Activate
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
              // Header Row
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
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
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
                'Texto da notificação',
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
