import 'package:disciplinum/features/modules/reading/presentation/widgets/book_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';

class FinishedBooksScreen extends ConsumerWidget {
  const FinishedBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livros Já Lidos 🏆'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              final service = ref.watch(readingServiceProvider);
              final completedBooks = service.completedBooks;

              if (completedBooks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined,
                          size: 60,
                          color: colorScheme.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        "Nenhum livro concluído ainda.",
                        style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Termine sua primeira leitura!",
                        style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: completedBooks.length,
                itemBuilder: (context, index) {
                  final book = completedBooks[index];
                  // Reutiliza o BookTile, mas sem ação de clique (ou apenas visualização)
                  return BookTile(
                    book: book,
                    onTap: () {
                      // Pode abrir detalhes se quiser, mas por enquanto nada
                    },
                    onLongPress: () {},
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
