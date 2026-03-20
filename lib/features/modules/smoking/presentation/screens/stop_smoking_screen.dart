import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'health_detail_screen.dart';
import 'package:disciplinum/shared/widgets/progress/my_progress_widgets.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'savings_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/features/schedule/presentation/screens/schedule_screen.dart';
import 'daily_checkins_stats.dart';
import 'package:disciplinum/shared/models/user_niche_time.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/shared/widgets/buttons/niche_action_button.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/stop_smoking_header_widget.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/stop_smoking_segmented_control.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/stop_smoking_tab_content.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/stop_smoking_actions_widget.dart';

class StopSmokingScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const StopSmokingScreen({super.key, this.heroTag});

  @override
  ConsumerState<StopSmokingScreen> createState() => _StopSmokingScreenState();
}

class _StopSmokingScreenState extends ConsumerState<StopSmokingScreen>
    with WidgetsBindingObserver {
  SmokingSettingsModel? settings;
  bool isLoading = true;
  bool _gamificationRunning = false;
  bool isSaving = false;

  TimeOfDay? _checkinTime;

  late PageController _pageController;
  int _selectedIndex = 0;

  final Niche _niche = NicheRepository.getById(NicheId.smoking);

  final TextEditingController _priceController =
      TextEditingController(text: '0,00');
  final TextEditingController _packsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'R\$';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: 0);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _priceController.dispose();
    _packsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        _reloadCheckinData();
      }
    }
  }

  @override
  void didUpdateWidget(StopSmokingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted) {
      _reloadCheckinData();
    }
  }

  Future<void> _reloadCheckinData() async {
    try {
      final prefs = ref.read(preferencesServiceProvider);
      final isGuest = await prefs.isGuestMode();
      final List<UserNicheTime> checkinTimes;

      if (isGuest) {
        checkinTimes = await prefs.loadUserNicheTimes(
            nicheId: NicheId.smoking.id);
      } else {
        checkinTimes = await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(
            nicheId: NicheId.smoking.id);
      }

      TimeOfDay? newCheckinTime;
      if (checkinTimes.isNotEmpty) {
        newCheckinTime = TimeOfDay(
            hour: checkinTimes[0].hour, minute: checkinTimes[0].minute);
      }

      if (_checkinTime != newCheckinTime) {
        if (mounted) {
          setState(() {
            _checkinTime = newCheckinTime;
          });
        }
      }
    } catch (e) {
      // Ignorar
    }
  }

  Future<void> _loadSettings() async {
    final service = ref.read(smokingServiceProvider);
    final data = await service.getSettings();
    final status = await ref.read(cloudSyncServiceProvider).loadModuleStatus(NicheId.smoking);

    if (mounted) {
      setState(() {
        settings = data;
        _gamificationRunning = status?.isActive ?? false;
        isLoading = false;
      });

      if (settings != null) {
        _selectedCurrency = settings!.currency;
        _formatCurrencyInput(settings!.packPrice.toStringAsFixed(2));
        _packsController.text =
            settings!.packsPerDay > 0 ? settings!.packsPerDay.toString() : '';

        if (!_gamificationRunning) {
          _selectedDate = DateTime.now();
        } else {
          _selectedDate = settings!.quitDate ?? DateTime.now();
        }

        _reloadCheckinData();
        _syncCheckInWithGamification(onlySyncSchedules: !_gamificationRunning);
      }
    }
  }

  void _formatCurrencyInput(String value) {
    if (value.isEmpty) {
      _priceController.value = const TextEditingValue(
        text: '0,00',
        selection: TextSelection.collapsed(offset: 4),
      );
      return;
    }

    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.isEmpty) {
      _priceController.value = const TextEditingValue(
        text: '0,00',
        selection: TextSelection.collapsed(offset: 4),
      );
      return;
    }

    double val = double.parse(numbers) / 100;

    String formatted;
    switch (_selectedCurrency) {
      case 'R\$':
      case 'ARS\$':
        formatted =
            val.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (match) => '${match.group(1)}.',
                );
        break;
      case 'US\$':
        String baseText = val.toStringAsFixed(2);
        List<String> parts = baseText.split('.');
        String integerPart = parts[0];
        String decimalPart = parts.length > 1 ? parts[1] : '';

        integerPart = integerPart.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
        );

        formatted =
            decimalPart.isNotEmpty ? '$integerPart.$decimalPart' : integerPart;
        break;
      case 'EUR':
        formatted = val.toStringAsFixed(2).replaceAll('.', ',');
        break;
      default:
        formatted = val.toStringAsFixed(2);
    }

    _priceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _syncCheckInWithGamification(
      {bool onlySyncSchedules = false}) async {
    final prefs = ref.read(preferencesServiceProvider);
    final isGuest = await prefs.isGuestMode();
    final List<UserNicheTime> times;

    if (isGuest) {
      times = await prefs.loadUserNicheTimes(
          nicheId: NicheId.smoking.id);
    } else {
      times = await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(
          nicheId: NicheId.smoking.id);
    }
    if (!mounted) return;

    final gamification = ref.read(gamificationServiceProvider);

    gamification.scheduleByModule[NicheId.smoking] =
        times.map((t) => TimeOfDay(hour: t.hour, minute: t.minute)).toList();

    if (onlySyncSchedules) {
      if (_gamificationRunning) {
        await gamification.restoreMonitoringSession();
      }
      return;
    }

    if (times.isNotEmpty && _gamificationRunning) {
      await PermissionService.ensurePermissions(context);
      gamification.startModuleCycle(nicheId: NicheId.smoking);

      if (!gamification.isGeneralMonitoringActive) {
        gamification.startMonitoringApps(
            nicheId: NicheId.smoking,
            horarios: gamification.scheduleByModule[NicheId.smoking]!);
      }
    }
  }

  Future<void> _saveSettings(
      double price, int packs, DateTime date, String currency) async {
    setState(() => isSaving = true);

    final newSettings = SmokingSettingsModel(
      dailyCigarettes: (packs * 20).round(), // Assume 20 cigarros por maço
      pricePerPack: price,
      cigarettesPerPack: 20,
      startDate: date,
      quitDate: date,
      currency: currency,
    );

    try {
      await ref.read(smokingServiceProvider).saveSettings(newSettings);
      if (mounted) {
        setState(() {
          settings = newSettings;
          isSaving = false;
        });

        await _syncCheckInWithGamification(onlySyncSchedules: true);

        if (mounted) {
          EnhancedSnackBarHelper.showSuccess(
              context, 'Informacoes salvas com sucesso!');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
        EnhancedSnackBarHelper.showError(context, 'Erro ao salvar: \$e');
      }
    }
  }

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();
    await PermissionService.ensurePermissions(context);
    bool accessibilityGranted =
        await PermissionService.hasAccessibilityPermission();
    if (!accessibilityGranted) return;
    if (!mounted) return;

    // VALIDAÇÃO: Verificar se configurou informações de consumo E check-in diário
    bool hasConsumptionInfo = settings != null;
    bool hasCheckinConfigured = _checkinTime != null;

    if (!hasConsumptionInfo && !hasCheckinConfigured) {
      EnhancedSnackBarHelper.showWarning(
        context,
        "Configure informações de consumo e check-in diário.",
      );
      return;
    }

    if (!hasConsumptionInfo && hasCheckinConfigured) {
      EnhancedSnackBarHelper.showWarning(
        context,
        "Configure informações de consumo.",
      );
      return;
    }

    if (hasConsumptionInfo && !hasCheckinConfigured) {
      EnhancedSnackBarHelper.showWarning(
        context,
        "Configure check-in diário.",
      );
      return;
    }

    bool notificationGranted = await NotificationService.requestPermission();
    if (notificationGranted) {
      if (settings != null) {
        setState(() => isSaving = true);
        try {
          final now = DateTime.now();
          final updatedSettings = SmokingSettingsModel(
            dailyCigarettes: settings!.dailyCigarettes,
            pricePerPack: settings!.pricePerPack,
            cigarettesPerPack: settings!.cigarettesPerPack,
            startDate: settings!.startDate,
            quitDate: now,
            currency: settings!.currency,
            lastPackPrice: settings!.lastPackPrice,
            lastPacksPerDay: settings!.lastPacksPerDay,
            lastQuitDate: settings!.lastQuitDate,
            lastCurrency: settings!.lastCurrency,
            lastSavedTotal: settings!.lastSavedTotal,
            lastEndDate: settings!.lastEndDate,
          );
          await ref.read(smokingServiceProvider).saveSettings(updatedSettings);
          if (mounted) {
            setState(() {
              settings = updatedSettings;
              isSaving = false;
            });
          }
        } catch (e) {
          if (mounted) setState(() => isSaving = false);
        }
      }
      _startGamificationCycle();
    } else {
      _showNotificationSettingsDialog();
    }
  }

  void _startGamificationCycle() {
    HapticFeedback.heavyImpact();
    setState(() => _gamificationRunning = true);
    ref.read(cloudSyncServiceProvider).saveModuleStatus(nicheId: NicheId.smoking, isActive: true);
    ref.read(gamificationServiceProvider).startModuleCycle(nicheId: NicheId.smoking);
  }

  Future<void> _desativarNichoMonitoramento() async {
    final gamification = ref.read(gamificationServiceProvider);
    final confirmed = await DeactivateModuleDialog.show(
      context: context,
      nicheId: NicheId.smoking,
      customMessage: "Ao desativar o módulo, seu progresso será reiniciado. Deseja continuar?",
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() => isLoading = true);

      try {
        await ref.read(smokingServiceProvider).archiveAndReset();
        await ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(
            nicheId: NicheId.smoking.id);
        await ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(
            nicheId: NicheId.smoking.id + 100);

        gamification.resetMedals(
          NicheId.smoking,
          notificationTitle: 'Módulo Desativado 🛑',
          notificationBody:
              'O módulo foi desativado e todos os dados de estatística e gamificação foram resetados.',
          deactivate: true,
        );

        if (mounted) {
          final data = await ref.read(smokingServiceProvider).getSettings();
          setState(() {
            settings = data;
            _gamificationRunning = false;
            isLoading = false;
            _selectedIndex = 0;
          });

          if (_pageController.hasClients) {
            _pageController.animateToPage(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic);
          }

          if (mounted) {
            EnhancedSnackBarHelper.showSuccess(context, "Módulo desativado");
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          EnhancedSnackBarHelper.showError(context, "Erro ao desativar: $e");
        }
      }
    }
  }

  Future<void> _showNotificationSettingsDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão necessária'),
        content: const Text(
          'Para receber os lembretes de check-in, habilite as notificações do app nas configurações.',
        ),
        actions: [
          TextButton(
            child: const Text('Abrir configurações'),
            onPressed: () {
              Navigator.of(context).pop();
              NotificationService.openNotificationSettings();
            },
          ),
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
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
                  : const Color.fromARGB(255, 226, 229, 251),
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
              StopSmokingHeaderWidget(
                niche: _niche,
                onBackPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: StopSmokingSegmentedControl(
                        selectedIndex: _selectedIndex,
                        onIndexChanged: (index) {
                          HapticFeedback.selectionClick();
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(index,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutQuad);
                          } else {
                            setState(() => _selectedIndex = index);
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
                              children: [
                                StopSmokingTabContent(
                                  tabIndex: 0,
                                  isDark: isDark,
                                  priceController: _priceController,
                                  packsController: _packsController,
                                  selectedCurrency: _selectedCurrency,
                                  selectedDate: _selectedDate,
                                  checkinTime: _checkinTime,
                                  onCurrencyChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCurrency = newValue;
                                        _formatCurrencyInput(_priceController.text);
                                      });
                                    }
                                  },
                                  onPriceChanged: _formatCurrencyInput,
                                  onDateTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                      locale: const Locale('pt', 'BR'),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _selectedDate = picked;
                                      });
                                    }
                                  },
                                  onDeleteTime: _showDeleteTimeDialog,
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                StopSmokingTabContent(
                                  tabIndex: 1,
                                  isDark: isDark,
                                  priceController: _priceController,
                                  packsController: _packsController,
                                  selectedCurrency: _selectedCurrency,
                                  selectedDate: _selectedDate,
                                  checkinTime: _checkinTime,
                                  onCurrencyChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCurrency = newValue;
                                        _formatCurrencyInput(_priceController.text);
                                      });
                                    }
                                  },
                                  onPriceChanged: _formatCurrencyInput,
                                  onDateTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                      locale: const Locale('pt', 'BR'),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _selectedDate = picked;
                                      });
                                    }
                                  },
                                  onDeleteTime: _showDeleteTimeDialog,
                                ),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StopSmokingActionsWidget(
                    selectedIndex: _selectedIndex,
                    isDark: isDark,
                    isSaving: isSaving,
                    pageController: _pageController,
                    onOpenCheckInManager: _openCheckInManager,
                    onShowStatisticsMenu: _showStatisticsMenu,
                    gamificationRunning: _gamificationRunning,
                    onToggleModule: _gamificationRunning
                        ? _desativarNichoMonitoramento
                        : _ativarNichoMonitoramento,
                    onSaveSettings: () {
                      if (_priceController.text.isNotEmpty &&
                          _packsController.text.isNotEmpty) {
                        String cleanPrice = _priceController.text;
                        if (_selectedCurrency == 'US\$') {
                          cleanPrice = cleanPrice.replaceAll(',', '');
                        } else {
                          cleanPrice =
                              cleanPrice.replaceAll('.', '').replaceAll(',', '.');
                        }
                        // Fallback caso sobre algo (ex letras)
                        cleanPrice = cleanPrice.replaceAll(RegExp(r'[^\d.]'), '');

                        _saveSettings(
                          double.tryParse(cleanPrice) ?? 0.0,
                          int.tryParse(_packsController.text) ?? 0,
                          _selectedDate,
                          _selectedCurrency,
                        );
                      }
                    },
                    context: context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }





  void _showDeleteTimeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir horário?"),
        content: Text(
          "Deseja excluir o horário ${_checkinTime!.hour.toString().padLeft(2, '0')}:${_checkinTime!.minute.toString().padLeft(2, '0')} do seu check-in diário?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Não"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);

              await ref.read(cloudSyncServiceProvider).removeUserNicheTime(
                nicheId: NicheId.smoking.id,
                hour: _checkinTime!.hour,
                minute: _checkinTime!.minute,
              );

              if (mounted) {
                setState(() {
                  _checkinTime = null;
                });
                await _syncCheckInWithGamification(onlySyncSchedules: true);
              }
            },
            child: const Text("Sim"),
          ),
        ],
      ),
    );
  }




  void _openCheckInManager() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      color: Color(0xFF6366F1), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Check-in Diario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'O que é?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'O Check-in Diário é o seu compromisso de registrar se você resistiu ao hábito de fumar hoje. '
              'Ele é fundamental para manter seu progresso.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Como funciona?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você receberá uma notificação no horário configurado perguntando se você fumou ou não. '
              'Responder todos os dias é mostre a si mesmo que você é capaz!',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: NicheActionButton(
                    icon: Icons.access_time_rounded,
                    label: 'Configurar Horário',
                    color: const Color(0xFF6366F1),
                    isDark: isDark,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final nicheId = _niche.id;
                      final initialItems =
                          await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(
                              nicheId: nicheId);
                      final initialTimes = initialItems
                          .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
                          .toList();

                      if (!mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScheduleScreen(
                            args: ScheduleScreenArgs(
                              nicheId: nicheId,
                              maxSlots: 1,
                              title: 'Horário de Check-in',
                              initialTimes: initialTimes,
                              onChanged: (times) {
                                _syncCheckInWithGamification(
                                    onlySyncSchedules: true);
                                _reloadCheckinData();
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
              'Estatísticas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListActionTile(
              icon: Icons.calendar_month_rounded,
              label: 'Estatísticas dos Check-ins',
              color: const Color(0xFF6366F1),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DailyCheckinsStats(),
                  ),
                );
              },
              isDark: isDark,
            ),
            ListActionTile(
              icon: Icons.savings_outlined,
              label: 'Economia',
              color: Colors.green,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavingsDetailScreen(
                      settings: settings ?? SmokingSettingsModel(
                        dailyCigarettes: 20,
                        pricePerPack: 10.0,
                        cigarettesPerPack: 20,
                        currency: 'BRL',
                        startDate: DateTime.now(),
                      ),
                      isActive: _gamificationRunning,
                    ),
                  ),
                );
              },
              isDark: isDark,
            ),
            ListActionTile(
              icon: Icons.health_and_safety_outlined,
              label: 'Saúde',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HealthDetailScreen(
                      settings: settings ?? SmokingSettingsModel(
                        dailyCigarettes: 20,
                        pricePerPack: 10.0,
                        cigarettesPerPack: 20,
                        currency: 'BRL',
                        startDate: DateTime.now(),
                      ),
                    ),
                  ),
                );
              },
              isDark: isDark,
            ),
            ListActionTile(
              icon: Icons.bar_chart_rounded,
              label: 'Conquistas',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProgressSmoking()),
                );
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

}
