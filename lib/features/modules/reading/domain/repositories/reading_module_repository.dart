import 'dart:async';
import 'package:disciplinum/core/modules/contracts/module_contracts.dart';
import 'package:disciplinum/core/modules/contracts/module_repository_contract.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/reading/gamification/domain/entities/reading_gamification_entity.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_module_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository do módulo Reading implementando ModuleRepositoryContract
class ReadingModuleRepository implements ModuleRepositoryContract<ReadingModuleState> {
  static ReadingModuleRepository? _instance;
  static ReadingModuleRepository get instance => _instance ??= ReadingModuleRepository._();
  
  ReadingModuleRepository._();

  final _statusController = StreamController<RepositoryStatus>.broadcast();
  RepositoryStatus _status = RepositoryStatus.initializing;

  @override
  String get moduleId => 'reading';

  @override
  RepositoryStatus get status => _status;

  @override
  Stream<RepositoryStatus> get statusStream => _statusController.stream;

  void _setStatus(RepositoryStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  @override
  Future<void> initialize() async {
    _setStatus(RepositoryStatus.ready);
    LoggerService.instance.gamification('ReadingModuleRepository inicializado');
  }

  @override
  Future<void> dispose() async {
    _setStatus(RepositoryStatus.disposed);
    await _statusController.close();
  }

  @override
  Future<ReadingModuleState> saveLocal(ReadingModuleState state) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      final store = ObjectBoxService.instance.store;
      final box = store.box<ReadingGamificationEntity>();
      
      // Busca se já existe algum objeto no box
      final existing = box.getAll().firstOrNull;
      
      final entity = ReadingGamificationEntity()
        ..earnedInsigniasList = state.earnedInsignias
        ..earnedMedalhasList = state.earnedMedalhas
        ..consecutiveDays = state.consecutiveDays
        ..lastReadingDate = state.lastReadingDate
        ..startDate = state.startDate
        ..touch();
      
      // Se já existe, usa o mesmo ID para atualizar
      // Se não existe, usa ID 0 para deixar ObjectBox gerar novo ID
      if (existing != null) {
        entity.id = existing.id;
      } else {
        entity.id = 0; // ObjectBox vai gerar novo ID
      }

      box.put(entity);

      LoggerService.instance.gamification('✅ ReadingModuleState salvo localmente (id=${entity.id})');
      _setStatus(RepositoryStatus.ready);
      return state;
    } catch (e) {
      _setStatus(RepositoryStatus.error);
      throw RepositoryException(
        message: 'Erro ao salvar localmente: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.saveLocal,
        originalError: e,
      );
    }
  }

  @override
  Future<ReadingModuleState?> loadLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      
      final store = ObjectBoxService.instance.store;
      final entity = store.box<ReadingGamificationEntity>().get(1);

      _setStatus(RepositoryStatus.ready);

      if (entity != null) {
        return entity.toModuleState();
      }
      return null;
    } catch (e) {
      _setStatus(RepositoryStatus.error);
      throw RepositoryException(
        message: 'Erro ao carregar localmente: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.loadLocal,
        originalError: e,
      );
    }
  }

  @override
  Future<bool> existsLocal(String userId) async {
    try {
      final store = ObjectBoxService.instance.store;
      final count = store.box<ReadingGamificationEntity>().count();
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteLocal(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      final store = ObjectBoxService.instance.store;
      store.box<ReadingGamificationEntity>().removeAll();
      LoggerService.instance.gamification('🗑️ ReadingModuleState local deletado');
      _setStatus(RepositoryStatus.ready);
    } catch (e) {
      _setStatus(RepositoryStatus.error);
      throw RepositoryException(
        message: 'Erro ao deletar localmente: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.deleteLocal,
        originalError: e,
      );
    }
  }

  @override
  Future<List<ReadingModuleState>> listAllLocal() async {
    try {
      final store = ObjectBoxService.instance.store;
      final entities = store.box<ReadingGamificationEntity>().getAll();
      return entities.map((e) => ReadingModuleState.fromJson(e.toJson())).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ReadingModuleState> syncToRemote(String userId, ReadingModuleState state) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) throw Exception('Usuário não autenticado');

      await supabase.from('reading_gamification_states').upsert({
        'user_id': currentUserId,
        'state_data': state.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      LoggerService.instance.gamification('☁️ ReadingModuleState sincronizado');
      _setStatus(RepositoryStatus.ready);
      return state;
    } catch (e) {
      _setStatus(RepositoryStatus.offline);
      throw RepositoryException(
        message: 'Erro ao sincronizar: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.syncToRemote,
        originalError: e,
      );
    }
  }

  @override
  Future<ReadingModuleState?> loadFromRemote(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) return null;

      final response = await supabase
          .from('reading_gamification_states')
          .select('state_data')
          .eq('user_id', currentUserId)
          .maybeSingle();

      _setStatus(RepositoryStatus.ready);
      
      if (response != null && response['state_data'] != null) {
        return ReadingModuleState.fromJson(response['state_data']);
      }
      return null;
    } catch (e) {
      _setStatus(RepositoryStatus.offline);
      throw RepositoryException(
        message: 'Erro ao carregar do remoto: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.loadFromRemote,
        originalError: e,
      );
    }
  }

  @override
  Future<bool> existsRemote(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      final response = await supabase
          .from('reading_gamification_states')
          .select('id')
          .eq('user_id', currentUserId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteRemote(String userId) async {
    try {
      _setStatus(RepositoryStatus.busy);
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId != null) {
        await supabase.from('reading_gamification_states').delete().eq('user_id', currentUserId);
      }
      LoggerService.instance.gamification('🗑️ ReadingModuleState remoto deletado');
      _setStatus(RepositoryStatus.ready);
    } catch (e) {
      _setStatus(RepositoryStatus.error);
      throw RepositoryException(
        message: 'Erro ao deletar remotamente: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.deleteRemote,
        originalError: e,
      );
    }
  }

  @override
  Future<ReadingModuleState> resolveConflict(ReadingModuleState local, ReadingModuleState remote) async {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      LoggerService.instance.gamification('⚡ Conflito resolvido: local é mais recente');
      return local;
    } else {
      LoggerService.instance.gamification('⚡ Conflito resolvido: remoto é mais recente');
      return remote;
    }
  }

  @override
  Future<ReadingModuleState> fullSync(String userId) async {
    try {
      _setStatus(RepositoryStatus.syncing);
      final local = await loadLocal(userId);
      final remote = await loadFromRemote(userId);

      ReadingModuleState result;
      if (local == null && remote == null) {
        result = ReadingModuleState();
        await saveLocal(result);
        await syncToRemote(userId, result);
      } else if (local == null && remote != null) {
        result = remote;
        await saveLocal(result);
      } else if (local != null && remote == null) {
        result = local;
        await syncToRemote(userId, result);
      } else {
        result = await resolveConflict(local!, remote!);
        await saveLocal(result);
        await syncToRemote(userId, result);
      }

      LoggerService.instance.gamification('🔄 ReadingModuleState full sync completo');
      _setStatus(RepositoryStatus.ready);
      return result;
    } catch (e) {
      _setStatus(RepositoryStatus.error);
      throw RepositoryException(
        message: 'Erro no full sync: $e',
        moduleId: moduleId,
        operation: RepositoryOperation.fullSync,
        originalError: e,
      );
    }
  }

  @override
  Future<bool> hasDivergence(String userId) async {
    try {
      final local = await loadLocal(userId);
      final remote = await loadFromRemote(userId);
      if (local == null && remote == null) return false;
      if (local == null || remote == null) return true;
      return local.updatedAt != remote.updatedAt;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAll(String userId) async {
    await deleteLocal(userId);
    await deleteRemote(userId);
    LoggerService.instance.gamification('🧹 ReadingModuleState completamente limpo');
  }

  @override
  Future<Map<String, dynamic>> exportToJson(String userId) async {
    final local = await loadLocal(userId);
    return {
      'module_id': moduleId,
      'exported_at': DateTime.now().toIso8601String(),
      'state': local?.toJson(),
    };
  }

  @override
  Future<ReadingModuleState> importFromJson(Map<String, dynamic> json) async {
    final state = ReadingModuleState.fromJson(json['state'] as Map<String, dynamic>);
    await saveLocal(state);
    LoggerService.instance.gamification('📥 ReadingModuleState importado');
    return state;
  }
}
