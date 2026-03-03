import 'package:flutter/material.dart';
import 'package:disciplinum/models/1_smoking/smoking_settings_model.dart';
import 'package:disciplinum/services/1_smoking/smoking_service.dart';
import 'package:disciplinum/screens/modules/1_smoking/health_detail_screen.dart';
import 'package:disciplinum/widgets/1_smoking/my_progress_smoking.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/screens/modules/1_smoking/savings_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/utils/snackbar_helper.dart';
import 'package:disciplinum/screens/modules/1_smoking/frases_motivacionais.dart';
import '../../schedule_screen.dart';
import 'package:disciplinum/screens/modules/1_smoking/daily_checkins_stats.dart';
import 'package:disciplinum/misc/system_stuff/preferences_service.dart';
import 'package:disciplinum/models/user_niche_time.dart';

class StopSmokingScreen extends StatefulWidget {
  final String? heroTag;
  const StopSmokingScreen({super.key, this.heroTag});

  @override
  State<StopSmokingScreen> createState() => _StopSmokingScreenState();
}

class _StopSmokingScreenState extends State<StopSmokingScreen>
    with WidgetsBindingObserver {
  SmokingSettingsModel? settings;
  bool isLoading = true;
  bool _gamificationRunning = false;
  bool isSaving = false;
  final SmokingService _service = SmokingService();

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
      final isGuest = await PreferencesService.isGuestMode();
      final List<UserNicheTime> checkinTimes;

      if (isGuest) {
        checkinTimes = await PreferencesService.loadUserNicheTimes(
            nicheId: NicheId.smoking.id);
      } else {
        checkinTimes = await CloudSyncService.loadUserNicheTimes(
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
    final data = await _service.getSettings();
    final status = await CloudSyncService.loadModuleStatus(NicheId.smoking);

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
          _selectedDate = settings!.quitDate;
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
    final isGuest = await PreferencesService.isGuestMode();
    final List<UserNicheTime> times;

    if (isGuest) {
      times = await PreferencesService.loadUserNicheTimes(
          nicheId: NicheId.smoking.id);
    } else {
      times = await CloudSyncService.loadUserNicheTimes(
          nicheId: NicheId.smoking.id);
    }
    if (!mounted) return;

    final gamification =
        Provider.of<GamificationService>(context, listen: false);

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
      packPrice: price,
      packsPerDay: packs,
      quitDate: date,
      currency: currency,
    );

    try {
      await _service.saveSettings(newSettings);
      if (mounted) {
        setState(() {
          settings = newSettings;
          isSaving = false;
        });

        await _syncCheckInWithGamification(onlySyncSchedules: true);

        if (mounted) {
          SnackBarHelper.showSuccess(
              context, 'Informacoes salvas com sucesso!');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
        SnackBarHelper.showError(context, 'Erro ao salvar: \$e');
      }
    }
  }

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();
    await PermissionService.ensurePermissions(context);
    if (!mounted) return;

    bool notificationGranted = await NotificationService.requestPermission();
    if (notificationGranted) {
      if (settings != null) {
        setState(() => isSaving = true);
        try {
          final now = DateTime.now();
          final updatedSettings = SmokingSettingsModel(
            packPrice: settings!.packPrice,
            packsPerDay: settings!.packsPerDay,
            quitDate: now,
            currency: settings!.currency,
            lastPackPrice: settings!.lastPackPrice,
            lastPacksPerDay: settings!.lastPacksPerDay,
            lastQuitDate: settings!.lastQuitDate,
            lastCurrency: settings!.lastCurrency,
            lastSavedTotal: settings!.lastSavedTotal,
            lastEndDate: settings!.lastEndDate,
          );
          await _service.saveSettings(updatedSettings);
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
    CloudSyncService.saveModuleStatus(nicheId: NicheId.smoking, isActive: true);
    Provider.of<GamificationService>(context, listen: false)
        .startModuleCycle(nicheId: NicheId.smoking);
  }

  Future<void> _desativarNichoMonitoramento() async {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
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
      setState(() => isLoading = true);

      try {
        await _service.archiveAndReset();
        await CloudSyncService.removeAllTimesForNiche(
            nicheId: NicheId.smoking.id);
        await CloudSyncService.removeAllTimesForNiche(
            nicheId: NicheId.smoking.id + 100);

        gamification.resetMedals(
          NicheId.smoking,
          notificationTitle: 'Módulo Desativado 🛑',
          notificationBody:
              'O módulo foi desativado e todos os dados de estatística e gamificação foram resetados.',
          deactivate: true,
        );

        if (mounted) {
          final data = await _service.getSettings();
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
            SnackBarHelper.showSuccess(
                context, "Módulo desativado e progresso zerado.");
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          SnackBarHelper.showError(context, "Erro ao desativar: $e");
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedIndex == 0)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTabActions(0),
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTabActions(1),
                    ),
                    _buildBottomButtons(isDark),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> options = ['Como funciona', 'Parar de fumar'];

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
              title: 'No topo da tela, preencha como é o seu consumo',
              content:
                  'Preencha os dados do seu consumo de cigarro no momento (ou de antes da tentativa atual de parada), salve, e ative o módulo.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              isDark,
              icon: Icons.check_box_outlined,
              title:
                  'Em "Check-in diário", selecione horario para o Check-in diário',
              content:
                  'No horário configurado, você receberá uma notificação para que você faça o "check-in diário" da sua disciplina, informando se você fumou ou não no dia.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              isDark,
              icon: Icons.notifications_outlined,
              title: 'Em "Notificações", configure notificações motivacionais',
              content:
                  'Insira até 8 horários para receber notificações motivacionais durante o dia. Pra te lembrar de manter a disciplina.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              isDark,
              icon: Icons.bar_chart_rounded,
              title:
                  'Em "Estatisticas", veja estatisticas financeiras e de saude',
              content:
                  'Veja dados de quanto você pode economizar, e como sua saúde pode melhorar, caso mantenha a disciplina.',
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas informações de consumo:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const Text(
              'Preencha os dados do seu consumo de cigarro no momento (ou de antes da tentativa atual de parada), salve, e ative o módulo.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey[300]!,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Preço do maço:"),
                      SizedBox(
                        width: 160,
                        height: 40,
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(left: 4, right: 4),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCurrency,
                                  isDense: true,
                                  icon: const Icon(Icons.arrow_drop_down,
                                      size: 16),
                                  alignment: Alignment.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                  selectedItemBuilder: (BuildContext context) {
                                    return ['R\$', 'US\$', 'EUR', 'ARS\$']
                                        .map<Widget>((String item) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCurrency = newValue;
                                        _formatCurrencyInput(
                                            _priceController.text);
                                      });
                                    }
                                  },
                                  items: ['R\$', 'US\$', 'EUR', 'ARS\$']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    String currencyName = '';
                                    switch (value) {
                                      case 'R\$':
                                        currencyName = 'Real';
                                        break;
                                      case 'US\$':
                                        currencyName = 'Dólar Americano';
                                        break;
                                      case 'EUR':
                                        currencyName = 'Euro';
                                        break;
                                      case 'ARS\$':
                                        currencyName = 'Peso Argentino';
                                        break;
                                    }
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text('$value - $currencyName'),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 50, maxWidth: 80),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.indigo, width: 2),
                            ),
                          ),
                          onChanged: _formatCurrencyInput,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Maços por dia:"),
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: TextField(
                          controller: _packsController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: '0',
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.indigo, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Data de parada:"),
                      InkWell(
                        onTap: () async {
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
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildCheckinSection(isDark),
            const SizedBox(height: 24),
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

  Widget _buildCheckinSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check-in Diário',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (_checkinTime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Horário configurado:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showDeleteTimeDialog(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_checkinTime!.hour.toString().padLeft(2, '0')}:${_checkinTime!.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.red.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Configure este horário no botão "Check-in diário"',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horário não configurado',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Acesse "Check-in diário" abaixo para configurar seu check-in diário',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
        ],
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

              await CloudSyncService.removeUserNicheTime(
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

  Widget _buildTabActions(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (index) {
      case 0:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: _buildActionButton(
            icon: Icons.rocket_launch_rounded,
            label: 'Começar',
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
            icon: Icons.save_rounded,
            label: isSaving ? 'Salvando...' : 'Salvar',
            color: const Color(0xFF6366F1),
            isDark: isDark,
            onTap: isSaving
                ? () {}
                : () {
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
                  icon: Icons.check_circle_outline,
                  label: 'Check-in diário',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _openCheckInManager,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FrasesMotivacionaisScreen(),
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
                  label: 'Estatisticas',
                  color: Colors.teal,
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
                      ? 'Desativar Módulo'
                      : 'Ativar Módulo',
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
                  child: _buildActionButton(
                    icon: Icons.access_time_rounded,
                    label: 'Configurar Horário',
                    color: const Color(0xFF6366F1),
                    isDark: isDark,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final nicheId = _niche.id.id;
                      final initialItems =
                          await CloudSyncService.loadUserNicheTimes(
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
            _buildMenuTile(
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
            _buildMenuTile(
              icon: Icons.savings_outlined,
              label: 'Economia',
              color: Colors.green,
              onTap: () {
                Navigator.pop(ctx);
                if (settings != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavingsDetailScreen(
                        settings: settings!,
                        isActive: _gamificationRunning,
                      ),
                    ),
                  );
                }
              },
            ),
            _buildMenuTile(
              icon: Icons.health_and_safety_outlined,
              label: 'Saúde',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                if (settings != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HealthDetailScreen(settings: settings!),
                    ),
                  );
                }
              },
            ),
            _buildMenuTile(
              icon: Icons.bar_chart_rounded,
              label: 'Meu Progresso',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProgressSmoking()),
                );
              },
            ),
            const SizedBox(height: 12),
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
