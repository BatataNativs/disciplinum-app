import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';

import 'package:disciplinum/features/modules/spending/presentation/screens/spending_notifications_screen.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';
import 'package:disciplinum/shared/widgets/progress/my_progress_widgets.dart';
import 'package:disciplinum/core/utils/app_info_helper.dart';
import 'package:disciplinum/features/modules/spending/presentation/screens/fixed_expenses_screen.dart';
import 'package:disciplinum/features/modules/spending/domain/services/spending_service.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/fixed_expense_model.dart';
import 'package:disciplinum/features/modules/spending/presentation/screens/fixed_bills_stats_screen.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/shared/widgets/lists/list_action_tile.dart';
import 'package:disciplinum/shared/widgets/buttons/niche_action_button.dart';

class SpendingScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const SpendingScreen({super.key, this.heroTag});

  @override
  ConsumerState<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends ConsumerState<SpendingScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.spending);
  final List<String> _selectedApps = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

  // --- CONTROLADOR DE PÁGINA ---
  late PageController _pageController;
  int _selectedIndex = 0; // 0=Como Funciona, 1=Controlar gastos

  bool _isPaidInCurrentMonth(FixedExpenseModel expense) {
    if (expense.lastPaid == null || !expense.isPaid) return false;
    final now = DateTime.now();
    final paymentDate = expense.lastPaid!;
    return paymentDate.year == now.year && paymentDate.month == now.month;
  }

  String _formatCurrencyValue(String value, String currency) {
    if (value.isEmpty) return '0,00';
    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.isEmpty) return '0,00';

    double val = double.parse(numbers) / 100;
    String formatted;

    // Formatação brasileira/europeia (1.234,56)
    if (currency == r'R$' || currency == r'ARS$' || currency == r'EUR') {
      formatted = val.toStringAsFixed(2).replaceAll('.', ',');
      if (currency != r'EUR') {
        // R$ e ARS$ usam ponto como milhar
        formatted = formatted.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
      }
    } else if (currency == r'US$') {
      // Formatação americana (1,234.56)
      String baseText = val.toStringAsFixed(2);
      List<String> parts = baseText.split('.');
      String integerPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match.group(1)},',
      );
      String decimalPart = parts.length > 1 ? parts[1] : '00';
      formatted = '$integerPart.$decimalPart';
    } else {
      formatted = val.toStringAsFixed(2);
    }
    return formatted;
  }

  void _showEditAmountDialog(FixedExpenseModel expense) {
    String currentCurrency = expense.currency;
    final TextEditingController controller = TextEditingController(
      text: _formatCurrencyValue(
          (expense.amount * 100).toInt().toString(), currentCurrency),
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        final colorScheme = theme.colorScheme;

        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.attach_money_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar valor',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        expense.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentCurrency,
                      isDense: true,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => currentCurrency = val);
                        }
                      },
                      items: [r'R$', r'US$', r'EUR', r'ARS$']
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '0,00',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => controller.clear(),
                      ),
                    ),
                    onChanged: (val) {
                      final formatted =
                          _formatCurrencyValue(val, currentCurrency);
                      controller.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  String cleanText = controller.text;
                  if (currentCurrency == r'US$') {
                    cleanText = cleanText.replaceAll(',', '');
                  } else {
                    cleanText =
                        cleanText.replaceAll('.', '').replaceAll(',', '.');
                  }
                  final newAmount = double.tryParse(cleanText);
                  if (newAmount != null) {
                    ref.read(spendingProvider.notifier).updateExpense(
                          expense.id,
                          newAmount: newAmount,
                          newCurrency: currentCurrency,
                        );
                    Navigator.pop(dialogCtx);
                    HapticFeedback.mediumImpact();
                    SnackBarHelper.showSuccess(context, 'Valor atualizado!');
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDueDayDialog(FixedExpenseModel expense) {
    final TextEditingController controller =
        TextEditingController(text: expense.dueDay.toString());

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alterar vencimento',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      expense.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: 10',
              labelText: 'Dia do mês (1–31)',
              prefixIcon: Icon(Icons.event_rounded, color: colorScheme.primary),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final newDay = int.tryParse(controller.text);
                if (newDay != null && newDay >= 1 && newDay <= 31) {
                  ref
                      .read(spendingProvider.notifier)
                      .updateExpense(expense.id, newDueDay: newDay);
                  Navigator.pop(dialogCtx);
                  HapticFeedback.mediumImpact();
                  SnackBarHelper.showSuccess(context, 'Vencimento alterado!');
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

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

  // --- HARDCODED TEXTS FOR SPENDING ---

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      final nicheId = _niche.nicheId;
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
          gamification.monitoredApps = Set<String>.from(_selectedApps);

          bool accessibilityGranted =
              await PermissionService.hasAccessibilityPermission();

          if (!mounted) return;

          if (accessibilityGranted) {
            gamification.startMonitoringApps(
              nicheId: NicheId.spending,
              horarios: [],
            );
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

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();

    await PermissionService.ensurePermissions(context, forceUsage: true);
    bool accessibilityGranted =
        await PermissionService.hasAccessibilityPermission();
    if (!accessibilityGranted) {
      return;
    }

    if (!mounted) return;

    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.monitoredApps = Set<String>.from(_selectedApps);

    gamification.startMonitoringApps(
      nicheId: NicheId.spending,
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
      nicheId: NicheId.spending,
      isActive: true,
    );
    Provider.of<GamificationService>(context, listen: false)
        .startModuleCycle(nicheId: NicheId.spending);
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
    final confirmed = await DeactivateModuleDialog.show(
      context: context,
      nicheId: NicheId.spending,
      customMessage:
          'Ao desativar o módulo, seu progresso e estatísticas serão reiniciados.\n\nDeseja continuar?',
    );

    if (confirmed != true) return;
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

    if (!mounted) return;
    setState(() {
      _gamificationRunning = false;
      _selectedIndex = 0;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
    }
    CloudSyncService.saveModuleStatus(
      nicheId: NicheId.spending,
      isActive: false,
    );

    if (!mounted) return;
    SnackBarHelper.showError(
      context,
      'Módulo desativado',
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
      NicheId.spending,
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
                nicheId: NicheId.spending,
              );
              for (var pkg in apps) {
                await CloudSyncService.addUserNicheApp(
                  nicheId: NicheId.spending,
                  package: pkg,
                );
              }
            },
            nicheId: NicheId.spending,
          ),
        ),
      ),
    );

    if (!mounted) return;

    // Se tiver apps e o controller estiver ok, avança para Controle
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

  void _removeSelectedApp(String package) async {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedApps.remove(package);
    });
    await CloudSyncService.removeUserNicheApp(
      nicheId: NicheId.spending,
      package: package,
    );
    // Se o módulo estiver rodando, atualizar o serviço de monitoramento
    if (_gamificationRunning) {
      if (!mounted) return;
      final gamification =
          Provider.of<GamificationService>(context, listen: false);
      gamification.monitoredApps = Set<String>.from(_selectedApps);
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
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildTabContent(0),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                          // 1: Controlar Gastos
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
                      child: NicheActionButton(
                        icon: Icons.rocket_launch_rounded,
                        label: 'Começar',
                        color: const Color(0xFF6366F1),
                        isDark: isDark,
                        onTap: () {
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic);
                          } else {
                            setState(() => _selectedIndex = 1);
                          }
                        },
                      ),
                    )
                  : _buildBottomButtons(isDark),
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
                child: NicheActionButton(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Controle de gastos',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _showControlGastosMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NicheActionButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SpendingNotificationsScreen(),
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
                child: NicheActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estatísticas',
                  color: Colors.teal,
                  isDark: isDark,
                  onTap: _showStatisticsMenu,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NicheActionButton(
                  icon: _gamificationRunning
                      ? Icons.power_settings_new
                      : Icons.power_off,
                  label: _gamificationRunning
                      ? 'Desativar módulo'
                      : 'Ativar módulo',
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

  void _showControlGastosMenu() {
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
              'Controle de Gastos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListActionTile(
              icon: Icons.touch_app_outlined,
              label: 'Selecionar apps',
              color: const Color(0xFF6366F1),
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                _openSelectApps();
              },
            ),
            ListActionTile(
              icon: Icons.receipt_long_rounded,
              label: 'Gastos fixos',
              color: Colors.teal,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FixedExpensesScreen()),
                );
              },
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
              'Estatísticas e Progresso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListActionTile(
              icon: Icons.receipt_long_outlined,
              label: 'Estatísticas de contas pagas',
              color: Colors.purple,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FixedBillsStatsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            ListActionTile(
              icon: Icons.bar_chart_rounded,
              label: 'Conquistas',
              color: Colors.blue,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProgressSpending()),
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
    final List<String> options = ['Como Funciona', 'Controlar Gastos'];

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
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.account_balance_wallet_outlined,
              title:
                  'Em "Controle de gastos", gerencie apps monitorados e gastos fixos',
              content:
                  'Em "Selecionar apps", escolha apps de compras online para monitorar. Ao abri-los, você receberá um alerta para evitar compras por impulso.\nEm "Gastos fixos", cadastre suas contas fixas (aluguel, luz, internet...) e seja lembrado de pagá-las antes do vencimento.',
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.edit_note_rounded,
              title: 'Edite valor e vencimento a qualquer momento',
              content:
                  'Na tela principal, toque nos três pontinhos (⋮) em cada conta para editar o valor daquele mês ou alterar o dia de vencimento. Ao marcar uma conta como paga, ela sai da lista e aparece nas estatísticas.',
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.notifications_outlined,
              title: 'Em "Notificações", configure seus alertas',
              content:
                  'Receba alertas ao abrir apps monitorados e lembretes para pagar suas contas fixas antes do vencimento.',
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.circle,
              title: 'Sistema de urgência por cores',
              content:
                  '🟢 Verde: a conta ainda está longe do vencimento.\n🟡 Amarelo: faltam poucos dias para vencer.\n🔴 Vermelho: a conta está vencendo hoje ou já venceu.',
            ),
            const SizedBox(height: 16),
            NicheInfoCard(
              isDark: isDark,
              icon: Icons.bar_chart_rounded,
              title: 'Em "Estatísticas", acompanhe seu progresso',
              content:
                  'Veja o resumo das contas pagas no mês, o total gasto e acompanhe sua disciplina financeira ao longo do tempo.',
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
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
            const SizedBox(height: 24),
            Text(
              'Gastos fixos:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final asyncExpenses = ref.watch(spendingProvider);

                return asyncExpenses.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Erro: $err')),
                  data: (allExpenses) {
                    final expenses = allExpenses
                        .where((e) => !_isPaidInCurrentMonth(e))
                        .toList();

                    if (expenses.isEmpty) {
                      return Container(
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
                            'Nenhum gasto fixo cadastrado.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...expenses.map((expense) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: expense
                                    .getUrgencyLevel()
                                    .color
                                    .withValues(alpha: 0.6),
                                width: 2.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Vence dia ${expense.dueDay.toString().padLeft(2, '0')} • ${expense.currency} ${_formatCurrencyValue((expense.amount * 100).toInt().toString(), expense.currency)}',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54),
                                  padding: EdgeInsets.zero,
                                  onSelected: (value) {
                                    if (value == 'edit_valor') {
                                      _showEditAmountDialog(expense);
                                    } else if (value == 'edit_vencimento') {
                                      _showEditDueDayDialog(expense);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit_valor',
                                      child: Text('Editar Valor'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit_vencimento',
                                      child: Text('Alterar Vencimento'),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(spendingProvider.notifier)
                                        .togglePaid(expense.id);
                                    HapticFeedback.mediumImpact();
                                  },
                                  child: Icon(
                                    _isPaidInCurrentMonth(expense)
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: _isPaidInCurrentMonth(expense)
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            'Para excluir um gasto fixo, vá em "Controle de gastos" e "Gastos fixos"',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  },
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
