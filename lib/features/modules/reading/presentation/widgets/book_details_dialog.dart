import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/shared/widgets/reading/update_progress_dialog.dart';
import 'package:disciplinum/shared/widgets/common/glowing_button.dart';
import 'package:disciplinum/shared/widgets/cards/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookDetailsDialog extends StatelessWidget {
  final ReadingBook book;

  const BookDetailsDialog({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: NeonCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com Ícone e Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: book.theme.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.book, color: book.theme.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (book.author != null)
                        Text(
                          book.author!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                )
              ],
            ),
            const SizedBox(height: 24),

            // Informações de Progresso
            _buildInfoRow(
              isDark,
              icon: Icons.pages,
              label: 'Páginas',
              value: '${book.currentPage} / ${book.totalPages}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              isDark,
              icon: Icons.percent,
              label: 'Progresso',
              value: book.progressPercentage,
            ),
            const SizedBox(height: 12),
            if (book.estimatedCompletionDate != null && !book.isCompleted)
              _buildInfoRow(
                isDark,
                icon: Icons.calendar_today,
                label: 'Estimativa',
                value:
                    "${book.estimatedCompletionDate!.day}/${book.estimatedCompletionDate!.month}",
                color: Colors.amber,
              ),

            const SizedBox(height: 32),

            // Botão "Marcador de Livros"
            GlowingButton(
              text: 'Marcador de Livros',
              icon: Icons.bookmark_add,
              color: const Color(0xFF6366F1),
              onPressed: () {
                Navigator.pop(context); // Fecha o detalhes
                showDialog(
                  context: context,
                  builder: (_) => UpdateProgressDialog(
                    book: book,
                    onUpdate: (updatedBook) {
                      // Implementar atualização
                      final service = Provider.of<ReadingService>(context, listen: false);
                      service.updateBook(
                        bookId: updatedBook.id,
                        title: updatedBook.title,
                        author: updatedBook.author,
                        totalPages: updatedBook.totalPages,
                        theme: updatedBook.theme,
                      );
                      
                      // Se precisar atualizar o progresso da página atual
                      if (updatedBook.currentPage != book.currentPage) {
                        service.updateProgress(updatedBook.id, updatedBook.currentPage);
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(bool isDark,
      {required IconData icon,
      required String label,
      required String value,
      Color? color}) {
    final textColor = color ?? (isDark ? Colors.white : Colors.black87);
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
