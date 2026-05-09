import 'package:objectbox/objectbox.dart';
import 'dart:convert';

@Entity()
class DigitalDetoxGamificationEntity {
  @Id()
  int id = 0;

  String userId;
  int currentStreak = 0;
  int longestStreak = 0;
  int totalDisciplinedDays = 0;
  DateTime? lastDisciplinedDate;
  int sevenDayCycle = 0;
  DateTime? cycleStartDate;
  String earnedInsignias = '[]';
  String earnedMedalhas = '[]';
  DateTime? cycle30StartDate;
  int daysInCurrent30DayCycle = 0;
  bool isModuleActive = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  DigitalDetoxGamificationEntity({
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalDisciplinedDays = 0,
    this.lastDisciplinedDate,
    this.sevenDayCycle = 0,
    this.cycleStartDate,
    this.earnedInsignias = '[]',
    this.earnedMedalhas = '[]',
    this.cycle30StartDate,
    this.daysInCurrent30DayCycle = 0,
    this.isModuleActive = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  List<String> get earnedInsigniasList => 
      earnedInsignias.isEmpty ? [] : jsonDecode(earnedInsignias).cast<String>();
      
  List<String> get earnedMedalhasList => 
      earnedMedalhas.isEmpty ? [] : jsonDecode(earnedMedalhas).cast<String>();

  DigitalDetoxGamificationEntity addDisciplinedDay() {
    final newStreak = currentStreak + 1;
    final newSevenDayCycle = sevenDayCycle + 1;
    final newDaysIn30DayCycle = daysInCurrent30DayCycle + 1;

    List<String> newInsignias = earnedInsigniasList;
    if (newStreak >= 1 && !newInsignias.contains('🥈 Ferro')) {
      newInsignias.add('🥈 Ferro - ${DateTime.now().day}/${DateTime.now().month}');
    }
    if (newStreak >= 2 && !newInsignias.contains('🥈 Alumínio')) {
      newInsignias.add('🥈 Alumínio - ${DateTime.now().day}/${DateTime.now().month}');
    }
    if (newStreak >= 3 && !newInsignias.contains('🥇 Latão')) {
      newInsignias.add('🥇 Latão - ${DateTime.now().day}/${DateTime.now().month}');
    }
    if (newStreak >= 5 && !newInsignias.contains('🥉 Bronze')) {
      newInsignias.add('🥉 Bronze - ${DateTime.now().day}/${DateTime.now().month}');
    }
    if (newStreak >= 10 && !newInsignias.contains('🥈 Prata')) {
      newInsignias.add('🥈 Prata - ${DateTime.now().day}/${DateTime.now().month}');
    }
    if (newStreak >= 15 && !newInsignias.contains('🥇 Ouro')) {
      newInsignias.add('🥇 Ouro - ${DateTime.now().day}/${DateTime.now().month}');
    }
    if (newStreak >= 20 && !newInsignias.contains('💎 Diamante')) {
      newInsignias.add('💎 Diamante - ${DateTime.now().day}/${DateTime.now().month}');
    }
    if (newStreak >= 30 && !newInsignias.contains('🎱 Disciplinum')) {
      newInsignias.add('🎱 Disciplinum - ${DateTime.now().day}/${DateTime.now().month}');
    }

    List<String> newMedalhas = earnedMedalhasList;
    if (newDaysIn30DayCycle >= 30) {
      if (newMedalhas.isEmpty) {
        newMedalhas.add('🥉 Bronze - ${DateTime.now().day}/${DateTime.now().month}');
      } else if (newMedalhas.length == 1) {
        newMedalhas.add('🥈 Prata - ${DateTime.now().day}/${DateTime.now().month}');
      } else if (newMedalhas.length == 2) {
        newMedalhas.add('🥇 Ouro - ${DateTime.now().day}/${DateTime.now().month}');
      } else if (newMedalhas.length < 4) {
        newMedalhas.add('💎 Diamante - ${DateTime.now().day}/${DateTime.now().month}');
      }
    }

    return copyWith(
      currentStreak: newStreak > longestStreak ? newStreak : longestStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      totalDisciplinedDays: totalDisciplinedDays + 1,
      lastDisciplinedDate: DateTime.now(),
      sevenDayCycle: newSevenDayCycle,
      daysInCurrent30DayCycle: newDaysIn30DayCycle >= 30 ? 0 : newDaysIn30DayCycle,
      cycle30StartDate: newDaysIn30DayCycle >= 30 ? DateTime.now() : cycle30StartDate,
      earnedInsignias: jsonEncode(newInsignias),
      earnedMedalhas: jsonEncode(newMedalhas),
      updatedAt: DateTime.now(),
    );
  }

  DigitalDetoxGamificationEntity resetStreak() {
    return DigitalDetoxGamificationEntity(
      userId: userId,
      currentStreak: 0,
      longestStreak: longestStreak,
      totalDisciplinedDays: totalDisciplinedDays,
      lastDisciplinedDate: null,
      sevenDayCycle: 0,
      cycleStartDate: DateTime.now(),
      daysInCurrent30DayCycle: 0,
      cycle30StartDate: DateTime.now(),
      earnedInsignias: earnedInsignias.contains('🪵 Madeira') ? jsonEncode(['🪵 Madeira']) : '[]',
      earnedMedalhas: '[]',
      isModuleActive: isModuleActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool shouldAwardFastingBreak() {
    return sevenDayCycle >= 7;
  }

  DigitalDetoxGamificationEntity resetSevenDayCycle() {
    return copyWith(
      sevenDayCycle: 0,
      cycleStartDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  DigitalDetoxGamificationEntity copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalDisciplinedDays,
    DateTime? lastDisciplinedDate,
    int? sevenDayCycle,
    DateTime? cycleStartDate,
    String? earnedInsignias,
    String? earnedMedalhas,
    DateTime? cycle30StartDate,
    int? daysInCurrent30DayCycle,
    bool? isModuleActive,
    DateTime? updatedAt,
  }) {
    return DigitalDetoxGamificationEntity(
      userId: userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalDisciplinedDays: totalDisciplinedDays ?? this.totalDisciplinedDays,
      lastDisciplinedDate: lastDisciplinedDate ?? this.lastDisciplinedDate,
      sevenDayCycle: sevenDayCycle ?? this.sevenDayCycle,
      cycleStartDate: cycleStartDate ?? this.cycleStartDate,
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      cycle30StartDate: cycle30StartDate ?? this.cycle30StartDate,
      daysInCurrent30DayCycle: daysInCurrent30DayCycle ?? this.daysInCurrent30DayCycle,
      isModuleActive: isModuleActive ?? this.isModuleActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
