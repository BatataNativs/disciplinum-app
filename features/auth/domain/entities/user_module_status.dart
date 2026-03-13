import 'package:equatable/equatable.dart';
import 'package:disciplinum/features/gamification/domain/entities/medal.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Entidade que representa o status do usuário em um módulo específico
/// Mapeia para tabela: user_module_status
class UserModuleStatus extends Equatable {
  final String userId;
  final int nicheId;
  final int consecutiveDays;
  final GamificationMedal? maxMedal;
  final bool isActive;
  final DateTime? startDate;
  final List<String> earnedInsignias;
  final Map<String, dynamic>? moduleSpecificData;
  final DateTime? lastActivityDate;
  final DateTime? lastUpdated;

  const UserModuleStatus({
    required this.userId,
    required this.nicheId,
    this.consecutiveDays = 0,
    this.maxMedal,
    this.isActive = false,
    this.startDate,
    this.earnedInsignias = const [],
    this.moduleSpecificData,
    this.lastActivityDate,
    this.lastUpdated,
  });

  /// Cria a partir de dados do Supabase
  factory UserModuleStatus.fromSupabase(Map<String, dynamic> data) {
    return UserModuleStatus(
      userId: data['user_id'] as String,
      nicheId: data['niche_id'] as int,
      consecutiveDays: data['consecutive_days'] as int? ?? 0,
      maxMedal: data['current_medal'] != null 
          ? _medalFromString(data['current_medal'] as String)
          : null,
      isActive: data['is_active'] as bool? ?? false,
      startDate: data['start_date'] != null
          ? DateTime.parse(data['start_date'] as String)
          : null,
      earnedInsignias: (data['earned_insignias'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      moduleSpecificData: data['module_specific_data'] as Map<String, dynamic>?,
      lastActivityDate: data['last_activity_date'] != null
          ? DateTime.parse(data['last_activity_date'] as String)
          : null,
      lastUpdated: data['last_updated'] != null
          ? DateTime.parse(data['last_updated'] as String)
          : null,
    );
  }

  /// Converte para JSON para salvar no Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'niche_id': nicheId,
      'consecutive_days': consecutiveDays,
      'current_medal': maxMedal?.name,
      'is_active': isActive,
      'start_date': startDate?.toIso8601String(),
      'earned_insignias': earnedInsignias,
      'module_specific_data': moduleSpecificData,
      'last_activity_date': lastActivityDate?.toIso8601String(),
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  /// Cria a partir de JSON
  factory UserModuleStatus.fromJson(Map<String, dynamic> json) {
    return UserModuleStatus(
      userId: json['user_id'] as String,
      nicheId: json['niche_id'] as int,
      consecutiveDays: json['consecutive_days'] as int? ?? 0,
      maxMedal: json['current_medal'] != null
          ? _medalFromString(json['current_medal'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? false,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      earnedInsignias: (json['earned_insignias'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      moduleSpecificData: json['module_specific_data'] as Map<String, dynamic>?,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'] as String)
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }

  /// Converte string para enum GamificationMedal
  static GamificationMedal? _medalFromString(String medalName) {
    switch (medalName.toLowerCase()) {
      case 'bronze':
        return GamificationMedal.bronze;
      case 'prata':
        return GamificationMedal.prata;
      case 'ouro':
        return GamificationMedal.ouro;
      case 'diamante':
        return GamificationMedal.diamante;
      default:
        return null;
    }
  }

  /// CopyWith para updates imutáveis
  UserModuleStatus copyWith({
    String? userId,
    int? nicheId,
    int? consecutiveDays,
    GamificationMedal? maxMedal,
    bool? isActive,
    DateTime? startDate,
    List<String>? earnedInsignias,
    Map<String, dynamic>? moduleSpecificData,
    DateTime? lastActivityDate,
    DateTime? lastUpdated,
  }) {
    return UserModuleStatus(
      userId: userId ?? this.userId,
      nicheId: nicheId ?? this.nicheId,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      maxMedal: maxMedal ?? this.maxMedal,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      moduleSpecificData: moduleSpecificData ?? this.moduleSpecificData,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Verifica se o módulo está em andamento
  bool get isInProgress => isActive && consecutiveDays > 0;

  /// Verifica se é um módulo novo (iniciado há menos de 7 dias)
  bool get isNewModule {
    if (startDate == null) return false;
    return DateTime.now().difference(startDate!).inDays < 7;
  }

  /// Obtém o NicheId a partir do nicheId inteiro
  NicheId get niche {
    switch (nicheId) {
      case 1:
        return NicheId.smoking;
      case 2:
        return NicheId.bingeEating;
      case 3:
        return NicheId.diet;
      case 4:
        return NicheId.spending;
      case 5:
        return NicheId.focus;
      case 6:
        return NicheId.adultContent;
      case 7:
        return NicheId.moneySavingChallenge;
      case 8:
        return NicheId.procrastination;
      case 9:
        return NicheId.reading;
      default:
        throw ArgumentError('Invalid nicheId: $nicheId');
    }
  }

  @override
  List<Object?> get props => [
        userId,
        nicheId,
        consecutiveDays,
        maxMedal,
        isActive,
        startDate,
        earnedInsignias,
        moduleSpecificData,
        lastActivityDate,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'UserModuleStatus(userId: $userId, nicheId: $nicheId, days: $consecutiveDays, medal: $maxMedal)';
  }
}
