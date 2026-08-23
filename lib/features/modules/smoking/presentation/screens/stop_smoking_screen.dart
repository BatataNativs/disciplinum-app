import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/features/modules/smoking/gamification/presentation/widgets/smoking_celebration_widget.dart';
import 'package:disciplinum/features/modules/smoking/presentation/notifiers/smoking_gamification_notifier.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/daily_checkins_stats.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/health_detail_screen.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/savings_detail_screen.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/cigarettes_avoided_detail_screen.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/smoking_breathing_screen.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/smoking_diary_screen.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/smoking_sos_screen.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/smoking_triggers_screen.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/smoking_notifications_screen.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/my_progress_smoking.dart'
    as smoking_progress;
import 'package:disciplinum/features/modules/smoking/presentation/widgets/smoking_consumption_bottom_sheet.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/smoking_dashboard_hero.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/smoking_info_dialog.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/smoking_top_action_bar.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/stop_smoking_header_widget.dart';
import 'package:disciplinum/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/user_niche_time.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/dialogs/permission_dialog.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:shimmer/shimmer.dart';

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

  final Niche _niche = NicheRepository.getById(NicheId.smoking);

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _packsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'R\$';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _priceController.dispose();
    _packsController.dispose();
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
        checkinTimes =
            await prefs.loadUserNicheTimes(nicheId: NicheId.smoking.id);
      } else {
        checkinTimes = await ref
            .read(cloudSyncServiceProvider)
            .loadUserNicheTimes(nicheId: NicheId.smoking.id);
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

    final gamificationState = ref.read(smokingGamificationNotifierProvider);
    final bool isModuleActive = gamificationState.isModuleActive;

    final bool moduleRunning;
    if (!isModuleActive && gamificationState.gamification == null) {
      final status = await ref
          .read(cloudSyncServiceProvider)
          .loadModuleStatus(NicheId.smoking);
      moduleRunning = status?.isModuleActive ?? false;
    } else {
      moduleRunning = isModuleActive;
    }

    if (mounted) {
      setState(() {
        settings = data;
        _gamificationRunning = moduleRunning;
        isLoading = false;
      });

      if (settings != null) {
        _selectedCurrency = settings!.currency;

        if (_gamificationRunning) {
          final gState = ref.read(smokingGamificationNotifierProvider);
          if (gState.gamification != null) {
            final packCost = gState.gamification!.packCost;
            final dailyCost = gState.gamification!.dailyCost;

            if (_selectedCurrency == 'R\$' || _selectedCurrency == 'ARS\$') {
              _priceController.text =
                  packCost.toStringAsFixed(2).replaceAll('.', ',');
            } else {
              _priceController.text = packCost.toStringAsFixed(2);
            }

            final packsPerDay = packCost > 0 ? (dailyCost / packCost) : 0;
            _packsController.text = packsPerDay.toStringAsFixed(1);
          } else {
            _priceController.clear();
            _packsController.clear();
          }
        } else {
          _priceController.clear();
          _packsController.clear();
        }

        if (!_gamificationRunning) {
          _selectedDate = DateTime.now();
        } else {
          _selectedDate = settings!.quitDate ?? DateTime.now();
        }

        _reloadCheckinData();
        _syncCheckInWithGamification(onlySyncSchedules: !_gamificationRunning);
      } else {
        _priceController.clear();
        _packsController.clear();
      }
    }
  }

  Future<void> _syncCheckInWithGamification(
      {bool onlySyncSchedules = false}) async {
    final prefs = ref.read(preferencesServiceProvider);
    final isGuest = await prefs.isGuestMode();
    final List<UserNicheTime> times;

    if (isGuest) {
      times = await prefs.loadUserNicheTimes(nicheId: NicheId.smoking.id);
    } else {
      times = await ref
          .read(cloudSyncServiceProvider)
          .loadUserNicheTimes(nicheId: NicheId.smoking.id);
    }
    if (!mounted) return;

    ref.read(stopSmokingControllerProvider);

    if (onlySyncSchedules) {
      return;
    }

    if (times.isNotEmpty && _gamificationRunning) {
      await PermissionService.ensurePermissions(context,
          nicheId: NicheId.smoking);
      LoggerService.instance.i('Smoking: Iniciando ciclo de monitoramento');
    }
  }

  Future<void> _saveSettings({
    required double price,
    required int packs,
    required DateTime quitDate,
    required String currency,
  }) async {
    setState(() => isSaving = true);

    final newSettings = SmokingSettingsModel(
      dailyCigarettes: (packs * 20).round(),
      pricePerPack: price,
      cigarettesPerPack: 20,
      startDate: quitDate,
      quitDate: _gamificationRunning ? (settings?.quitDate ?? quitDate) : quitDate,
      currency: currency,
    );

    try {
      await ref.read(smokingServiceProvider).saveSettings(newSettings);

      if (mounted) {
        setState(() {
          settings = newSettings;
          _selectedCurrency = currency;
          _selectedDate = quitDate;
          if (currency == 'R\$' || currency == 'ARS\$') {
            _priceController.text =
                price.toStringAsFixed(2).replaceAll('.', ',');
          } else {
            _priceController.text = price.toStringAsFixed(2);
          }
          _packsController.text = packs.toString();
          isSaving = false;
        });

        await _syncCheckInWithGamification(onlySyncSchedules: true);

        if (mounted) {
          EnhancedSnackBarHelper.showSuccess(
            context,
            'Informações de consumo salvas com sucesso!',
          );
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar', error: e);
      if (mounted) {
        setState(() => isSaving = false);
        EnhancedSnackBarHelper.showError(context, 'Erro ao salvar: $e');
      }
    }
  }

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();
    await PermissionService.ensurePermissions(context,
        nicheId: NicheId.smoking);

    if (!mounted) return;

    final hasConsumptionInfo = settings?.isConfigured ?? false;
    final hasCheckinConfigured = _checkinTime != null;

    if (!hasConsumptionInfo || !hasCheckinConfigured) {
      if (!hasConsumptionInfo && !hasCheckinConfigured) {
        EnhancedSnackBarHelper.showWarning(
          context,
          "Configure as informações de consumo e o check-in diário para iniciar.",
        );
      } else if (!hasConsumptionInfo) {
        EnhancedSnackBarHelper.showWarning(
          context,
          "Configure as informações de consumo para iniciar.",
        );
      } else {
        EnhancedSnackBarHelper.showWarning(
          context,
          "Configure o check-in diário para iniciar.",
        );
      }
      return;
    }

    bool notificationGranted = await NotificationService.requestPermission();

    if (notificationGranted) {
      if (settings != null) {
        setState(() => isSaving = true);
        try {
          final now = DateTime.now();
          final updatedSettings = settings!.copyWith(quitDate: now);
          await ref.read(smokingServiceProvider).saveSettings(updatedSettings);
          if (mounted) {
            setState(() {
              settings = updatedSettings;
              isSaving = false;
            });
          }
        } catch (e) {
          LoggerService.instance.e('Erro ao salvar configurações', error: e);
          if (mounted) setState(() => isSaving = false);
        }
      }
      await _startGamificationCycle();
    } else {
      _showNotificationSettingsDialog();
    }
  }

  Future<void> _startGamificationCycle() async {
    HapticFeedback.heavyImpact();
    setState(() => _gamificationRunning = true);
    ref
        .read(cloudSyncServiceProvider)
        .saveModuleStatus(nicheId: NicheId.smoking, isModuleActive: true);

    final dailyCost =
        settings != null ? (settings!.packPrice * settings!.packsPerDay) : 0.0;
    final packCost = settings?.packPrice ?? 0.0;

    await ref.read(smokingGamificationNotifierProvider.notifier).activateModule(
          dailyCost: dailyCost,
          packCost: packCost,
        );

    if (mounted) {
      EnhancedSnackBarHelper.showSuccess(
        context,
        'Módulo ativado! Parabéns pela decisão!',
      );
    }
  }

  Future<void> _desativarNichoMonitoramento() async {
    ref.read(stopSmokingControllerProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeactivateModuleDialog(
        nicheId: NicheId.smoking,
        customMessage:
            "Ao desativar o módulo, seu progresso atual será arquivado. Deseja continuar?",
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() => isLoading = true);

      try {
        await ref.read(smokingServiceProvider).archiveAndReset();
        await ref
            .read(cloudSyncServiceProvider)
            .removeAllTimesForNiche(nicheId: NicheId.smoking.id);
        await ref
            .read(cloudSyncServiceProvider)
            .removeAllTimesForNiche(nicheId: NicheId.smoking.id + 100);

        final prefs = ref.read(preferencesServiceProvider);
        await prefs.removeAllTimesForNiche(nicheId: NicheId.smoking.id);
        await prefs.removeAllTimesForNiche(nicheId: NicheId.smoking.id + 100);

        if (mounted) {
          final data = await ref.read(smokingServiceProvider).getSettings();

          setState(() {
            settings = data;
            _gamificationRunning = false;
            isLoading = false;
            _checkinTime = null;
          });

          await ref
              .read(smokingGamificationNotifierProvider.notifier)
              .deactivateModule();

          await ref.read(cloudSyncServiceProvider).saveModuleStatus(
                nicheId: NicheId.smoking,
                isModuleActive: false,
              );

          if (mounted) {
            EnhancedSnackBarHelper.showError(
              context,
              "Módulo desativado",
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        LoggerService.instance.e('Erro ao desativar módulo', error: e);
        if (mounted) {
          EnhancedSnackBarHelper.showError(
            context,
            'Erro ao desativar módulo. Tente novamente.',
          );
        }
      }
    }
  }

  void _openConsumptionBottomSheet() {
    SmokingConsumptionBottomSheet.show(
      context,
      isModuleActive: _gamificationRunning,
      initialPrice: _priceController.text.isNotEmpty
          ? _priceController.text
          : (settings?.packPrice.toStringAsFixed(2) ?? '10,00'),
      initialPacks: _packsController.text.isNotEmpty
          ? _packsController.text
          : (settings?.packsPerDay.toStringAsFixed(0) ?? '1'),
      initialCurrency: _selectedCurrency,
      initialDate: _selectedDate,
      onSave: _saveSettings,
    );
  }

  Future<void> _showNotificationSettingsDialog() async {
    context.showNotificationPermissionDialog(
      title: 'Permissão necessária',
      message:
          'Para receber os lembretes de check-in, habilite as notificações do app nas configurações.',
      onOpenSettings: () => NotificationService.openNotificationSettings(),
    );
  }

  void _openCheckInManager() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.alarm_on_rounded,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-in Diário',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Compromisso diário de consistência',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card de Status do Horário
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _checkinTime != null
                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                      : Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _checkinTime != null
                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                        : Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _checkinTime != null
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      color: _checkinTime != null
                          ? const Color(0xFF10B981)
                          : Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _checkinTime != null
                            ? 'Horário configurado: ${_checkinTime!.hour.toString().padLeft(2, '0')}:${_checkinTime!.minute.toString().padLeft(2, '0')}'
                            : 'Nenhum horário definido ainda',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _checkinTime != null
                              ? const Color(0xFF10B981)
                              : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Informações Explicativas em Cards
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.task_alt_rounded,
                            size: 16,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'O que é o Check-in?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'É o seu registro diário confirmando que você resistiu ao cigarro hoje, mantendo sua sequência ativa.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.35,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            size: 16,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Como funciona?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'No horário agendado, você receberá uma notificação direta para confirmar sua disciplina sem esforço.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.35,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Botão Ação
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    Navigator.pop(ctx);
                    final nicheId = _niche.id;
                    final initialItems = await ref
                        .read(cloudSyncServiceProvider)
                        .loadUserNicheTimes(nicheId: nicheId);
                    final initialTimes = initialItems
                        .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
                        .toList();

                    if (!mounted) return;

                    await navigator.push(
                      MaterialPageRoute(
                        builder: (_) => ScheduleScreen(
                          args: ScheduleScreenArgs(
                            nicheId: nicheId,
                            maxSlots: 1,
                            title: 'Horário de Check-in',
                            initialTimes: initialTimes,
                            onChanged: (times) async {
                              await _syncCheckInWithGamification(
                                  onlySyncSchedules: true);
                              await _reloadCheckinData();
                            },
                          ),
                        ),
                      ),
                    );

                    if (mounted) {
                      await _reloadCheckinData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.alarm_add_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _checkinTime != null
                            ? 'Alterar Horário (${_checkinTime!.hour.toString().padLeft(2, '0')}:${_checkinTime!.minute.toString().padLeft(2, '0')})'
                            : 'Definir Horário do Check-in',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  void _showStatisticsMenu() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas e Saúde',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
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
            ),
            ListActionTile(
              icon: Icons.savings_outlined,
              label: 'Economia Financeira',
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavingsDetailScreen(
                      settings: settings ??
                          SmokingSettingsModel(
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
            ),
            ListActionTile(
              icon: Icons.health_and_safety_outlined,
              label: 'Recuperação da Saúde',
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HealthDetailScreen(
                      settings: settings ??
                          SmokingSettingsModel(
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
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _openNotificationsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SmokingNotificationsScreen(),
      ),
    );
  }

  void _openSavingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavingsDetailScreen(
          settings: settings ??
              SmokingSettingsModel(
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
  }

  void _openCigarettesAvoidedScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CigarettesAvoidedDetailScreen(
          settings: settings ??
              SmokingSettingsModel(
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
  }

  void _openBreathingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SmokingBreathingScreen(),
      ),
    );
  }

  void _openDiaryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SmokingDiaryScreen(),
      ),
    );
  }

  void _openSosScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SmokingSosScreen(),
      ),
    );
  }

  void _openTriggersScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SmokingTriggersScreen(),
      ),
    );
  }

  void _openAchievementsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const smoking_progress.MyProgressSmoking(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gamificationState = ref.watch(smokingGamificationNotifierProvider);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_niche.name),
          centerTitle: true,
        ),
        body: Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest,
          highlightColor: colorScheme.surface,
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

    return SmokingCelebrationWidget(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Header com botão ?
              StopSmokingHeaderWidget(
                niche: _niche,
                onBackPressed: () => Navigator.pop(context),
                onHelpPressed: () => SmokingInfoDialog.show(context),
              ),

              // Nova Barra de Ações Superior (4 botões: Check-in, Lembretes, Estatísticas, Conquistas)
              SmokingTopActionBar(
                onOpenCheckIn: _openCheckInManager,
                onOpenNotifications: _openNotificationsScreen,
                onOpenStatistics: _showStatisticsMenu,
                onOpenAchievements: _openAchievementsScreen,
              ),

              // Conteúdo Principal Scrollável e Limpo
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: SmokingDashboardHero(
                    isModuleActive: _gamificationRunning,
                    settings: settings,
                    checkinTime: _checkinTime,
                    earnedInsignias: gamificationState.earnedInsignias,
                    earnedMedalhas: gamificationState.earnedMedalhas,
                    onOpenConsumptionSettings: _openConsumptionBottomSheet,
                    onOpenCheckInManager: _openCheckInManager,
                    onOpenSavings: _openSavingsScreen,
                    onOpenCigarettesAvoided: _openCigarettesAvoidedScreen,
                    onOpenBreathing: _openBreathingScreen,
                    onOpenDiary: _openDiaryScreen,
                    onOpenSos: _openSosScreen,
                    onOpenTriggers: _openTriggersScreen,
                    onToggleModule: () {
                      if (_gamificationRunning) {
                        _desativarNichoMonitoramento();
                      } else {
                        _ativarNichoMonitoramento();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
