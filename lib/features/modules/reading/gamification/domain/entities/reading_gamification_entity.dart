import 'package:isar/isar.dart';
import 'dart:convert';

part 'reading_gamification_entity.g.dart';

@collection
class ReadingGamificationEntity {
  Id id = Isar.autoIncrement;

  /// Lista de insígnias conquistadas (JSON)
  String earnedInsignias = '[]';

  /// Lista de medalhas conquistadas (JSON)
  String earnedMedalhas = '[]';

  /// Dias consecutivos de leitura
  int consecutiveDays = 0;

  /// Data da última leitura
  DateTime? lastReadingDate;

  /// Data de início do hábito
  DateTime? startDate;

  /// Data de criação do registro
  DateTime createdAt = DateTime.now();

  /// Data da última atualização
  DateTime updatedAt = DateTime.now();

  ReadingGamificationEntity();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'earnedInsignias': earnedInsignias,
      'earnedMedalhas': earnedMedalhas,
      'consecutiveDays': consecutiveDays,
      'lastReadingDate': lastReadingDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReadingGamificationEntity.fromJson(Map<String, dynamic> json) {
    final entity = ReadingGamificationEntity();
    entity.id = json['id'] ?? Isar.autoIncrement;
    entity.earnedInsignias = json['earnedInsignias'] ?? '[]';
    entity.earnedMedalhas = json['earnedMedalhas'] ?? '[]';
    entity.consecutiveDays = json['consecutiveDays'] ?? 0;
    entity.lastReadingDate = json['lastReadingDate'] != null ? DateTime.parse(json['lastReadingDate']) : null;
    entity.startDate = json['startDate'] != null ? DateTime.parse(json['startDate']) : null;
    entity.createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now();
    entity.updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now();
    return entity;
  }

  void touch() {
    updatedAt = DateTime.now();
  }

  List<String> get earnedInsigniasList {
    try {
      final List<dynamic> decoded = json.decode(earnedInsignias);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  set earnedInsigniasList(List<String> insignias) {
    earnedInsignias = json.encode(insignias);
    touch();
  }

  List<String> get earnedMedalhasList {
    try {
      final List<dynamic> decoded = json.decode(earnedMedalhas);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  set earnedMedalhasList(List<String> medalhas) {
    earnedMedalhas = json.encode(medalhas);
    touch();
  }
}
