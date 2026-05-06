import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/spending_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Spending usando ObjectBox
/// Com sincronização para Supabase (cloud)
class SpendingConfigRepository {
  static SpendingConfigRepository? _instance;
  static SpendingConfigRepository get instance => _instance ??= SpendingConfigRepository._internal();

  SpendingConfigRepository._internal();

  Box<SpendingConfigEntity> get _box => ObjectBoxService.instance.store.box<SpendingConfigEntity>();

  Future<SpendingConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final query = _box.query(SpendingConfigEntity_.userId.equals(userId)).build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar configuração do Spending', error: e, stackTrace: stackTrace);
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

      LoggerService.instance.i('Configuração do Spending salva com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar configuração do Spending', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final existingConfig = await getConfig();
      if (existingConfig != null) {
        _box.remove(existingConfig.id);
      }

      LoggerService.instance.i('Configuração do Spending removida com sucesso');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao remover configuração do Spending', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _box.removeAll();
      LoggerService.instance.i('Todas as configurações do Spending foram limpas');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar configurações do Spending', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> setModuleActive(String userId, bool isActive) async {
    try {
      final config = await getConfig();
      if (config != null) {
        final updatedConfig = config.copyWith(
          isModuleActive: isActive,
        );
        await saveConfig(updatedConfig);
      } else {
        final newConfig = SpendingConfigEntity(
          userId: userId,
          isModuleActive: isActive,
        );
        await saveConfig(newConfig);
      }
      LoggerService.instance.i('Estado do módulo Spending atualizado: $isActive');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estado do módulo Spending', error: e);
      rethrow;
    }
  }

  Future<bool> isModuleActive() async {
    try {
      final config = await getConfig();
      return config?.isModuleActive ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar estado do módulo Spending', error: e);
      return false;
    }
  }

  Future<double?> getMonthlyBudget() async {
    try {
      final config = await getConfig();
      return config?.monthlyBudget;
    } catch (e) {
      LoggerService.instance.e('Erro ao buscar orçamento mensal', error: e);
      return null;
    }
  }

  Future<void> updateMonthlyBudget(double budget) async {
    try {
      final config = await getConfig();
      if (config != null) {
        final updatedConfig = config.copyWith(monthlyBudget: budget);
        await saveConfig(updatedConfig);
        LoggerService.instance.i('Orçamento mensal atualizado: $budget');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar orçamento mensal', error: e);
      rethrow;
    }
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  Future<void> syncWithSupabase(SpendingConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

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

      await Supabase.instance.client.from('user_module_settings').upsert(
        data,
        onConflict: 'user_id, module_id',
      );

      LoggerService.instance.i('Configuração Spending sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar Spending com Supabase', error: e);
    }
  }

  Future<SpendingConfigEntity?> loadFromSupabase() async {
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
          .eq('module_id', 'spending')
          .maybeSingle();

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

  /// Sincronização bidirecional completa
  Future<SpendingConfigEntity> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      SpendingConfigEntity? cloudConfig = await loadFromSupabase();

      if (cloudConfig != null) {
        // Salva localmente e retorna
        await saveConfig(cloudConfig);
        return cloudConfig;
      }

      // Se não encontrou no Supabase, carrega localmente
      SpendingConfigEntity? localConfig = await getConfig();

      if (localConfig != null) {
        // Envia para o Supabase
        await syncWithSupabase(localConfig);
        return localConfig;
      }

      // Se não encontrou em nenhum lugar, cria novo
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = SpendingConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Spending', error: e);
      // Fallback
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return SpendingConfigEntity(userId: userId);
    }
  }
}
