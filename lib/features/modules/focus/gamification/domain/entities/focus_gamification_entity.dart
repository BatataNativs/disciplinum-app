import 'package:objectbox/objectbox.dart';
import 'dart:convert';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_module_state.dart';

@Entity()
class FocusGamificationEntity {
  @Id()
  int id = 0;

  String earnedInsignias = '[]';
  String earnedMedalhas = '[]';
  int disciplinumCount = 0;
  int totalFocusMinutes = 0;
  int completedSessions = 0;
  int maxStreakDays = 0;
  int currentStreakDays = 0;
  DateTime? lastFocusSession;
  DateTime? startDate;
  String blockedApps = '[]';
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  FocusGamificationEntity();

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

  List<String> get blockedAppsList {
    try {
      final List<dynamic> decoded = json.decode(blockedApps);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  set blockedAppsList(List<String> apps) {
    blockedApps = json.encode(apps);
    touch();
  }
}
