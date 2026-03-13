import 'package:disciplinum/features/gamification/domain/entities/user_module_status.dart';
import '../entities/user_achievement.dart';
import '../entities/medal.dart';
import '../entities/insignia.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

class AchievementCalculator {
  /// Calcula medalhas baseadas em dias consecutivos
  static GamificationMedal calculateMedal(int consecutiveDays) {
    if (consecutiveDays >= 30) return GamificationMedal.diamante;
    if (consecutiveDays >= 21) return GamificationMedal.ouro;
    if (consecutiveDays >= 14) return GamificationMedal.prata;
    if (consecutiveDays >= 7) return GamificationMedal.bronze;
    return GamificationMedal.semMedalha;
  }

  /// Calcula insígnias baseadas em milestones específicos
  static List<FocusInsignia> calculateInsignias(
    NicheId nicheId,
    UserModuleStatus moduleStatus,
  ) {
    final List<FocusInsignia> insignias = [];

    if (nicheId == NicheId.focus) {
      // Insígnias específicas para foco
      if (moduleStatus.consecutiveDays >= 1) {
        insignias.add(FocusInsignia.madeira);
      }
      if (moduleStatus.consecutiveDays >= 3) {
        insignias.add(FocusInsignia.ferro);
      }
      if (moduleStatus.consecutiveDays >= 7) {
        insignias.add(FocusInsignia.aluminio);
      }
      if (moduleStatus.consecutiveDays >= 14) {
        insignias.add(FocusInsignia.latao);
      }
      if (moduleStatus.consecutiveDays >= 21) {
        insignias.add(FocusInsignia.bronze);
      }
      if (moduleStatus.consecutiveDays >= 30) {
        insignias.add(FocusInsignia.prata);
      }
      if (moduleStatus.consecutiveDays >= 60) {
        insignias.add(FocusInsignia.ouro);
      }
      if (moduleStatus.consecutiveDays >= 90) {
        insignias.add(FocusInsignia.diamante);
      }
      if (moduleStatus.consecutiveDays >= 365) {
        insignias.add(FocusInsignia.disciplinum);
      }
    }

    return insignias;
  }

  /// Verifica se uma nova conquista foi desbloqueada
  static List<UserAchievement> checkNewAchievements(
    String userId,
    NicheId nicheId,
    UserModuleStatus currentStatus,
    UserModuleStatus previousStatus,
  ) {
    final List<UserAchievement> newAchievements = [];

    // Verificar mudança de medalha
    final currentMedal = calculateMedal(currentStatus.consecutiveDays);
    final previousMedal = calculateMedal(previousStatus.consecutiveDays);

    if (currentMedal != previousMedal && currentMedal != GamificationMedal.semMedalha) {
      newAchievements.add(UserAchievement(
        id: 'medal_${userId}_${nicheId.id}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        nicheId: nicheId.id,
        achievementType: 'medal',
        achievementId: currentMedal.name,
        title: currentMedal.nameBr,
        description: 'Você alcançou a medalha ${currentMedal.nameBr}!',
        earnedAt: DateTime.now(),
        metadata: {
          'consecutive_days': currentStatus.consecutiveDays,
          'previous_medal': previousMedal.name,
        },
      ));
    }

    // Verificar novas insígnias
    final currentInsignias = calculateInsignias(nicheId, currentStatus);
    final previousInsignias = calculateInsignias(nicheId, previousStatus);

    for (final insignia in currentInsignias) {
      if (!previousInsignias.contains(insignia)) {
        newAchievements.add(UserAchievement(
          id: 'insignia_${userId}_${nicheId.id}_${insignia.name}_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          nicheId: nicheId.id,
          achievementType: 'insignia',
          achievementId: insignia.name,
          title: insignia.nameBr,
          description: 'Você desbloqueou a insígnia ${insignia.nameBr}!',
          earnedAt: DateTime.now(),
          metadata: {
            'consecutive_days': currentStatus.consecutiveDays,
            'insignia_level': insignia.requiredDays,
          },
        ));
      }
    }

    return newAchievements;
  }

  /// Calcula progresso para próxima conquista
  static Map<String, dynamic> calculateProgressToNext(
    NicheId nicheId,
    UserModuleStatus moduleStatus,
  ) {
    final currentMedal = calculateMedal(moduleStatus.consecutiveDays);
    final insignias = calculateInsignias(nicheId, moduleStatus);

    // Progresso para próxima medalha
    GamificationMedal? nextMedal;
    int daysToNextMedal = 0;

    switch (currentMedal) {
      case GamificationMedal.semMedalha:
        nextMedal = GamificationMedal.bronze;
        daysToNextMedal = 7 - moduleStatus.consecutiveDays;
        break;
      case GamificationMedal.bronze:
        nextMedal = GamificationMedal.prata;
        daysToNextMedal = 14 - moduleStatus.consecutiveDays;
        break;
      case GamificationMedal.prata:
        nextMedal = GamificationMedal.ouro;
        daysToNextMedal = 21 - moduleStatus.consecutiveDays;
        break;
      case GamificationMedal.ouro:
        nextMedal = GamificationMedal.diamante;
        daysToNextMedal = 30 - moduleStatus.consecutiveDays;
        break;
      case GamificationMedal.diamante:
        nextMedal = null; // Já é a medalha máxima
        daysToNextMedal = 0;
        break;
    }

    // Progresso para próxima insígnia (apenas para foco)
    FocusInsignia? nextInsignia;
    int daysToNextInsignia = 0;

    if (nicheId == NicheId.focus) {
      final sortedInsignias = [
        FocusInsignia.madeira,
        FocusInsignia.ferro,
        FocusInsignia.aluminio,
        FocusInsignia.latao,
        FocusInsignia.bronze,
        FocusInsignia.prata,
        FocusInsignia.ouro,
        FocusInsignia.diamante,
        FocusInsignia.disciplinum,
      ];

      for (int i = 0; i < sortedInsignias.length - 1; i++) {
        if (moduleStatus.consecutiveDays < sortedInsignias[i + 1].requiredDays) {
          nextInsignia = sortedInsignias[i + 1];
          daysToNextInsignia = nextInsignia.requiredDays - moduleStatus.consecutiveDays;
          break;
        }
      }
    }

    return {
      'current_medal': currentMedal.name,
      'next_medal': nextMedal?.name,
      'days_to_next_medal': daysToNextMedal > 0 ? daysToNextMedal : 0,
      'current_insignias': insignias.map((i) => i.name).toList(),
      'next_insignia': nextInsignia?.name,
      'days_to_next_insignia': daysToNextInsignia > 0 ? daysToNextInsignia : 0,
      'total_insignias': 9, // Total de insígnias disponíveis
      'unlocked_insignias': insignias.length,
    };
  }
}
