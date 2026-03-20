import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/storage/entities/daily_checkin_entity.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';

/// Serviço responsável por registrar e carregar os check-ins diários
/// do módulo Parar de Fumar (resposta "Sim" na notificação diária).
class SmokingCheckinService {
  static const String _prefsKey = 'smoking_checkin_dates';
  
  final IsarService _isarService;
  final CloudSyncService _cloudSync;
  final SharedPreferences _prefs;

  SmokingCheckinService(this._isarService, this._cloudSync, this._prefs) {
    // Tentar migração ao inicializar
    _migrateFromPrefs();
  }

  /// Formata DateTime como string de data (yyyy-MM-dd)
  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Registra check-in do dia atual (ou de [date] se fornecida).
  /// Idempotente — não duplica se chamado mais de uma vez no mesmo dia.
  Future<void> recordCheckin({DateTime? date}) async {
    final target = date ?? DateTime.now();
    final dateStr = _dateKey(target);

    // 1. Persiste localmente no Isar
    try {
      final existing = await _isarService.dailyCheckins
          .filter()
          .nicheIdEqualTo(NicheId.smoking)
          .dateStrEqualTo(dateStr)
          .findFirst();

      if (existing == null) {
        await _isarService.database.writeTxn(() async {
          await _isarService.dailyCheckins.put(
            DailyCheckin(
              nicheId: NicheId.smoking,
              dateStr: dateStr,
            ),
          );
        });
        LoggerService.instance.i('✅ Check-in local registrado para $dateStr (Smoking)');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar check-in no Isar', error: e);
    }

    // 2. Persiste na nuvem
    await _cloudSync.saveDailyCheckin(
      nicheId: NicheId.smoking,
      dateStr: dateStr,
    );
  }

  /// Carrega todas as datas de check-in.
  /// Tenta nuvem primeiro, com fallback local (Isar).
  Future<List<DateTime>> loadCheckins() async {
    // 1. Tentar carregar da nuvem e sincronizar
    try {
      final cloudDatesStr = await _cloudSync.loadDailyCheckins(NicheId.smoking);
      if (cloudDatesStr.isNotEmpty) {
        await _syncIsarFromCloud(cloudDatesStr);
        return cloudDatesStr.map((s) => DateTime.parse(s)).toList();
      }
    } catch (e) {
      LoggerService.instance.w('Erro ao carregar check-ins da nuvem', error: e);
    }

    // 2. Fallback: carregar do Isar
    try {
      final localCheckins = await _isarService.dailyCheckins
          .filter()
          .nicheIdEqualTo(NicheId.smoking)
          .findAll();
      
      return localCheckins.map((c) => DateTime.parse(c.dateStr)).toList();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar check-ins do Isar', error: e);
      return [];
    }
  }

  /// Apaga todos os check-ins do usuário (usado no reset de módulo).
  Future<void> clearAllCheckins() async {
    // 1. Limpa Isar
    try {
      await _isarService.database.writeTxn(() async {
        await _isarService.dailyCheckins
            .filter()
            .nicheIdEqualTo(NicheId.smoking)
            .deleteAll();
      });
      LoggerService.instance.i('🗑️ Check-ins locais apagados (Smoking)');
    } catch (e) {
      LoggerService.instance.e('Erro ao apagar check-ins no Isar', error: e);
    }

    // 2. Limpa Nuvem
    await _cloudSync.clearDailyCheckins(NicheId.smoking);
  }

  // --- MÉTODOS DE MANUTENÇÃO ---

  /// Migra dados do SharedPreferences para o Isar (uma única vez)
  Future<void> _migrateFromPrefs() async {
    try {
      if (!_prefs.containsKey(_prefsKey)) return;

      final stored = _prefs.getStringList(_prefsKey) ?? [];
      if (stored.isEmpty) return;

      LoggerService.instance.i('📦 Iniciando migração de SmokingCheckins para Isar (${stored.length} itens)');

      await _isarService.database.writeTxn(() async {
        for (final dateStr in stored) {
          // Verificar se já existe no Isar para evitar duplicatas por causa do rollback/crash
          final exists = await _isarService.dailyCheckins
              .filter()
              .nicheIdEqualTo(NicheId.smoking)
              .dateStrEqualTo(dateStr)
              .findFirst();

          if (exists == null) {
            await _isarService.dailyCheckins.put(
              DailyCheckin(
                nicheId: NicheId.smoking,
                dateStr: dateStr,
              ),
            );
          }
        }
      });

      // Remover do Prefs após migração bem-sucedida
      await _prefs.remove(_prefsKey);
      LoggerService.instance.i('✅ Migração de SmokingCheckins concluída e Prefs limpo.');
    } catch (e) {
      LoggerService.instance.e('Erro durante migração de SmokingCheckins', error: e);
    }
  }

  Future<void> _syncIsarFromCloud(List<String> cloudDatesStr) async {
    try {
      await _isarService.database.writeTxn(() async {
        for (final dateStr in cloudDatesStr) {
          final exists = await _isarService.dailyCheckins
              .filter()
              .nicheIdEqualTo(NicheId.smoking)
              .dateStrEqualTo(dateStr)
              .findFirst();

          if (exists == null) {
            await _isarService.dailyCheckins.put(
              DailyCheckin(
                nicheId: NicheId.smoking,
                dateStr: dateStr,
              ),
            );
          }
        }
      });
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar Isar com nuvem', error: e);
    }
  }
}
