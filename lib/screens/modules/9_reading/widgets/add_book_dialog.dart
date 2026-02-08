import 'package:disciplinum/models/9_reading/reading_model.dart';
import 'package:disciplinum/services/9_reading/reading_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddBookDialog extends StatefulWidget {
  const AddBookDialog({super.key});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  ReadingTheme _selectedTheme = ReadingTheme.outros;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final service = Provider.of<ReadingService>(context, listen: false);
      service.addBook(
        title: _titleController.text,
        author: _authorController.text.isEmpty ? null : _authorController.text,
        totalPages: int.parse(_pagesController.text),
        theme: _selectedTheme,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Livro 📖'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite o título' : null,
              ),
              TextFormField(
                controller: _authorController,
                decoration:
                    const InputDecoration(labelText: 'Autor (Opcional)'),
                textCapitalization: TextCapitalization.words,
              ),
              TextFormField(
                controller: _pagesController,
                decoration:
                    const InputDecoration(labelText: 'Total de Páginas'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Digite o total';
                  if (int.tryParse(value) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReadingTheme>(
                initialValue: _selectedTheme,
                decoration: const InputDecoration(labelText: 'Tema'),
                isExpanded: true, // Evita overflow do texto
                items: ReadingTheme.values.map((theme) {
                  return DropdownMenuItem(
                    value: theme,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: theme.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          // Garante que o texto não estoure
                          child: Text(theme.label,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedTheme = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
