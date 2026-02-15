import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:disciplinum/services/4_spending/spending_service.dart';
import 'package:disciplinum/models/4_spending/fixed_expense_model.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          expense.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          'Vence dia ${expense.dueDay.toString().padLeft(2, '0')} • ${expense.currency} ${expense.amount.toStringAsFixed(2)}',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                expense.isPaid ? Icons.check_circle : Icons.circle_outlined,
                color: expense.isPaid ? Colors.green : Colors.grey,
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
    final amountController =
        TextEditingController(text: expense?.amount.toString());
    final dayController =
        TextEditingController(text: expense?.dueDay.toString());
    String selectedCurrency = expense?.currency ?? 'R\$';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedCurrency,
                      items: ['R\$', '\$', '€']
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => selectedCurrency = v!,
                      decoration: const InputDecoration(labelText: 'Moeda'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
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
                        final name = nameController.text.trim();
                        final amount =
                            double.tryParse(amountController.text) ?? 0;
                        final day = int.tryParse(dayController.text) ?? 1;

                        if (name.isNotEmpty && amount > 0) {
                          final service = Provider.of<SpendingService>(context,
                              listen: false);
                          if (expense == null) {
                            service.addFixedExpense(FixedExpenseModel(
                              id: const Uuid().v4(),
                              name: name,
                              amount: amount,
                              currency: selectedCurrency,
                              dueDay: day.clamp(1, 31),
                            ));
                          } else {
                            service.updateFixedExpense(expense.copyWith(
                              name: name,
                              amount: amount,
                              currency: selectedCurrency,
                              dueDay: day.clamp(1, 31),
                            ));
                          }
                          Navigator.pop(ctx);
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
      ),
    );
  }
}
