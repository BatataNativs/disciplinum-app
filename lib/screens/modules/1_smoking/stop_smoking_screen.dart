import 'package:flutter/material.dart';
import 'package:disciplinum/models/1_smoking/smoking_settings_model.dart';
import 'package:disciplinum/services/1_smoking/smoking_service.dart';
import 'package:disciplinum/widgets/1_smoking/savings_dashboard.dart';
import 'package:disciplinum/widgets/1_smoking/health_timeline_card.dart';
import 'package:disciplinum/screens/modules/1_smoking/savings_detail_screen.dart';
import 'package:disciplinum/app_router.dart';

import 'package:disciplinum/models/niche_id.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';

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
          const SnackBar(content: Text("Metas salvas com sucesso! 🚀")),
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
          "Isso vai apagar seus dados e o módulo será desativado até que você preencha e ative novamente.\n\n"
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
            child: const Text("Sim, resetar e desativar"),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Parar de Fumar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          foregroundColor: isDark ? Colors.white : Colors.black,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (settings == null || !_gamificationRunning)
                ? SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/no_smoking.png',
                              width: 75,
                              height: 75,
                            ),
                            const SizedBox(height: 20),
                            Text(
                                settings == null
                                    ? "Vamos começar sua jornada\nde parar de fumar!"
                                    : "Módulo Inativo",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black)),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _showSetupDialog,
                              child: Text(
                                  settings == null
                                      ? "Configurar metas e datas"
                                      : "Adicionar informações de consumo",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                            if (settings != null) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 220,
                                height: 50,
                                child: GlowingButton(
                                  text: 'Ativar Módulo',
                                  color: const Color.fromARGB(255, 16, 165, 53),
                                  onPressed: _ativarNichoMonitoramento,
                                  borderRadius: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () {
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
                                icon: const Icon(Icons.history,
                                    color: Colors.white70),
                                label: const Text("Ver Histórico de Economia",
                                    style: TextStyle(color: Colors.white70)),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      isDark ? Colors.white24 : Colors.black12,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "No botão acima, antes de ativar o módulo, informe o preço médio do maço que você costuma (ou costumava) pagar, o número de maços que você costuma (ou costumava) fumar por dia e a data de parada (hoje ou anterior).\n\nCaso ainda esteja fumando, essa é uma boa oportunidade para tentar parar de fumar! \n\nFaça isso e veja, entre outras coisas, o quanto você pode economizar ao largar esse hábito",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14, // Reduzi levemente a fonte
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigate to details
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
                                flex: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                        AppRouter.smokingNotifications);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .cardColor
                                          .withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.blueAccent
                                              .withValues(alpha: 0.3)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 5)
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent
                                                .withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                              Icons.notifications_active,
                                              color: Colors.blueAccent,
                                              size: 28),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Notificações",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Configure aqui",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: GlowingButton(
                              text: _gamificationRunning
                                  ? 'Desativar Módulo'
                                  : 'Ativar Módulo',
                              color: _gamificationRunning
                                  ? Colors.redAccent
                                  : const Color.fromARGB(255, 16, 165, 53),
                              onPressed: _gamificationRunning
                                  ? _desativarNichoMonitoramento
                                  : _ativarNichoMonitoramento,
                              borderRadius: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        HealthTimelineCard(settings: settings!),

                        const SizedBox(height: 30),

                        // BOTÃO DE RECAÍDA
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: Colors.redAccent, width: 2),
                              ),
                            ),
                            icon: const Icon(Icons.refresh,
                                color: Colors.redAccent),
                            label: const Text("TIVE UMA RECAÍDA (ZERAR)",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            onPressed: _resetProgress,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }
}
