import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/features/modules/reading/presentation/widgets/add_book_dialog.dart';
import 'package:disciplinum/features/modules/reading/presentation/widgets/book_tile.dart';

import 'package:disciplinum/features/modules/reading/presentation/widgets/book_details_dialog.dart';
import 'package:disciplinum/features/modules/reading/presentation/screens/finished_books_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MyShelfScreen extends StatelessWidget {
  const MyShelfScreen({super.key});

  void _showBookOptions(BuildContext context, dynamic book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                book.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  Icon(Icons.edit_outlined, color: const Color(0xFF6366F1)),
              title: const Text('Editar livro'),
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(ctx);
                AddBookDialog.show(context, bookToEdit: book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Excluir livro',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(ctx);
                _confirmDelete(context, book);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir livro?'),
        content: Text(
          'Tem certeza que deseja excluir "${book.title}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final service =
                  Provider.of<ReadingService>(context, listen: false);
              service.deleteBook(book.id);
              Navigator.pop(ctx);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Removido Scaffold e FAB para integrar com ReadingScreen
    return Consumer<ReadingService>(
      builder: (context, service, child) {
        // Filtra apenas livros NÃO concluídos para a estante principal
        final activeBooks = service.books.where((b) => !b.isCompleted).toList();
        final hasCompletedBooks = service.completedBooks.isNotEmpty;

        if (activeBooks.isEmpty && !hasCompletedBooks) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Sua estante está vazia.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Streak Header
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("🔥 Sequência atual: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${service.currentStreak} dias",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orange)),
                  const SizedBox(width: 8),
                  if (service.hasDiamond)
                    const Text("💎")
                  else if (service.hasGold)
                    const Text("🥇")
                  else if (service.hasSilver)
                    const Text("🥈")
                  else if (service.hasBronze)
                    const Text("🥉"),
                ],
              ),
            ),

            // Botão para ver livros concluídos (se houver)
            if (hasCompletedBooks)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Ver Livros Já Lidos'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FinishedBooksScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),

            Expanded(
              child: activeBooks.isEmpty
                  ? Center(
                      child: Text("Estante ativa vazia. Adicione um livro!",
                          style: TextStyle(color: Colors.grey)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 livros por linha
                        childAspectRatio: 0.65, // Proporção capa
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: activeBooks.length,
                      itemBuilder: (context, index) {
                        final book = activeBooks[index];
                        return BookTile(
                          book: book,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => BookDetailsDialog(book: book),
                            );
                          },
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            _showBookOptions(context, book);
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
}
