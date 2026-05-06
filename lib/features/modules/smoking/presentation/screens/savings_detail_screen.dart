import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:disciplinum/features/modules/smoking/gamification/presentation/providers/smoking_gamification_provider.dart';

class SavingsDetailScreen extends ConsumerStatefulWidget {
  final SmokingSettingsModel settings;
  final bool isActive;

  const SavingsDetailScreen({
    super.key,
    required this.settings,
    this.isActive = true,
  });

  @override
  ConsumerState<SavingsDetailScreen> createState() => _SavingsDetailScreenState();
}

class _SavingsDetailScreenState extends ConsumerState<SavingsDetailScreen> 
    with WidgetsBindingObserver {
  int _activeTab = 0; // 0 = Atual, 1 = Última Tentativa
  late SmokingSettingsModel _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings;
    WidgetsBinding.instance.addObserver(this);
    LoggerService.instance.d('💰 SavingsDetailScreen: initState - currency=${_currentSettings.currency}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LoggerService.instance.d('💰 SavingsDetailScreen: didChangeAppLifecycleState - state=$state');
    if (state == AppLifecycleState.resumed) {
      // CORREÇÃO: Recarregar settings quando volta para primeiro plano
      LoggerService.instance.d('💰 SavingsDetailScreen: App resumed - calling _refreshSettings');
      _refreshSettings();
    }
  }

  Future<void> _refreshSettings() async {
    try {
      final service = ref.read(smokingServiceProvider);
      final updatedSettings = await service.getSettings();
      LoggerService.instance.d('💰 SavingsDetailScreen: got updatedSettings - currency=${updatedSettings?.currency}');
      
      if (mounted && updatedSettings != null) {
        if (updatedSettings.currency != _currentSettings.currency) {
          LoggerService.instance.d('💰 SavingsDetailScreen: Currency changed! ${_currentSettings.currency} -> ${updatedSettings.currency}');
          setState(() {
            _currentSettings = updatedSettings;
          });
          LoggerService.instance.d('💰 SavingsDetailScreen: setState called with new currency');
        }
      } else {
        LoggerService.instance.w('💰 SavingsDetailScreen: no updatedSettings or not mounted');
      }
    } catch (e) {
      LoggerService.instance.e('💰 SavingsDetailScreen: error in _refreshSettings', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cur = _activeTab == 0
        ? _currentSettings.currency
        : (_currentSettings.lastCurrency ?? _currentSettings.currency);
    
    // Usar dados do gamification state para projeções
    final gamificationNotifier = ref.watch(smokingGamificationNotifierProvider);
    final gamificationState = gamificationNotifier.gamification;
    final dailyCost = gamificationState?.dailyCost ?? 0.0;
    final consecutiveDays = gamificationState?.consecutivePositiveDays ?? 0;
    
    LoggerService.instance.d('💰 SavingsDetailScreen: build called - activeTab=$_activeTab, currency=$cur, dailyCost=$dailyCost, consecutiveDays=$consecutiveDays');

    // CORREÇÃO: Formatar moeda corretamente
    String formatCurrency(double amount, String currency) {
      LoggerService.instance.d('💰 formatCurrency called: amount=$amount, currency="$currency"');
      // CORREÇÃO: Suporte para múltiplas moedas
      String locale;
      String symbol;
      
      if (currency == 'R\$' || currency == 'BRL') {
        locale = 'pt_BR';
        symbol = 'R\$';
      } else if (currency == 'ARS' || currency == '\$') {
        locale = 'es_AR';
        symbol = '\$';
      } else {
        // Fallback para outras moedas (USD, EUR, etc)
        locale = 'en_US';
        symbol = currency == 'US\$' || currency == 'USD' ? '\$' : currency;
      }
      
      LoggerService.instance.d('💰 formatCurrency: locale=$locale, symbol=$symbol');
      final formatter = NumberFormat.currency(
        locale: locale,
        symbol: symbol,
        decimalDigits: 2,
      );
      final result = formatter.format(amount);
      LoggerService.instance.d('💰 formatCurrency result: "$result"');
      return result;
    }

    final saved = _activeTab == 0
        ? (widget.isActive ? (dailyCost * consecutiveDays) : 0.0)
        : (_currentSettings.lastSavedTotal ?? 0);

    // Se na aba "Atual" com módulo desativado, zerar todas as projeções
    final effectiveDailyCost = (_activeTab == 0 && !widget.isActive) ? 0.0 : dailyCost;
    final monthly = effectiveDailyCost * 30;
    final yearly = monthly * 12;

    final double maxVal = yearly;
    final double scale = maxVal > 0 ? 200 / maxVal : 0;

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Economia Detalhada"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            // Swipe para esquerda -> próxima aba (Última Tentativa)
            // Swipe para direita -> aba anterior (Atual)
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < 0 && _activeTab == 0) {
                // Swipe left, vai para aba 1
                setState(() => _activeTab = 1);
              } else if (details.primaryVelocity! > 0 && _activeTab == 1) {
                // Swipe right, vai para aba 0
                setState(() => _activeTab = 0);
              }
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- TAB SELECTOR (Estilo Auth) ---
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      alignment: _activeTab == 0
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildTabButton("Atual", 0),
                        _buildTabButton("Última tentativa", 1),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // BIG TOTAL
              Text(
                _activeTab == 0
                    ? "Economia Total Atual"
                    : "Economia da Última Tentativa",
                style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              Text(
                formatCurrency(saved, cur),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: _activeTab == 0
                      ? Colors.green
                      : Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 40),

              // CHART CONTAINER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text("Comparativo e Projeção",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar(context, saved, scale, "Acumulado", Colors.green, cur),
                        _buildBar(context, monthly, scale, "Mensal", Colors.blue, cur),
                        _buildBar(context, yearly, scale, "Anual", Colors.purple, cur),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Detailed List
              if (_activeTab == 0 && !widget.isActive) ...[
                // Aba "Atual" com módulo desativado - mostrar mensagem
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.power_off_rounded,
                        size: 48,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Módulo Desativado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ative o módulo Stop Smoking para ver suas economias.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_activeTab == 1 && _currentSettings.lastPackPrice == null)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    "Nenhuma tentativa anterior registrada.",
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                )
              else ...[
                _buildDetailRow(
                  context,
                  "Custo do Maço",
                  formatCurrency(_activeTab == 0 ? gamificationState?.packCost ?? _currentSettings.packPrice : _currentSettings.lastPackPrice!, cur),
                ),
                _buildDetailRow(
                  context,
                  "Maços/Dia (antes)",
                  "${_activeTab == 0 ? (dailyCost / (gamificationState?.packCost ?? 1)).toStringAsFixed(1) : _currentSettings.lastPacksPerDay}",
                ),
                _buildDetailRow(
                  context,
                  "Economia Diária",
                  formatCurrency(dailyCost, cur),
                ),
                _buildDetailRow(context, "Economia Mensal",
                    formatCurrency(monthly, cur)),
                _buildDetailRow(context, "Economia Anual",
                    formatCurrency(yearly, cur)),
                _buildDetailRow(
                  context,
                  "Data que parou",
                  DateFormat('dd/MM/yyyy').format(_activeTab == 0
                      ? _currentSettings.quitDate ?? DateTime.now()
                      : _currentSettings.lastQuitDate ?? DateTime.now()),
                ),
                if (_activeTab == 1 && _currentSettings.lastEndDate != null)
                  _buildDetailRow(
                    context,
                    "Data que encerrou",
                    DateFormat('dd/MM/yyyy')
                        .format(_currentSettings.lastEndDate!),
                  ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isActive = _activeTab == index;
    final colorScheme = Theme.of(context).colorScheme;
    final Color activeToggleText = colorScheme.onPrimary;
    final Color inactiveToggleText = colorScheme.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isActive ? activeToggleText : inactiveToggleText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, double value, double scale,
      String label, Color color, String currency) {
    double height = value * scale;
    if (height < 10) height = 10;
    if (height > 200) height = 200;

    // CORREÇÃO: Formatar moeda corretamente no gráfico
    String formatCurrencyShort(double amount, String currency) {
      final locale = currency == 'BRL' ? 'pt_BR' : 'en_US';
      final symbol = currency == 'BRL' ? 'R\$' : '\$';
      
      if (amount > 1000) {
        final formatter = NumberFormat.currency(
          locale: locale,
          symbol: symbol,
          decimalDigits: 1,
        );
        return '${formatter.format(amount / 1000)}k';
      } else {
        final formatter = NumberFormat.currency(
          locale: locale,
          symbol: symbol,
          decimalDigits: 0,
        );
        return formatter.format(amount);
      }
    }

    return Column(
      children: [
        Text(
          formatCurrencyShort(value, currency),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
