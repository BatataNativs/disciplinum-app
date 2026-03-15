import 'package:isar/isar.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

part 'user_module_state.g.dart';

/// Entidade para armazenar estado dos módulos do usuário no Isar
@collection
class UserModuleState {
  /// ID único do registro
  Id id = Isar.autoIncrement;

  /// ID do usuário
  final String userId;

  /// ID do nicho/módulo
  @enumerated
  final int nicheId;

  /// Se o módulo está ativo
  final bool isActive;

  /// Dias consecutivos de uso
  final int consecutiveDays;

  /// Data do último acesso
  final DateTime lastAccessDate;

  /// Data de criação do registro
  final DateTime createdAt;

  /// Data da última atualização
  final DateTime updatedAt;

  /// Períodos de foco respeitados (apenas para módulo Foco)
  final int focusPeriodsRespected;

  /// Medalha máxima alcançada
  final String? maxMedal;

  /// Dados adicionais em formato JSON
  final String? additionalData;

  UserModuleState({
    required this.userId,
    required this.nicheId,
    required this.isActive,
    required this.consecutiveDays,
    required this.lastAccessDate,
    required this.createdAt,
    required this.updatedAt,
    this.focusPeriodsRespected = 0,
    this.maxMedal,
    this.additionalData,
  });

  /// Cria um UserModuleState a partir do zero
  factory UserModuleState.create({
    required String userId,
    required int nicheId,
    bool isActive = false,
  }) {
    final now = DateTime.now();
    return UserModuleState(
      userId: userId,
      nicheId: nicheId,
      isActive: isActive,
      consecutiveDays: 0,
      lastAccessDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Converte para NicheId enum
  @enumerated
  NicheId get niche => NicheId.values.firstWhere(
        (id) => id.id == nicheId,
        orElse: () => NicheId.reading,
      );

  /// Cria uma cópia com valores atualizados
  UserModuleState copyWith({
    String? userId,
    int? nicheId,
    bool? isActive,
    int? consecutiveDays,
    DateTime? lastAccessDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? focusPeriodsRespected,
    String? maxMedal,
    String? additionalData,
  }) {
    return UserModuleState(
      userId: userId ?? this.userId,
      nicheId: nicheId ?? this.nicheId,
      isActive: isActive ?? this.isActive,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastAccessDate: lastAccessDate ?? this.lastAccessDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      focusPeriodsRespected: focusPeriodsRespected ?? this.focusPeriodsRespected,
      maxMedal: maxMedal ?? this.maxMedal,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'UserModuleState('
        'id: $id, '
        'userId: $userId, '
        'nicheId: $nicheId, '
        'isActive: $isActive, '
        'consecutiveDays: $consecutiveDays, '
        'lastAccessDate: $lastAccessDate, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'focusPeriodsRespected: $focusPeriodsRespected, '
        'maxMedal: $maxMedal, '
        'additionalData: $additionalData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModuleState &&
        other.userId == userId &&
        other.nicheId == nicheId &&
        other.isActive == isActive &&
        other.consecutiveDays == consecutiveDays &&
        other.lastAccessDate == lastAccessDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.focusPeriodsRespected == focusPeriodsRespected &&
        other.maxMedal == maxMedal &&
        other.additionalData == additionalData;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        nicheId.hashCode ^
        isActive.hashCode ^
        consecutiveDays.hashCode ^
        lastAccessDate.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        focusPeriodsRespected.hashCode ^
        maxMedal.hashCode ^
        additionalData.hashCode;
  }
}
