import 'package:flutter/material.dart';

/// Temas de leitura
enum ReadingTheme {
  ficcaoCientifica('Ficção Científica'),
  terrorMisterio('Terror & Mistério'),
  romance('Romance'),
  suspenseThriller('Suspense/Thriller'),
  policialInvestigacao('Policial/Investigação'),
  trueCrime('True Crime'),
  fantasia('Fantasia'),
  aventura('Aventura'),
  guerraMilitar('Guerra/Militar'),
  biografiaAutobiografia('Biografia/Autobiografia'),
  autoajuda('Autoajuda'),
  outros('Outros');

  const ReadingTheme(this.name);
  final String name;

  /// Getter para compatibilidade com código que usa 'label'
  String get label => name;

  Color get color {
    switch (this) {
      case ReadingTheme.ficcaoCientifica:
        return const Color.fromARGB(255, 9, 119, 179);
      case ReadingTheme.terrorMisterio:
        return const Color(0xFF212121);
      case ReadingTheme.romance:
        return const Color(0xFFE91E63);
      case ReadingTheme.suspenseThriller:
        return const Color(0xFF311B92);
      case ReadingTheme.policialInvestigacao:
        return const Color(0xFF607D8B);
      case ReadingTheme.trueCrime:
        return const Color(0xFFB71C1C);
      case ReadingTheme.fantasia:
        return const Color(0xFF9C27B0);
      case ReadingTheme.aventura:
        return const Color(0xFF2E7D32);
      case ReadingTheme.guerraMilitar:
        return const Color(0xFF33691E);
      case ReadingTheme.biografiaAutobiografia:
        return const Color(0xFF795548);
      case ReadingTheme.autoajuda:
        return const Color(0xFFE65100);
      case ReadingTheme.outros:
        return const Color(0xFF9E9E9E);
    }
  }

  static ReadingTheme fromString(String? value) {
    if (value == null) return ReadingTheme.outros;
    return ReadingTheme.values.firstWhere(
      (theme) => theme.name == value,
      orElse: () => ReadingTheme.outros,
    );
  }
}

/// Log de leitura
class ReadingLog {
  final DateTime timestamp;
  final int pageNumber;
  final String? notes;

  ReadingLog({
    required this.timestamp,
    required this.pageNumber,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'pageNumber': pageNumber,
        'notes': notes,
      };

  factory ReadingLog.fromJson(Map<String, dynamic> json) => ReadingLog(
        timestamp: DateTime.parse(json['timestamp']),
        pageNumber: json['pageNumber'],
        notes: json['notes'],
      );
}

/// Livro de leitura
class ReadingBook {
  final String id;
  final String title;
  final String? author;
  final int totalPages;
  final int currentPage;
  final ReadingTheme theme;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<ReadingLog> logs;

  ReadingBook({
    required this.id,
    required this.title,
    this.author,
    required this.totalPages,
    this.currentPage = 0,
    required this.theme,
    required this.createdAt,
    this.completedAt,
    this.logs = const [],
  });

  bool get isCompleted => currentPage >= totalPages;
  double get progress => totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0.0;
  String get progressPercentage => '${(progress * 100).toInt()}%';

  /// Calcula data estimada de conclusão baseada no progresso atual
  DateTime? get estimatedCompletionDate {
    if (isCompleted || currentPage == 0) return null;
    
    final daysSinceStart = DateTime.now().difference(createdAt).inDays;
    if (daysSinceStart == 0) return null;
    
    final pagesPerDay = currentPage / daysSinceStart;
    if (pagesPerDay <= 0) return null;
    
    final remainingPages = totalPages - currentPage;
    final remainingDays = (remainingPages / pagesPerDay).ceil();
    
    return DateTime.now().add(Duration(days: remainingDays));
  }

  ReadingBook copyWith({
    String? id,
    String? title,
    String? author,
    int? totalPages,
    int? currentPage,
    ReadingTheme? theme,
    DateTime? createdAt,
    DateTime? completedAt,
    List<ReadingLog>? logs,
  }) {
    return ReadingBook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      logs: logs ?? this.logs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'totalPages': totalPages,
        'currentPage': currentPage,
        'theme': theme.name,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'logs': logs.map((log) => log.toJson()).toList(),
      };

  factory ReadingBook.fromJson(Map<String, dynamic> json) => ReadingBook(
        id: json['id'],
        title: json['title'],
        author: json['author'],
        totalPages: json['totalPages'],
        currentPage: json['currentPage'] ?? 0,
        theme: ReadingTheme.fromString(json['theme']),
        createdAt: DateTime.parse(json['createdAt']),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        logs: (json['logs'] as List<dynamic>?)
            ?.map((log) => ReadingLog.fromJson(log))
            .toList() ?? [],
      );
}
