import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para desafios de economia usando Isar puro
class MoneySavingChallengeRepository {
  static MoneySavingChallengeRepository? _instance;
  static MoneySavingChallengeRepository get instance => _instance ??= MoneySavingChallengeRepository._internal();
  
  MoneySavingChallengeRepository._internal();

  Future<List<MoneySavingChallengeEntity>> getAllChallenges() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      return await isar.moneySavingChallengeEntitys
          .filter()
          .userIdEqualTo(userId)
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar desafios de economia', error: e);
      return [];
    }
  }

  Future<MoneySavingChallengeEntity?> getChallenge(String challengeId) async {
    try {
      final isar = IsarService.instance.database;
      
      return await isar.moneySavingChallengeEntitys
          .filter()
          .challengeIdEqualTo(challengeId)
          .findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar desafio de economia', error: e);
      return null;
    }
  }

  Future<MoneySavingChallengeEntity?> getActiveChallenge() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      return await isar.moneySavingChallengeEntitys
          .filter()
          .userIdEqualTo(userId)
          .isActiveEqualTo(true)
          .findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar desafio ativo', error: e);
      return null;
    }
  }

  Future<void> saveChallenge(MoneySavingChallengeEntity challenge) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        challenge.touch();
        await isar.moneySavingChallengeEntitys.put(challenge);
      });
      
      LoggerService.instance.i('Desafio de economia salvo: ${challenge.title}');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar desafio de economia', error: e);
      rethrow;
    }
  }

  Future<void> deleteChallenge(String challengeId) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        // Remove o desafio
        await isar.moneySavingChallengeEntitys
            .filter()
            .challengeIdEqualTo(challengeId)
            .deleteAll();
        
        // Remove as células do grid
        await isar.moneySavingGridCellEntitys
            .filter()
            .challengeIdEqualTo(challengeId)
            .deleteAll();
      });
      
      LoggerService.instance.i('Desafio de economia removido: $challengeId');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover desafio de economia', error: e);
      rethrow;
    }
  }

  Future<void> setActiveChallenge(String challengeId, bool isActive) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        // Desativa todos os desafios do usuário
        final activeChallenges = await isar.moneySavingChallengeEntitys
            .filter()
            .userIdEqualTo(userId)
            .isActiveEqualTo(true)
            .findAll();
        
        for (final challenge in activeChallenges) {
          challenge.isActive = false;
          challenge.touch();
        }
        
        await isar.moneySavingChallengeEntitys.putAll(activeChallenges);
        
        // Ativa o desafio especificado
        if (isActive) {
          final challenge = await isar.moneySavingChallengeEntitys
              .filter()
              .challengeIdEqualTo(challengeId)
              .findFirst();
          
          if (challenge != null) {
            challenge.isActive = true;
            challenge.touch();
            await isar.moneySavingChallengeEntitys.put(challenge);
          }
        }
      });
      
      LoggerService.instance.i('Desafio ativo atualizado: $challengeId (active: $isActive)');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar desafio ativo', error: e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.moneySavingChallengeEntitys
            .filter()
            .userIdEqualTo(userId)
            .deleteAll();
        
        await isar.moneySavingGridCellEntitys
            .filter()
            .challengeIdEqualTo(userId) // Isso precisa ser corrigido
            .deleteAll();
      });
      
      LoggerService.instance.i('Todos os desafios de economia foram removidos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar desafios de economia', error: e);
      rethrow;
    }
  }

  // Métodos para gerenciar células do grid
  Future<List<MoneySavingGridCellEntity>> getGridCells(String challengeId) async {
    try {
      final isar = IsarService.instance.database;
      
      return await isar.moneySavingGridCellEntitys
          .filter()
          .challengeIdEqualTo(challengeId)
          .sortByCellIndex()
          .findAll();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar células do grid', error: e);
      return [];
    }
  }

  Future<void> saveGridCells(List<MoneySavingGridCellEntity> cells) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        for (final cell in cells) {
          cell.touch();
          await isar.moneySavingGridCellEntitys.put(cell);
        }
      });
      
      LoggerService.instance.i('Células do grid salvas: ${cells.length} células');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar células do grid', error: e);
      rethrow;
    }
  }

  Future<void> markCell(String challengeId, int cellIndex) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        final cell = await isar.moneySavingGridCellEntitys
            .filter()
            .challengeIdEqualTo(challengeId)
            .cellIndexEqualTo(cellIndex)
            .findFirst();
        
        if (cell != null) {
          cell.mark();
          await isar.moneySavingGridCellEntitys.put(cell);
        }
      });
      
      LoggerService.instance.i('Célula marcada: challengeId=$challengeId, index=$cellIndex');
    } catch (e) {
      LoggerService.instance.e('Erro ao marcar célula', error: e);
      rethrow;
    }
  }

  Future<void> unmarkCell(String challengeId, int cellIndex) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        final cell = await isar.moneySavingGridCellEntitys
            .filter()
            .challengeIdEqualTo(challengeId)
            .cellIndexEqualTo(cellIndex)
            .findFirst();
        
        if (cell != null) {
          cell.unmark();
          await isar.moneySavingGridCellEntitys.put(cell);
        }
      });
      
      LoggerService.instance.i('Célula desmarcada: challengeId=$challengeId, index=$cellIndex');
    } catch (e) {
      LoggerService.instance.e('Erro ao desmarcar célula', error: e);
      rethrow;
    }
  }
}
