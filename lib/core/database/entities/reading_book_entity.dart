import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';

@Entity()
class ReadingBookEntity {
  @Id()
  int id = 0;

  late String userId;
  late String title;
  late String author;
  late int totalPages;
  late int currentPage;
  
  // Armazenado como int para ObjectBox (enum não é suportado no construtor)
  late int themeIndex;
  
  // Transient - não armazenado no banco, converte int para enum
  @Transient()
  ReadingTheme get theme => ReadingTheme.values[themeIndex];
  
  // Setter para facilitar uso
  set theme(ReadingTheme value) => themeIndex = value.index;
  
  String? coverUrl;
  DateTime? startDate;
  DateTime? completedDate;
  bool isCompleted = false;
  String? notes;
  int? rating;
  late DateTime createdAt;
  late DateTime updatedAt;
  String? additionalData;

  // Construtor padrão necessário para ObjectBox
  ReadingBookEntity()
      : userId = '',
        title = '',
        author = '',
        totalPages = 0,
        currentPage = 0,
        themeIndex = 11, // ReadingTheme.outros.index = 11 (último item)
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

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
    final entity = ReadingBookEntity();
    entity.userId = userId;
    entity.title = title;
    entity.author = author;
    entity.totalPages = totalPages;
    entity.currentPage = currentPage;
    entity.themeIndex = theme.index;
    entity.coverUrl = coverUrl;
    entity.startDate = currentPage > 0 ? now : null;
    entity.createdAt = now;
    entity.updatedAt = now;
    return entity;
  }

  double get progress {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  double get progressPercentage => progress * 100;
  bool get isStarted => currentPage > 0;
  bool get isInProgress => isStarted && !isCompleted;

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
    final entity = ReadingBookEntity();
    entity.id = id;
    entity.userId = userId ?? this.userId;
    entity.title = title ?? this.title;
    entity.author = author ?? this.author;
    entity.totalPages = totalPages ?? this.totalPages;
    entity.currentPage = currentPage ?? this.currentPage;
    entity.themeIndex = theme?.index ?? themeIndex;
    entity.coverUrl = coverUrl ?? this.coverUrl;
    entity.startDate = startDate ?? this.startDate;
    entity.completedDate = completedDate ?? this.completedDate;
    entity.isCompleted = isCompleted ?? this.isCompleted;
    entity.notes = notes ?? this.notes;
    entity.rating = rating ?? this.rating;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    entity.additionalData = additionalData ?? this.additionalData;
    return entity;
  }

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

  ReadingBookEntity updateProgress(int newCurrentPage) {
    final now = DateTime.now();
    final clampedPage = newCurrentPage.clamp(0, totalPages);
    return copyWith(
      currentPage: clampedPage,
      startDate: startDate ?? (clampedPage > 0 ? now : startDate),
      updatedAt: now,
    );
  }
}
