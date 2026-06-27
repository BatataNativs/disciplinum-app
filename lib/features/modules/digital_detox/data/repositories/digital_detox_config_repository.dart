import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/entities/digital_detox_config_entity.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository de configuraÃ§Ãµes do Jejum Digital
/// Gerencia persistÃªncia de configuraÃ§Ãµes usando ObjectBox
class DigitalDetoxConfigRepository {
  static DigitalDetoxConfigRepository? _instance;
  static DigitalDetoxConfigRepository get instance => _instance ??= DigitalDetoxConfigRepository._internal();

  DigitalDetoxConfigRepository._internal();

  Box<DigitalDetoxConfigEntity> get _box => ObjectBoxService.instance.store.box<DigitalDetoxConfigEntity>();

  /// Busca configuração pelo userId
  /// Se não encontrar pelo userId real, verifica se há uma entrada orphan de 'guest_user'
  /// salva erroneamente por race condition no Riverpod, e migra para o userId correto.
  Future<DigitalDetoxConfigEntity?> getConfig(String userId) async {
    try {
      final found = _box.query(DigitalDetoxConfigEntity_.userId.equals(userId)).build().findFirst();
      if (found != null) return found;
      
      // Se o userId real não foi encontrado, verifica se existe uma entrada salva
      // erroneamente como 'guest_user' (bug de race condition no provider de auth).
      // Isso NÃO é dado do modo convidado real — é dado do usuário logado salvo com
      // chave errada. Fazemos a migração corrigindo o userId.
      if (userId != 'guest_user') {
        final orphan = _box.query(DigitalDetoxConfigEntity_.userId.equals('guest_user')).build().findFirst();
        if (orphan != null) {
          orphan.userId = userId;
          _box.put(orphan);
          LoggerService.instance.i('DigitalDetox: config migrada de guest_user para $userId');
          return orphan;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cria ou retorna configuração existente
  Future<DigitalDetoxConfigEntity> getOrCreateConfig(String userId) async {
    var config = await getConfig(userId);
    if (config == null) {
      config = DigitalDetoxConfigEntity(userId: userId);
      config.id = _box.put(config);
    }
    return config;
  }

  /// Salva configuração
  Future<void> saveConfig(DigitalDetoxConfigEntity config) async {
    config.touch();
    _box.put(config);
  }

  /// Ativa/desativa módulo
  Future<void> setModuleActive(String userId, bool isActive) async {
    final config = await getOrCreateConfig(userId);
    config.isModuleActive = isActive;
    
    // Se estiver desativando, limpa a lista de apps monitorados
    if (!isActive) {
      config.monitoredApps.clear();
      LoggerService.instance.i('Apps monitorados limpos ao desativar módulo Digital Detox');
    }
    
    await saveConfig(config);
  }

  /// Verifica se módulo está ativo
  Future<bool> isModuleActive(String userId) async {
    final config = await getConfig(userId);
    return config?.isModuleActive ?? false;
  }

  /// Adiciona app monitorado
  Future<void> addMonitoredApp(String userId, String appPackage) async {
    final config = await getOrCreateConfig(userId);
    if (!config.monitoredApps.contains(appPackage)) {
      config.monitoredApps.add(appPackage);
      await saveConfig(config);
    }
  }

  /// Remove app monitorado
  Future<void> removeMonitoredApp(String userId, String appPackage) async {
    final config = await getOrCreateConfig(userId);
    config.monitoredApps.remove(appPackage);
    await saveConfig(config);
  }

  /// Atualiza streak de dias disciplinados
  Future<void> updateDisciplinedStreak(String userId, int streak, DateTime lastDate) async {
    final config = await getOrCreateConfig(userId);
    config.currentDisciplinedStreak = streak;
    config.lastDisciplinedDate = lastDate;
    await saveConfig(config);
  }

  /// Limpa todas as configurações
  Future<void> clearAll() async {
    _box.removeAll();
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  Future<void> syncWithSupabase(DigitalDetoxConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = {
        'user_id': userId,
        'module_id': 'digital_detox',
        'is_module_active': config.isModuleActive,
        'monitored_apps': config.monitoredApps,
        'enable_time_window': config.enableTimeWindow,
        'allowed_start_time': config.allowedStartTime,
        'allowed_end_time': config.allowedEndTime,
        'block_on_weekends': config.blockOnWeekends,
        'weekend_allowed_start_time': config.weekendAllowedStartTime,
        'weekend_allowed_end_time': config.weekendAllowedEndTime,
        'enable_daily_limit': config.enableDailyLimit,
        'daily_limit_minutes': config.dailyLimitMinutes,
        'limit_type': config.limitType,
        'warn_before_limit_minutes': config.warnBeforeLimitMinutes,
        'enable_pre_detox_warning': config.enablePreDetoxWarning,
        'pre_detox_warning_minutes': config.preDetoxWarningMinutes,
        'pre_detox_warning_message': config.preDetoxWarningMessage,
        'current_disciplined_streak': config.currentDisciplinedStreak,
        'longest_disciplined_streak': config.longestDisciplinedStreak,
        'total_disciplined_days': config.totalDisciplinedDays,
        'last_disciplined_date': config.lastDisciplinedDate?.toIso8601String(),
        'enable_rollover_minutes': config.enableRolloverMinutes,
        'max_rollover_minutes': config.maxRolloverMinutes,
        'rollover_expiration_days': config.rolloverExpirationDays,
        'enable_weekly_limit': config.enableWeeklyLimit,
        'weekly_limit_minutes': config.weeklyLimitMinutes,
        'weekly_limit_strategy': config.weeklyLimitStrategy,
        'enable_session_mode': config.enableSessionMode,
        'session_duration_minutes': config.sessionDurationMinutes,
        'session_cooldown_hours': config.sessionCooldownHours,
        'max_sessions_per_day': config.maxSessionsPerDay,
        'session_daily_limit_minutes': config.sessionDailyLimitMinutes,
        'fasting_break_days_required': config.fastingBreakDaysRequired,
        'fasting_break_validity_days': config.fastingBreakValidityDays,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('user_module_settings').upsert(
        data,
        onConflict: 'user_id, module_id',
      );

      LoggerService.instance.i('Configuração DigitalDetox sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar DigitalDetox com Supabase', error: e);
    }
  }

  Future<DigitalDetoxConfigEntity?> loadFromSupabase() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado');
        return null;
      }

      final response = await Supabase.instance.client
          .from('user_module_settings')
          .select()
          .eq('user_id', userId)
          .eq('module_id', 'digital_detox')
          .maybeSingle();

      if (response == null) return null;

      final entity = DigitalDetoxConfigEntity(userId: userId);
      entity.isModuleActive = response['is_module_active'] ?? false;
      entity.monitoredApps = (response['monitored_apps'] as List<dynamic>?)?.cast<String>() ?? [];
      entity.enableTimeWindow = response['enable_time_window'] ?? false;
      entity.allowedStartTime = response['allowed_start_time'] ?? "08:00";
      entity.allowedEndTime = response['allowed_end_time'] ?? "22:00";
      entity.blockOnWeekends = response['block_on_weekends'] ?? false;
      entity.weekendAllowedStartTime = response['weekend_allowed_start_time'];
      entity.weekendAllowedEndTime = response['weekend_allowed_end_time'];
      entity.enableDailyLimit = response['enable_daily_limit'] ?? false;
      entity.dailyLimitMinutes = response['daily_limit_minutes'] ?? 60;
      entity.limitType = response['limit_type'] ?? "global";
      entity.warnBeforeLimitMinutes = response['warn_before_limit_minutes'] ?? 5;
      entity.enablePreDetoxWarning = response['enable_pre_detox_warning'] ?? true;
      entity.preDetoxWarningMinutes = response['pre_detox_warning_minutes'] ?? 5;
      entity.preDetoxWarningMessage = response['pre_detox_warning_message'];
      entity.currentDisciplinedStreak = response['current_disciplined_streak'] ?? 0;
      entity.longestDisciplinedStreak = response['longest_disciplined_streak'] ?? 0;
      entity.totalDisciplinedDays = response['total_disciplined_days'] ?? 0;
      entity.lastDisciplinedDate = response['last_disciplined_date'] != null ? DateTime.parse(response['last_disciplined_date']) : null;
      entity.enableRolloverMinutes = response['enable_rollover_minutes'] ?? false;
      entity.maxRolloverMinutes = response['max_rollover_minutes'] ?? 60;
      entity.rolloverExpirationDays = response['rollover_expiration_days'] ?? 7;
      entity.enableWeeklyLimit = response['enable_weekly_limit'] ?? false;
      entity.weeklyLimitMinutes = response['weekly_limit_minutes'] ?? 540;
      entity.weeklyLimitStrategy = response['weekly_limit_strategy'] ?? "flexible";
      entity.enableSessionMode = response['enable_session_mode'] ?? false;
      entity.sessionDurationMinutes = response['session_duration_minutes'] ?? 10;
      entity.sessionCooldownHours = response['session_cooldown_hours'] ?? 2;
      entity.maxSessionsPerDay = response['max_sessions_per_day'] ?? 4;
      entity.sessionDailyLimitMinutes = response['session_daily_limit_minutes'] ?? 40;
      entity.fastingBreakDaysRequired = response['fasting_break_days_required'] ?? 7;
      entity.fastingBreakValidityDays = response['fasting_break_validity_days'] ?? 30;
      entity.createdAt = response['created_at'] != null ? DateTime.parse(response['created_at']) : DateTime.now();
      entity.updatedAt = response['updated_at'] != null ? DateTime.parse(response['updated_at']) : DateTime.now();
      
      return entity;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar DigitalDetox do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<DigitalDetoxConfigEntity> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      DigitalDetoxConfigEntity? cloudConfig = await loadFromSupabase();
      
      if (cloudConfig != null) {
        // Salva localmente e retorna
        await saveConfig(cloudConfig);
        return cloudConfig;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      DigitalDetoxConfigEntity? localConfig = await getConfig(Supabase.instance.client.auth.currentUser?.id ?? 'guest_user');
      
      if (localConfig != null) {
        // Envia para o Supabase
        await syncWithSupabase(localConfig);
        return localConfig;
      }
      
      // Se não encontrou em nenhum lugar, cria novo
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = DigitalDetoxConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa DigitalDetox', error: e);
      // Fallback
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return DigitalDetoxConfigEntity(userId: userId);
    }
  }
}
