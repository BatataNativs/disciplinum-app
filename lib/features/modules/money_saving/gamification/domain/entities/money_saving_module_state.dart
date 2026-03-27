import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_insignia.dart';

/// Estado de gamificação do módulo Money Saving Challenge
/// Armazena progresso, conquistas e estatísticas
class MoneySavingModuleState {
  /// Lista de insignias conquistadas
  final List<String> earnedInsignias;
  
  /// Lista de medalhas conquistadas
  final List<String> earnedMedalhas;
  
  /// Dias consecutivos economizando
  final int consecutiveDays;
  
  /// Contador de insignias Disciplinum
  final int disciplinumCount;
  
  /// Reseta apenas as insígnias (preserva a inicial)
  MoneySavingModuleState resetInsignias() {
    // Preserva apenas a insígnia inicial (Economista Inicial)
    final initialInsignia = MoneySavingInsignia.economistaInicial.name;
    final hasInitialInsignia = earnedInsignias.contains(initialInsignia);
    
    final newInsignias = <String>[];
    final newDisciplinumCount = 0;
    
    // Restaura a inicial se o usuário já tinha
    if (hasInitialInsignia) {
      newInsignias.add(initialInsignia);
    }
    
    return MoneySavingModuleState(
      earnedInsignias: newInsignias,
      earnedMedalhas: [], // Reseta medalhas também
      consecutiveDays: 0, // Reset dias
      disciplinumCount: newDisciplinumCount,
      totalSavedAmount: totalSavedAmount,
      bestStreak: bestStreak,
      lastSavingDate: lastSavingDate,
      startDate: startDate,
      lastUpdated: DateTime.now(),
      isActive: isActive,
    );
  }
  
  /// Valor total acumulado
  final double totalSavedAmount;
  
  /// Maior sequência já alcançada
  final int bestStreak;
  
  /// Data da última economia
  final DateTime? lastSavingDate;
  
  /// Data de início do desafio
  final DateTime? startDate;
  
  /// Data da última atualização
  final DateTime lastUpdated;
  
  /// Indica se o módulo está ativo
  final bool isActive;

  const MoneySavingModuleState({
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.consecutiveDays = 0,
    this.disciplinumCount = 0,
    this.totalSavedAmount = 0.0,
    this.bestStreak = 0,
    this.lastSavingDate,
    this.startDate,
    required this.lastUpdated,
    this.isActive = false,
  });

  /// Cria um estado inicial
  factory MoneySavingModuleState.initial() {
    return MoneySavingModuleState(
      lastUpdated: DateTime.now(),
    );
  }

  /// Cria a partir de JSON
  factory MoneySavingModuleState.fromJson(Map<String, dynamic> json) {
    return MoneySavingModuleState(
      earnedInsignias: List<String>.from(json['earnedInsignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earnedMedalhas'] ?? []),
      consecutiveDays: json['consecutiveDays'] ?? 0,
      disciplinumCount: json['disciplinumCount'] ?? 0,
      totalSavedAmount: (json['totalSavedAmount'] ?? 0.0).toDouble(),
      bestStreak: json['bestStreak'] ?? 0,
      lastSavingDate: json['lastSavingDate'] != null 
          ? DateTime.parse(json['lastSavingDate'])
          : null,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'])
          : null,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isActive: json['isActive'] ?? false,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'earnedInsignias': earnedInsignias,
      'earnedMedalhas': earnedMedalhas,
      'consecutiveDays': consecutiveDays,
      'disciplinumCount': disciplinumCount,
      'totalSavedAmount': totalSavedAmount,
      'bestStreak': bestStreak,
      'lastSavingDate': lastSavingDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Cria uma cópia com alguns campos alterados
  MoneySavingModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutiveDays,
    int? disciplinumCount,
    double? totalSavedAmount,
    int? bestStreak,
    DateTime? lastSavingDate,
    DateTime? startDate,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return MoneySavingModuleState(
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      disciplinumCount: disciplinumCount ?? this.disciplinumCount,
      totalSavedAmount: totalSavedAmount ?? this.totalSavedAmount,
      bestStreak: bestStreak ?? this.bestStreak,
      lastSavingDate: lastSavingDate ?? this.lastSavingDate,
      startDate: startDate ?? this.startDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Verifica se está em streak (dias consecutivos > 0)
  bool get isInStreak => consecutiveDays > 0;

  /// Verifica se tem alguma conquista
  bool get hasAchievements => earnedInsignias.isNotEmpty || earnedMedalhas.isNotEmpty;

  /// Calcula dias desde a última economia
  int get daysSinceLastSaving {
    if (lastSavingDate == null) return 999;
    return DateTime.now().difference(lastSavingDate!).inDays;
  }

  /// Verifica se o streak foi quebrado
  bool get streakBroken => daysSinceLastSaving > 1;

  /// Obtém estatísticas detalhadas
  Map<String, dynamic> getStatistics() {
    return {
      'totalInsignias': earnedInsignias.length,
      'totalMedalhas': earnedMedalhas.length,
      'currentStreak': consecutiveDays,
      'bestStreak': bestStreak,
      'disciplinumCount': disciplinumCount,
      'totalSavedAmount': totalSavedAmount,
      'daysSinceLastSaving': daysSinceLastSaving,
      'isInStreak': isInStreak,
      'streakBroken': streakBroken,
      'isActive': isActive,
      'startDate': startDate?.toIso8601String(),
      'lastSavingDate': lastSavingDate?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MoneySavingModuleState('
        'consecutiveDays: $consecutiveDays, '
        'disciplinumCount: $disciplinumCount, '
        'totalSavedAmount: $totalSavedAmount, '
        'bestStreak: $bestStreak, '
        'earnedInsignias: ${earnedInsignias.length}, '
        'earnedMedalhas: ${earnedMedalhas.length}, '
        'isActive: $isActive'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MoneySavingModuleState &&
      other.earnedInsignias == earnedInsignias &&
      other.earnedMedalhas == earnedMedalhas &&
      other.consecutiveDays == consecutiveDays &&
      other.disciplinumCount == disciplinumCount &&
      other.totalSavedAmount == totalSavedAmount &&
      other.bestStreak == bestStreak &&
      other.lastSavingDate == lastSavingDate &&
      other.startDate == startDate &&
      other.lastUpdated == lastUpdated &&
      other.isActive == isActive;
  }

  @override
  int get hashCode {
    return earnedInsignias.hashCode ^
      earnedMedalhas.hashCode ^
      consecutiveDays.hashCode ^
      disciplinumCount.hashCode ^
      totalSavedAmount.hashCode ^
      bestStreak.hashCode ^
      lastSavingDate.hashCode ^
      startDate.hashCode ^
      lastUpdated.hashCode ^
      isActive.hashCode;
  }
}
