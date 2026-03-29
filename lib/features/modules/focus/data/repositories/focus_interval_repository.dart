import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_interval_entity.dart';
import 'package:disciplinum/shared/domain/models/time_of_day_range.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repositório para gerenciar intervalos de foco usando Isar puro
class FocusIntervalRepository {
  static FocusIntervalRepository? _instance;
  static FocusIntervalRepository get instance => _instance ??= FocusIntervalRepository._internal();
  
  FocusIntervalRepository._internal();

  /// Salva ou atualiza um intervalo de foco para um nicho
  Future<void> saveInterval({
    required int nicheId,
    required TimeOfDayRange interval,
  }) async {
    try {
      final isar = IsarService.instance.database;
      
      // Busca se já existe um intervalo para este nicheId
      final existing = await isar.focusIntervalEntitys
          .filter()
          .nicheIdEqualTo(nicheId)
          .findFirst();
      
      final entity = existing != null
          ? existing.copyWith(
              startHour: interval.start.hour,
              startMinute: interval.start.minute,
              endHour: interval.end.hour,
              endMinute: interval.end.minute,
            )
          : FocusIntervalEntity.fromDomain(
              nicheId: nicheId,
              interval: interval,
            );
      
      await isar.writeTxn(() async {
        entity.touch();
        await isar.focusIntervalEntitys.put(entity);
      });
      
      LoggerService.instance.i('Intervalo de foco salvo: nicheId=$nicheId, interval=$interval');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar intervalo de foco', error: e);
      rethrow;
    }
  }

  /// Busca um intervalo de foco por nicheId
  Future<TimeOfDayRange?> getInterval(int nicheId) async {
    try {
      final isar = IsarService.instance.database;
      
      final entity = await isar.focusIntervalEntitys
          .filter()
          .nicheIdEqualTo(nicheId)
          .findFirst();
      
      return entity?.toDomain();
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar intervalo de foco', error: e);
      return null;
    }
  }

  /// Busca todos os intervalos de foco
  Future<Map<int, TimeOfDayRange>> getAllIntervals() async {
    try {
      final isar = IsarService.instance.database;
      
      final entities = await isar.focusIntervalEntitys.where().findAll();
      
      final result = <int, TimeOfDayRange>{};
      for (final entity in entities) {
        result[entity.nicheId] = entity.toDomain();
      }
      
      return result;
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar todos os intervalos de foco', error: e);
      return {};
    }
  }

  /// Remove um intervalo de foco por nicheId
  Future<void> removeInterval(int nicheId) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.focusIntervalEntitys
            .filter()
            .nicheIdEqualTo(nicheId)
            .deleteAll();
      });
      
      LoggerService.instance.i('Intervalo de foco removido: nicheId=$nicheId');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover intervalo de foco', error: e);
      rethrow;
    }
  }

  /// Remove todos os intervalos de foco
  Future<void> clearAll() async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.focusIntervalEntitys.clear();
      });
      
      LoggerService.instance.i('Todos os intervalos de foco foram removidos');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar intervalos de foco', error: e);
      rethrow;
    }
  }

  /// Verifica se existe um intervalo para o nicheId
  Future<bool> hasInterval(int nicheId) async {
    try {
      final interval = await getInterval(nicheId);
      return interval != null;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar existência de intervalo', error: e);
      return false;
    }
  }
}
