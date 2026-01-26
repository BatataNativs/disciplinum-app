import 'package:flutter/material.dart';
import 'package:disciplinum/models/1_smoking/smoking_settings_model.dart';
import 'package:disciplinum/services/1_smoking/smoking_service.dart';
import 'package:disciplinum/widgets/1_smoking/savings_dashboard.dart';
import 'package:disciplinum/widgets/1_smoking/health_compact_card.dart';
import 'package:disciplinum/screens/modules/1_smoking/health_detail_screen.dart';
import 'package:disciplinum/widgets/1_smoking/my_progress_smoking.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/widgets/niche_details/niche_header.dart';
import 'package:disciplinum/widgets/niche_details/niche_info_section.dart';
import 'package:disciplinum/screens/modules/1_smoking/savings_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/screens/modules/1_smoking/smoking_notifications_screen.dart';

class StopSmokingScreen extends StatefulWidget {
  const StopSmokingScreen({super.key});

  @override
  State<StopSmokingScreen> createState() => _StopSmokingScreenState();
}

class _StopSmokingScreenState extends State<StopSmokingScreen> {
  SmokingSettingsModel? settings;
  bool isLoading = true;
  bool _gamificationRunning = false;
  bool isSaving = false;
  final SmokingService _service = SmokingService();

  // --- CONTROLADOR DE PÁGINA ---
  late PageController _pageController;
  int _selectedIndex = 0;

  final Niche _niche = NicheRepository.getById(NicheId.smoking);

  final TextEditingController _priceController =
      TextEditingController(text: '0,00');
  final TextEditingController _packsController =
      TextEditingController(text: '0');
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'R\$';

