import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/infrastructure/entities/user_module_status.dart';
import 'package:disciplinum/shared/models/user_niche_app.dart';
import 'package:disciplinum/shared/models/user_niche_time.dart';
import 'package:disciplinum/features/iap/domain/entities/user_entitlement.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/storage/entities/daily_checkin_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

// Imports para sincronização de módulos (gamificação + estado)
import 'package:disciplinum/features/modules/smoking/domain/repositories/smoking_module_repository.dart';
import 'package:disciplinum/features/modules/reading/domain/repositories/reading_module_repository.dart';
import 'package:disciplinum/features/modules/money_saving/domain/repositories/money_saving_module_repository.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/repositories/binge_eating_module_repository.dart';
import 'package:disciplinum/features/modules/adult_content/domain/repositories/adult_content_module_repository.dart';
import 'package:disciplinum/features/modules/diet/domain/repositories/diet_module_repository.dart';
import 'package:disciplinum/features/modules/focus/domain/repositories/focus_module_repository.dart';
import 'package:disciplinum/features/modules/procrastination/domain/repositories/procrastination_module_repository.dart';
import 'package:disciplinum/features/modules/spending/domain/repositories/spending_module_repository.dart';

// Imports para sincronização de dados específicos
import 'package:disciplinum/features/modules/reading/data/repositories/reading_repository.dart';
import 'package:disciplinum/features/modules/diet/domain/repositories/meal_entry_repository.dart';
import 'package:disciplinum/features/modules/focus/data/repositories/focus_interval_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/data/repositories/digital_detox_config_repository.dart';

class CloudSyncService {
  final SupabaseClient supabase;
  final ObjectBoxPreferencesRepository? prefsRepo;

  CloudSyncService({
    required this.supabase,
    this.prefsRepo,
  });

  Future<String?> _getUserId() async {
    if (prefsRepo != null) {
      final savedId = await prefsRepo!.getString('user_id');
      if (savedId != null && savedId.isNotEmpty) return savedId;
    }
    final user = supabase.auth.currentUser;
    if (user != null) return user.id;
    return 'local_user';
  }

  // --- APPS (100% ObjectBox Preferences) ---
  Future<void> addUserNicheApp({
    required NicheId nicheId,
    required String package,
  }) async {
    if (prefsRepo != null) {
      final key = 'user_niche_apps_${nicheId.id}';
      final current = await prefsRepo!.getStringList(key) ?? [];
      if (!current.contains(package)) {
        final updated = List<String>.from(current)..add(package);
        await prefsRepo!.setStringList(key, updated);
      }
    }
  }

  Future<void> removeUserNicheApp({
    required NicheId nicheId,
    required String package,
  }) async {
    if (prefsRepo != null) {
      final key = 'user_niche_apps_${nicheId.id}';
      final current = await prefsRepo!.getStringList(key) ?? [];
      final updated = List<String>.from(current)..remove(package);
      await prefsRepo!.setStringList(key, updated);
    }
  }

  Future<List<UserNicheApp>> loadUserNicheApps({
    required NicheId nicheId,
  }) async {
    final userId = await _getUserId() ?? 'local_user';
    if (prefsRepo != null) {
      final list = await prefsRepo!.getStringList('user_niche_apps_${nicheId.id}');
      if (list != null) {
        return list.map((pkg) => UserNicheApp(
          userId: userId,
          nicheId: nicheId.id,
          appPackage: pkg,
        )).toList();
      }
    }
    return [];
  }

  Future<void> removeAllAppsForNiche({
    required NicheId nicheId,
  }) async {
    if (prefsRepo != null) {
      await prefsRepo!.remove('user_niche_apps_${nicheId.id}');
    }
  }

  // --- HORÁRIOS (100% ObjectBox Preferences) ---
  Future<void> addUserNicheTime({
    required int nicheId,
    required int hour,
    required int minute,
    String? phrase,
  }) async {
    final userId = await _getUserId() ?? 'local_user';
    final entry = UserNicheTime(
      userId: userId,
      nicheId: nicheId,
      hour: hour,
      minute: minute,
      phrase: phrase,
    );
    if (prefsRepo != null) {
      final key = 'user_niche_times_$nicheId';
      final current = await prefsRepo!.getStringList(key) ?? [];
      final updated = List<String>.from(current)..add(jsonEncode(entry.toJson()));
      await prefsRepo!.setStringList(key, updated);
    }
  }

  Future<void> removeUserNicheTime({
    required int nicheId,
    required int hour,
    required int minute,
  }) async {
    if (prefsRepo != null) {
      final key = 'user_niche_times_$nicheId';
      final current = await prefsRepo!.getStringList(key) ?? [];
      final updated = current.where((s) {
        try {
          final map = jsonDecode(s) as Map<String, dynamic>;
          return !(map['hour'] == hour && map['minute'] == minute);
        } catch (_) {
          return true;
        }
      }).toList();
      await prefsRepo!.setStringList(key, updated);
    }
  }

