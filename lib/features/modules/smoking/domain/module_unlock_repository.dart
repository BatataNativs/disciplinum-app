import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/module_unlock_entity.dart';
import 'package:isar/isar.dart';

/// Repository para gerenciar desbloqueios locais de módulos
class ModuleUnlockRepository {
  static final ModuleUnlockRepository _instance = ModuleUnlockRepository._internal();
  static ModuleUnlockRepository get instance => _instance;

  ModuleUnlockRepository._internal();

  Isar get _isar => IsarService.instance.database;

  /// Obtém ou cria registro de desbloqueio para um módulo
  Future<ModuleUnlockEntity> getOrCreateUnlock(String moduleId, String unlockType) async {
    final existing = await _isar.moduleUnlockEntitys
        .filter()
        .moduleIdEqualTo(moduleId)
        .unlockTypeEqualTo(unlockType)
        .findFirst();

    if (existing != null) {
      return existing;
    }

    // Cria novo registro
    final newUnlock = ModuleUnlockEntity(
      moduleId: moduleId,
      unlockType: unlockType,
      isUnlocked: false,
    );

    await _isar.writeTxn(() async {
      await _isar.moduleUnlockEntitys.put(newUnlock);
    });

    return newUnlock;
  }

  /// Verifica se um módulo está desbloqueado
  Future<bool> isUnlocked(String moduleId, String unlockType) async {
    final unlock = await _isar.moduleUnlockEntitys
        .filter()
        .moduleIdEqualTo(moduleId)
        .unlockTypeEqualTo(unlockType)
        .findFirst();

    return unlock?.isUnlocked ?? false;
  }

  /// Desbloqueia uma funcionalidade para um módulo
  Future<void> unlock(String moduleId, String unlockType, {String method = 'ad'}) async {
    final unlock = await getOrCreateUnlock(moduleId, unlockType);
    
    final updated = unlock.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      unlockMethod: method,
    );

    await _isar.writeTxn(() async {
      await _isar.moduleUnlockEntitys.put(updated);
    });
  }

  /// Bloqueia uma funcionalidade (para reset/testes)
  Future<void> lock(String moduleId, String unlockType) async {
    final unlock = await getOrCreateUnlock(moduleId, unlockType);
    
    final updated = unlock.copyWith(
      isUnlocked: false,
      unlockedAt: null,
      unlockMethod: null,
    );

    await _isar.writeTxn(() async {
      await _isar.moduleUnlockEntitys.put(updated);
    });
  }

  /// Obtém todos os desbloqueios de um módulo
  Future<List<ModuleUnlockEntity>> getModuleUnlocks(String moduleId) async {
    return await _isar.moduleUnlockEntitys
        .filter()
        .moduleIdEqualTo(moduleId)
        .findAll();
  }

  /// Deleta todos os desbloqueios (para reset completo)
  Future<void> deleteAllUnlocks() async {
    await _isar.writeTxn(() async {
      await _isar.moduleUnlockEntitys.clear();
    });
  }
}
