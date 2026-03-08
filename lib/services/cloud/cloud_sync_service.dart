import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/user_module_status.dart';
import 'package:disciplinum/models/user_niche_app.dart';
import 'package:disciplinum/models/user_niche_time.dart';
import 'package:disciplinum/models/user_entitlement.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';

class CloudSyncService {
  static final supabase = Supabase.instance.client;

  // CORRIGIDO: Timestamp UTC para sincronização confiável
  static String _timestampUtc() {
    return DateTime.now().toUtc().toIso8601String();
  }

  // Usar em todos os lugares que salvam timestamp na nuvem
  static String _localTimestamp() {
    // Para compatibilidade, manter nome mas documentar que é UTC
    return _timestampUtc();
  }

  static Future<T?> _retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) {
          debugPrint('❌ Operação falhou após $maxRetries tentativas: $e');
          return null;
        }
        debugPrint('⚠️ Tentativa ${i + 1} falhou, tentando novamente...');
        await Future.delayed(Duration(seconds: i + 1));
      }
    }
    return null;
  }

  // --- APPS ---
  static Future<void> addUserNicheApp({
    required NicheId nicheId,
    required String package,
  }) async {
    await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      await supabase.from('user_niche_apps').insert({
        'user_id': user.id,
        'niche_id': nicheId.id,
        'app_package': package,
      });
    });
  }

  static Future<void> removeUserNicheApp({
    required NicheId nicheId,
    required String package,
  }) async {
    await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      await supabase.from('user_niche_apps').delete().match({
        'user_id': user.id,
        'niche_id': nicheId.id,
        'app_package': package,
      });
    });
  }

  static Future<List<UserNicheApp>> loadUserNicheApps({
    required NicheId nicheId,
  }) async {
    return await _retryOperation(() async {
          final user = supabase.auth.currentUser;
          if (user == null) return <UserNicheApp>[];
          final result = await supabase
              .from('user_niche_apps')
              .select('user_id, niche_id, app_package')
              .eq('user_id', user.id)
              .eq('niche_id', nicheId.id);
          return (result as List)
              .map((row) => UserNicheApp.fromJson(row))
              .toList();
        }) ??
        [];
  }

  static Future<void> removeAllAppsForNiche({
    required NicheId nicheId,
  }) async {
    await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      await supabase.from('user_niche_apps').delete().match({
        'user_id': user.id,
        'niche_id': nicheId.id,
      });
    });
  }

  // --- HORÁRIOS ---
  static Future<void> addUserNicheTime({
    required int nicheId,
    required int hour,
    required int minute,
    String? phrase,
  }) async {
    await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      await supabase.from('user_niche_times').insert({
        'user_id': user.id,
        'niche_id': nicheId,
        'hour': hour,
        'minute': minute,
        'phrase': phrase,
      });
    });
  }

  static Future<void> removeUserNicheTime({
    required int nicheId,
    required int hour,
    required int minute,
  }) async {
    await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      await supabase.from('user_niche_times').delete().match({
        'user_id': user.id,
        'niche_id': nicheId,
        'hour': hour,
        'minute': minute,
      });
    });
  }

  static Future<List<UserNicheTime>> loadUserNicheTimes({
    required int nicheId,
  }) async {
    return await _retryOperation(() async {
          final user = supabase.auth.currentUser;
          if (user == null) return <UserNicheTime>[];
          final result = await supabase
              .from('user_niche_times')
              .select('user_id, niche_id, hour, minute, phrase')
              .eq('user_id', user.id)
              .eq('niche_id', nicheId);
          return (result as List)
              .map((row) => UserNicheTime.fromJson(row))
              .toList();
        }) ??
        [];
  }

  static Future<void> removeAllTimesForNiche({
    required int nicheId,
  }) async {
    await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      await supabase.from('user_niche_times').delete().match({
        'user_id': user.id,
        'niche_id': nicheId,
      });
    });
  }

  // --- STATUS E MEDALHAS ---
  static Future<UserModuleStatus?> loadModuleStatus(NicheId nicheId) async {
    final result = await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final data = await supabase
          .from('user_module_status')
          .select()
          .eq('user_id', user.id)
          .eq('niche_id', nicheId.id)
          .maybeSingle();

      if (data == null) return null;
      return UserModuleStatus.fromJson(data);
    });
    return result;
  }

  static Future<void> saveModuleStatus({
    required NicheId nicheId,
    required bool isActive,
    int? consecutiveDays,
    int? focusPeriodsRespected, // NOVO: Períodos de foco respeitados
    String? maxMedal,
    List<String>? earnedInsignias,
    bool forceClearMedal = false,
  }) async {
    await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final Map<String, dynamic> partialData = {
        'user_id': user.id,
        'niche_id': nicheId.id,
        'is_active': isActive,
        'last_updated': _localTimestamp(),
      };

      if (consecutiveDays != null) {
        partialData['consecutive_days'] = consecutiveDays;
      }

      if (focusPeriodsRespected != null) {
        partialData['focus_periods_respected'] = focusPeriodsRespected; // NOVO
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

  static Future<bool> syncNow() async {
    try {
      await GamificationService.instance.refreshAllDataFromCloud();
      return true;
    } catch (e) {
      debugPrint('❌ Erro durante sincronização global: $e');
      return false;
    }
  }

  // --- ENTITLEMENTS ---
  static Future<void> addEntitlement({
    required String entitlementType,
    int? nicheId,
    required String source,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      await supabase.from('user_entitlements').insert({
        'user_id': user.id,
        'entitlement_type': entitlementType,
        'niche_id': nicheId,
        'source': source,
        'expires_at': expiresAt?.toIso8601String(),
        'metadata': metadata ?? {},
      });
    });
  }

  static Future<void> removeEntitlement({
    required String entitlementType,
    int? nicheId,
  }) async {
    await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final matchData = <String, Object>{
        'user_id': user.id,
        'entitlement_type': entitlementType,
      };
      if (nicheId != null) {
        matchData['niche_id'] = nicheId;
      }
      await supabase.from('user_entitlements').delete().match(matchData);
    });
  }

  static Future<List<UserEntitlement>> loadEntitlements({
    String? entitlementType,
    int? nicheId,
  }) async {
    return await _retryOperation(() async {
          final user = supabase.auth.currentUser;
          if (user == null) return <UserEntitlement>[];

          var query = supabase
              .from('user_entitlements')
              .select()
              .eq('user_id', user.id);

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

  static Future<void> syncAllEntitlements() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      debugPrint('🔄 Sincronizando entitlements do usuário...');
      
      // Carrega todos os entitlements da nuvem
      final cloudEntitlements = await loadEntitlements();
      
      // Sincroniza com GamificationService usando métodos específicos da nuvem
      final gamification = GamificationService.instance;
      
      // Sincroniza desbloqueios por Ads (sem regravar na nuvem)
      final notificationEntitlements = cloudEntitlements
        .where((e) => e.entitlementType == 'notification');
      
      for (final entitlement in notificationEntitlements) {
        if (entitlement.nicheId != null) {
          final nicheId = NicheId.tryFromInt(entitlement.nicheId!);
          if (nicheId != null) {
            await gamification.syncUnlockNotificationFromCloud(nicheId);
          }
        }
      }
      
      // Sincroniza desbloqueios por Motivações (sem regravar na nuvem)
      final motivationEntitlements = cloudEntitlements
        .where((e) => e.entitlementType == 'motivation');
      
      for (final entitlement in motivationEntitlements) {
        if (entitlement.nicheId != null) {
          final nicheId = NicheId.tryFromInt(entitlement.nicheId!);
          if (nicheId != null) {
            await gamification.syncUnlockMotivationFromCloud(nicheId);
          }
        }
      }
      
      debugPrint('✅ Sincronização de entitlements concluída.');
    } catch (e) {
      debugPrint('❌ Erro na sincronização de entitlements: $e');
    }
  }
}
