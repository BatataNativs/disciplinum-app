import 'package:disciplinum/services/9_reading/reading_service.dart';
import 'package:disciplinum/screens/modules/9_reading/widgets/add_book_dialog.dart';
import 'package:disciplinum/screens/modules/9_reading/widgets/book_tile.dart';

import 'package:disciplinum/screens/modules/9_reading/widgets/book_details_dialog.dart';
import 'package:disciplinum/screens/modules/9_reading/finished_books_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyShelfScreen extends StatelessWidget {
  const MyShelfScreen({super.key});

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
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => showDialog(
                      context: context, builder: (_) => const AddBookDialog()),
                  child: const Text("Adicionar Primeiro Livro"),
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
                            // Opção de editar/excluir (já tem no update dialog, mas pode ter aqui tb)
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
