import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Controller Riverpod para Reading
/// Substitui ChangeNotifier por StateNotifier
class ReadingController extends StateNotifier<ReadingState> {
  final ReadingService _service;
  
  ReadingController(this._service) : super(const ReadingState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final books = _service.books;
      final finishedBooks = books.where((book) => book.isCompleted).toList();
      final currentStreak = _service.currentStreak;
      
      state = state.copyWith(
        books: books,
        finishedBooks: finishedBooks,
        currentStreak: currentStreak,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addBook({
    required String title,
    required int totalPages,
    required ReadingTheme theme,
    String? author,
  }) async {
    try {
      await _service.addBook(
        title: title,
        totalPages: totalPages,
        theme: theme,
        author: author,
      );
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateProgress(String bookId, int currentPage) async {
    try {
      await _service.updateProgress(bookId, currentPage);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateBook({
    required String bookId,
    required String title,
    String? author,
    int? currentPage,
    int? totalPages,
    ReadingTheme? theme,
  }) async {
    try {
      final book = _service.books.firstWhere((b) => b.id == bookId);
      
      await _service.updateBook(
        bookId: bookId,
        title: title,
        author: author ?? book.author,
        totalPages: totalPages ?? book.totalPages,
        theme: theme ?? book.theme,
      );
      
      if (currentPage != null) {
        await _service.updateProgress(bookId, currentPage);
      }
      
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _service.deleteBook(bookId);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Estado do ReadingController
class ReadingState {
  final List<ReadingBook> books;
  final List<ReadingBook> finishedBooks;
  final int currentStreak;
  final bool isLoading;
  final String? error;

  const ReadingState({
    this.books = const [],
    this.finishedBooks = const [],
    this.currentStreak = 0,
    this.isLoading = false,
    this.error,
  });

  ReadingState copyWith({
    List<ReadingBook>? books,
    List<ReadingBook>? finishedBooks,
    int? currentStreak,
    bool? isLoading,
    String? error,
  }) {
    return ReadingState(
      books: books ?? this.books,
      finishedBooks: finishedBooks ?? this.finishedBooks,
      currentStreak: currentStreak ?? this.currentStreak,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Calcula estatísticas derivadas
  int get totalPagesRead {
    return books.fold(0, (sum, book) => sum + book.currentPage);
  }

  int get totalBooksRead => finishedBooks.length;

  double get averagePagesPerBook {
    if (books.isEmpty) return 0;
    return totalPagesRead / books.length;
  }
}

/// Provider para o ReadingController
final readingControllerProvider = StateNotifierProvider<ReadingController, ReadingState>((ref) {
  final service = ref.watch(readingServiceProvider);
  return ReadingController(service);
});
