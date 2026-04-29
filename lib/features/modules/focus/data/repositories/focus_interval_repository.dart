import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_interval_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/shared/domain/models/time_of_day_range.dart';

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

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  /// Sincroniza todos os intervalos do usuário com o Supabase
  Future<void> syncWithSupabase() async {
    try {
      final entities = _box.getAll();

      final intervalsData = entities.map((interval) => {
        'id': interval.id,
        'niche_id': interval.nicheId,
        'start_hour': interval.startHour,
        'start_minute': interval.startMinute,
        'end_hour': interval.endHour,
        'end_minute': interval.endMinute,
        'created_at': interval.createdAt.toIso8601String(),
        'updated_at': interval.updatedAt.toIso8601String(),
      }).toList();

      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      await Supabase.instance.client.from('user_module_settings').upsert({
        'user_id': userId,
        'module_id': 'focus_intervals',
        'intervals_data': intervalsData,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, module_id');

      LoggerService.instance.i('${entities.length} intervalos de foco sincronizados com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar intervalos com Supabase', error: e);
    }
  }

  /// Carrega intervalos do Supabase
  Future<List<FocusIntervalEntity>> loadFromSupabase() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final response = await Supabase.instance.client
          .from('user_module_settings')
          .select()
          .eq('user_id', userId)
          .eq('module_id', 'focus_intervals')
          .maybeSingle();

      if (response == null || response['intervals_data'] == null) {
        return [];
      }

      final intervalsData = response['intervals_data'] as List<dynamic>;
      final intervals = intervalsData.map((data) {
        final entity = FocusIntervalEntity(
          nicheId: data['niche_id'] ?? 0,
          startHour: data['start_hour'] ?? 0,
          startMinute: data['start_minute'] ?? 0,
          endHour: data['end_hour'] ?? 0,
          endMinute: data['end_minute'] ?? 0,
        );
        entity.id = data['id'] ?? 0;
        entity.createdAt = data['created_at'] != null
            ? DateTime.parse(data['created_at'])
            : DateTime.now();
        entity.updatedAt = data['updated_at'] != null
            ? DateTime.parse(data['updated_at'])
            : DateTime.now();

        return entity;
      }).toList();

      LoggerService.instance.i('${intervals.length} intervalos de foco carregados do Supabase');
      return intervals;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar intervalos do Supabase', error: e);
      return [];
    }
  }

  /// Sincronização bidirecional completa
  Future<void> performFullSync() async {
    try {
      // Carrega da nuvem primeiro
      final cloudIntervals = await loadFromSupabase();

      if (cloudIntervals.isNotEmpty) {
        // Limpa os existentes e salva os da nuvem
        _box.removeAll();
        for (final interval in cloudIntervals) {
          _box.put(interval);
        }
        LoggerService.instance.i('Sincronização: ${cloudIntervals.length} intervalos da nuvem salvos localmente');
      } else {
        // Se não tem na nuvem, envia os locais
        await syncWithSupabase();
      }
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa de intervalos', error: e);
    }
  }
}
