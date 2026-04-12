import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/module_unlock_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repository para gerenciar desbloqueios locais de módulos
class ModuleUnlockRepository {
  static final ModuleUnlockRepository _instance = ModuleUnlockRepository._internal();
  static ModuleUnlockRepository get instance => _instance;

  ModuleUnlockRepository._internal();

  Box<ModuleUnlockEntity>? _box;

  Box<ModuleUnlockEntity> get box {
    _box ??= ObjectBoxService.instance.store.box<ModuleUnlockEntity>();
    return _box!;
  }

  /// Obtém ou cria registro de desbloqueio para um módulo
  Future<ModuleUnlockEntity> getOrCreateUnlock(String moduleId, String unlockType) async {
    final query = box.query(ModuleUnlockEntity_.moduleId.equals(moduleId)
        .and(ModuleUnlockEntity_.unlockType.equals(unlockType)))
        .build();
    final existing = query.findFirst();
    query.close();

    if (existing != null) {
      return existing;
    }

    // Cria novo registro
    final newUnlock = ModuleUnlockEntity(
      moduleId: moduleId,
      unlockType: unlockType,
      isUnlocked: false,
    );

    box.put(newUnlock);

    return newUnlock;
  }

  /// Verifica se um módulo está desbloqueado
  Future<bool> isUnlocked(String moduleId, String unlockType) async {
    final query = box.query(ModuleUnlockEntity_.moduleId.equals(moduleId)
        .and(ModuleUnlockEntity_.unlockType.equals(unlockType)))
        .build();
    final unlock = query.findFirst();
    query.close();

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

    box.put(updated);
  }

  /// Bloqueia uma funcionalidade (para reset/testes)
  Future<void> lock(String moduleId, String unlockType) async {
    final unlock = await getOrCreateUnlock(moduleId, unlockType);

    final updated = unlock.copyWith(
      isUnlocked: false,
      unlockedAt: null,
      unlockMethod: null,
    );

    box.put(updated);
  }

  /// Obtém todos os desbloqueios de um módulo
  Future<List<ModuleUnlockEntity>> getModuleUnlocks(String moduleId) async {
    final query = box.query(ModuleUnlockEntity_.moduleId.equals(moduleId)).build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Deleta todos os desbloqueios (para reset completo)
  Future<void> deleteAllUnlocks() async {
    box.removeAll();
  }
}
