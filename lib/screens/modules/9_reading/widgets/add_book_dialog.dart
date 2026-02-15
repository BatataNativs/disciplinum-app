import 'package:disciplinum/models/9_reading/reading_model.dart';
import 'package:disciplinum/services/9_reading/reading_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddBookDialog extends StatefulWidget {
  /// Se não-nulo, o diálogo entra em modo de edição
  final ReadingBook? bookToEdit;

  const AddBookDialog({super.key, this.bookToEdit});

  static void show(BuildContext context, {ReadingBook? bookToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddBookDialog(bookToEdit: bookToEdit),
    );
  }

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  ReadingTheme _selectedTheme = ReadingTheme.ficcaoCientifica;

  bool get _isEditing => widget.bookToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final book = widget.bookToEdit!;
      _titleController.text = book.title;
      _authorController.text = book.author ?? '';
      _pagesController.text = book.totalPages.toString();
      _selectedTheme = book.theme;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final service = Provider.of<ReadingService>(context, listen: false);
      if (_isEditing) {
        service.updateBook(
          bookId: widget.bookToEdit!.id,
          title: _titleController.text,
          author:
              _authorController.text.isEmpty ? null : _authorController.text,
          totalPages: int.parse(_pagesController.text),
          theme: _selectedTheme,
        );
      } else {
        service.addBook(
          title: _titleController.text,
          author:
              _authorController.text.isEmpty ? null : _authorController.text,
          totalPages: int.parse(_pagesController.text),
          theme: _selectedTheme,
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Form(
          key: _formKey,
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
                _isEditing ? 'Editar Livro 📖' : 'Adicionar Livro 📖',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite o título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration:
                    const InputDecoration(labelText: 'Autor (Opcional)'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
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
                isExpanded: true,
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
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: _submit,
                      child: Text(_isEditing ? 'Salvar' : 'Adicionar'),
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
