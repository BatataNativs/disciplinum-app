import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/storage/entities/daily_checkin_entity.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_insignia_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';

/// Serviço responsável por registrar e carregar os check-ins diários
/// do módulo Parar de Fumar (resposta "Sim" na notificação diária).
class SmokingCheckinService {
  final Box<DailyCheckin> _box;
  final CloudSyncService _cloudSync;
  final SmokingInsigniaService _insigniaService;

  SmokingCheckinService(
    ObjectBoxService objectBoxService,
    this._cloudSync,
    this._insigniaService,
  ) : _box = objectBoxService.store.box<DailyCheckin>() {
    // Registra listener para eventos de check-in via notificação
    _registerEventListeners();
  }
  
  /// Registra listeners para eventos do EventBus
  void _registerEventListeners() {
    EventBus.instance.listen<ModuleCheckInEvent>((event) {
      if (event.nicheId == NicheId.smoking.index && event.isPositive) {
        LoggerService.instance.i('📥 Evento de check-in recebido para Smoking');
        // Registra o check-in quando usuário responde "Sim" na notificação
        recordCheckin(date: event.checkInDate);
      }
    });
    
    LoggerService.instance.i('👂 SmokingCheckinService: Listeners de eventos registrados');
  }

  /// Formata DateTime como string de data (yyyy-MM-dd)
  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Registra check-in do dia atual (ou de [date] se fornecida).
  /// Idempotente — não duplica se chamado mais de uma vez no mesmo dia.
  Future<void> recordCheckin({DateTime? date}) async {
    final target = date ?? DateTime.now();
    final dateStr = _dateKey(target);
    final nicheIdDate = '${NicheId.smoking.index}_$dateStr';

    // 1. Persiste localmente no ObjectBox
    try {
      final existing = _box.query(DailyCheckin_.nicheIdDate.equals(nicheIdDate))
          .build()
          .findFirst();

      if (existing == null) {
        _box.put(
          DailyCheckin.create(
            nicheId: NicheId.smoking,
            dateStr: dateStr,
          ),
        );
        LoggerService.instance.i('✅ Check-in local registrado para $dateStr (Smoking)');
        
        // 2. Após registrar check-in, atualiza gamificação
        // Carrega todos os check-ins para calcular dias consecutivos
        final allCheckins = await loadCheckins();
        final consecutiveDays = _calculateConsecutiveDays(allCheckins);
        
        // Atualiza insígnias, medalhas e marcos de saúde
        await _insigniaService.updateFromCheckIns(consecutiveDays);
        
        LoggerService.instance.i('🎮 Gamificação atualizada: $consecutiveDays dias consecutivos');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar check-in no ObjectBox', error: e);
    }

    // 3. Persiste na nuvem
    await _cloudSync.saveDailyCheckin(
      nicheId: NicheId.smoking,
      dateStr: dateStr,
    );
  }

  /// Calcula dias consecutivos a partir de uma lista de check-ins
  int _calculateConsecutiveDays(List<DateTime> checkins) {
    if (checkins.isEmpty) return 0;
    
    // Ordena check-ins do mais recente para o mais antigo
    final sorted = checkins.toList()..sort((a, b) => b.compareTo(a));
    
    // Conta dias consecutivos a partir de hoje
    int consecutive = 0;
    var currentDate = DateTime.now();
    
    for (final checkin in sorted) {
      final checkinDate = DateTime(checkin.year, checkin.month, checkin.day);
      final expectedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
      
      if (checkinDate.isAtSameMomentAs(expectedDate)) {
        consecutive++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return consecutive;
  }

  /// Carrega todas as datas de check-in.
  /// Tenta nuvem primeiro, com fallback local (ObjectBox).
  Future<List<DateTime>> loadCheckins() async {
    // 1. Tentar carregar da nuvem e sincronizar
    try {
      final cloudDatesStr = await _cloudSync.loadDailyCheckins(NicheId.smoking);
      if (cloudDatesStr.isNotEmpty) {
        await _syncObjectBoxFromCloud(cloudDatesStr);
        return cloudDatesStr.map((s) => DateTime.parse(s)).toList();
      }
    } catch (e) {
      LoggerService.instance.w('Erro ao carregar check-ins da nuvem', error: e);
    }

    // 2. Fallback: carregar do ObjectBox
    try {
      final smokingIndex = NicheId.smoking.index;
      final localCheckins = _box.query(DailyCheckin_.nicheIdIndex.equals(smokingIndex))
          .build()
          .find();
      
      return localCheckins.map((c) => DateTime.parse(c.dateStr)).toList();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar check-ins do ObjectBox', error: e);
      return [];
    }
  }

  /// Apaga todos os check-ins do usuário (usado no reset de módulo).
  Future<void> clearAllCheckins() async {
    // 1. Limpa ObjectBox
    try {
      final smokingIndex = NicheId.smoking.index;
      final query = _box.query(DailyCheckin_.nicheIdIndex.equals(smokingIndex)).build();
      final toDelete = query.find();
      query.close();
      
      for (final checkin in toDelete) {
        _box.remove(checkin.id);
      }
      LoggerService.instance.i('🗑️ Check-ins locais apagados (Smoking)');
    } catch (e) {
      LoggerService.instance.e('Erro ao apagar check-ins no ObjectBox', error: e);
    }

    // 2. Limpa Nuvem
    await _cloudSync.clearDailyCheckins(NicheId.smoking);
  }

  Future<void> _syncObjectBoxFromCloud(List<String> cloudDatesStr) async {
    try {
      for (final dateStr in cloudDatesStr) {
        final nicheIdDate = '${NicheId.smoking.index}_$dateStr';
        final exists = _box.query(DailyCheckin_.nicheIdDate.equals(nicheIdDate))
            .build()
            .findFirst();

        if (exists == null) {
          _box.put(
            DailyCheckin.create(
              nicheId: NicheId.smoking,
              dateStr: dateStr,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar ObjectBox com nuvem', error: e);
    }
  }
}
