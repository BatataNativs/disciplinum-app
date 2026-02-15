import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/user_module_status.dart';
import 'package:disciplinum/models/user_niche_app.dart';
import 'package:disciplinum/models/user_niche_time.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';

final supabase = Supabase.instance.client;

Future<T?> _retryOperation<T>(
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

class CloudSyncService {
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
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await supabase
          .from('user_module_status')
          .select()
          .eq('user_id', user.id)
          .eq('niche_id', nicheId.id)
          .maybeSingle();

      if (data == null) return null;
      return UserModuleStatus.fromJson(data);
    } catch (e) {
      debugPrint('Erro ao carregar status do módulo: $e');
      return null;
    }
  }

  static Future<void> saveModuleStatus({
    required NicheId nicheId,
    required bool isActive,
    int? consecutiveDays,
    String? maxMedal,
    bool forceClearMedal = false,
  }) async {
    await _retryOperation(() async {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final Map<String, dynamic> partialData = {
        'user_id': user.id,
        'niche_id': nicheId.id,
        'is_active': isActive,
        'last_updated': DateTime.now().toIso8601String(),
      };

      if (consecutiveDays != null) {
        partialData['consecutive_days'] = consecutiveDays;
      }

      if (forceClearMedal) {
        partialData['max_medal'] = null;
      } else if (maxMedal != null) {
        partialData['max_medal'] = maxMedal;
      }

      await supabase.from('user_module_status').upsert(
            partialData,
            onConflict: 'user_id, niche_id',
          );
    });
  }

  static Future<bool> syncNow() async {
    try {
      return await GamificationService.instance.refreshAllDataFromCloud();
    } catch (e) {
      debugPrint('❌ Erro durante sincronização global: $e');
      return false;
    }
  }
}
