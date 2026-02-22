import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:disciplinum/services/4_spending/spending_service.dart';
import 'package:disciplinum/models/4_spending/fixed_expense_model.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:flutter/services.dart';

class FixedExpensesScreen extends StatefulWidget {
  const FixedExpensesScreen({super.key});

  @override
  State<FixedExpensesScreen> createState() => _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends State<FixedExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos Fixos'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
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
          child: Consumer<SpendingService>(
            builder: (context, service, child) {
              final expenses = service.fixedExpenses;

              return Column(
                children: [
                  Expanded(
                    child: expenses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 64,
                                    color: Colors.grey.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Nenhum gasto fixo cadastrado',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Adicione suas contas mensais aqui',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              return _buildExpenseTile(
                                  expense, isDark, service);
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: GlowingButton(
                      text: 'Novo Gasto Fixo',
                      color: const Color(0xFF6366F1),
                      onPressed: () => _showAddExpenseDialog(context),
                      borderRadius: 18,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseTile(
      FixedExpenseModel expense, bool isDark, SpendingService service) {
    String formatAmountForDisplay(double amount, String currency) {
      switch (currency) {
        case 'R\$':
          return amount.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match.group(1)}.',
          );
        case 'US\$':
          String baseText = amount.toStringAsFixed(2);
          List<String> parts = baseText.split('.');
          String integerPart = parts[0];
          String decimalPart = parts.length > 1 ? parts[1] : '';
          
          integerPart = integerPart.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match.group(1)},',
          );
          
          return decimalPart.isNotEmpty ? '$integerPart.$decimalPart' : integerPart;
        case '€':
          return amount.toStringAsFixed(2).replaceAll('.', ',');
        case 'ARS\$':
          return amount.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match.group(1)}.',
          );
        default:
          return amount.toStringAsFixed(2);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: expense.getUrgencyLevel().color.withValues(alpha: 0.6),
          width: 2.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          expense.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          'Vence dia ${expense.dueDay.toString().padLeft(2, '0')} • ${expense.currency} ${formatAmountForDisplay(expense.amount, expense.currency)}',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                expense.isPaid ? Icons.check_circle : Icons.circle_outlined,
                color: expense.isPaid ? Colors.green : Colors.grey,
                size: 24,
              ),
              onPressed: () => service.togglePaid(expense.id),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: isDark ? Colors.white70 : Colors.black45),
              onSelected: (value) {
                if (value == 'edit') {
                  _showAddExpenseDialog(context, expense: expense);
                } else if (value == 'delete') {
                  service.deleteFixedExpense(expense.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(
                    value: 'delete',
                    child:
                        Text('Excluir', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context,
      {FixedExpenseModel? expense}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController(text: expense?.name);
    final dayController =
        TextEditingController(text: expense?.dueDay.toString());
    String selectedCurrency = expense?.currency ?? 'R\$';
    double currentAmount = expense?.amount ?? 0.0;
    
    // Obter o serviço antes de abrir o modal
    final service = Provider.of<SpendingService>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    expense == null ? 'Novo Gasto Fixo' : 'Editar Gasto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nome da conta'),
                    textCapitalization: TextCapitalization.sentences,
                    enableSuggestions: true,
                    autocorrect: true,
                    keyboardType: TextInputType.text,
                    inputFormatters: [],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCurrency,
                          items: ['R\$', 'US\$', '€', 'ARS\$']
                              .map((c) {
                                String currencyName = '';
                                switch (c) {
                                  case 'R\$':
                                    currencyName = 'Real';
                                    break;
                                  case 'US\$':
                                    currencyName = 'Dólar';
                                    break;
                                  case '€':
                                    currencyName = 'Euro';
                                    break;
                                  case 'ARS\$':
                                    currencyName = 'Peso';
                                    break;
                                }
                                return DropdownMenuItem(value: c, child: Text('$c - $currencyName'));
                              })
                              .toList(),
                          onChanged: (v) {
                            debugPrint('Dropdown onChanged - Moeda selecionada: $v');
                            setState(() {
                              selectedCurrency = v!;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'Moeda'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _CurrencyTextField(
                          key: ValueKey(selectedCurrency), // Força reconstrução quando moeda muda
                          currency: selectedCurrency,
                          initialValue: expense?.amount,
                          onChanged: (value) => currentAmount = value,
                          labelText: 'Valor',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dayController,
                    decoration:
                        const InputDecoration(labelText: 'Dia do vencimento'),
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            debugPrint('Botão Salvar pressionado');
                            final name = nameController.text.trim();
                            final day = int.tryParse(dayController.text) ?? 1;

                            debugPrint('Dados: name="$name", amount=$currentAmount, day=$day');
                            debugPrint('Validação: name.isNotEmpty=${name.isNotEmpty}, amount>0=${currentAmount > 0}');

                            if (name.isNotEmpty && currentAmount > 0) {
                              debugPrint('Validação passou, tentando adicionar/editar gasto');
                              try {
                                if (expense == null) {
                                  debugPrint('Adicionando novo gasto');
                                  service.addFixedExpense(FixedExpenseModel(
                                    id: const Uuid().v4(),
                                    name: name,
                                    amount: currentAmount,
                                    currency: selectedCurrency,
                                    dueDay: day.clamp(1, 31),
                                  ));
                                } else {
                                  debugPrint('Editando gasto existente: ${expense.id}');
                                  service.updateFixedExpense(expense.copyWith(
                                    name: name,
                                    amount: currentAmount,
                                    currency: selectedCurrency,
                                    dueDay: day.clamp(1, 31),
                                  ));
                                }
                                debugPrint('Gasto salvo com sucesso, fechando modal');
                                Navigator.pop(ctx);
                              } catch (e) {
                                debugPrint('Erro ao salvar gasto: $e');
                              }
                            } else {
                              debugPrint('Validação falhou');
                            }
                          },
                          child: const Text('Salvar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CurrencyTextField extends StatefulWidget {
  final String currency;
  final double? initialValue;
  final ValueChanged<double> onChanged;
  final String labelText;

  const _CurrencyTextField({
    super.key,
    required this.currency,
    this.initialValue,
    required this.onChanged,
    required this.labelText,
  });

  @override
  State<_CurrencyTextField> createState() => _CurrencyTextFieldState();
}

class _CurrencyTextFieldState extends State<_CurrencyTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    
    if (widget.initialValue != null) {
      _controller.text = _formatCurrency(widget.initialValue!);
    }
  }

  @override
  void didUpdateWidget(_CurrencyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza quando a moeda mudar
    if (oldWidget.currency != widget.currency) {
      // Reformatar o valor atual com a nova moeda
      if (_controller.text.isNotEmpty) {
        String cleanText = _controller.text.replaceAll(RegExp(r'[^\d]'), '');
        if (cleanText.isNotEmpty) {
          double value = double.parse(cleanText) / 100.0;
          _controller.text = _formatCurrency(value);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    switch (widget.currency) {
      case 'R\$':
        return value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
      case 'US\$':
        return value.toStringAsFixed(2);
      case '€':
        return value.toStringAsFixed(2).replaceAll('.', ',');
      case 'ARS\$':
        return value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
      default:
        return value.toStringAsFixed(2);
    }
  }

  void _onTextChanged(String text) {
    if (text.isEmpty) {
      widget.onChanged(0.0);
      return;
    }

    // Remove formatação para obter o valor numérico
    String cleanText = text;
    cleanText = cleanText.replaceAll(RegExp(r'[R\$US\$ARS\$€]'), '');
    cleanText = cleanText.replaceAll('.', '');
    cleanText = cleanText.replaceAll(',', '.');
    
    final value = double.tryParse(cleanText) ?? 0.0;
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_CurrencyTextField build - Moeda atual: ${widget.currency}');
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixText: '${widget.currency} ',
        prefixStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        _DynamicCurrencyInputFormatter(() => widget.currency),
      ],
      onChanged: _onTextChanged,
    );
  }
}

class _DynamicCurrencyInputFormatter extends TextInputFormatter {
  final String Function() getCurrency;
  
  _DynamicCurrencyInputFormatter(this.getCurrency);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove caracteres não numéricos
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Converte para valor numérico (divide por 100 para considerar centavos)
    double value = double.parse(cleanText) / 100.0;
    
    String currency = getCurrency();
    debugPrint('CurrencyInputFormatter - Moeda: $currency, Valor: $value');
    
    String formattedText;
    switch (currency) {
      case 'R\$':
        formattedText = value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
        break;
      case 'US\$':
        String baseText = value.toStringAsFixed(2);
        // Primeiro adiciona separadores de milhar, depois mantém o ponto decimal
        List<String> parts = baseText.split('.');
        String integerPart = parts[0];
        String decimalPart = parts.length > 1 ? parts[1] : '';
        
        // Adiciona vírgulas como separadores de milhar
        integerPart = integerPart.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
        );
        
        formattedText = decimalPart.isNotEmpty ? '$integerPart.$decimalPart' : integerPart;
        break;
      case '€':
        formattedText = value.toStringAsFixed(2).replaceAll('.', ',');
        break;
      case 'ARS\$':
        formattedText = value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
        break;
      default:
        formattedText = value.toStringAsFixed(2);
    }
    
    debugPrint('CurrencyInputFormatter - Formatado: $formattedText');

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
