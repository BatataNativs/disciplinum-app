import 'package:flutter/material.dart';

/// Temas disponíveis para os livros, com suas cores específicas.
enum ReadingTheme {
  ficcaoCientifica,
  terrorMisterio,
  romance,
  suspenseThriller,
  policialInvestigacao,
  trueCrime,
  fantasia,
  aventura,
  guerraMilitar,
  biografiaAutobiografia,
  autoajuda,
  outros, // Fallback
}

extension ReadingThemeExtension on ReadingTheme {
  String get label {
    switch (this) {
      case ReadingTheme.ficcaoCientifica:
        return 'Ficção Científica';
      case ReadingTheme.terrorMisterio:
        return 'Terror / Mistério';
      case ReadingTheme.romance:
        return 'Romance';
      case ReadingTheme.suspenseThriller:
        return 'Suspense / Thriller';
      case ReadingTheme.policialInvestigacao:
        return 'Policial / Investigação (ficção)';
      case ReadingTheme.trueCrime:
        return 'True Crime (casos reais)';
      case ReadingTheme.fantasia:
        return 'Fantasia';
      case ReadingTheme.aventura:
        return 'Aventura';
      case ReadingTheme.guerraMilitar:
        return 'Guerra / Militar';
      case ReadingTheme.biografiaAutobiografia:
        return 'Biografia / Autobiografia';
      case ReadingTheme.autoajuda:
        return 'Autoajuda / Desenv. Pessoal';
      case ReadingTheme.outros:
        return 'Outros';
    }
  }

  Color get color {
    switch (this) {
      case ReadingTheme.ficcaoCientifica:
        return const Color(0xFF00BCD4);
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
        return const Color(0xFF4CAF50);
      case ReadingTheme.guerraMilitar:
        return const Color(0xFF33691E);
      case ReadingTheme.biografiaAutobiografia:
        return const Color(0xFF795548);
      case ReadingTheme.autoajuda:
        return const Color(0xFFFF9800);
      case ReadingTheme.outros:
        return const Color(0xFF9E9E9E);
    }
  }

  static ReadingTheme fromString(String? value) {
    if (value == null) return ReadingTheme.outros;
    return ReadingTheme.values.firstWhere(
      (e) => e.toString() == 'ReadingTheme.$value' || e.name == value,
      orElse: () => ReadingTheme.outros,
    );
  }
}

/// Registro de leitura (log)
class ReadingLog {
  final DateTime date;
  final int pageNumber; // Página onde parou (absoluto)

  ReadingLog({required this.date, required this.pageNumber});

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'page_number': pageNumber,
    };
  }

  factory ReadingLog.fromJson(Map<String, dynamic> json) {
    return ReadingLog(
      date: DateTime.parse(json['date']),
      pageNumber: json['page_number'] ?? 0,
    );
  }
}

class ReadingBook {
  final String id;
  final String title;
  final String? author;
  final int totalPages;
  int currentPage;
  final ReadingTheme theme;
  final DateTime createdAt;
  DateTime? completedAt;
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
  double get progress =>
      totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0.0;
  String get progressPercentage => '${(progress * 100).toInt()}%';

  DateTime? get estimatedCompletionDate {
    if (isCompleted) {
      return null;
    }
    if (logs.length < 2) {
      return null; // Precisa de pelo menos 2 pontos para calcular ritmo
    }

    // Ordena logs
    final sortedLogs = List<ReadingLog>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    final firstLog = sortedLogs.first;
    final lastLog = sortedLogs.last;

    final daysDiff = lastLog.date.difference(firstLog.date).inDays;

    // Se tudo foi lido no mesmo dia (diff 0), usa 1 dia como base para não dividir por zero
    // ou se a diferença for muito pequena, o cálculo pode ser impreciso.
    final effectiveDays = daysDiff > 0 ? daysDiff : 1;

    final pagesReadInInterval = lastLog.pageNumber - firstLog.pageNumber;

    if (pagesReadInInterval <= 0) {
      return null;
    }

    final dailyPace = pagesReadInInterval / effectiveDays;

    final pagesRemaining = totalPages - currentPage;
    final daysRemaining = (pagesRemaining / dailyPace).ceil();

    return DateTime.now().add(Duration(days: daysRemaining));
  }

  ReadingBook copyWith({
    String? title,
    String? author,
    int? totalPages,
    int? currentPage,
    ReadingTheme? theme,
    DateTime? completedAt,
    List<ReadingLog>? logs,
  }) {
    return ReadingBook(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      theme: theme ?? this.theme,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      logs: logs ?? this.logs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'total_pages': totalPages,
      'current_page': currentPage,
      'theme': theme.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'logs': logs.map((l) => l.toJson()).toList(),
    };
  }

  factory ReadingBook.fromJson(Map<String, dynamic> json) {
    return ReadingBook(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      totalPages: json['total_pages'] ?? 0,
      currentPage: json['current_page'] ?? 0,
      theme: ReadingThemeExtension.fromString(json['theme']),
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      logs: (json['logs'] as List?)
              ?.map((l) => ReadingLog.fromJson(l))
              .toList() ??
          [],
    );
  }
}
