import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';

/// Dialog para adicionar novo livro
/// Widget reutilizável para todos os módulos de leitura
class AddBookDialog extends StatefulWidget {
  final Function(ReadingBook) onAdd;

  const AddBookDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  ReadingTheme _selectedTheme = ReadingTheme.ficcaoCientifica;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Livro'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Autor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pagesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total de páginas *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReadingTheme>(
              initialValue: _selectedTheme,
              decoration: const InputDecoration(
                labelText: 'Tema',
                border: OutlineInputBorder(),
              ),
              items: ReadingTheme.values.map((theme) {
                return DropdownMenuItem(
                  value: theme,
                  child: Text(theme.label),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: _addBook,
          child: const Text('ADICIONAR'),
        ),
      ],
    );
  }

  void _addBook() {
    final title = _titleController.text.trim();
    final totalPages = int.tryParse(_pagesController.text) ?? 0;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O título é obrigatório')),
      );
      return;
    }

    if (totalPages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O total de páginas deve ser maior que zero')),
      );
      return;
    }

    final book = ReadingBook(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      author: _authorController.text.trim().isEmpty 
          ? null 
          : _authorController.text.trim(),
      totalPages: totalPages,
      theme: _selectedTheme,
      createdAt: DateTime.now(),
    );

    widget.onAdd(book);
    Navigator.of(context).pop();
  }
}
