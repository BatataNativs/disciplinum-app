import 'package:disciplinum/features/gamification/domain/entities/medal.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Entidade unificada que consolida o estado de todos os módulos
/// Reduz a complexidade de múltiplos Maps espalhados pelo código
class ModuleState {
  final NicheId id;
  int consecutiveDays;
  DateTime? startDate;
  GamificationMedal? currentMedal;
  Map<String, dynamic> moduleSpecificData;
  DateTime? lastUpdated;
  bool isActive;

  ModuleState({
    required this.id,
    this.consecutiveDays = 0,
    this.startDate,
    this.currentMedal,
    this.moduleSpecificData = const {},
    this.lastUpdated,
    this.isActive = false,
  });

  /// Cria um ModuleState a partir de dados JSON (do storage)
  factory ModuleState.fromJson(Map<String, dynamic> json) {
    return ModuleState(
      id: NicheId.fromInt(json['id'] as int),
      consecutiveDays: json['consecutiveDays'] as int? ?? 0,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String) 
          : null,
      currentMedal: json['currentMedal'] != null
          ? _medalFromInt(json['currentMedal'] as int)
          : null,
      moduleSpecificData: json['moduleSpecificData'] as Map<String, dynamic>? ?? {},
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  /// Converte medalha de int para enum
  static GamificationMedal _medalFromInt(int value) {
    switch (value) {
      case 0: return GamificationMedal.bronze;
      case 1: return GamificationMedal.prata;
      case 2: return GamificationMedal.ouro;
      case 3: return GamificationMedal.diamante;
      default: return GamificationMedal.bronze;
    }
  }

  /// Converte medalha de enum para int
  static int _medalToInt(GamificationMedal medal) {
    switch (medal) {
      case GamificationMedal.bronze: return 0;
      case GamificationMedal.prata: return 1;
      case GamificationMedal.ouro: return 2;
      case GamificationMedal.diamante: return 3;
    }
  }

  /// Converte para JSON para salvar no storage
  Map<String, dynamic> toJson() {
    return {
      'id': id.id,
      'consecutiveDays': consecutiveDays,
      'startDate': startDate?.toIso8601String(),
      'currentMedal': currentMedal != null ? _medalToInt(currentMedal!) : null,
      'moduleSpecificData': moduleSpecificData,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Cria uma cópia com atualizações
  ModuleState copyWith({
    NicheId? id,
    int? consecutiveDays,
    DateTime? startDate,
    GamificationMedal? currentMedal,
    Map<String, dynamic>? moduleSpecificData,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return ModuleState(
      id: id ?? this.id,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      startDate: startDate ?? this.startDate,
      currentMedal: currentMedal ?? this.currentMedal,
      moduleSpecificData: moduleSpecificData ?? this.moduleSpecificData,
      lastUpdated: lastUpdated ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  /// Incrementa dias consecutivos
  ModuleState incrementConsecutiveDays() {
    return copyWith(
      consecutiveDays: consecutiveDays + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Reseta dias consecutivos
  ModuleState resetConsecutiveDays() {
    return copyWith(
      consecutiveDays: 0,
      startDate: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Ativa o módulo
  ModuleState activate() {
    return copyWith(
      isActive: true,
      startDate: startDate ?? DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Desativa o módulo
  ModuleState deactivate() {
    return copyWith(
      isActive: false,
      lastUpdated: DateTime.now(),
    );
  }

  /// Atualiza medalha atual
  ModuleState updateMedal(GamificationMedal newMedal) {
    return copyWith(
      currentMedal: newMedal,
      lastUpdated: DateTime.now(),
    );
  }

  /// Adiciona ou atualiza dados específicos do módulo
  ModuleState updateModuleData(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(moduleSpecificData);
    newData[key] = value;
    
    return copyWith(
      moduleSpecificData: newData,
      lastUpdated: DateTime.now(),
    );
  }

  /// Obtém dado específico do módulo
  T? getModuleData<T>(String key) {
    return moduleSpecificData[key] as T?;
  }

  /// Verifica se o módulo está em streak
  bool get isInStreak => consecutiveDays > 0 && isActive;

  /// Verifica se o módulo é novo (iniciado recentemente)
  bool get isNew {
    if (startDate == null) return false;
    final daysSinceStart = DateTime.now().difference(startDate!).inDays;
    return daysSinceStart <= 7;
  }

  @override
  String toString() {
    return 'ModuleState(id: $id, consecutiveDays: $consecutiveDays, isActive: $isActive, currentMedal: $currentMedal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModuleState &&
        other.id == id &&
        other.consecutiveDays == consecutiveDays &&
        other.startDate == startDate &&
        other.currentMedal == currentMedal &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        consecutiveDays.hashCode ^
        startDate.hashCode ^
        currentMedal.hashCode ^
        isActive.hashCode;
  }
}
