import 'package:objectbox/objectbox.dart';
import 'dart:convert';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_module_state.dart';

@Entity()
class SmokingGamificationEntity {
  @Id()
  int id = 0;

  String earnedInsignias = '[]';
  String earnedMedalhas = '[]';
  int consecutivePositiveDays = 0;
  int disciplinumCount = 0;
  DateTime? lastPositiveCheckIn;
  DateTime? startDate;
  double dailyCost = 0.0;
  double packCost = 0.0;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  SmokingGamificationEntity();

  factory SmokingGamificationEntity.fromModuleState(SmokingModuleState moduleState) {
    final entity = SmokingGamificationEntity();
    entity.earnedInsignias = json.encode(moduleState.earnedInsignias);
    entity.earnedMedalhas = json.encode(moduleState.earnedMedalhas);
    entity.consecutivePositiveDays = moduleState.consecutivePositiveDays;
    entity.disciplinumCount = moduleState.disciplinumCount;
    entity.lastPositiveCheckIn = moduleState.lastPositiveCheckIn;
    entity.startDate = moduleState.startDate;
    entity.dailyCost = moduleState.dailyCost;
    entity.packCost = moduleState.packCost;
    entity.updatedAt = moduleState.updatedAt;
    return entity;
  }

  SmokingModuleState toModuleState() {
    return SmokingModuleState(
      earnedInsignias: earnedInsigniasList,
      earnedMedalhas: earnedMedalhasList,
      consecutivePositiveDays: consecutivePositiveDays,
      disciplinumCount: disciplinumCount,
      lastPositiveCheckIn: lastPositiveCheckIn,
      startDate: startDate,
      dailyCost: dailyCost,
      packCost: packCost,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'earnedInsignias': earnedInsignias,
      'earnedMedalhas': earnedMedalhas,
      'consecutivePositiveDays': consecutivePositiveDays,
      'disciplinumCount': disciplinumCount,
      'lastPositiveCheckIn': lastPositiveCheckIn?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'dailyCost': dailyCost,
      'packCost': packCost,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SmokingGamificationEntity.fromJson(Map<String, dynamic> json) {
    final entity = SmokingGamificationEntity();
    entity.id = json['id'] ?? 0;
    entity.earnedInsignias = json['earnedInsignias'] ?? '[]';
    entity.earnedMedalhas = json['earnedMedalhas'] ?? '[]';
    entity.consecutivePositiveDays = json['consecutivePositiveDays'] ?? 0;
    entity.disciplinumCount = json['disciplinumCount'] ?? 0;
    entity.lastPositiveCheckIn = json['lastPositiveCheckIn'] != null
        ? DateTime.parse(json['lastPositiveCheckIn'])
        : null;
    entity.startDate = json['startDate'] != null
        ? DateTime.parse(json['startDate'])
        : null;
    entity.dailyCost = (json['dailyCost'] ?? 0.0).toDouble();
    entity.packCost = (json['packCost'] ?? 0.0).toDouble();
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

  bool hasInsignia(String insigniaId) {
    return earnedInsigniasList.contains(insigniaId);
  }

  void addInsignia(String insigniaId) {
    final list = earnedInsigniasList;
    if (!list.contains(insigniaId)) {
      list.add(insigniaId);
      earnedInsigniasList = list;
      if (insigniaId == 'disciplinum') {
        disciplinumCount++;
      }
    }
  }

  void removeInsignia(String insigniaId) {
    final list = earnedInsigniasList;
    list.remove(insigniaId);
    earnedInsigniasList = list;
    if (insigniaId == 'disciplinum' && disciplinumCount > 0) {
      disciplinumCount--;
    }
  }

  bool hasMedalha(String medalhaId) {
    return earnedMedalhasList.contains(medalhaId);
  }

  void addMedalha(String medalhaId) {
    final list = earnedMedalhasList;
    if (!list.contains(medalhaId)) {
      list.add(medalhaId);
      earnedMedalhasList = list;
    }
  }

  void removeMedalha(String medalhaId) {
    final list = earnedMedalhasList;
    list.remove(medalhaId);
    earnedMedalhasList = list;
  }

  void reset() {
    earnedInsigniasList = [];
    earnedMedalhasList = [];
    consecutivePositiveDays = 0;
    disciplinumCount = 0;
    lastPositiveCheckIn = null;
    startDate = null;
    touch();
  }

  void resetInsignias() {
    earnedInsigniasList = [];
    disciplinumCount = 0;
    touch();
  }

  void resetMedalhas() {
    earnedMedalhasList = [];
    touch();
  }

  int getTotalDaysWithoutSmoking() {
    if (startDate == null) return 0;
    return DateTime.now().difference(startDate!).inDays;
  }

  double getTotalMoneySaved() {
    return dailyCost * consecutivePositiveDays;
  }

  int getPacksSaved() {
    if (packCost <= 0) return 0;
    return (getTotalMoneySaved() / packCost).floor();
  }

  bool get isInStreak => consecutivePositiveDays > 0;
  bool get hasSignificantStreak => consecutivePositiveDays >= 7;

  String getUserLevel() {
    if (disciplinumCount >= 4) return 'Mestre';
    if (disciplinumCount >= 3) return 'Expert';
    if (disciplinumCount >= 2) return 'Avançado';
    if (disciplinumCount >= 1) return 'Intermediário';
    if (consecutivePositiveDays >= 10) return 'Dedicado';
    if (consecutivePositiveDays >= 5) return 'Iniciante';
    return 'Novato';
  }

  bool hasRecentAchievements() {
    if (lastPositiveCheckIn == null) return false;
    final daysSinceLastCheckIn = DateTime.now().difference(lastPositiveCheckIn!).inDays;
    return daysSinceLastCheckIn <= 7;
  }

  @override
  String toString() {
    return 'SmokingGamificationEntity('
        'id: $id, '
        'consecutiveDays: $consecutivePositiveDays, '
        'insignias: ${earnedInsigniasList.length}, '
        'medalhas: ${earnedMedalhasList.length}, '
        'disciplinum: $disciplinumCount, '
        'level: ${getUserLevel()})';
  }
}
