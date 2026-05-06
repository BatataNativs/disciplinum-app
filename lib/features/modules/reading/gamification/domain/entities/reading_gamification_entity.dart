import 'package:objectbox/objectbox.dart';
import 'dart:convert';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_module_state.dart';

@Entity()
class ReadingGamificationEntity {
  @Id()
  int id = 0;

  String earnedInsignias = '[]';
  String earnedMedalhas = '[]';
  int consecutiveDays = 0;
  DateTime? lastReadingDate;
  DateTime? startDate;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isModuleActive = false;

  ReadingGamificationEntity();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'earned_insignias': earnedInsigniasList,
      'earned_medalhas': earnedMedalhasList,
      'consecutive_days': consecutiveDays,
      'last_reading_date': lastReadingDate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_module_active': isModuleActive,
    };
  }

  factory ReadingGamificationEntity.fromJson(Map<String, dynamic> json) {
    final entity = ReadingGamificationEntity();
    entity.id = json['id'] ?? 0;
    entity.earnedInsignias = json['earnedInsignias'] ?? '[]';
    entity.earnedMedalhas = json['earnedMedalhas'] ?? '[]';
    entity.consecutiveDays = json['consecutiveDays'] ?? 0;
    entity.lastReadingDate = json['lastReadingDate'] != null ? DateTime.parse(json['lastReadingDate']) : null;
    entity.startDate = json['startDate'] != null ? DateTime.parse(json['startDate']) : null;
    entity.createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now();
    entity.updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now();
    entity.isModuleActive = json['isModuleActive'] ?? json['isActive'] ?? false;
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

  /// Construtor a partir do ReadingModuleState
  factory ReadingGamificationEntity.fromModuleState(ReadingModuleState moduleState) {
    final entity = ReadingGamificationEntity();
    entity.earnedInsignias = json.encode(moduleState.earnedInsignias);
    entity.earnedMedalhas = json.encode(moduleState.earnedMedalhas);
    entity.consecutiveDays = moduleState.consecutiveDays;
    entity.lastReadingDate = moduleState.lastReadingDate;
    entity.startDate = moduleState.startDate;
    entity.updatedAt = moduleState.updatedAt;
    entity.isModuleActive = moduleState.isModuleActive;
    return entity;
  }

  /// Converte para ReadingModuleState
  ReadingModuleState toModuleState() {
    return ReadingModuleState(
      earnedInsignias: earnedInsigniasList,
      earnedMedalhas: earnedMedalhasList,
      consecutiveDays: consecutiveDays,
      lastReadingDate: lastReadingDate,
      startDate: startDate,
      updatedAt: updatedAt,
      isModuleActive: isModuleActive,
    );
  }
}
