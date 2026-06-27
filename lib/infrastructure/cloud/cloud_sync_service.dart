import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/infrastructure/entities/user_module_status.dart';
import 'package:disciplinum/shared/models/user_niche_app.dart';
import 'package:disciplinum/shared/models/user_niche_time.dart';
import 'package:disciplinum/features/iap/domain/entities/user_entitlement.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/network/network_health_service.dart';
import 'package:disciplinum/core/network/connectivity_fallback.dart';

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
  final ConnectivityFallback _fallback = ConnectivityFallback();

  CloudSyncService({
    required this.supabase,
    this.prefsRepo,
  });

  // --- MÉTODOS AUXILIARES ---

  String _timestampUtc() {
    return DateTime.now().toUtc().toIso8601String();
  }

  String _localTimestamp() {
    return _timestampUtc();
  }

  Future<T?> _retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    // Verificar saúde da rede antes de tentar
    final networkHealth = NetworkHealthService();
    final canAttempt = await networkHealth.shouldAttemptNetworkOperation();
    if (!canAttempt) {
      LoggerService.instance.w('Rede não está saudável, pulando operação de sincronização');
      return null;
    }

    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        final isNetworkError = e.toString().contains('SocketException') ||
                              e.toString().contains('ClientException') ||
                              e.toString().contains('Failed host lookup') ||
                              e.toString().contains('No address associated with hostname');
        
        if (isNetworkError) {
          LoggerService.instance.w('Erro de DNS/rede detectado na tentativa ${i + 1}: ${e.toString().substring(0, 100)}...');
          
          // Para erros de DNS, esperar mais tempo e tentar apenas 2 vezes
          if (i >= 1) {
            LoggerService.instance.e('DNS falhou após 2 tentativas, desistindo da operação');
            return null;
          }
          
          await Future.delayed(Duration(seconds: (i + 1) * 3));
          
          // Tentar verificar conectividade novamente
          await networkHealth.checkConnectivity();
        } else {
          LoggerService.instance.w('Tentativa ${i + 1} falhou, tentando novamente...');
          await Future.delayed(Duration(seconds: i + 1));
        }
      }
    }
    return null;
  }

  Future<String?> _getUserId() async {
    final user = supabase.auth.currentUser;
    if (user != null) return user.id;
    
    // Fallback para o Isar se o usuário não estiver na sessão do Supabase (ex: persistência local)
    if (prefsRepo != null) {
      return await prefsRepo!.getString('user_id');
    }
    return null;
  }

  // --- APPS ---
  Future<void> addUserNicheApp({
    required NicheId nicheId,
    required String package,
  }) async {
    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;
      await supabase.from('user_niche_apps').insert({
        'user_id': userId,
        'niche_id': nicheId.id,
        'app_package': package,
      });
    });
  }

  Future<void> removeUserNicheApp({
    required NicheId nicheId,
    required String package,
  }) async {
    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;
      await supabase.from('user_niche_apps').delete().match({
        'user_id': userId,
        'niche_id': nicheId.id,
        'app_package': package,
      });
    });
  }

  Future<List<UserNicheApp>> loadUserNicheApps({
    required NicheId nicheId,
  }) async {
    return await _retryOperation(() async {
          final userId = await _getUserId();
          if (userId == null) return <UserNicheApp>[];
          final result = await supabase
              .from('user_niche_apps')
              .select('user_id, niche_id, app_package')
              .eq('user_id', userId)
              .eq('niche_id', nicheId.id);
          return (result as List)
              .map((row) => UserNicheApp.fromJson(row))
              .toList();
        }) ??
        [];
  }

  Future<void> removeAllAppsForNiche({
    required NicheId nicheId,
  }) async {
    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;
      await supabase.from('user_niche_apps').delete().match({
        'user_id': userId,
        'niche_id': nicheId.id,
      });
    });
  }

  // --- HORÁRIOS ---
  Future<void> addUserNicheTime({
    required int nicheId,
    required int hour,
    required int minute,
    String? phrase,
  }) async {
    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;
      await supabase.from('user_niche_times').insert({
        'user_id': userId,
        'niche_id': nicheId,
        'hour': hour,
        'minute': minute,
        'phrase': phrase,
      });
    });
  }

  Future<void> removeUserNicheTime({
    required int nicheId,
    required int hour,
    required int minute,
  }) async {
    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;
      await supabase.from('user_niche_times').delete().match({
        'user_id': userId,
        'niche_id': nicheId,
        'hour': hour,
        'minute': minute,
      });
    });
  }

  Future<List<UserNicheTime>> loadUserNicheTimes({
    required int nicheId,
  }) async {
    final operationKey = 'user_niche_times_$nicheId';
    
    return await _fallback.executeWithFallback<List<UserNicheTime>>(
      operationKey,
      () async {
        // Operação na nuvem
        final result = await _retryOperation<List<UserNicheTime>>(() async {
          final userId = await _getUserId();
          if (userId == null) return <UserNicheTime>[];
          final data = await supabase
              .from('user_niche_times')
              .select('user_id, niche_id, hour, minute, phrase')
              .eq('user_id', userId)
              .eq('niche_id', nicheId);
          return (data as List)
              .map((row) => UserNicheTime.fromJson(row))
              .toList();
        });
        return result ?? [];
      },
      () {
        // Fallback local (ler do Isar/SharedPreferences se disponível)
        // Por enquanto, retorna lista vazia
        return <UserNicheTime>[];
      },
    ) ?? [];
  }

  Future<void> removeAllTimesForNiche({
    required int nicheId,
  }) async {
    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;
      await supabase.from('user_niche_times').delete().match({
        'user_id': userId,
        'niche_id': nicheId,
      });
    });
  }

  // --- STATUS E MEDALHAS ---
  Future<UserModuleStatus?> loadModuleStatus(NicheId nicheId) async {
    return await _retryOperation<UserModuleStatus?>(() async {
      final userId = await _getUserId();
      if (userId == null) return null;

      final data = await supabase
          .from('user_module_status')
          .select()
          .eq('user_id', userId)
          .eq('niche_id', nicheId.id)
          .maybeSingle();

      if (data == null) return null;
      return UserModuleStatus.fromJson(data);
    });
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
    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;

      final Map<String, dynamic> partialData = {
        'user_id': userId,
        'niche_id': nicheId.id,
        'is_active': isModuleActive,
        'last_updated': _localTimestamp(),
      };

      if (consecutiveDays != null) {
        partialData['consecutive_days'] = consecutiveDays;
      }

      if (focusPeriodsRespected != null) {
        partialData['focus_periods_respected'] = focusPeriodsRespected;
      }

      if (forceClearMedal) {
        partialData['max_medal'] = null;
      } else if (maxMedal != null) {
        partialData['max_medal'] = maxMedal;
      }

      if (earnedInsignias != null) {
        partialData['earned_insignias'] = earnedInsignias;
      }

      await supabase.from('user_module_status').upsert(
            partialData,
            onConflict: 'user_id, niche_id',
          );
    });
  }

  Future<bool> syncNow() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        LoggerService.instance.w('Sincronização abortada: Usuário não autenticado.');
        return false;
      }

      LoggerService.instance.i('Iniciando sincronização global para o usuário $userId...');
      
      // === SINCRONIZAÇÃO DOS MÓDULOS (dados reais de gamificação) ===
      // Cada módulo tem seu próprio repository que sincroniza com ObjectBox + Supabase
      await _syncModule(SmokingModuleRepository.instance, userId, 'smoking');
      await _syncModule(ReadingModuleRepository.instance, userId, 'reading');
      await _syncModule(MoneySavingModuleRepository.instance, userId, 'money_saving');
      await _syncModule(BingeEatingModuleRepository.instance, userId, 'binge_eating');
      await _syncModule(AdultContentModuleRepository.instance, userId, 'adult_content');
      await _syncModule(DietModuleRepository.instance, userId, 'diet');
      await _syncModule(FocusModuleRepository.instance, userId, 'focus');
      await _syncModule(ProcrastinationModuleRepository.instance, userId, 'procrastination');
      await _syncModule(SpendingModuleRepository.instance, userId, 'spending');
      
      // === SINCRONIZAÇÃO DE DADOS ESPECÍFICOS (livros, refeições, intervalos) ===
      // Dados que usam user_module_settings com module_id específico
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
      
      // === SINCRONIZAÇÃO LEGADA (user_module_status, apps, horários) ===
      for (final nicheId in NicheId.values) {
        try {
          // 1. Sincronizar Status do Módulo (legado)
          await loadModuleStatus(nicheId);

          // 2. Sincronizar Apps do Nicho
          await loadUserNicheApps(nicheId: nicheId);
          
          // 3. Sincronizar Horários
          await loadUserNicheTimes(nicheId: nicheId.id);
        } catch (e) {
          LoggerService.instance.e('Erro ao sincronizar nicho ${nicheId.id}', error: e);
          // Continua para o próximo nicho em vez de abortar tudo
        }
      }

      // 4. Sincronizar Entitlements
      await loadEntitlements();

      // 5. Salvar timestamp da sincronização na nuvem (para continuidade entre dispositivos)
      final now = DateTime.now();
      await saveLastSyncTimestamp(now);
      
      // Também salvar localmente para referência rápida
      if (prefsRepo != null) {
        await prefsRepo!.setString('last_sync_timestamp', now.toIso8601String());
      }

      LoggerService.instance.i('Sincronização global concluída com sucesso. Timestamp: $now');
      return true;
    } catch (e) {
      LoggerService.instance.e('Erro crítico durante a sincronização global', error: e);
      return false;
    }
  }

  /// Sincroniza um módulo específico chamando seu fullSync()
  Future<void> _syncModule(dynamic repository, String userId, String moduleName) async {
    try {
      LoggerService.instance.d('🔄 Sincronizando módulo: $moduleName');
      final result = await repository.fullSync(userId);
      
      // Log detalhado do estado sincronizado
      final isActive = result.isModuleActive ?? false;
      final hasRemoteData = result.updatedAt != null && result.updatedAt!.isAfter(DateTime(2020));
      LoggerService.instance.i('✅ Módulo $moduleName sincronizado: isActive=$isActive, hasData=$hasRemoteData, updatedAt=${result.updatedAt}');
    } catch (e, stackTrace) {
      // Se o módulo não existir na nuvem ou der erro, loga detalhadamente
      LoggerService.instance.w('⚠️ Módulo $moduleName não sincronizado: $e');
      LoggerService.instance.d('StackTrace: $stackTrace');
    }
  }

  /// Sincroniza dados específicos de um módulo (livros, refeições, intervalos)
  Future<void> _syncSpecificData(Future<void> Function() syncFn, String dataName) async {
    try {
      LoggerService.instance.d('🔄 Sincronizando dados: $dataName');
      await syncFn();
      LoggerService.instance.d('✅ Dados sincronizados: $dataName');
    } catch (e) {
      // Se os dados não existirem na nuvem ou der erro, apenas loga e continua
      LoggerService.instance.d('⚠️ Dados $dataName não sincronizados (pode ser novo): $e');
    }
  }

  // --- DAILY CHECKINS (Smoking, Binge Eating, etc.) ---
  
  Future<void> saveDailyCheckin({
    required NicheId nicheId,
    required String dateStr,
  }) async {
    final tableName = _getCheckinTableForNiche(nicheId);
    if (tableName == null) return;

    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;

      await supabase.from(tableName).upsert(
        {
          'user_id': userId,
          'check_date': dateStr,
        },
        onConflict: 'user_id, check_date',
        ignoreDuplicates: true,
      );
    });
  }

  Future<List<String>> loadDailyCheckins(NicheId nicheId) async {
    final tableName = _getCheckinTableForNiche(nicheId);
    if (tableName == null) return [];

    return await _retryOperation(() async {
          final userId = await _getUserId();
          if (userId == null) return <String>[];
          
          final result = await supabase
              .from(tableName)
              .select('check_date')
              .eq('user_id', userId)
              .order('check_date', ascending: true);

          return (result as List)
              .map((row) => row['check_date'] as String)
              .toList();
        }) ??
        [];
  }

  Future<void> clearDailyCheckins(NicheId nicheId) async {
    final tableName = _getCheckinTableForNiche(nicheId);
    if (tableName == null) return;

    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;
      await supabase.from(tableName).delete().eq('user_id', userId);
    });
  }

  String? _getCheckinTableForNiche(NicheId nicheId) {
    switch (nicheId) {
      case NicheId.smoking:
        return 'smoking_daily_checkins';
      case NicheId.diet:
        return 'binge_daily_checkins';
      default:
        return null;
    }
  }

  // --- ENTITLEMENTS ---
  Future<void> addEntitlement({
    required String entitlementType,
    int? nicheId,
    required String source,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;
      await supabase.from('user_entitlements').insert({
        'user_id': userId,
        'entitlement_type': entitlementType,
        'niche_id': nicheId,
        'source': source,
        'expires_at': expiresAt?.toIso8601String(),
        'metadata': metadata ?? {},
      });
    });
  }

  Future<void> removeEntitlement({
    required String entitlementType,
    int? nicheId,
  }) async {
    await _retryOperation(() async {
      final userId = await _getUserId();
      if (userId == null) return;
      final matchData = <String, Object>{
        'user_id': userId,
        'entitlement_type': entitlementType,
      };
      if (nicheId != null) {
        matchData['niche_id'] = nicheId;
      }
      await supabase.from('user_entitlements').delete().match(matchData);
    });
  }

  Future<List<UserEntitlement>> loadEntitlements({
    String? entitlementType,
    int? nicheId,
  }) async {
    return await _retryOperation(() async {
          final userId = await _getUserId();
          if (userId == null) return <UserEntitlement>[];

          var query = supabase
              .from('user_entitlements')
              .select()
              .eq('user_id', userId);

          if (entitlementType != null) {
            query = query.eq('entitlement_type', entitlementType);
          }

          if (nicheId != null) {
            query = query.eq('niche_id', nicheId);
          }

          final result = await query;
          return (result as List)
              .map((row) => UserEntitlement.fromJson(row))
              .where((entitlement) => entitlement.isValid)
              .toList();
        }) ??
        [];
  }

  /// Sincroniza entitlements, idealmente chamado pelo IapService ou GamificationService
  Future<void> syncAllEntitlements({
    required Future<void> Function(NicheId, String type) onUnlock,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return;

      LoggerService.instance.i('Sincronizando entitlements do usuário...');
      final cloudEntitlements = await loadEntitlements();
      
      final notificationEntitlements = cloudEntitlements.where((e) => e.entitlementType == 'notification');
      for (final entitlement in notificationEntitlements) {
        if (entitlement.nicheId != null) {
          final nicheId = NicheId.tryFromInt(entitlement.nicheId!);
          if (nicheId != null) await onUnlock(nicheId, 'notification');
        }
      }
    
      final motivationEntitlements = cloudEntitlements.where((e) => e.entitlementType == 'motivation');
      for (final entitlement in motivationEntitlements) {
        if (entitlement.nicheId != null) {
          final nicheId = NicheId.tryFromInt(entitlement.nicheId!);
          if (nicheId != null) await onUnlock(nicheId, 'motivation');
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização de entitlements', error: e);
    }
  }

  // --- SYNC TIMESTAMP (Para continuidade entre dispositivos) ---

  /// Salva a data da última sincronização na nuvem
  Future<void> saveLastSyncTimestamp(DateTime timestamp) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        LoggerService.instance.w('Não foi possível salvar timestamp: usuário não autenticado');
        return;
      }

      await supabase.from('user_module_settings').upsert({
        'user_id': userId,
        'module_id': 'global', // Módulo especial para metadados
        'setting_key': 'last_sync_timestamp',
        'setting_value': timestamp.toIso8601String(),
        'updated_at': _localTimestamp(),
      }, onConflict: 'user_id, module_id, setting_key');

      LoggerService.instance.i('☁️ Timestamp de sync salvo na nuvem: $timestamp');
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST204') {
        // Schema cache desatualizado - coluna ainda não visível na API
        LoggerService.instance.w('⚠️ Schema cache desatualizado. Aguardando refresh do PostgREST...');
      } else {
        LoggerService.instance.w('Erro ao salvar timestamp na nuvem: $e');
      }
    } catch (e) {
      LoggerService.instance.w('Erro ao salvar timestamp na nuvem: $e');
    }
  }

  /// Carrega a data da última sincronização da nuvem
  Future<DateTime?> loadLastSyncTimestamp() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        LoggerService.instance.w('Não foi possível carregar timestamp: usuário não autenticado');
        return null;
      }

      final response = await supabase
          .from('user_module_settings')
          .select('setting_value')
          .eq('user_id', userId)
          .eq('module_id', 'global')
          .eq('setting_key', 'last_sync_timestamp')
          .maybeSingle();

      if (response != null && response['setting_value'] != null) {
        final timestamp = DateTime.parse(response['setting_value']);
        LoggerService.instance.i('☁️ Timestamp de sync carregado da nuvem: $timestamp');
        return timestamp;
      }

      LoggerService.instance.d('Nenhum timestamp encontrado na nuvem');
      return null;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST204') {
        // Schema cache desatualizado - coluna ainda não visível na API
        LoggerService.instance.w('⚠️ Schema cache desatualizado. Aguardando refresh do PostgREST...');
      } else {
        LoggerService.instance.w('Erro ao carregar timestamp da nuvem: $e');
      }
      return null;
    } catch (e) {
      LoggerService.instance.w('Erro ao carregar timestamp da nuvem: $e');
      return null;
    }
  }

}