  @override
  void initState() {
    super.initState();
    // Inicializa o controller
    _pageController = PageController(initialPage: 0);
    _loadSettings();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _packsController.dispose();
    _pageController.dispose();
    super.dispose();
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
        _priceController.text =
            settings!.packPrice.toStringAsFixed(2).replaceAll('.', ',');
        _packsController.text = settings!.packsPerDay.toString();

        if (!_gamificationRunning) {
          _selectedDate = DateTime.now();
        } else {
          _selectedDate = settings!.quitDate;
        }

        _selectedCurrency = settings!.currency;

        _syncCheckInWithGamification(onlySyncSchedules: !_gamificationRunning);
      }
    }
  }

  void _formatCurrencyInput(String value) {
    if (value.isEmpty) {
      _priceController.value = TextEditingValue(
        text: '0,00',
        selection: TextSelection.collapsed(offset: 4),
      );
      return;
    }

    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.isEmpty) {
      _priceController.value = TextEditingValue(
        text: '0,00',
        selection: TextSelection.collapsed(offset: 4),
      );
      return;
    }

    double val = double.parse(numbers) / 100;
    String formatted =
        val.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            );

    _priceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _syncCheckInWithGamification(
      {bool onlySyncSchedules = false}) async {
    final times =
        await CloudSyncService.loadUserNicheTimes(nicheId: NicheId.smoking.id);
    if (!mounted) return;

    final gamification =
        Provider.of<GamificationService>(context, listen: false);

    gamification.scheduleByModule[NicheId.smoking] =
        times.map((t) => TimeOfDay(hour: t.hour, minute: t.minute)).toList();

    if (onlySyncSchedules) return;

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

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.saveSettings(newSettings);
      if (mounted) {
        setState(() {
          settings = newSettings;
          isSaving = false;
        });

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        } else {
          setState(() {
            _selectedIndex = 2;
          });
        }

        await _syncCheckInWithGamification(onlySyncSchedules: true);

        messenger.showSnackBar(
          const SnackBar(
              content: Text("Dados de consumo salvos com sucesso! ✔")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
        messenger.showSnackBar(
          SnackBar(content: Text("Erro ao salvar: $e")),
        );
      }
    }
  }

  Future<void> _resetProgress() async {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Poxa, teve uma recaída?"),
        content: const Text(
          "Que pena!\nÉ difícil, mas não desista!\n\n"
          "Tente novamente quando se sentir pronto!\n(espero que em breve).\n\n"
          "Ao registrar a recaída, isso vai apagar seu progresso atual e o módulo será desativado até que você preencha novos dados de consumo e o ative novamente.\n\n"
          "Deseja registrar a recaída?",
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
            child: const Text("Sim, infelizmente.."),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);
      try {
        await _service.archiveAndReset();
        await CloudSyncService.removeAllTimesForNiche(
            nicheId: NicheId.smoking.id);
        await CloudSyncService.removeAllTimesForNiche(
            nicheId: NicheId.smoking.id + 100);

        gamification.resetMedals(
          NicheId.smoking,
          notificationTitle: 'Módulo de Parar de Fumar Reiniciado',
          notificationBody:
              'Seu progresso foi zerado e o módulo desativado. Como estímulo, confira no app o quanto economizou nessa tentativa!',
          deactivate: true,
        );

        if (mounted) {
          _service.getSettings().then((data) {
            if (mounted) {
              setState(() {
                settings = data;
                _gamificationRunning = false;
                isLoading = false;
              });
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Progresso resetado. Configure novamente quando estiver pronto. 💪")),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao resetar: $e")),
          );
        }
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
        setState(() => isLoading = true);
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
              isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) setState(() => isLoading = false);
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
    final messenger = ScaffoldMessenger.of(context);
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Desativar módulo?"),
        content: const Text(
          "Ao desativar o módulo, seu progresso de dias e medalhas será reiniciado.\n\n"
          "Deseja continuar?",
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
          notificationTitle: 'Módulo Desativado',
          notificationBody:
              'Seu progresso foi zerado e o módulo desativado. Confira no app o quanto economizou nessa tentativa!',
          deactivate: true,
        );

        if (mounted) {
          final data = await _service.getSettings();
          setState(() {
            settings = data;
            _gamificationRunning = false;
            isLoading = false;
          });

          messenger.showSnackBar(
            const SnackBar(
                content: Text("Módulo desativado e progresso zerado.")),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          messenger.showSnackBar(
            SnackBar(content: Text("Erro ao desativar: $e")),
          );
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
          title: Text(_niche.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                            fontSize: 26,
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
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSegmentedControl(),
                    ),
                    const SizedBox(height: 24),

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
                          // PAGINA 0: Como Funciona
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
                          // PAGINA 1: Info Consumo
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
                          // PAGINA 2: Ativar
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
    final List<String> options = ['Como funciona', 'Info de Consumo', 'Ativar'];

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
                if (_pageController.hasClients) {
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutQuad);
                } else {
                  setState(() {
                    _selectedIndex = index;
                  });
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
            const NicheInfoSection(
              hintText:
                  "Este módulo ajuda você a parar de fumar. Esse hábito nocivo pode prejudicar sua saúde, suas finanças, sua qualidade de vida e sua família. \n\nNa próxima tela, informe o preço médio do maço e quantos maços fuma por dia para calcular sua economia de dinheiro e melhorias na sua saúde\n\n(caso seja menos de 1 maço, informe, aproximadamente, em decimal. Ex: 0,5 maços).",
            ),
            const SizedBox(height: 24),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas informações de consumo:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.grey[300]!,
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
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCurrency = newValue;
                                      });
                                    }
                                  },
                                  items: ['R\$', 'US\$', '€', '\$']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
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
                          onChanged: (val) {
                            _formatCurrencyInput(val);
                          },
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
                          onChanged: (val) {
                            if (val.isEmpty) {
                              _packsController.value = TextEditingValue(
                                text: '0',
                                selection: TextSelection.collapsed(offset: 1),
                              );
                            }
                          },
                          decoration: InputDecoration(
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
          ],
        );
      case 2:
        return Column(
          children: [
            if (_gamificationRunning && settings != null) ...[
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SavingsDetailScreen(
                              settings: settings!,
                              isActive: _gamificationRunning,
                            ),
                          ),
                        );
                      },
                      child: SavingsDashboard(
                        settings: settings!,
                        compact: true,
                        isActive: _gamificationRunning,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HealthCompactCard(
                      settings: settings!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HealthDetailScreen(settings: settings!),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyProgressSmoking()),
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
                                  const SmokingNotificationsScreen()),
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
      // --- NOVO BOTÃO COMEÇAR (ABA 0) ---
      case 0:
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: GlowingButton(
            text: 'Começar',
            color: const Color.fromARGB(255, 57, 92, 208),
            onPressed: () {
              if (_pageController.hasClients) {
                _pageController.animateToPage(1, // Vai para "Info de Consumo"
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
            text: isSaving ? 'Salvando...' : 'Salvar',
            color: const Color.fromARGB(255, 57, 92, 208),
            onPressed: isSaving
                ? () {} // Bloqueia clique
                : () {
                    if (_priceController.text.isNotEmpty &&
                        _packsController.text.isNotEmpty) {
                      String cleanPrice = _priceController.text
                          .replaceAll(RegExp(r'[^\d,]'), '')
                          .replaceAll(',', '.');

                      _saveSettings(
                        double.tryParse(cleanPrice) ?? 0.0,
                        int.tryParse(_packsController.text) ?? 0,
                        _selectedDate,
                        _selectedCurrency,
                      );
                    }
                  },
            borderRadius: 18,
          ),
        );
      case 2:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 55,
              child: GlowingButton(
                text:
                    _gamificationRunning ? 'Desativar Módulo' : 'Ativar Módulo',
                color: _gamificationRunning
                    ? const Color.fromARGB(255, 239, 68, 68)
                    : const Color.fromARGB(255, 16, 185, 129),
                onPressed: _gamificationRunning
                    ? _desativarNichoMonitoramento
                    : _ativarNichoMonitoramento,
                borderRadius: 18,
              ),
            ),
            if (_gamificationRunning) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _resetProgress,
                icon: const Icon(Icons.refresh,
                    color: Colors.redAccent, size: 20),
                label: const Text(
                  "Tive uma recaída (Resetar)",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
