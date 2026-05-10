import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/storage/entities/user_choices_entity.dart';
import 'package:disciplinum/core/storage/repositories/user_choices_repository.dart';
import 'package:disciplinum/core/storage/services/user_choices_sync_service.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Provider para gerenciar escolhas do usuário com persistência dual
/// Combina ObjectBox (local) + Supabase (cloud) com Riverpod
/// Provider para o ID do usuário atual
final currentUserIdProvider = Provider<String>((ref) {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser != null) {
    return currentUser.id;
  }
  
  // Fallback para usuário não autenticado (modo convidado)
  return 'guest_user';
});

/// Provider para o repositório de escolhas
final userChoicesRepositoryProvider = Provider<UserChoicesRepository>((ref) {
  return UserChoicesRepository(ObjectBoxService.instance.store);
});

/// Provider para o serviço de sincronização
final userChoicesSyncServiceProvider = Provider<UserChoicesSyncService>((ref) {
  final repository = ref.watch(userChoicesRepositoryProvider);
  return UserChoicesSyncService(
    Supabase.instance.client,
    repository,
  );
});

/// Provider para as escolhas do usuário atual
final userChoicesProvider = FutureProvider<UserChoicesEntity?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(userChoicesRepositoryProvider);
  return await repository.getByUserId(userId);
});

/// Provider para o estado de sincronização
final syncStatusProvider = Provider<SyncStatus>((ref) {
  return const SyncStatus();
});

/// Controller para gerenciar as escolhas
final userChoicesControllerProvider = Provider<UserChoicesController>((ref) {
  return UserChoicesController(ref);
});

/// Estado de sincronização
class SyncStatus {
  final bool isSyncing;
  final String? lastSync;
  final String? error;
  
  const SyncStatus({
    this.isSyncing = false,
    this.lastSync,
    this.error,
  });
}

/// Controller para gerenciar as escolhas do usuário
class UserChoicesController {
  final Ref _ref;
  UserChoicesEntity? _cachedChoices;
  
  UserChoicesController(this._ref);

  /// Obtém as escolhas atuais
  UserChoicesEntity? get choices => _cachedChoices;

  /// Inicializa as escolhas (busca local, depois nuvem se necessário)
  Future<void> initialize() async {
    try {
      final userId = _ref.read(currentUserIdProvider);
      LoggerService.instance.d('🔐 Inicializando UserChoices para userId: $userId');
      
      // Tenta obter localmente primeiro
      var choices = await _ref.read(userChoicesProvider.future);
      
      if (choices == null) {
        LoggerService.instance.d('🔐 Nenhuma escolha local, tentando nuvem');
        // Se não tiver local, busca da nuvem
        final syncService = _ref.read(userChoicesSyncServiceProvider);
        choices = await syncService.fetchFromCloud(userId);
        
        if (choices != null) {
          // Salva localmente se encontrou na nuvem
          final repository = _ref.read(userChoicesRepositoryProvider);
          await repository.save(choices);
          LoggerService.instance.i('🔐 Escolhas carregadas da nuvem e salvas localmente');
        }
      }
      
      _cachedChoices = choices;
      LoggerService.instance.d('🔐 UserChoices inicializado: ${choices?.toString()}');
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao inicializar UserChoices', error: e);
    }
  }

  /// Atualiza visibilidade do e-mail
  Future<bool> updateShowEmail(bool showEmail) async {
    try {
      final userId = _ref.read(currentUserIdProvider);
      LoggerService.instance.d('🔐 Atualizando showEmail: $showEmail para userId: $userId');
      
      final syncService = _ref.read(userChoicesSyncServiceProvider);
      final success = await syncService.updateField(userId, 'show_email', showEmail);
      if (success) {
        _invalidateCache();
        LoggerService.instance.i('🔐 showEmail atualizado com sucesso');
      }
      
      return success;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao atualizar showEmail', error: e);
      return false;
    }
  }

  /// Atualiza visibilidade do avatar
  Future<bool> updateShowAvatar(bool showAvatar) async {
    try {
      final userId = _ref.read(currentUserIdProvider);
      LoggerService.instance.d('🔐 Atualizando showAvatar: $showAvatar para userId: $userId');
      
      final syncService = _ref.read(userChoicesSyncServiceProvider);
      final success = await syncService.updateField(userId, 'show_avatar', showAvatar);
      if (success) {
        _invalidateCache();
        LoggerService.instance.i('🔐 showAvatar atualizado com sucesso');
      }
      
      return success;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao atualizar showAvatar', error: e);
      return false;
    }
  }

  /// Atualiza tema
  Future<bool> updateTheme(String theme) async {
    try {
      final userId = _ref.read(currentUserIdProvider);
      LoggerService.instance.d('🔐 Atualizando theme: $theme para userId: $userId');
      
      final syncService = _ref.read(userChoicesSyncServiceProvider);
      final success = await syncService.updateField(userId, 'theme', theme);
      if (success) {
        _invalidateCache();
        LoggerService.instance.i('🔐 theme atualizado com sucesso');
      }
      
      return success;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao atualizar theme', error: e);
      return false;
    }
  }

