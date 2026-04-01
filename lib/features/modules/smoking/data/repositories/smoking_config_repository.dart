import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_config_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório específico para configurações de Smoking usando Isar puro
/// Com sincronização para Supabase (cloud)
class SmokingConfigRepository {
  static SmokingConfigRepository? _instance;
  static SmokingConfigRepository get instance => _instance ??= SmokingConfigRepository._internal();
  
  SmokingConfigRepository._internal();

  Future<SmokingConfigEntity?> getConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      return await isar.smokingConfigEntitys
          .filter()
          .userIdEqualTo(userId)
          .findFirst();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar configuração do Smoking', error: e);
      return null;
    }
  }

  Future<void> saveConfig(SmokingConfigEntity config) async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        // Verificar se já existe uma configuração com o mesmo userId
        final existingConfig = await isar.smokingConfigEntitys
            .filter()
            .userIdEqualTo(config.userId)
            .findFirst();
        
        if (existingConfig != null) {
          // Reutilizar o ID interno do Isar para atualizar em vez de criar nova
          config.id = existingConfig.id;
        }
        
        config.touch();
        await isar.smokingConfigEntitys.put(config);
      });
      
      LoggerService.instance.i('Configuração do Smoking salva com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar configuração do Smoking', error: e);
      rethrow;
    }
  }

  Future<void> deleteConfig() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.smokingConfigEntitys
            .filter()
            .userIdEqualTo(userId)
            .deleteAll();
      });
      
      LoggerService.instance.i('Configuração do Smoking removida com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao remover configuração do Smoking', error: e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final isar = IsarService.instance.database;
      
      await isar.writeTxn(() async {
        await isar.smokingConfigEntitys.clear();
      });
      
      LoggerService.instance.i('Todas as configurações do Smoking foram limpas');
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar configurações do Smoking', error: e);
      rethrow;
    }
  }

  Future<void> setModuleActive(String userId, bool isActive) async {
    try {
      final config = await getConfig();
      if (config != null) {
        final updatedConfig = config.copyWith(isModuleActive: isActive);
        await saveConfig(updatedConfig);
      } else {
        final newConfig = SmokingConfigEntity(userId: userId, isModuleActive: isActive);
        await saveConfig(newConfig);
      }
      LoggerService.instance.i('Estado do módulo Smoking atualizado: $isActive');
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estado do módulo Smoking', error: e);
      rethrow;
    }
  }

  Future<bool> isModuleActive() async {
    try {
      final config = await getConfig();
      return config?.isModuleActive ?? false;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar estado do módulo Smoking', error: e);
      return false;
    }
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  Future<void> syncWithSupabase(SmokingConfigEntity config) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para sincronização');
        return;
      }

      final data = {
        'user_id': userId,
        'module_id': 'smoking',
        'is_module_active': config.isModuleActive,
        'daily_cigarettes': config.dailyCigarettes,
        'price_per_pack': config.pricePerPack,
        'cigarettes_per_pack': config.cigarettesPerPack,
        'quit_date': config.quitDate?.toIso8601String(),
        'currency': config.currency,
        'last_pack_price': config.lastPackPrice,
        'last_packs_per_day': config.lastPacksPerDay,
        'last_quit_date': config.lastQuitDate?.toIso8601String(),
        'last_currency': config.lastCurrency,
        'last_saved_total': config.lastSavedTotal,
        'last_end_date': config.lastEndDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('user_module_settings').upsert(
        data,
        onConflict: 'user_id, module_id',
      );

      LoggerService.instance.i('Configuração Smoking sincronizada com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar Smoking com Supabase', error: e);
    }
  }

  Future<SmokingConfigEntity?> loadFromSupabase() async {
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
          .eq('module_id', 'smoking')
          .maybeSingle();

      if (response == null) return null;

      return SmokingConfigEntity(
        userId: userId,
        isModuleActive: response['is_module_active'] ?? false,
        dailyCigarettes: response['daily_cigarettes'] ?? 0,
        pricePerPack: response['price_per_pack']?.toDouble() ?? 0.0,
        cigarettesPerPack: response['cigarettes_per_pack'] ?? 20,
        quitDate: response['quit_date'] != null ? DateTime.parse(response['quit_date']) : null,
        currency: response['currency'] ?? 'R\$',
        lastPackPrice: response['last_pack_price']?.toDouble(),
        lastPacksPerDay: response['last_packs_per_day']?.toDouble(),
        lastQuitDate: response['last_quit_date'] != null ? DateTime.parse(response['last_quit_date']) : null,
        lastCurrency: response['last_currency'],
        lastSavedTotal: response['last_saved_total']?.toDouble(),
        lastEndDate: response['last_end_date'] != null ? DateTime.parse(response['last_end_date']) : null,
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar Smoking do Supabase', error: e);
      return null;
    }
  }

  /// Sincronização bidirecional completa
  Future<SmokingConfigEntity> performFullSync() async {
    try {
      // Tenta carregar do Supabase primeiro
      SmokingConfigEntity? cloudConfig = await loadFromSupabase();
      
      if (cloudConfig != null) {
        // Salva localmente e retorna
        await saveConfig(cloudConfig);
        return cloudConfig;
      }
      
      // Se não encontrou no Supabase, carrega localmente
      SmokingConfigEntity? localConfig = await getConfig();
      
      if (localConfig != null) {
        // Envia para o Supabase
        await syncWithSupabase(localConfig);
        return localConfig;
      }
      
      // Se não encontrou em nenhum lugar, cria novo
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final newConfig = SmokingConfigEntity(userId: userId);
      await saveConfig(newConfig);
      return newConfig;
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa Smoking', error: e);
      // Fallback
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      return SmokingConfigEntity(userId: userId);
    }
  }
}
