import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/spending_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositorio especifico para configuracoes de Spending usando ObjectBox
class SpendingConfigRepository {
  static SpendingConfigRepository? _instance;
  static SpendingConfigRepository get instance =>
      _instance ??= SpendingConfigRepository._internal();

  SpendingConfigRepository._internal();

  Box<SpendingConfigEntity> get _box =>
      ObjectBoxService.instance.store.box<SpendingConfigEntity>();

  Future<SpendingConfigEntity?> getConfig() async {
    try {
      final userId =
          Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final query =
          _box.query(SpendingConfigEntity_.userId.equals(userId)).build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuracao do Spending',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveConfig(SpendingConfigEntity config) async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      config.touch();
      _box.put(config);
      LoggerService.instance.i('Configuracao do Spending salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuracao do Spending',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<SpendingConfigEntity> getOrCreateConfig(String userId) async {
    try {
      final existing = await getConfig();
      if (existing != null) return existing;
      final newConfig = SpendingConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro ao criar config do Spending', error: e);
      return SpendingConfigEntity(userId: userId);
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        _box.remove(existingConfig.id);
      }
      LoggerService.instance.i('Configuracao do Spending removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuracao do Spending',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configuracoes do Spending foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configuracoes do Spending',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> setModuleActive(String userId, bool isActive) async {
    try {
      final config = await getOrCreateConfig(userId);
      final updatedConfig = config.copyWith(isModuleActive: isActive);
      await saveConfig(updatedConfig);
      LoggerService.instance.i('Estado do modulo Spending atualizado: $isActive');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estado do modulo Spending', error: e);
      rethrow;
    }
  }

  Future<bool> isModuleActive() async {
    try {
      final config = await getConfig();
      return config?.isModuleActive ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar estado do modulo Spending', error: e);
      return false;
    }
  }

  Future<void> setAppLockActive(String userId, bool isActive) async {
    try {
      final config = await getOrCreateConfig(userId);
      final updated = config.copyWith(enableAppLock: isActive, isModuleActive: isActive);
      await saveConfig(updated);
      LoggerService.instance.i('Spending AppLock atualizado: $isActive');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar AppLock do Spending', error: e);
      rethrow;
    }
  }

  Future<void> addMonitoredApp(String userId, String appPackage) async {
    try {
      final config = await getOrCreateConfig(userId);
      final apps = List<String>.from(config.monitoredApps);
      if (!apps.contains(appPackage)) {
        apps.add(appPackage);
        await saveConfig(config.copyWith(monitoredApps: apps));
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao adicionar app monitorado Spending', error: e);
      rethrow;
    }
  }

  Future<void> removeMonitoredApp(String userId, String appPackage) async {
    try {
      final config = await getOrCreateConfig(userId);
      final apps = List<String>.from(config.monitoredApps)..remove(appPackage);
      await saveConfig(config.copyWith(monitoredApps: apps));
    } catch (e) {
      LoggerService.instance.e('Erro ao remover app monitorado Spending', error: e);
      rethrow;
    }
  }

  Future<List<String>> getMonitoredApps(String userId) async {
    final config = await getOrCreateConfig(userId);
    return config.monitoredApps;
  }

  Future<double?> getMonthlyBudget() async {
    try {
      final config = await getConfig();
      return config?.monthlyBudget;
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar orcamento mensal', error: e);
      return null;
    }
  }

  Future<void> updateMonthlyBudget(double budget) async {
    try {
      final config = await getConfig();
      if (config != null) {
        final updatedConfig = config.copyWith(monthlyBudget: budget);
        await saveConfig(updatedConfig);
        LoggerService.instance.i('Orcamento mensal atualizado: $budget');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar orcamento mensal', error: e);
      rethrow;
    }
  }

  Future<void> syncWithSupabase(SpendingConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final data = {
        'user_id': userId,
        'module_id': 'spending',
        'is_module_active': config.isModuleActive,
        'monthly_budget': config.monthlyBudget,
        'currency': config.currency,
        'enable_notifications': config.enableNotifications,
        'reminder_day': config.reminderDay,
        'updated_at': DateTime.now().toIso8601String(),
      };
      await Supabase.instance.client.from('user_module_settings').upsert(data, onConflict: 'user_id, module_id');
      LoggerService.instance.i('Configuracao Spending sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar Spending com Supabase', error: e);
    }
  }

  Future<SpendingConfigEntity?> loadFromSupabase() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return null;
      final response = await Supabase.instance.client
          .from('user_module_settings').select()
          .eq('user_id', userId).eq('module_id', 'spending').maybeSingle();
      if (response == null) return null;
      return SpendingConfigEntity(
        userId: userId,
        isModuleActive: response['is_module_active'] ?? false,
        monthlyBudget: (response['monthly_budget'] as num?)?.toDouble() ?? 0.0,
        currency: response['currency'] ?? 'R\$',
        enableNotifications: response['enable_notifications'] ?? true,
        reminderDay: response['reminder_day'] ?? 1,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar Spending do Supabase', error: e);
      return null;
    }
  }

  Future<SpendingConfigEntity> performFullSync() async {
    try {
      final cloudConfig = await loadFromSupabase();
      if (cloudConfig != null) { await saveConfig(cloudConfig); return cloudConfig; }
      final localConfig = await getConfig();
      if (localConfig != null) { await syncWithSupabase(localConfig); return localConfig; }
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = SpendingConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronizacao completa Spending', error: e);
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return SpendingConfigEntity(userId: userId);
    }
  }
}
