import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';

/// Dialog para atualizar progresso de leitura
/// Widget reutilizável para todos os módulos de leitura
class BookUpdateProgressDialog extends StatefulWidget {
  final ReadingBook? book;
  final Function(ReadingBook) onUpdate;

  const BookUpdateProgressDialog({
    super.key,
    this.book,
    required this.onUpdate,
  });

  @override
  State<BookUpdateProgressDialog> createState() => _BookUpdateProgressDialogState();
}

class _BookUpdateProgressDialogState extends State<BookUpdateProgressDialog> {
  late TextEditingController _pagesController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.book?.currentPage ?? 0;
    _pagesController = TextEditingController(text: _currentPage.toString());
  }

  @override
  void dispose() {
    _pagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = widget.book?.totalPages ?? 0;
    
    return AlertDialog(
      title: Text(widget.book == null ? 'Adicionar Progresso' : 'Atualizar Progresso'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.book != null) ...[
            Text(
              widget.book!.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _pagesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Página atual',
              suffixText: '/ $totalPages',
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              _currentPage = int.tryParse(value) ?? 0;
            },
          ),
          if (totalPages > 0) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _currentPage / totalPages,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${((_currentPage / totalPages) * 100).toInt()}% concluído',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.book != null) {
              final updatedBook = widget.book!.copyWith(
                currentPage: _currentPage,
              );
              widget.onUpdate(updatedBook);
            }
            Navigator.of(context).pop();
          },
          child: const Text('ATUALIZAR'),
        ),
      ],
    );
  }
}
