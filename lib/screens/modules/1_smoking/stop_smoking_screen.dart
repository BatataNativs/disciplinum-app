import 'package:flutter/material.dart';
import 'package:disciplinum/models/1_smoking/smoking_settings_model.dart';
import 'package:disciplinum/services/1_smoking/smoking_service.dart';
import 'package:disciplinum/widgets/1_smoking/savings_dashboard.dart';
import 'package:disciplinum/widgets/1_smoking/health_compact_card.dart';
import 'package:disciplinum/screens/modules/1_smoking/health_detail_screen.dart';
import 'package:disciplinum/screens/modules/1_smoking/savings_detail_screen.dart';

import 'package:disciplinum/models/niche_id.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/widgets/niche_details/niche_header.dart';
import 'package:disciplinum/widgets/niche_details/niche_info_section.dart';
import 'package:disciplinum/widgets/profile/lojinha.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter/services.dart';

class StopSmokingScreen extends StatefulWidget {
  const StopSmokingScreen({super.key});

  @override
  State<StopSmokingScreen> createState() => _StopSmokingScreenState();
}

class _StopSmokingScreenState extends State<StopSmokingScreen> {
  SmokingSettingsModel? settings;
  bool isLoading = true;
  bool _gamificationRunning = false;
  final SmokingService _service = SmokingService();
  int _selectedIndex = 0;
  final Niche _niche = NicheRepository.getById(NicheId.smoking);

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
        // Sincroniza e restaura o ciclo se já estiver ativo
        _syncCheckInWithGamification(onlySyncSchedules: !_gamificationRunning);
      }
    }
  }

  Future<void> _syncCheckInWithGamification(
      {bool onlySyncSchedules = false}) async {
    final times =
        await CloudSyncService.loadUserNicheTimes(nicheId: NicheId.smoking.id);
    if (!mounted) return;

    final gamification =
        Provider.of<GamificationService>(context, listen: false);

    // Atualiza horários no cache do serviço
    gamification.scheduleByModule[NicheId.smoking] =
        times.map((t) => TimeOfDay(hour: t.hour, minute: t.minute)).toList();

    if (onlySyncSchedules) return;

    // Se houver horários e o módulo estiver ativo, garante que o ciclo está rodando
    if (times.isNotEmpty && _gamificationRunning) {
      // Garante permissões (Notificação e Status de uso)
      await PermissionService.ensurePermissions(context);

      gamification.startModuleCycle(nicheId: NicheId.smoking);

      // Garante que o monitor background (Timer) está ativo
      if (!gamification.isGeneralMonitoringActive) {
        gamification.startMonitoringApps(
            nicheId: NicheId.smoking,
            horarios: gamification.scheduleByModule[NicheId.smoking]!);
      }
    }
  }

  Future<void> _saveSettings(
      double price, int packs, DateTime date, String currency) async {
    setState(() => isLoading = true);
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
          isLoading = false;
        });

        // Apenas sincroniza horários SEM ativar ao salvar
        await _syncCheckInWithGamification(onlySyncSchedules: true);

        messenger.showSnackBar(
          const SnackBar(
              content: Text("Dados de consumo salvos com sucesso! ✔")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        messenger.showSnackBar(
          SnackBar(content: Text("Erro ao salvar: $e")),
        );
      }
    }
  }

  // --- CORREÇÃO PRINCIPAL AQUI ---
  Future<void> _resetProgress() async {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tive uma recaída?"),
        content: const Text(
          "Isso vai apagar seu progresso e o módulo será desativado até que você preencha e ative novamente.\n\n"
          "Deseja realmente resetar e desativar?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
                "Sim, resetar (Zerar progresso) e desativar (Desativar módulo)"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);
      try {
        // 1. Arquiva tentativa atual e reseta economia no banco
        await _service.archiveAndReset();

        // 2. Reseta gamificação e desativa module
        gamification.resetMedals(
          NicheId.smoking,
          notificationTitle: 'Módulo de Fumar Reiniciado',
          notificationBody:
              'Seu progresso foi zerado e o módulo desativado. Confira no app o quanto economizou nessa tentativa!',
          deactivate: true,
        );

        if (mounted) {
          // Recarrega as configurações para ter os dados do histórico
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
        title: const Text("Desativar e Zerar?"),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
        // 1. Arquiva e reseta economia
        await _service.archiveAndReset();

        // 2. Desativa e reseta gamificação
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

  void _showSetupDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceController = TextEditingController();
    final packsController = TextEditingController();

    if (settings != null) {
      // Formatar o preço inicial com 2 casas
      priceController.text =
          settings!.packPrice.toStringAsFixed(2).replaceAll('.', ',');
      packsController.text = settings!.packsPerDay.toString();
    }

    DateTime selectedDate = settings?.quitDate ?? DateTime.now();
    String selectedCurrency = settings?.currency ?? 'R\$';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            scrollable: true,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: Text(
              "Adicione esses dados para começar!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? Colors.white : Colors.indigo[900],
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Linha 1: Preço (Ocupa tudo)
                TextField(
                  controller: priceController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Preço médio do maço:",
                    prefixIcon: Container(
                      width: 80,
                      alignment: Alignment.centerLeft,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCurrency,
                          isDense: true,
                          icon: const Icon(Icons.arrow_drop_down, size: 18),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          items: [
                            {'val': 'R\$', 'label': 'R\$ (Real)'},
                            {'val': 'US\$', 'label': 'US\$ (Dólar)'},
                            {'val': '€', 'label': '€ (Euro)'},
                            {'val': '\$', 'label': '\$ (Peso)'},
                          ]
                              .map((c) => DropdownMenuItem(
                                    value: c['val'] as String,
                                    child: Text(c['label'] as String),
                                  ))
                              .toList(),
                          selectedItemBuilder: (context) {
                            return [
                              'R\$',
                              'US\$',
                              '€',
                              '\$',
                            ].map((symbol) {
                              return Center(
                                child: Text(
                                  symbol,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.indigo,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (v) {
                            if (v != null) {
                              setStateDialog(() => selectedCurrency = v);
                            }
                          },
                        ),
                      ),
                    ),
                    labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.indigo),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    String formatted = _formatCurrency(value, selectedCurrency);
                    if (priceController.text != formatted) {
                      priceController.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Linha 2: Maços/dia e Data (Lado a lado)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Coluna 1: Maços
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: packsController,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: "Maços por dia:",
                          labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.indigo),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Coluna 2: Data
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Data que parou de fumar\n(hoje ou anterior):",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            height:
                                48, // Altura para alinhar visualmente com o TextField
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors
                                          .grey, // Cor mais suave como borda de input
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      4), // Borda padrão MDL
                                ),
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                  locale: const Locale('pt', 'BR'),
                                );
                                if (picked != null) {
                                  setStateDialog(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color:
                                        isDark ? Colors.white54 : Colors.indigo,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
            actionsPadding:
                const EdgeInsets.only(bottom: 20, right: 20, left: 20),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  if (priceController.text.isNotEmpty &&
                      packsController.text.isNotEmpty) {
                    // Remove R$, US$, etc and convert comma
                    String cleanPrice = priceController.text
                        .replaceAll(RegExp(r'[^\d,]'), '')
                        .replaceAll(',', '.');

                    _saveSettings(
                      double.parse(cleanPrice),
                      int.parse(packsController.text),
                      selectedDate,
                      selectedCurrency,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Salvar"),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper para formatar moeda
  String _formatCurrency(String value, String currencySymbol) {
    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.isEmpty) return '0,00';

    double val = double.parse(numbers) / 100;
    return val.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
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
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      NicheHeader(
                        niche: _niche,
                        showBackground: false,
                      ),
                      const SizedBox(height: 16),
                      _buildSegmentedControl(),
                      const SizedBox(height: 24),
                      // Top Content Zone (Static)
                      _buildTabContent(),
                      const SizedBox(height: 24),
                      // Bottom Action Zone (Static)
                      _buildTabActions(),
                      const SizedBox(height: 40),
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

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> options = ['Info de Consumo', 'Ativar'];

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

  Widget _buildTabContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (_selectedIndex) {
      case 0:
        return Column(
          key: const ValueKey('content_info'),
          children: const [
            NicheInfoSection(
              hintText:
                  "No botão abaixo, antes de ativar o módulo, informe o preço médio do maço que você costuma (ou costumava) pagar, o número de maços que você costuma (ou costumava) fumar por dia e a data de parada (hoje ou anterior).\n\nCaso ainda esteja fumando, essa é uma boa oportunidade para uma tentativa de parar!\n\nFaça isso e veja, entre outras coisas, o quanto você pode economizar ao largar esse hábito. Força!",
            ),
            SizedBox(height: 24),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey('content_activate'),
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
              _buildMedalProgress(
                primaryColor: isDark
                    ? const Color.fromARGB(255, 99, 102, 241)
                    : const Color.fromARGB(255, 57, 92, 208),
                secondaryColor: isDark
                    ? const Color.fromARGB(255, 139, 92, 246)
                    : const Color.fromARGB(255, 99, 102, 241),
              ),
              const SizedBox(height: 16),
              _buildNotificationMessageSection(context),
            ] else ...[
              const Icon(Icons.do_not_disturb_on_rounded,
                  size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Módulo Inativo",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              const Text(
                "Ative o módulo para começar a monitorar seu progresso e economia.",
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

  Widget _buildTabActions() {
    switch (_selectedIndex) {
      case 0:
        return SizedBox(
          key: const ValueKey('action_setup'),
          width: double.infinity,
          height: 55,
          child: GlowingButton(
            text: settings == null
                ? 'Configurar metas e datas'
                : 'Editar informações de consumo',
            color: const Color.fromARGB(255, 57, 92, 208),
            onPressed: _showSetupDialog,
            borderRadius: 18,
          ),
        );
      case 1:
        return Column(
          key: const ValueKey('action_activate'),
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
      color = const Color.fromARGB(255, 33, 150, 243);
    } else if (diasConsecutivos >= 7) {
      final faltam = 10 - diasConsecutivos;
      text =
          'Sua medalha atual é de Ouro 🥇. Faltam $faltam ${faltam == 1 ? 'dia' : 'dias'} para a medalha de Diamante 💎.';
    } else if (diasConsecutivos >= 5) {
      final faltam = 7 - diasConsecutivos;
      text =
          'Sua medalha atual é de Prata 🥈. Faltam $faltam ${faltam == 1 ? 'dia' : 'dias'} para a medalha de Ouro 🥇.';
    } else if (diasConsecutivos >= 3) {
      final faltam = 5 - diasConsecutivos;
      text =
          'Sua medalha atual é de Bronze 🥉. Faltam $faltam ${faltam == 1 ? 'dia' : 'dias'} para a medalha de Prata 🥈.';
    } else {
      final faltam = 3 - diasConsecutivos;
      text =
          'Sem medalhas ainda. Faltam $faltam ${faltam == 1 ? 'dia' : 'dias'} para a medalha de Bronze 🥉.';
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
      builder: (context) => AlertDialog(
        title: const Text('Mensagem da Notificação'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Digite a mensagem...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await gamification.setCustomMessage(_niche.id, controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
