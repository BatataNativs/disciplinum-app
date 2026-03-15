import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:disciplinum/core/storage/local_storage_service.dart';

/// Adapter para compatibilizar ReadingService com injeção de dependências do Riverpod
/// 
/// Este adapter permite que o ReadingService existente continue funcionando
/// enquanto recebe as dependências injetadas pelo Riverpod
class ReadingServiceAdapter {
  final LocalStorageService _localStorage;
  final ReadingService _originalService;

  ReadingServiceAdapter(this._localStorage, this._originalService);

  // Wrapper methods que usam as dependências injetadas
  Future<void> addBookWithInjection({
    required String title,
    required int totalPages,
    required ReadingTheme theme,
    String? author,
  }) async {
    // Implementar usando as dependências injetadas
    await _originalService.addBook(
      title: title,
      totalPages: totalPages,
      theme: theme,
      author: author,
    );
    
    // Log da operação
    _localStorage.save('reading_adapter', 'Book added: $title');
  }

  Future<void> updateBookWithInjection({
    required String bookId,
    required String title,
    String? author,
    required int totalPages,
    required ReadingTheme theme,
  }) async {
    // Implementar usando as dependências injetadas
    await _originalService.updateBook(
      bookId: bookId,
      title: title,
      author: author,
      totalPages: totalPages,
      theme: theme,
    );
    
    // Log da operação
    _localStorage.save('reading_adapter', 'Book updated: $title');
  }

  /// Obtém livros ativos do ReadingService
  List<ReadingBook> getActiveBooks() {
    try {
      // Usar o getter books do ReadingService para obter livros ativos
      return _originalService.books;
    } catch (e) {
      // Em caso de erro, retorna lista vazia
      return <ReadingBook>[];
    }
  }

  /// Salva progresso de leitura
  Future<void> saveReadingProgress({
    required String bookId,
    required int currentPage,
  }) async {
    try {
      // Usar o método updateProgress do ReadingService
      await _originalService.updateProgress(bookId, currentPage);
      _localStorage.save('reading_adapter', 'Progress saved for book: $bookId');
    } catch (e) {
      // Log de erro
      _localStorage.save('reading_adapter', 'Error saving progress: $e');
    }
  }

  Future<void> updateProgressWithInjection(String bookId, int newPageCount) async {
    await _originalService.updateProgress(bookId, newPageCount);
    
    // Log da operação
    _localStorage.save('reading_adapter', 'Progress updated: $bookId -> $newPageCount');
  }

  Future<void> deleteBookWithInjection(String bookId) async {
    await _originalService.deleteBook(bookId);
    _localStorage.save('reading_adapter', 'Book deleted: $bookId');
  }

  // Métodos auxiliares para integração com Riverpod
  Future<Map<String, dynamic>> getReadingStats() async {
    final books = _originalService.books;
    
    return {
      'total_books': books.length,
      'completed_books': books.where((book) => book.currentPage >= book.totalPages).length,
      'total_pages': books.fold<int>(0, (sum, book) => sum + book.totalPages),
      'read_pages': books.fold<int>(0, (sum, book) => sum + book.currentPage),
      'average_progress': books.isEmpty ? 0.0 : 
          (books.fold<int>(0, (sum, book) => sum + book.currentPage) / 
           books.fold<int>(0, (sum, book) => sum + book.totalPages)) * 100,
    };
  }

  Future<void> syncWithCloud() async {
    try {
      _localStorage.save('reading_adapter', 'Starting cloud sync');
      
      // Simulação de sincronização com backend
      await Future.delayed(const Duration(seconds: 1));
      
      _localStorage.save('reading_adapter', 'Cloud sync completed');
    } catch (e) {
      _localStorage.save('reading_adapter', 'Cloud sync error: $e');
    }
  }
}
