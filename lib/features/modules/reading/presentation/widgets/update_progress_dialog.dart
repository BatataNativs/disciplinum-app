import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';

class UpdateProgressDialog extends ConsumerStatefulWidget {
  final ReadingBook book;

  const UpdateProgressDialog({super.key, required this.book});

  @override
  ConsumerState<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends ConsumerState<UpdateProgressDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.book.currentPage.toString());
  }

  void _submit() {
    final newPage = int.tryParse(_controller.text);
    if (newPage != null) {
      // Validação simples
      if (newPage > widget.book.totalPages) {
        SnackBarHelper.showError(context, 'Página não pode ser maior que o total!');
        return;
      }

      ref.read(readingServiceProvider).updateProgress(widget.book.id, newPage);
      Navigator.of(context).pop();
    }
  }

  void _deleteBook() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Excluir livro?'),
              content: const Text(
                  'Tem certeza que deseja remover este livro da sua estante?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    ref.read(readingServiceProvider).deleteBook(widget.book.id);
                    Navigator.pop(ctx); // fecha confirmacao
                    Navigator.pop(context); // fecha dialogo de update
                  },
                  child: const Text('Excluir',
                      style: TextStyle(color: Colors.red)),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Atualizar: ${widget.book.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'Página atual: ${widget.book.currentPage} / ${widget.book.totalPages}'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Li até a página:',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _deleteBook,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Excluir Livro'),
        ),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar')),
        ElevatedButton(onPressed: _submit, child: const Text('Salvar Leitura')),
      ],
    );
  }
}
