import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';

import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:disciplinum/features/modules/focus/presentation/widgets.dart' as focus_progress;
import 'package:disciplinum/features/modules/focus/presentation/screens/focus_notifications_screen.dart';
import 'package:disciplinum/core/utils/app_info_helper.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/buttons/modern_start_button.dart';
import 'package:disciplinum/shared/widgets/common/module_screen_header.dart';
import 'package:disciplinum/shared/widgets/common/how_it_works_section.dart';

class FocusScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const FocusScreen({super.key, this.heroTag});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.focus);
  final List<String> _selectedApps = [];
  TimeOfDay? _focusStart;
  TimeOfDay? _focusEnd;
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

  // --- CONTROLADOR DE PÁGINA ---
  late PageController _pageController;
  int _selectedIndex = 0; // 0=Como Funciona, 1=Configurações

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadAllPersistentData();
    
    // NOVO: Escutar mudanças na gamificação para remover intervalo quando período for cumprido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // focusService já lida com o estado, verificar se precisamos de gamificationListener
        // final gamification = ref.read(gamificationServiceProvider.notifier);
        // gamification.addListener(_onGamificationChanged);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }



  // --- HARDCODED TEXTS FOR FOCUS ---

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      final nicheId = _niche.nicheId;
      final userApps =
          await ref.read(cloudSyncServiceProvider).loadUserNicheApps(nicheId: nicheId);
      final userTimes =
          await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(nicheId: nicheId.id);
      final status = await ref.read(cloudSyncServiceProvider).loadModuleStatus(nicheId);

      final apps = userApps.map((a) => a.appPackage).toList();

      TimeOfDay? start;
      TimeOfDay? end;

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
          // Usando provider local do Focus
          final focusController = ref.read(focusControllerIsarProvider.notifier);

          bool accessibilityGranted =
              await PermissionService.hasAccessibilityPermission();

          if (!mounted) return;

          if (accessibilityGranted) {
            // Registra sessão de foco quando as permissões são concedidas
            if (_focusStart != null && _focusEnd != null) {
              final startMinutes = _focusStart!.hour * 60 + _focusStart!.minute;
              final endMinutes = _focusEnd!.hour * 60 + _focusEnd!.minute;
              final durationMinutes = endMinutes - startMinutes;
              
              if (durationMinutes > 0) {
                await focusController.recordFocusSession(
                  minutes: durationMinutes,
                  nicheId: _niche.nicheId.id,
                );
              }
            }
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
      EnhancedSnackBarHelper.showInfo(context, 'App removido: $label');
    }
  }

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();

    // VALIDAÇÃO: Verificar se configurou intervalo de foco e apps
    if (_focusStart == null || _focusEnd == null || _selectedApps.isEmpty) {
      EnhancedSnackBarHelper.showInfo(
        context,
        "Primeiro, configure intervalo de foco e apps a monitorar.",
      );
      return;
    }

    // NOVO: Verificar permissão de sobreposição primeiro
    bool overlayGranted = await PermissionService.ensureOverlayPermissionForModule(
      context,
      _niche.nicheId,
    );
    
    if (!overlayGranted) {
      // Usuário clicou "Depois" - desativar módulo e mostrar snackbar
      if (mounted) {
        EnhancedSnackBarHelper.showInfo(
          context,
          'Você precisa conceder a permissão de sobreposição para ativar o módulo de Foco.',
        );
      }
      return;
    }

    // Continuar com as outras permissões
    if (!mounted) return;
    await PermissionService.ensurePermissions(context);
    bool accessibilityGranted =
        await PermissionService.hasAccessibilityPermission();
    if (!accessibilityGranted) {
      return; // O diálogo já foi mostrado pelo ensurePermissions
    }

    if (!mounted) return;

    // Usando provider local do Focus
    final focusController = ref.read(focusControllerIsarProvider.notifier);

    // Registra sessão de foco quando ativa o módulo
    if (_focusStart != null && _focusEnd != null) {
      final startMinutes = _focusStart!.hour * 60 + _focusStart!.minute;
      final endMinutes = _focusEnd!.hour * 60 + _focusEnd!.minute;
      final durationMinutes = endMinutes - startMinutes;
      
      if (durationMinutes > 0) {
        await focusController.recordFocusSession(
          minutes: durationMinutes,
          nicheId: _niche.nicheId.id,
        );
      }
    }

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
    ref.read(cloudSyncServiceProvider).saveModuleStatus(
      nicheId: _niche.nicheId,
      isActive: true,
    );
    // Incrementa streak ao iniciar ciclo de gamificação
    final focusController = ref.read(focusControllerIsarProvider.notifier);
    focusController.incrementStreak();
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

  Future<void> _desativarNichoMonitoramento() async {
    // Usando provider local do Focus
    final focusController = ref.read(focusControllerIsarProvider.notifier);
    final confirmed = await DeactivateModuleDialog.show(
      context: context,
      nicheId: NicheId.focus,
      customMessage: "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado. Deseja continuar?",
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      
      // Reseta o streak ao desativar o módulo
      await focusController.resetStreak();
      
      _resetMedalsForModule(
        notificationTitle: 'Módulo Desativado 🛑',
        notificationBody:
            'O módulo foi desativado e todos os dados de estatística e gamificação foram resetados.',
        deactivate: true,
      );

      // Obtém o estado atual do módulo
      final focusState = ref.read(focusControllerIsarProvider);
      final gamificationStatus = focusState.config?.isEnabled ?? false;

      setState(() {
        _gamificationRunning = gamificationStatus;
        _selectedIndex = 0;
      });

      if (_pageController.hasClients) {
        _pageController.animateToPage(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      }
      await ref.read(cloudSyncServiceProvider).saveModuleStatus(
        nicheId: _niche.nicheId,
        isActive: false,
      );

      if (mounted) {
        EnhancedSnackBarHelper.showWarning(context, 'Módulo desativado');
      }
    }
  }

  void _resetMedalsForModule({
    String? notificationTitle,
    String? notificationBody,
    bool deactivate = false,
  }) {
    // Usando provider local do Focus para limpar dados
    final focusController = ref.read(focusControllerIsarProvider.notifier);
    focusController.clearAllData();
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
                  nicheId: _niche.nicheId,
                  package: pkg,
                );
              }
            },
            nicheId: _niche.nicheId,
          ),
        ),
      ),
    );

    // Se tiver apps e o controller estiver ok, avança para a próxima etapa
    if (_selectedApps.isNotEmpty) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(1, // Vai para "Configurações"
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      } else {
        setState(() => _selectedIndex = 1);
      }
    } else {
      setState(() {});
    }
  }

  Future<void> _pickFocusInterval() async {
    HapticFeedback.selectionClick();
    final now = TimeOfDay.now();

    final start = await showTimePicker(
      context: context,
      initialTime: now,
      helpText: 'HORÁRIO DE INÍCIO',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (start == null) return;
    if (!mounted) return;

    // Calcular hora final como 1 hora à frente da hora inicial
    final suggestedEnd = TimeOfDay(
      hour: (start.hour + 1) % 24,
      minute: start.minute,
    );

    final end = await showTimePicker(
      context: context,
      initialTime: suggestedEnd,
      helpText: 'HORÁRIO DE TÉRMINO',
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
    await ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(nicheId: _niche.id);
    await ref.read(cloudSyncServiceProvider).addUserNicheTime(
      nicheId: _niche.id,
      hour: start.hour,
      minute: start.minute,
    );
    await ref.read(cloudSyncServiceProvider).addUserNicheTime(
      nicheId: _niche.id,
      hour: end.hour,
      minute: end.minute,
    );

    // Se o tempo foi definido, avança para o seletor de apps
    if (!mounted) return;
    await _openSelectApps();
  }

  void _removeFocusInterval({bool showNotification = true}) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _focusStart = null;
      _focusEnd = null;
    });

    await ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(nicheId: _niche.id);

    if (mounted && showNotification) {
      EnhancedSnackBarHelper.showInfo(context, 'Intervalo de foco removido');
    }
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

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
              ModuleScreenHeader(
                title: _niche.name,
              ),
              Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: _buildSegmentedControl()),

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
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildTabContent(0),
                        ),
                        
                        // 1: Configurações
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
                  
                  // Botões apenas na aba 1
                  if (_selectedIndex == 1)
                    _buildBottomButtons(isDark),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
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
                  icon: Icons.settings_suggest_rounded,
                  label: 'Configurar',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _pickFocusInterval,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernStartButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FocusNotificationsScreen(),
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
                child: ModernStartButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estatísticas',
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
                      ? 'Desativar módulo'
                      : 'Ativar módulo',
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
              'Estatísticas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.bar_chart_rounded, color: Colors.blue),
              title: const Text('Conquistas'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const focus_progress.MyProgressFocus()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> options = ['Como Funciona', 'Foco e produtividade'];

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
        return HowItWorksSection(
          isDark: isDark,
          onGetStarted: () => _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
          infoCards: const [
            InfoCardData(
              icon: Icons.settings_outlined,
              title: 'Em "Configurar", defina seus intervalos de foco',
              content: 'Defina intervalos de horários de foco e selecione apps que possam te distrair. Depois, ative o módulo.',
            ),
            InfoCardData(
              icon: Icons.notifications_outlined,
              title: 'Notificações',
              content: 'Receba notificações para te lembrar de manter o foco durante o seu horário produtivo.',
            ),
            InfoCardData(
              icon: Icons.bar_chart_rounded,
              title: 'Em "Estatísticas", monitore seu foco',
              content: 'Veja como anda seu foco, acompanhando seus períodos de foco concluídos com sucesso e o progresso geral no módulo.',
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "A notificação chegará automaticamente sempre que você abrir um dos aplicativos selecionados durante o intervalo de foco.",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Intervalo de foco definido:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      color: const Color(0xFF6366F1), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_focusStart == null || _focusEnd == null)
                          const Text('Nenhum intervalo definido.',
                              style: TextStyle(color: Colors.grey))
                        else
                          Text(
                            'Das ${_formatTime(_focusStart!)} até ${_formatTime(_focusEnd!)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87),
                          ),
                        const Text(
                          'Para editar, apague este horário, e defina novamente em "Configurar"',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (_focusStart != null && _focusEnd != null)
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.grey, size: 20),
                      onPressed: _removeFocusInterval,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aplicativos monitorados:',
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
                    'Nenhum app selecionado.',
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

}

