import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// BottomSheet moderna para configurar/editar as informações de consumo de cigarro
class SmokingConsumptionBottomSheet extends StatefulWidget {
  final bool isModuleActive;
  final String initialPrice;
  final String initialPacks;
  final String initialCurrency;
  final DateTime initialDate;
  final Future<void> Function({
    required double price,
    required int packs,
    required DateTime quitDate,
    required String currency,
  }) onSave;

  const SmokingConsumptionBottomSheet({
    super.key,
    required this.isModuleActive,
    required this.initialPrice,
    required this.initialPacks,
    required this.initialCurrency,
    required this.initialDate,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isModuleActive,
    required String initialPrice,
    required String initialPacks,
    required String initialCurrency,
    required DateTime initialDate,
    required Future<void> Function({
      required double price,
      required int packs,
      required DateTime quitDate,
      required String currency,
    }) onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SmokingConsumptionBottomSheet(
        isModuleActive: isModuleActive,
        initialPrice: initialPrice,
        initialPacks: initialPacks,
        initialCurrency: initialCurrency,
        initialDate: initialDate,
        onSave: onSave,
      ),
    );
  }

  @override
  State<SmokingConsumptionBottomSheet> createState() =>
      _SmokingConsumptionBottomSheetState();
}

class _SmokingConsumptionBottomSheetState
    extends State<SmokingConsumptionBottomSheet> {
  late final TextEditingController _priceController;
  late final TextEditingController _packsController;
  late String _selectedCurrency;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.initialPrice);
    _packsController = TextEditingController(text: widget.initialPacks);
    _selectedCurrency = widget.initialCurrency;
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _packsController.dispose();
    super.dispose();
  }

  void _formatCurrencyInput(String value) {
    if (value.isEmpty) {
      _priceController.clear();
      return;
    }

    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.isEmpty) {
      _priceController.clear();
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

    if (val <= 0.009) {
      _priceController.clear();
      return;
    }

    _priceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _handleSave() async {
    final priceText = _priceController.text.trim();
    final packsText = _packsController.text.trim();

    if (priceText.isEmpty || packsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String cleanPrice = priceText;
    if (_selectedCurrency == 'US\$') {
      cleanPrice = cleanPrice.replaceAll(',', '');
    } else {
      cleanPrice =
          cleanPrice.replaceAll('.', '').replaceAll(',', '.');
    }
    cleanPrice = cleanPrice.replaceAll(RegExp(r'[^\d.]'), '');

    final priceVal = double.tryParse(cleanPrice) ?? 0.0;
    final packsVal = (double.tryParse(packsText) ?? 0.0).round();

    if (priceVal <= 0 || packsVal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira valores válidos maiores que zero.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      await widget.onSave(
        price: priceVal,
        packs: packsVal,
        quitDate: _selectedDate,
        currency: _selectedCurrency,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: bottomInset + 20,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
                    Icons.tune_rounded,
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
                        'Informações de Consumo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Dados para cálculo de economia e saúde',
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
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card com Campos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  // Preço do Maço
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preço do maço:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        height: 44,
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCurrency,
                                isDense: true,
                                icon: const Icon(Icons.arrow_drop_down, size: 16),
                                alignment: Alignment.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: colorScheme.onSurface,
                                ),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedCurrency = val;
                                      _formatCurrencyInput(
                                          _priceController.text);
                                    });
                                  }
                                },
                                items: ['R\$', 'US\$', 'EUR', 'ARS\$']
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 50, maxWidth: 64),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            hintText: '0,00',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: _formatCurrencyInput,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Maços por dia
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Maços por dia:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        height: 44,
                        child: TextField(
                          controller: _packsController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Data de parada
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Data de início/parada:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
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
                            setState(() => _selectedDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: const Color(0xFF6366F1),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botão Salvar
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Salvar Informações',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

