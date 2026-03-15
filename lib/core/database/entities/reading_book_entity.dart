import 'package:isar/isar.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';

part 'reading_book_entity.g.dart';

/// Entidade para armazenar livros de leitura no Isar
@collection
class ReadingBookEntity {
  /// ID único do registro
  Id id = Isar.autoIncrement;

  /// ID do usuário dono do livro
  final String userId;

  /// Título do livro
  final String title;

  /// Autor do livro
  final String author;

  /// Número total de páginas
  final int totalPages;

  /// Página atual
  final int currentPage;

  /// Tema do livro
  @enumerated
  final ReadingTheme theme;

  /// URL da capa (opcional)
  final String? coverUrl;

  /// Data de início da leitura
  final DateTime? startDate;

  /// Data de conclusão (se concluído)
  final DateTime? completedDate;

  /// Se o livro está concluído
  final bool isCompleted;

  /// Notas do usuário
  final String? notes;

  /// Avaliação (1-5 estrelas)
  final int? rating;

  /// Data de criação do registro
  final DateTime createdAt;

  /// Data da última atualização
  final DateTime updatedAt;

  /// Dados adicionais em formato JSON
  final String? additionalData;

  ReadingBookEntity({
    required this.userId,
    required this.title,
    required this.author,
    required this.totalPages,
    required this.currentPage,
    required this.theme,
    this.coverUrl,
    this.startDate,
    this.completedDate,
    this.isCompleted = false,
    this.notes,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  /// Cria um ReadingBookEntity a partir do zero
  factory ReadingBookEntity.create({
    required String userId,
    required String title,
    required String author,
    required int totalPages,
    required ReadingTheme theme,
    int currentPage = 0,
    String? coverUrl,
  }) {
    final now = DateTime.now();
    return ReadingBookEntity(
      userId: userId,
      title: title,
      author: author,
      totalPages: totalPages,
      currentPage: currentPage,
      theme: theme,
      coverUrl: coverUrl,
      startDate: currentPage > 0 ? now : null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Calcula o progresso de leitura (0.0 a 1.0)
  double get progress {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  /// Calcula o progresso em porcentagem (0 a 100)
  double get progressPercentage => progress * 100;

  /// Verifica se o livro foi iniciado
  bool get isStarted => currentPage > 0;

  /// Verifica se o livro está em andamento
  bool get isInProgress => isStarted && !isCompleted;

  /// Cria uma cópia com valores atualizados
  ReadingBookEntity copyWith({
    String? userId,
    String? title,
    String? author,
    int? totalPages,
    int? currentPage,
    ReadingTheme? theme,
    String? coverUrl,
    DateTime? startDate,
    DateTime? completedDate,
    bool? isCompleted,
    String? notes,
    int? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? additionalData,
  }) {
    return ReadingBookEntity(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      theme: theme ?? this.theme,
      coverUrl: coverUrl ?? this.coverUrl,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// Marca como concluído
  ReadingBookEntity markAsCompleted({int? rating, String? notes}) {
    final now = DateTime.now();
    return copyWith(
      isCompleted: true,
      completedDate: now,
      currentPage: totalPages,
      rating: rating,
      notes: notes,
      updatedAt: now,
    );
  }

  /// Atualiza o progresso de leitura
  ReadingBookEntity updateProgress(int newCurrentPage) {
    final now = DateTime.now();
    final clampedPage = newCurrentPage.clamp(0, totalPages);
    
    return copyWith(
      currentPage: clampedPage,
      startDate: startDate ?? (clampedPage > 0 ? now : startDate),
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'ReadingBookEntity('
        'id: $id, '
        'userId: $userId, '
        'title: $title, '
        'author: $author, '
        'totalPages: $totalPages, '
        'currentPage: $currentPage, '
        'theme: $theme, '
        'coverUrl: $coverUrl, '
        'startDate: $startDate, '
        'completedDate: $completedDate, '
        'isCompleted: $isCompleted, '
        'notes: $notes, '
        'rating: $rating, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'additionalData: $additionalData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingBookEntity &&
        other.userId == userId &&
        other.title == title &&
        other.author == author &&
        other.totalPages == totalPages &&
        other.currentPage == currentPage &&
        other.theme == theme &&
        other.coverUrl == coverUrl &&
        other.startDate == startDate &&
        other.completedDate == completedDate &&
        other.isCompleted == isCompleted &&
        other.notes == notes &&
        other.rating == rating &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.additionalData == additionalData;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        title.hashCode ^
        author.hashCode ^
        totalPages.hashCode ^
        currentPage.hashCode ^
        theme.hashCode ^
        coverUrl.hashCode ^
        startDate.hashCode ^
        completedDate.hashCode ^
        isCompleted.hashCode ^
        notes.hashCode ^
        rating.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        additionalData.hashCode;
  }
}
