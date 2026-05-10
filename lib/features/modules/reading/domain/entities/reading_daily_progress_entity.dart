import 'package:objectbox/objectbox.dart';

@Entity()
class ReadingDailyProgressEntity {
  @Id()
  int id = 0;

  /// Data da leitura (apenas dia, mês e ano)
  DateTime date;

  /// Número de páginas lidas neste dia
  int pagesRead;

  /// Número de minutos gastos lendo neste dia
  int minutesRead;

  /// ID do usuário (para suporte multiusuário)
  String userId;

  /// Timestamp de criação
  DateTime createdAt;

  /// Timestamp de última atualização
  DateTime updatedAt;

  ReadingDailyProgressEntity({
    required this.date,
    required this.pagesRead,
    required this.minutesRead,
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'pages_read': pagesRead,
      'minutes_read': minutesRead,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria a partir de Map
  factory ReadingDailyProgressEntity.fromMap(Map<String, dynamic> map) {
    return ReadingDailyProgressEntity(
      date: DateTime.parse(map['date'] as String),
      pagesRead: map['pages_read'] as int,
      minutesRead: map['minutes_read'] as int,
      userId: map['user_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Atualiza o timestamp de modificação
  void touch() {
    updatedAt = DateTime.now();
  }

  /// Obtém apenas a parte da data (sem hora)
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);
}
