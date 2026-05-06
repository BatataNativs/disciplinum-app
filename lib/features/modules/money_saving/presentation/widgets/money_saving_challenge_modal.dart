import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/components/currency_input_formatter.dart';

class MoneySavingChallengeModal extends StatefulWidget {
  final MoneySavingChallengeModel? challenge;
  final String? editId;
  final Function(MoneySavingChallengeModel) onSave;

  const MoneySavingChallengeModal({
    super.key,
    this.challenge,
    this.editId,
    required this.onSave,
  });

  @override
  State<MoneySavingChallengeModal> createState() => _MoneySavingChallengeModalState();
}

class _MoneySavingChallengeModalState extends State<MoneySavingChallengeModal> {
  final TextEditingController _titleController =
      TextEditingController(text: 'Novo Desafio');
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _periodValueController = TextEditingController();
  final TextEditingController _minValueController = TextEditingController();
  final TextEditingController _maxValueController = TextEditingController();
  String _selectedPeriodType = 'mês(es)';
  String _selectedCurrency = 'R\$';

  final List<String> _periodTypes = [
    'dia(s)',
    'semana(s)',
    'mês(es)',
    'ano(s)',
    'indeterminado'
  ];
  final List<String> _currencyOptions = ['R\$', 'US\$', '€', '\$'];
  final Map<String, String> _currencyNames = {
    'R\$': 'R\$ - Real',
    'US\$': 'US\$ - Dólar Americano',
    '€': '€ - Euro',
    '\$': '\$ - Peso Argentino',
  };

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    
    // Listener para atualizar o singular/plural do dropdown em tempo real
    _periodValueController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _initializeFields() {
    if (widget.challenge != null) {
      _titleController.text = widget.challenge!.title;
      _targetController.text = _formatValue(widget.challenge!.targetAmount, widget.challenge!.currency);
      _periodValueController.text = widget.challenge!.periodValue.toString();
      _minValueController.text = _formatValue(widget.challenge!.minValue, widget.challenge!.currency);
      _maxValueController.text = _formatValue(widget.challenge!.maxValue, widget.challenge!.currency);
      _selectedPeriodType = widget.challenge!.periodType;
      _selectedCurrency = widget.challenge!.currency;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _periodValueController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  double _parseFormattedCurrency(String text, String currency) {
    if (text.isEmpty) return 0;
    bool isLatin = currency == 'R\$' || currency == '€' || currency == '\$';

    String cleaned;
    if (isLatin) {
      cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    } else {
      cleaned = text.replaceAll(',', '');
    }
    return double.tryParse(cleaned) ?? 0;
  }

  void _reformatAmountFields(String newCurrency, String oldCurrency) {
    for (var controller in [
      _targetController,
      _minValueController,
      _maxValueController
    ]) {
      if (controller.text.isNotEmpty) {
        double value = _parseFormattedCurrency(controller.text, oldCurrency);
        controller.text = _formatValue(value, newCurrency);
      }
    }
  }

  String _formatValue(double value, String currency) {
    bool isLatin = currency == 'R\$' || currency == '€' || currency == '\$';
    String fixed = value.toStringAsFixed(2);
    List<String> parts = fixed.split('.');
    String whole = parts[0];
    String decimal = parts[1];

    String decimalSep = isLatin ? ',' : '.';
    String thousandSep = isLatin ? '.' : ',';

    String result = '';
    int count = 0;
    for (int i = whole.length - 1; i >= 0; i--) {
      result = whole[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = thousandSep + result;
        count = 0;
      }
    }
    return result + decimalSep + decimal;
  }

  Future<void> _saveChallenge() async {
    final target = _targetController.text.isEmpty
        ? 3000.0
        : _parseFormattedCurrency(_targetController.text, _selectedCurrency);
    final periodValue = _periodValueController.text.isEmpty
        ? 6
        : (int.tryParse(_periodValueController.text) ?? 0);
    final minValue = _minValueController.text.isEmpty
        ? 10.0
        : _parseFormattedCurrency(_minValueController.text, _selectedCurrency);
    final maxValue = _maxValueController.text.isEmpty
        ? 100.0
        : _parseFormattedCurrency(_maxValueController.text, _selectedCurrency);

    if (target <= 0) {
      _showSnackBar('Defina uma meta válida');
      return;
    }
    if (minValue <= 0 || maxValue <= 0) {
      _showSnackBar('Defina os valores mínimo e máximo');
      return;
    }
    if (minValue >= maxValue) {
      _showSnackBar('O valor mínimo deve ser menor que o máximo');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final challenge = MoneySavingChallengeModel(
        id: widget.editId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim().isEmpty
            ? 'Novo Desafio'
            : _titleController.text.trim(),
        targetAmount: target,
        periodValue: periodValue,
        periodType: _selectedPeriodType,
        gridSize: 0,
        minValue: minValue,
        maxValue: maxValue,
        currency: _selectedCurrency,
        isActive: true,
        createdAt: widget.challenge?.createdAt ?? DateTime.now(),
        markedCells: [],
        cellValues: [],
      );

      await widget.onSave(challenge);
      
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar(widget.editId == null ? 'Desafio criado!' : 'Desafio atualizado!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar('Erro ao salvar desafio');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.editId != null ? 'Editar Desafio' : 'Novo Desafio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTitleField(),
            const SizedBox(height: 20),
            _buildCurrencyAndTargetFields(),
            const SizedBox(height: 20),
            _buildPeriodField(),
            const SizedBox(height: 20),
            _buildMinMaxFields(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nome',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _titleController,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: const InputDecoration(
            hintText: 'Dê um nome ao desafio!',
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyAndTargetFields() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Moeda',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              _buildCurrencyDropdown(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                CurrencyInputFormatter(currency: _selectedCurrency),
              ],
              style: TextStyle(color: colorScheme.onSurface),
              decoration: const InputDecoration(
                hintText: '5.000,00',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 24),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
          onChanged: (value) {
            if (value != null) {
              final oldCurrency = _selectedCurrency;
              setState(() {
                _selectedCurrency = value;
                _reformatAmountFields(value, oldCurrency);
              });
            }
          },
          items: _currencyOptions.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                _currencyNames[c] ?? c,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPeriodField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _periodValueController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: const InputDecoration(
                hintText: '6',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildPeriodTypeDropdown()),
      ],
    );
  }

  Widget _buildPeriodTypeDropdown() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriodType,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedPeriodType = value);
            }
          },
          items: _periodTypes.map((p) {
            String label = p;
            final val = int.tryParse(_periodValueController.text) ?? 0;
            if (val == 1) {
              if (p == 'dia(s)') {
                label = 'dia';
              } else if (p == 'semana(s)') {
                label = 'semana';
              } else if (p == 'mês(es)') {
                label = 'mês';
              } else if (p == 'ano(s)') {
                label = 'ano';
              }
            } else if (val > 1) {
              if (p == 'dia(s)') {
                label = 'dias';
              } else if (p == 'semana(s)') {
                label = 'semanas';
              } else if (p == 'mês(es)') {
                label = 'meses';
              } else if (p == 'ano(s)') {
                label = 'anos';
              }
            }
            return DropdownMenuItem(value: p, child: Text(label));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMinMaxFields() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aporte mínimo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _minValueController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyInputFormatter(currency: _selectedCurrency),
                  ],
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    hintText: '10,00',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aporte máximo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _maxValueController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyInputFormatter(currency: _selectedCurrency),
                  ],
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    hintText: '100,00',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Color(0xFF4338CA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _isSaving ? null : _saveChallenge,
            child: Text(
              _isSaving
                  ? (widget.editId == null ? 'Criando...' : 'Salvando...')
                  : (widget.editId == null ? 'Criar!' : 'Salvar!'),
            ),
          ),
        ),
      ],
    );
  }
}
