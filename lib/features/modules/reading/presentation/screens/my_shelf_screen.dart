import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';

class MyShelfScreen extends ConsumerWidget {
  const MyShelfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar ReadingService quando estiver disponível
    final readingServiceAdapter = ref.watch(readingServiceAdapterProvider);
    
    // Tentar obter livros do ReadingService, fallback para mockados
    final activeBooks = readingServiceAdapter.getActiveBooks();
    
    // Se não houver livros, usar dados mockados
    final booksToShow = activeBooks.isEmpty ? _getMockBooks() : activeBooks;
    
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
        // Por enquanto, usar booksToShow que já combina ReadingService + mock
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Livros Ativos (${activeBooks.length})",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
                    trailing: Text("${book.currentPage}/${book.totalPages}"),
                    onTap: () {
                      _navigateToBookDetails(context, book);
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

  void _navigateToBookDetails(BuildContext context, ReadingBook book) {
    // Implementar navegação para detalhes do livro
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showReadingProgress(context, book);
            },
            child: const Text('Atualizar Progresso'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showReadingProgress(BuildContext context, ReadingBook book) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Atualizar Progresso - ${book.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Página atual: ${book.currentPage}'),
          const SizedBox(height: 16),
          Text('Total: ${book.totalPages} páginas'),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: book.currentPage / book.totalPages,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 8),
          Text('${((book.currentPage / book.totalPages) * 100).toStringAsFixed(1)}% concluído'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _saveBookProgress(context, book);
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

  void _saveBookProgress(BuildContext context, ReadingBook book) {
    // Implementar salvamento de progresso real usando ReadingServiceAdapter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progresso salvo com sucesso!')),
    );
  }

  /// Dados mockados para fallback quando ReadingService não tiver dados
  List<ReadingBook> _getMockBooks() {
    return [
      ReadingBook(
        id: '1',
        title: 'O Poder do Hábito',
        author: 'Charles Duhigg',
        totalPages: 300,
        currentPage: 150,
        theme: ReadingTheme.autoajuda,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        logs: [],
      ),
      ReadingBook(
        id: '2',
        title: 'A Tríade do Tempo',
        author: 'Christian Barbosa',
        totalPages: 200,
        currentPage: 80,
        theme: ReadingTheme.outros,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        logs: [],
      ),
      ReadingBook(
        id: '3',
        title: 'Dart for Beginners',
        author: 'John Smith',
        totalPages: 250,
        currentPage: 200,
        theme: ReadingTheme.outros,
        createdAt: DateTime.now(),
        logs: [],
      ),
    ];
  }
}
