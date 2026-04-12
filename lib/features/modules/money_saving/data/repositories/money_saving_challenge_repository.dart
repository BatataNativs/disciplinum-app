import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para desafios de economia usando ObjectBox
class MoneySavingChallengeRepository {
  static MoneySavingChallengeRepository? _instance;
  static MoneySavingChallengeRepository get instance => _instance ??= MoneySavingChallengeRepository._internal();
  
  MoneySavingChallengeRepository._internal();

  Box<MoneySavingChallengeEntity> get _box => ObjectBoxService.instance.store.box<MoneySavingChallengeEntity>();
  Box<MoneySavingGridCellEntity> get _cellsBox => ObjectBoxService.instance.store.box<MoneySavingGridCellEntity>();

  Future<List<MoneySavingChallengeEntity>> getAllChallenges() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final query = _box.query(MoneySavingChallengeEntity_.userId.equals(userId)).order(MoneySavingChallengeEntity_.createdAt, flags: Order.descending).build();
      final result = query.find();
      query.close();
      return result;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar desafios de economia', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<MoneySavingChallengeEntity?> getChallenge(String challengeId) async {
    try {
      final query = _box.query(MoneySavingChallengeEntity_.challengeId.equals(challengeId)).build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao buscar desafio de economia', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<MoneySavingChallengeEntity?> getActiveChallenge() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final query = _box.query(
        MoneySavingChallengeEntity_.userId.equals(userId)
          .and(MoneySavingChallengeEntity_.isActive.equals(true))
      ).build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao buscar desafio ativo', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveChallenge(MoneySavingChallengeEntity challenge) async {
    try {
      // Find existing to preserve auto-incrementing ID if updating
      final existing = await getChallenge(challenge.challengeId);
      if (existing != null) {
         challenge.id = existing.id;
      }

      challenge.touch();
      _box.put(challenge);
      
      LoggerService.instance.i('Desafio de economia salvo: ${challenge.title}');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar desafio de economia', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteChallenge(String challengeId) async {
    try {
      final query = _box.query(MoneySavingChallengeEntity_.challengeId.equals(challengeId)).build();
      final ids = query.findIds();
      _box.removeMany(ids);
      query.close();
      
      final cellQuery = _cellsBox.query(MoneySavingGridCellEntity_.challengeId.equals(challengeId)).build();
      final cellIds = cellQuery.findIds();
      _cellsBox.removeMany(cellIds);
      cellQuery.close();
      
      LoggerService.instance.i('Desafio de economia removido: $challengeId');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover desafio de economia', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> setActiveChallenge(String challengeId, bool isActive) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      
      // Desativa todos os desafios do usuário
      final queryActive = _box.query(
        MoneySavingChallengeEntity_.userId.equals(userId)
          .and(MoneySavingChallengeEntity_.isActive.equals(true))
      ).build();
      
      final activeChallenges = queryActive.find();
      queryActive.close();
      
      for (final challenge in activeChallenges) {
        challenge.isActive = false;
        challenge.touch();
      }
      
      if (activeChallenges.isNotEmpty) {
        _box.putMany(activeChallenges);
      }
      
      // Ativa o desafio especificado
      if (isActive) {
        final queryTarget = _box.query(MoneySavingChallengeEntity_.challengeId.equals(challengeId)).build();
        final challenge = queryTarget.findFirst();
        queryTarget.close();
        
        if (challenge != null) {
          challenge.isActive = true;
          challenge.touch();
          _box.put(challenge);
        }
      }
      
      LoggerService.instance.i('Desafio ativo atualizado: $challengeId (active: $isActive)');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao atualizar desafio ativo', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      
      final query = _box.query(MoneySavingChallengeEntity_.userId.equals(userId)).build();
      final ids = query.findIds();
      _box.removeMany(ids);
      query.close();
      
      final cellQuery = _cellsBox.query(MoneySavingGridCellEntity_.challengeId.equals(userId)).build();
      final cellIds = cellQuery.findIds();
      _cellsBox.removeMany(cellIds);
      cellQuery.close();
      
      LoggerService.instance.i('Todos os desafios de economia foram removidos');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar desafios de economia', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Métodos para gerenciar células do grid
  Future<List<MoneySavingGridCellEntity>> getGridCells(String challengeId) async {
    try {
      final query = _cellsBox.query(MoneySavingGridCellEntity_.challengeId.equals(challengeId))
          .order(MoneySavingGridCellEntity_.cellIndex).build();
      final result = query.find();
      query.close();
      return result;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar células do grid', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> saveGridCells(List<MoneySavingGridCellEntity> cells) async {
    try {
      for (final cell in cells) {
        cell.touch();
      }
      _cellsBox.putMany(cells);
      
      LoggerService.instance.i('Células do grid salvas: ${cells.length} células');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar células do grid', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> markCell(String challengeId, int cellIndex) async {
    try {
      final query = _cellsBox.query(
        MoneySavingGridCellEntity_.challengeId.equals(challengeId)
          .and(MoneySavingGridCellEntity_.cellIndex.equals(cellIndex))
      ).build();
      
      final cell = query.findFirst();
      query.close();
      
      if (cell != null) {
        cell.mark();
        _cellsBox.put(cell);
      }
      
      LoggerService.instance.i('Célula marcada: challengeId=$challengeId, index=$cellIndex');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao marcar célula', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> unmarkCell(String challengeId, int cellIndex) async {
    try {
      final query = _cellsBox.query(
        MoneySavingGridCellEntity_.challengeId.equals(challengeId)
          .and(MoneySavingGridCellEntity_.cellIndex.equals(cellIndex))
      ).build();
      
      final cell = query.findFirst();
      query.close();
      
      if (cell != null) {
        cell.unmark();
        _cellsBox.put(cell);
      }
      
      LoggerService.instance.i('Célula desmarcada: challengeId=$challengeId, index=$cellIndex');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao desmarcar célula', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
