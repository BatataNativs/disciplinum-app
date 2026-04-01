import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/smoking/domain/module_unlock_repository.dart';

/// Provider para o ModuleUnlockRepository
final moduleUnlockRepositoryProvider = Provider<ModuleUnlockRepository>((ref) {
  return ModuleUnlockRepository.instance;
});

/// Provider para verificar se um módulo tem desbloqueio específico
/// Parâmetros: (moduleId, unlockType)
final moduleUnlockStatusProvider = FutureProvider.family<bool, ({String moduleId, String unlockType})>((ref, params) async {
  final repository = ref.read(moduleUnlockRepositoryProvider);
  return await repository.isUnlocked(params.moduleId, params.unlockType);
});

/// Provider stream para monitorar mudanças no desbloqueio
final moduleUnlockStreamProvider = StreamProvider.family<bool, ({String moduleId, String unlockType})>((ref, params) async* {
  final repository = ref.read(moduleUnlockRepositoryProvider);
  
  // Emite estado inicial
  final initialStatus = await repository.isUnlocked(params.moduleId, params.unlockType);
  yield initialStatus;
  
  // Polling a cada 2 segundos para detectar mudanças (até ter um sistema de eventos melhor)
  while (true) {
    await Future.delayed(const Duration(seconds: 2));
    final currentStatus = await repository.isUnlocked(params.moduleId, params.unlockType);
    yield currentStatus;
  }
});

/// Notifier para gerenciar desbloqueios
class ModuleUnlockNotifier extends StateNotifier<AsyncValue<bool>> {
  final ModuleUnlockRepository _repository;
  final String moduleId;
  final String unlockType;

  ModuleUnlockNotifier(this._repository, this.moduleId, this.unlockType) 
      : super(const AsyncValue.loading()) {
    _loadUnlockStatus();
  }

  Future<void> _loadUnlockStatus() async {
    try {
      final isUnlocked = await _repository.isUnlocked(moduleId, unlockType);
      state = AsyncValue.data(isUnlocked);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Desbloqueia a funcionalidade
  Future<void> unlock({String method = 'ad'}) async {
    try {
      await _repository.unlock(moduleId, unlockType, method: method);
      state = const AsyncValue.data(true);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Recarrega o status
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadUnlockStatus();
  }
}

/// Provider para gerenciar desbloqueio específico com notifier
final moduleUnlockNotifierProvider = StateNotifierProvider.family<ModuleUnlockNotifier, AsyncValue<bool>, ({String moduleId, String unlockType})>((ref, params) {
  final repository = ref.read(moduleUnlockRepositoryProvider);
  return ModuleUnlockNotifier(repository, params.moduleId, params.unlockType);
});
