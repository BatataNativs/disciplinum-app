import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_module_state.dart';

@Entity()
class ProcrastinationGamificationEntity {
  @Id()
  int id = 0;
  
  String userId;
  List<String> earnedInsignias;
  List<String> earnedMedalhas;
  int consecutiveDays;
  int disciplinumCount;
  DateTime lastUpdated;
  bool isActive;

  ProcrastinationGamificationEntity({
    required this.userId,
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

  factory ProcrastinationGamificationEntity.fromModuleState(
    String userId,
    ProcrastinationModuleState state,
  ) {
    return ProcrastinationGamificationEntity(
      userId: userId,
      earnedInsignias: state.earnedInsignias,
      earnedMedalhas: state.earnedMedalhas,
      consecutiveDays: state.consecutiveProductiveDays,
      disciplinumCount: state.disciplinumCount,
      lastUpdated: state.updatedAt,
      isActive: state.isActive,
    );
  }

  ProcrastinationModuleState toModuleState() {
    return ProcrastinationModuleState(
      earnedInsignias: earnedInsignias,
      earnedMedalhas: earnedMedalhas,
      consecutiveProductiveDays: consecutiveDays,
      disciplinumCount: disciplinumCount,
      updatedAt: lastUpdated,
      isActive: isActive,
    );
  }
}
