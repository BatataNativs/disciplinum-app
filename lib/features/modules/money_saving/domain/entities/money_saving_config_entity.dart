import 'package:isar/isar.dart';

part 'money_saving_config_entity.g.dart';

/// Entidade Isar para configurações do módulo Money Saving
/// Persiste estado de ativação do módulo
@Collection()
class MoneySavingConfigEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String userId;

  // Estado do módulo
  bool isModuleActive = false;

  // ID do desafio ativo (opcional)
  String? activeChallengeId;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  MoneySavingConfigEntity({
    required this.userId,
    this.isModuleActive = false,
    this.activeChallengeId,
  });

  /// Atualiza o timestamp
  void touch() {
    updatedAt = DateTime.now();
  }

  /// Cria cópia com novos valores
  MoneySavingConfigEntity copyWith({
    String? userId,
    bool? isModuleActive,
    String? activeChallengeId,
  }) {
    return MoneySavingConfigEntity(
      userId: userId ?? this.userId,
      isModuleActive: isModuleActive ?? this.isModuleActive,
      activeChallengeId: activeChallengeId ?? this.activeChallengeId,
    )..id = id
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();
  }
}
