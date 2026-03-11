import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:flutter/material.dart';

class BookTile extends StatelessWidget {
  final ReadingBook book;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const BookTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = book.theme.color;
    final isCompleted = book.isCompleted;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              isCompleted ? Border.all(color: Colors.green, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // "Capa" do livro (Topo colorido)
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    book.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            // Barra de progresso e info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (book.author != null)
                      Text(
                        book.author!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: book.progress,
                          backgroundColor:
                              const Color(0xFF0D47A1).withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0D47A1)),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${book.currentPage}/${book.totalPages}',
                              style: const TextStyle(fontSize: 10),
                            ),
                            Text(
                              book.progressPercentage,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (book.estimatedCompletionDate != null &&
                            !isCompleted)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Estimativa: ${_formatDate(book.estimatedCompletionDate!)}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
