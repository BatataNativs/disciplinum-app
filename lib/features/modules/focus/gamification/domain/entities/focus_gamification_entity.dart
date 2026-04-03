import 'package:isar/isar.dart';
import 'dart:convert';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_module_state.dart';

part 'focus_gamification_entity.g.dart';

/// Entidade Isar para gamificação do módulo Focus
/// Armazena estado completo de gamificação com persistência local
@collection
class FocusGamificationEntity {
  /// ID único do registro
  Id id = Isar.autoIncrement;

  /// Lista de insígnias conquistadas (JSON)
  String earnedInsignias = '[]';

  /// Lista de medalhas conquistadas (JSON)
  String earnedMedalhas = '[]';

  /// Contador de insígnias Disciplinum conquistadas
  int disciplinumCount = 0;

  /// Tempo total de foco (em minutos)
  int totalFocusMinutes = 0;

  /// Número de sessões de foco completadas
  int completedSessions = 0;

  /// Maior sequência de dias com foco
  int maxStreakDays = 0;

  /// Sequência atual de dias com foco
  int currentStreakDays = 0;

  /// Data da última sessão de foco
  DateTime? lastFocusSession;

  /// Data de início da jornada de foco
  DateTime? startDate;

  /// Lista de apps bloqueados durante foco (JSON)
  String blockedApps = '[]';

  /// Data de criação do registro
  DateTime createdAt = DateTime.now();

  /// Data da última atualização
  DateTime updatedAt = DateTime.now();

  /// Construtor padrão
  FocusGamificationEntity();

  /// Converte para FocusModuleState
  FocusModuleState toModuleState() {
    return FocusModuleState(
      earnedInsignias: earnedInsigniasList,
      earnedMedalhas: earnedMedalhasList,
      sessionsCompleted: completedSessions,
      totalFocusMinutes: totalFocusMinutes,
      currentStreakDays: currentStreakDays,
      longestStreakDays: maxStreakDays,
      currentStageId: 'bronze',
      unlockedAchievements: blockedAppsList,
    );
  }

  /// Construtor a partir do FocusModuleState
  factory FocusGamificationEntity.fromModuleState(FocusModuleState moduleState) {
    final entity = FocusGamificationEntity();
    entity.earnedInsignias = json.encode(moduleState.earnedInsignias);
    entity.earnedMedalhas = json.encode(moduleState.earnedMedalhas);
    entity.totalFocusMinutes = moduleState.totalFocusMinutes;
    entity.completedSessions = moduleState.sessionsCompleted;
    entity.maxStreakDays = moduleState.longestStreakDays;
    entity.currentStreakDays = moduleState.currentStreakDays;
    entity.blockedApps = json.encode(moduleState.unlockedAchievements);
    entity.updatedAt = moduleState.updatedAt;
    return entity;
  }

  /// Converte para JSON (para compatibilidade)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'earnedInsignias': earnedInsignias,
      'earnedMedalhas': earnedMedalhas,
      'disciplinumCount': disciplinumCount,
      'totalFocusMinutes': totalFocusMinutes,
      'completedSessions': completedSessions,
      'maxStreakDays': maxStreakDays,
      'currentStreakDays': currentStreakDays,
      'lastFocusSession': lastFocusSession?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'blockedApps': blockedApps,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converte de JSON (para compatibilidade)
  factory FocusGamificationEntity.fromJson(Map<String, dynamic> json) {
    final entity = FocusGamificationEntity();
    entity.earnedInsignias = json['earnedInsignias'] ?? '[]';
    entity.earnedMedalhas = json['earnedMedalhas'] ?? '[]';
    entity.disciplinumCount = json['disciplinumCount'] ?? 0;
    entity.totalFocusMinutes = json['totalFocusMinutes'] ?? 0;
    entity.completedSessions = json['completedSessions'] ?? 0;
    entity.maxStreakDays = json['maxStreakDays'] ?? 0;
    entity.currentStreakDays = json['currentStreakDays'] ?? 0;
    entity.lastFocusSession = json['lastFocusSession'] != null 
        ? DateTime.parse(json['lastFocusSession']) 
        : null;
    entity.startDate = json['startDate'] != null 
        ? DateTime.parse(json['startDate']) 
        : null;
    entity.blockedApps = json['blockedApps'] ?? '[]';
    entity.createdAt = json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now();
    entity.updatedAt = json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt']) 
        : DateTime.now();
    return entity;
  }

  /// Atualiza timestamp de modificação
  void touch() {
    updatedAt = DateTime.now();
  }

  /// Obtém lista de insígnias como `List<String>`
  List<String> get earnedInsigniasList {
    try {
      final List<dynamic> decoded = json.decode(earnedInsignias);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Define lista de insígnias
  set earnedInsigniasList(List<String> insignias) {
    earnedInsignias = json.encode(insignias);
    touch();
  }

  /// Obtém lista de medalhas como `List<String>`
  List<String> get earnedMedalhasList {
    try {
      final List<dynamic> decoded = json.decode(earnedMedalhas);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Define lista de medalhas
  set earnedMedalhasList(List<String> medalhas) {
    earnedMedalhas = json.encode(medalhas);
    touch();
  }

  /// Obtém lista de apps bloqueados como `List<String>`
  List<String> get blockedAppsList {
    try {
      final List<dynamic> decoded = json.decode(blockedApps);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Define lista de apps bloqueados
  set blockedAppsList(List<String> apps) {
    blockedApps = json.encode(apps);
    touch();
  }
}
