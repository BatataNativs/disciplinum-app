import 'package:isar/isar.dart';

part 'module_unlock_entity.g.dart';

/// Entidade para armazenar estado de desbloqueio de funcionalidades por módulo
/// Usado para verificar se usuário desbloqueou via anúncio ou outra forma local
@collection
class ModuleUnlockEntity {
  Id id = Isar.autoIncrement;
  
  /// ID do módulo (nicheId)
  late String moduleId;
  
  /// Tipo de desbloqueio (motivation_phrases, custom_notifications, etc)
  late String unlockType;
  
  /// Se está desbloqueado
  bool isUnlocked = false;
  
  /// Data do desbloqueio
  DateTime? unlockedAt;
  
  /// Método de desbloqueio (ad, purchase, etc)
  String? unlockMethod;
  
  /// Data de criação do registro
  late DateTime createdAt;
  
  /// Última atualização
  late DateTime updatedAt;

  ModuleUnlockEntity({
    required this.moduleId,
    required this.unlockType,
    this.isUnlocked = false,
    this.unlockedAt,
    this.unlockMethod,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Atualiza o timestamp
  void touch() {
    updatedAt = DateTime.now();
  }

  /// Cria cópia com modificações
  ModuleUnlockEntity copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? unlockMethod,
  }) {
    final entity = ModuleUnlockEntity(
      moduleId: moduleId,
      unlockType: unlockType,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockMethod: unlockMethod ?? this.unlockMethod,
    );
    entity.id = id;
    entity.createdAt = createdAt;
    entity.updatedAt = DateTime.now();
    return entity;
  }
}