  Future<List<UserNicheTime>> loadUserNicheTimes({
    required int nicheId,
  }) async {
    if (prefsRepo != null) {
      final list = await prefsRepo!.getStringList('user_niche_times_$nicheId');
      if (list != null) {
        return list.map((s) {
          try {
            return UserNicheTime.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        }).whereType<UserNicheTime>().toList();
      }
    }
    return [];
  }

  Future<void> removeAllTimesForNiche({
    required int nicheId,
  }) async {
    if (prefsRepo != null) {
      await prefsRepo!.remove('user_niche_times_$nicheId');
    }
  }

  // --- STATUS E MEDALHAS (100% ObjectBox Preferences) ---
  Future<UserModuleStatus?> loadModuleStatus(NicheId nicheId) async {
    if (prefsRepo != null) {
      final jsonStr = await prefsRepo!.getString('user_module_status_${nicheId.id}');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          return UserModuleStatus.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
        } catch (e) {
          LoggerService.instance.w('Erro ao ler UserModuleStatus local: $e');
        }
      }
    }
    return null;
  }

  Future<void> saveModuleStatus({
    required NicheId nicheId,
    required bool isModuleActive,
    int? consecutiveDays,
    int? focusPeriodsRespected,
    String? maxMedal,
    List<String>? earnedInsignias,
    bool forceClearMedal = false,
  }) async {
    final userId = await _getUserId() ?? 'local_user';
    final existing = await loadModuleStatus(nicheId);

    final status = UserModuleStatus(
      userId: userId,
      nicheId: nicheId.id,
      isModuleActive: isModuleActive,
      consecutiveDays: consecutiveDays ?? existing?.consecutiveDays ?? 0,
      focusPeriodsRespected: focusPeriodsRespected ?? existing?.focusPeriodsRespected,
      lastUpdated: DateTime.now().toUtc(),
      maxMedal: forceClearMedal ? null : (maxMedal ?? existing?.maxMedal),
      earnedInsignias: earnedInsignias ?? existing?.earnedInsignias ?? [],
    );

    if (prefsRepo != null) {
      await prefsRepo!.setString(
        'user_module_status_${nicheId.id}',
        jsonEncode(status.toJson()),
      );
    }
  }

  // --- SINCRONIZAÇÃO GLOBAL (100% Local-First) ---
  Future<bool> syncNow() async {
    try {
      final userId = await _getUserId() ?? 'local_user';
      LoggerService.instance.i('Iniciando sincronização local para o usuário $userId...');
      
      // Sincronização dos repositórios de módulos (ObjectBox puro)
      await _syncModule(SmokingModuleRepository.instance, userId, 'smoking');
      await _syncModule(ReadingModuleRepository.instance, userId, 'reading');
      await _syncModule(MoneySavingModuleRepository.instance, userId, 'money_saving');
      await _syncModule(BingeEatingModuleRepository.instance, userId, 'binge_eating');
      await _syncModule(AdultContentModuleRepository.instance, userId, 'adult_content');
      await _syncModule(DietModuleRepository.instance, userId, 'diet');
      await _syncModule(FocusModuleRepository.instance, userId, 'focus');
      await _syncModule(ProcrastinationModuleRepository.instance, userId, 'procrastination');
      await _syncModule(SpendingModuleRepository.instance, userId, 'spending');
      
      // Sincronização de dados específicos
      await _syncSpecificData(
        () => ReadingRepository().performFullSync(userId),
        'reading_books',
      );
      await _syncSpecificData(
        () => MealEntryRepository.instance.performFullSync(userId),
        'diet_meals',
      );
      await _syncSpecificData(
        () => FocusIntervalRepository.instance.performFullSync(),
        'focus_intervals',
      );
      await _syncSpecificData(
        () => DigitalDetoxConfigRepository.instance.performFullSync(),
        'digital_detox_config',
      );

      final now = DateTime.now();
      await saveLastSyncTimestamp(now);

      LoggerService.instance.i('Sincronização local concluída com sucesso. Timestamp: $now');
      return true;
    } catch (e) {
      LoggerService.instance.e('Erro durante a sincronização local', error: e);
      return false;
    }
  }

  Future<void> _syncModule(dynamic repository, String userId, String moduleName) async {
    try {
      LoggerService.instance.d('🔄 Verificando módulo local: $moduleName');
      await repository.fullSync(userId);
    } catch (e, stackTrace) {
      LoggerService.instance.w('⚠️ Módulo $moduleName: $e');
      LoggerService.instance.d('StackTrace: $stackTrace');
    }
  }

  Future<void> _syncSpecificData(Future<void> Function() syncFn, String dataName) async {
    try {
      LoggerService.instance.d('🔄 Verificando dados locais: $dataName');
      await syncFn();
    } catch (e) {
      LoggerService.instance.d('⚠️ Dados $dataName: $e');
    }
  }

  // --- DAILY CHECKINS (100% ObjectBox DailyCheckin) ---
  Future<void> saveDailyCheckin({
    required NicheId nicheId,
    required String dateStr,
  }) async {
    try {
      final store = ObjectBoxService.instance.store;
      final box = store.box<DailyCheckin>();
      final nicheIdDate = '${nicheId.index}_$dateStr';
      final existing = box.query(DailyCheckin_.nicheIdDate.equals(nicheIdDate)).build().findFirst();
      if (existing == null) {
        box.put(DailyCheckin.create(
          nicheId: nicheId,
          dateStr: dateStr,
        ));
        LoggerService.instance.d('Checkin salvo localmente no ObjectBox: $nicheIdDate');
      }
    } catch (e) {
      LoggerService.instance.w('Erro ao salvar checkin no ObjectBox: $e');
    }
  }

  Future<List<String>> loadDailyCheckins(NicheId nicheId) async {
    try {
      final store = ObjectBoxService.instance.store;
      final box = store.box<DailyCheckin>();
      final checkins = box.query(DailyCheckin_.nicheIdIndex.equals(nicheId.index)).build().find();
      final dates = checkins.map((c) => c.dateStr).toList()..sort();
      return dates;
    } catch (e) {
      LoggerService.instance.w('Erro ao ler checkins do ObjectBox: $e');
      return [];
    }
  }

  Future<void> clearDailyCheckins(NicheId nicheId) async {
    try {
      final store = ObjectBoxService.instance.store;
      final box = store.box<DailyCheckin>();
      final checkins = box.query(DailyCheckin_.nicheIdIndex.equals(nicheId.index)).build().find();
      box.removeMany(checkins.map((c) => c.id).toList());
      LoggerService.instance.d('Checkins limpos localmente no ObjectBox para o nicho ${nicheId.name}');
    } catch (e) {
      LoggerService.instance.w('Erro ao limpar checkins no ObjectBox: $e');
    }
  }

  // --- ENTITLEMENTS (100% Local ObjectBox Preferences) ---
  Future<void> addEntitlement({
    required String entitlementType,
    int? nicheId,
    required String source,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    if (prefsRepo == null) return;
    final userId = await _getUserId() ?? 'local_user';
    final entitlement = UserEntitlement(
      id: '${entitlementType}_${nicheId ?? 0}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      entitlementType: entitlementType,
      nicheId: nicheId,
      source: source,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      metadata: metadata ?? {},
    );

    final current = await loadEntitlements();
    final updated = List<UserEntitlement>.from(current)..add(entitlement);
    final jsonList = updated.map((e) => jsonEncode(e.toJson())).toList();
    await prefsRepo!.setStringList('local_user_entitlements', jsonList);
  }

  Future<void> removeEntitlement({
    required String entitlementType,
    int? nicheId,
  }) async {
    if (prefsRepo == null) return;
    final current = await loadEntitlements();
    final updated = current.where((e) {
      final matchType = e.entitlementType == entitlementType;
      final matchNiche = nicheId == null || e.nicheId == nicheId;
      return !(matchType && matchNiche);
    }).toList();
    final jsonList = updated.map((e) => jsonEncode(e.toJson())).toList();
    await prefsRepo!.setStringList('local_user_entitlements', jsonList);
  }

  Future<List<UserEntitlement>> loadEntitlements({
    String? entitlementType,
    int? nicheId,
  }) async {
    if (prefsRepo == null) return [];
    final jsonList = await prefsRepo!.getStringList('local_user_entitlements');
    if (jsonList == null) return [];

    final list = jsonList.map((s) {
      try {
        return UserEntitlement.fromJson(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<UserEntitlement>().where((e) => e.isValid).toList();

    var filtered = list;
    if (entitlementType != null) {
      filtered = filtered.where((e) => e.entitlementType == entitlementType).toList();
    }
    if (nicheId != null) {
      filtered = filtered.where((e) => e.nicheId == nicheId).toList();
    }
    return filtered;
  }

  Future<void> syncAllEntitlements({
    required Future<void> Function(NicheId, String type) onUnlock,
  }) async {
    try {
      final entitlements = await loadEntitlements();
      for (final entitlement in entitlements) {
        if (entitlement.nicheId != null) {
          final nicheId = NicheId.tryFromInt(entitlement.nicheId!);
          if (nicheId != null) {
            await onUnlock(nicheId, entitlement.entitlementType);
          }
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar entitlements locais', error: e);
    }
  }

  // --- SYNC TIMESTAMP ---
  Future<void> saveLastSyncTimestamp(DateTime timestamp) async {
    if (prefsRepo != null) {
      await prefsRepo!.setString('last_sync_timestamp', timestamp.toIso8601String());
    }
  }

  Future<DateTime?> loadLastSyncTimestamp() async {
    if (prefsRepo != null) {
      final str = await prefsRepo!.getString('last_sync_timestamp');
      if (str != null && str.isNotEmpty) {
        return DateTime.tryParse(str);
      }
    }
    return null;
  }
}
