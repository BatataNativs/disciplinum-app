import 'package:disciplinum/features/gamification/domain/entities/user_module_status.dart';

/// Entidade que consolida o estado completo de um módulo
/// Substitui múltiplos Maps espalhados pelo GamificationService
class ModuleState {
  final int nicheId;
  final bool isActive;
  final int consecutiveDays;
  final int? focusPeriodsRespected;
  final DateTime? lastUpdated;
  final String? maxMedal;
  final List<String> earnedInsignias;
  final int currentXp;
  final Map<String, dynamic> moduleSpecificData;
  final DateTime? lastCheckIn;
  final DateTime? lastRelapse;
  final int totalCheckIns;
  final int totalRelapses;

  const ModuleState({
    required this.nicheId,
    required this.isActive,
    this.consecutiveDays = 0,
    this.focusPeriodsRespected,
    this.lastUpdated,
    this.maxMedal,
    this.earnedInsignias = const [],
    this.currentXp = 0,
    this.moduleSpecificData = const {},
    this.lastCheckIn,
    this.lastRelapse,
    this.totalCheckIns = 0,
    this.totalRelapses = 0,
  });

  /// Cria ModuleState a partir de UserModuleStatus
  factory ModuleState.fromUserModuleStatus(UserModuleStatus status) {
    return ModuleState(
      nicheId: status.nicheId,
      isActive: status.isActive,
      consecutiveDays: status.consecutiveDays,
      focusPeriodsRespected: status.focusPeriodsRespected,
      lastUpdated: status.lastUpdated,
      maxMedal: status.maxMedal,
      earnedInsignias: status.earnedInsignias,
      // Campos novos com valores padrão
      currentXp: 0,
      moduleSpecificData: {},
      lastCheckIn: null,
      lastRelapse: null,
      totalCheckIns: 0,
      totalRelapses: 0,
    );
  }

  /// Converte para UserModuleStatus (para compatibilidade)
  UserModuleStatus toUserModuleStatus({required String userId}) {
    return UserModuleStatus(
      userId: userId,
      nicheId: nicheId,
      isActive: isActive,
      consecutiveDays: consecutiveDays,
      focusPeriodsRespected: focusPeriodsRespected,
      lastUpdated: lastUpdated,
      maxMedal: maxMedal,
      earnedInsignias: earnedInsignias,
    );
  }

  /// Cria cópia com valores atualizados
  ModuleState copyWith({
    int? nicheId,
    bool? isActive,
    int? consecutiveDays,
    int? focusPeriodsRespected,
    DateTime? lastUpdated,
    String? maxMedal,
    List<String>? earnedInsignias,
    int? currentXp,
    Map<String, dynamic>? moduleSpecificData,
    DateTime? lastCheckIn,
    DateTime? lastRelapse,
    int? totalCheckIns,
    int? totalRelapses,
  }) {
    return ModuleState(
      nicheId: nicheId ?? this.nicheId,
      isActive: isActive ?? this.isActive,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      focusPeriodsRespected: focusPeriodsRespected ?? this.focusPeriodsRespected,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      maxMedal: maxMedal ?? this.maxMedal,
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      currentXp: currentXp ?? this.currentXp,
      moduleSpecificData: moduleSpecificData ?? this.moduleSpecificData,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      lastRelapse: lastRelapse ?? this.lastRelapse,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      totalRelapses: totalRelapses ?? this.totalRelapses,
    );
  }

  /// Verifica se o módulo está em streak ativo
  bool get hasActiveStreak => consecutiveDays > 0 && isActive;

  /// Verifica se o módulo precisa de check-in hoje
  bool get needsCheckInToday {
    if (lastCheckIn == null) return true;
    
    final now = DateTime.now();
    final lastCheckInDate = DateTime(
      lastCheckIn!.year,
      lastCheckIn!.month,
      lastCheckIn!.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    
    return lastCheckInDate.isBefore(today);
  }

  /// Calcula dias desde última recaída
  int get daysSinceLastRelapse {
    if (lastRelapse == null) return consecutiveDays;
    
    final now = DateTime.now();
    final difference = now.difference(lastRelapse!);
    return difference.inDays;
  }

  /// Calcula taxa de sucesso (check-ins vs total)
  double get successRate {
    if (totalCheckIns == 0) return 0.0;
    return (totalCheckIns - totalRelapses) / totalCheckIns;
  }

  /// Verifica se o módulo pode ganhar XP
  bool get canEarnXp => isActive && hasActiveStreak;

  /// Calcula XP total potencial (base + bônus)
  int get potentialXp {
    if (!canEarnXp) return 0;
    
    int baseXp = consecutiveDays * 10;
    int streakBonus = consecutiveDays > 7 ? 50 : 0;
    int insigniaBonus = earnedInsignias.length * 25;
    
    return baseXp + streakBonus + insigniaBonus;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModuleState &&
        other.nicheId == nicheId &&
        other.isActive == isActive &&
        other.consecutiveDays == consecutiveDays &&
        other.focusPeriodsRespected == focusPeriodsRespected &&
        other.currentXp == currentXp &&
        other.totalCheckIns == totalCheckIns &&
        other.totalRelapses == totalRelapses;
  }

  @override
  int get hashCode {
    return Object.hash(
      nicheId,
      isActive,
      consecutiveDays,
      focusPeriodsRespected,
      currentXp,
      totalCheckIns,
      totalRelapses,
    );
  }

  @override
  String toString() {
    return 'ModuleState('
        'nicheId: $nicheId, '
        'isActive: $isActive, '
        'consecutiveDays: $consecutiveDays, '
        'currentXp: $currentXp, '
        'totalCheckIns: $totalCheckIns, '
        'totalRelapses: $totalRelapses'
        ')';
  }
}
