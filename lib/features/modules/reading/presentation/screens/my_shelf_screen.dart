import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/widgets/dialogs/app_dialog.dart';

class MyShelfScreen extends ConsumerWidget {
  const MyShelfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar ReadingService diretamente (Riverpod)
    final readingService = ref.watch(readingServiceProvider);
    
    // Obter livros do ReadingService
    final booksToShow = readingService.books;
    
    if (booksToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "Nenhum livro encontrado",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Comece adicionando seu primeiro livro",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        // Implementar quando Isar estiver integrado
        // Por enquanto, usar booksToShow do ReadingService
        final activeBooks = booksToShow;
        
        if (activeBooks.isEmpty) {
          return const Center(
            child: Text(
              "Nenhum livro ativo no momento",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        
        return Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: activeBooks.length,
                itemBuilder: (context, index) {
                  final book = activeBooks[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.book,
                      color: Colors.blue,
                    ),
                    title: Text(book.title),
                    subtitle: Text(book.author ?? 'Autor desconhecido'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${book.currentPage}/${book.totalPages}"),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _deleteBookWithConfirm(context, ref, book),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _navigateToBookDetails(context, ref, book);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBookWithConfirm(BuildContext context, WidgetRef ref, ReadingBook book) async {
    final shouldDelete = await AppDialog.showConfirmation(
      context: context,
      title: 'Excluir livro?',
      content: 'Deseja excluir o livro "${book.title}" da sua estante?',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      isDangerous: true,
    );

    if (shouldDelete == true) {
      final readingService = ref.read(readingServiceProvider);
      await readingService.deleteBook(book.id);
    }
  }

  void _navigateToBookDetails(BuildContext context, WidgetRef ref, ReadingBook book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Autor: ${book.author ?? 'Autor desconhecido'}'),
            const SizedBox(height: 8),
            Text('Progresso: ${book.currentPage}/${book.totalPages} páginas'),
            const SizedBox(height: 8),
            Text('Tema: ${book.theme.name}'),
            const SizedBox(height: 8),
            Text('Início: ${_formatDate(book.createdAt)}'),
            if (book.completedAt != null) ...[
              const SizedBox(height: 8),
              Text('Concluído: ${_formatDate(book.completedAt!)}'),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showReadingProgress(context, ref, book);
                    },
                    child: const Text('Atualizar Progresso'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _showReadingProgress(BuildContext context, WidgetRef ref, ReadingBook book) {
    final currentPageController = TextEditingController(); // Campo vazio por padrão
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Atualizar Progresso - ${book.title}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text('Página atual: ${book.currentPage}'),
              const SizedBox(height: 4),
              Text('Total: ${book.totalPages} páginas'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: book.currentPage / book.totalPages,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 4),
              Text('${((book.currentPage / book.totalPages) * 100).toStringAsFixed(1)}% concluído'),
              const SizedBox(height: 16),
              TextField(
                controller: currentPageController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nova página atual',
                  hintText: 'Última página lida: ${book.currentPage}',
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _saveBookProgress(context, ref, book, currentPageController);
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBookProgress(BuildContext context, WidgetRef ref, ReadingBook book, TextEditingController currentPageController) {
    final newPage = int.tryParse(currentPageController.text);
    
    if (newPage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um número válido')),
      );
      return;
    }
    
    if (newPage < 0 || newPage > book.totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Página deve estar entre 0 e ${book.totalPages}')),
      );
      return;
    }
    
    // Salvar usando ReadingService
    final readingService = ref.read(readingServiceProvider);
    readingService.updateProgress(book.id, newPage);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progresso salvo com sucesso!')),
    );
  }
}

