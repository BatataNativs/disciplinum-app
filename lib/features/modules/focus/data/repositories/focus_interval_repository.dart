import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_interval_entity.dart';
import 'package:disciplinum/shared/domain/models/time_of_day_range.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Repositório para gerenciar intervalos de foco usando ObjectBox
class FocusIntervalRepository {
  static FocusIntervalRepository? _instance;
  static FocusIntervalRepository get instance => _instance ??= FocusIntervalRepository._internal();
  
  FocusIntervalRepository._internal();

  Box<FocusIntervalEntity> get _box => ObjectBoxService.instance.store.box<FocusIntervalEntity>();

  Future<FocusIntervalEntity?> _getEntity(int nicheId) async {
    final query = _box.query(FocusIntervalEntity_.nicheId.equals(nicheId)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  /// Salva ou atualiza um intervalo de foco para um nicho
  Future<void> saveInterval({
    required int nicheId,
    required TimeOfDayRange interval,
  }) async {
    try {
      final existing = await _getEntity(nicheId);
      
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
      
      entity.touch();
      _box.put(entity);
      
      LoggerService.instance.i('Intervalo de foco salvo: nicheId=$nicheId, interval=$interval');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar intervalo de foco', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Busca um intervalo de foco por nicheId
  Future<TimeOfDayRange?> getInterval(int nicheId) async {
    try {
      final entity = await _getEntity(nicheId);
      return entity?.toDomain();
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao buscar intervalo de foco', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Busca todos os intervalos de foco
  Future<Map<int, TimeOfDayRange>> getAllIntervals() async {
    try {
      final entities = _box.getAll();
      
      final result = <int, TimeOfDayRange>{};
      for (final entity in entities) {
        result[entity.nicheId] = entity.toDomain();
      }
      
      return result;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao buscar todos os intervalos de foco', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  /// Remove um intervalo de foco por nicheId
  Future<void> removeInterval(int nicheId) async {
    try {
      final query = _box.query(FocusIntervalEntity_.nicheId.equals(nicheId)).build();
      final ids = query.findIds();
      _box.removeMany(ids);
      query.close();
      
      LoggerService.instance.i('Intervalo de foco removido: nicheId=$nicheId');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover intervalo de foco', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Remove todos os intervalos de foco
  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todos os intervalos de foco foram removidos');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar intervalos de foco', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Verifica se existe um intervalo para o nicheId
  Future<bool> hasInterval(int nicheId) async {
    try {
      final interval = await getInterval(nicheId);
      return interval != null;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao verificar existência de intervalo', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