  /// Atualiza configurações de notificações
  Future<bool> updateNotificationSettings({
    required bool enabled,
    required String time,
  }) async {
    try {
      final userId = _ref.read(currentUserIdProvider);
      LoggerService.instance.d('🔐 Atualizando notificações: enabled=$enabled, time=$time para userId: $userId');
      
      final syncService = _ref.read(userChoicesSyncServiceProvider);
      final success = await syncService.updateField(userId, 'notifications_enabled', enabled) &&
                   await syncService.updateField(userId, 'notification_time', time);
      
      if (success) {
        _invalidateCache();
        LoggerService.instance.i('🔐 Configurações de notificação atualizadas com sucesso');
      }
      
      return success;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao atualizar configurações de notificação', error: e);
      return false;
    }
  }

  /// Atualiza idioma
  Future<bool> updateLanguage(String language) async {
    try {
      final userId = _ref.read(currentUserIdProvider);
      LoggerService.instance.d('🔐 Atualizando idioma: $language para userId: $userId');
      
      final syncService = _ref.read(userChoicesSyncServiceProvider);
      final success = await syncService.updateField(userId, 'language', language);
      if (success) {
        _invalidateCache();
        LoggerService.instance.i('🔐 Idioma atualizado com sucesso');
      }
      
      return success;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao atualizar idioma', error: e);
      return false;
    }
  }

  /// Atualiza visibilidade de módulo específico
  Future<bool> updateModuleVisibility(String moduleId, bool isVisible) async {
    try {
      final userId = _ref.read(currentUserIdProvider);
      LoggerService.instance.d('🔐 Atualizando visibilidade do módulo $moduleId: $isVisible para userId: $userId');
      
      final syncService = _ref.read(userChoicesSyncServiceProvider);
      final success = await syncService.updateModuleVisibility(userId, moduleId, isVisible);
      if (success) {
        _invalidateCache();
        LoggerService.instance.i('🔐 Visibilidade do módulo $moduleId atualizada com sucesso');
      }
      
      return success;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao atualizar visibilidade do módulo $moduleId', error: e);
      return false;
    }
  }

  /// Obtém visibilidade de um módulo específico
  bool getModuleVisibility(String moduleId) {
    final choices = _cachedChoices;
    return choices?.moduleVisibility[moduleId] ?? true; // Default: visível
  }

  /// Sincronização completa
  Future<bool> fullSync() async {
    try {
      final userId = _ref.read(currentUserIdProvider);
      LoggerService.instance.i('🔐 Iniciando sincronização completa para userId: $userId');
      
      _updateSyncStatus(const SyncStatus(isSyncing: true));
      
      final syncService = _ref.read(userChoicesSyncServiceProvider);
      final success = await syncService.fullSync(userId);
      
      _updateSyncStatus(SyncStatus(
        isSyncing: false,
        lastSync: DateTime.now().toIso8601String(),
        error: success ? null : 'Falha na sincronização',
      ));
      
      _invalidateCache();
      
      LoggerService.instance.i('🔐 Sincronização completa ${success ? 'concluída' : 'falhou'} para userId: $userId');
      return success;
    } catch (e) {
      _updateSyncStatus(SyncStatus(
        isSyncing: false,
        error: e.toString(),
      ));
      LoggerService.instance.e('🔐 Erro na sincronização completa', error: e);
      return false;
    }
  }

  /// Obtém estatísticas de sincronização
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final userId = _ref.read(currentUserIdProvider);
      final syncService = _ref.read(userChoicesSyncServiceProvider);
      return await syncService.getSyncStats(userId);
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao obter estatísticas', error: e);
      return {'error': e.toString()};
    }
  }

  /// Limpa todos os dados do usuário
  Future<bool> clearAll() async {
    try {
      final userId = _ref.read(currentUserIdProvider);
      LoggerService.instance.i('🔐 Limpando todos os dados para userId: $userId');
      
      final syncService = _ref.read(userChoicesSyncServiceProvider);
      final success = await syncService.clearUserData(userId);
      
      _invalidateCache();
      
      LoggerService.instance.i('🔐 Dados limpos ${success ? 'com sucesso' : 'com falha'} para userId: $userId');
      return success;
    } catch (e) {
      LoggerService.instance.e('🔐 Erro ao limpar dados', error: e);
      return false;
    }
  }

  /// Invalida cache local
  void _invalidateCache() {
    _ref.invalidate(userChoicesProvider);
    _cachedChoices = null;
  }

  /// Atualiza estado de sincronização
  void _updateSyncStatus(SyncStatus status) {
    // Aqui poderíamos ter um provider separado para o status de sincronização
    // se necessário futuramente
  }
}
