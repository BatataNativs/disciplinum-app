import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:intl/intl.dart';

class SavingsDetailScreen extends StatefulWidget {
  final SmokingSettingsModel settings;
  final bool isActive;

  const SavingsDetailScreen({
    super.key,
    required this.settings,
    this.isActive = true,
  });

  @override
  State<SavingsDetailScreen> createState() => _SavingsDetailScreenState();
}

class _SavingsDetailScreenState extends State<SavingsDetailScreen> {
  int _activeTab = 0; // 0 = Atual, 1 = Última Tentativa

  @override
  Widget build(BuildContext context) {
    final cur = _activeTab == 0
        ? widget.settings.currency
        : (widget.settings.lastCurrency ?? widget.settings.currency);

    final saved = _activeTab == 0
        ? (widget.isActive ? widget.settings.moneySavedTotal : 0.0)
        : (widget.settings.lastSavedTotal ?? 0);

    final monthly = _activeTab == 0
        ? widget.settings.monthlySavings
        : ((widget.settings.lastPackPrice ?? 0) *
            (widget.settings.lastPacksPerDay ?? 0) *
            30);

    final yearly = monthly * 12;

    final double maxVal = yearly;
    final double scale = maxVal > 0 ? 200 / maxVal : 0;

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
          title: const Text("Economia Detalhada"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- TAB SELECTOR (Estilo Auth) ---
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color.fromARGB(255, 226, 229, 251)
                          .withValues(alpha: 0.5),
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
                            color: isDark
                                ? Colors.grey[900]
                                : const Color.fromARGB(255, 121, 148, 222),
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
                        _buildTabButton("Atual", 0, isDark),
                        _buildTabButton("Última tentativa", 1, isDark),
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
                    color: isDark ? Colors.white70 : Colors.grey[700]),
              ),
              Text(
                "$cur${saved.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: _activeTab == 0
                      ? (isDark ? Colors.greenAccent : Colors.green)
                      : (isDark ? Colors.blueGrey[300] : Colors.blueGrey),
                ),
              ),
              const SizedBox(height: 40),

              // CHART CONTAINER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    )
                  ],
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
                        _buildBar(context, saved, scale, "Acumulado",
                            Colors.green, cur),
                        _buildBar(context, monthly, scale, "Mensal",
                            Colors.blue, cur),
                        _buildBar(context, yearly, scale, "Anual",
                            Colors.purple, cur),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Detailed List
              if (_activeTab == 0 ||
                  (widget.settings.lastPackPrice != null)) ...[
                _buildDetailRow(
                  context,
                  "Custo do Maço",
                  "$cur${(_activeTab == 0 ? widget.settings.packPrice : widget.settings.lastPackPrice!).toStringAsFixed(2)}",
                ),
                _buildDetailRow(
                  context,
                  "Maços/Dia (antes)",
                  "${_activeTab == 0 ? widget.settings.packsPerDay : widget.settings.lastPacksPerDay}",
                ),
                _buildDetailRow(
                  context,
                  "Economia Diária",
                  "$cur${((_activeTab == 0 ? widget.settings.packPrice : widget.settings.lastPackPrice!) * (_activeTab == 0 ? widget.settings.packsPerDay : widget.settings.lastPacksPerDay!)).toStringAsFixed(2)}",
                ),
                _buildDetailRow(context, "Economia Mensal",
                    "$cur${monthly.toStringAsFixed(2)}"),
                _buildDetailRow(context, "Economia Anual",
                    "$cur${yearly.toStringAsFixed(2)}"),
                _buildDetailRow(
                  context,
                  "Data que parou",
                  DateFormat('dd/MM/yyyy').format(_activeTab == 0
                      ? widget.settings.quitDate ?? DateTime.now()
                      : widget.settings.lastQuitDate ?? DateTime.now()),
                ),
                if (_activeTab == 1 && widget.settings.lastEndDate != null)
                  _buildDetailRow(
                    context,
                    "Data que encerrou",
                    DateFormat('dd/MM/yyyy')
                        .format(widget.settings.lastEndDate!),
                  ),
              ] else
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    "Nenhum histórico disponível ainda.",
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index, bool isDark) {
    final isActive = _activeTab == index;
    final Color activeToggleText = isDark ? Colors.black : Colors.white;
    final Color inactiveToggleText =
        isDark ? Colors.black54 : Colors.grey.shade600;

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
      String label, Color color, String cur) {
    double height = value * scale;
    if (height < 10) height = 10;
    if (height > 200) height = 200;

    return Column(
      children: [
        Text(
          "$cur${value > 1000 ? "${(value / 1000).toStringAsFixed(1)}k" : value.toStringAsFixed(0)}",
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
