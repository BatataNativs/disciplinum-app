import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Status da migração
enum MigrationStatus {
  complete,      // Tabela existe e RLS configurado
  tableMissing,  // Tabela não existe
  rlsMissing,    // Tabela existe mas RLS não configurado
  unknown,       // Erro desconhecido
}

/// Verificador de migrações do Supabase para Spending Gamification
/// Garante que a tabela e políticas existam antes de usar
class SpendingMigrationChecker {
  static SpendingMigrationChecker? _instance;
  static SpendingMigrationChecker get instance => _instance ??= SpendingMigrationChecker._();
  
  SpendingMigrationChecker._();

  /// Verifica se a tabela spending_gamification_states existe
  Future<bool> _checkTableExists() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Tenta fazer uma consulta simples na tabela
      await supabase
          .from('spending_gamification_states')
          .select('count')
          .limit(1);
      
      return true;
    } catch (e) {
      LoggerService.instance.e('Tabela spending_gamification_states não encontrada', error: e);
      return false;
    }
  }

  /// Verifica se as políticas RLS estão configuradas
  Future<bool> _checkRLSPolicies() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para verificar RLS');
        return false;
      }

      // Tenta inserir um registro de teste
      final testData = {
        'user_id': userId,
        'state_data': {'test': true},
      };

      final result = await supabase
          .from('spending_gamification_states')
          .insert(testData)
          .select('id')
          .limit(1);

      // Se inseriu com sucesso, RLS está funcionando
      if (result.isNotEmpty) {
        // Limpa o registro de teste
        await supabase
            .from('spending_gamification_states')
            .delete()
            .eq('id', result.first['id']);
        
        return true;
      }
      
      return false;
    } catch (e) {
      LoggerService.instance.e('Políticas RLS não configuradas ou erro ao testar', error: e);
      return false;
    }
  }

  /// Verifica status completo da migração
  Future<MigrationStatus> checkMigrationStatus() async {
    try {
      // 1. Verifica se tabela existe
      final tableExists = await _checkTableExists();
      if (!tableExists) {
        return MigrationStatus.tableMissing;
      }

      // 2. Verifica se RLS está configurado
      final rlsConfigured = await _checkRLSPolicies();
      if (!rlsConfigured) {
        return MigrationStatus.rlsMissing;
      }

      return MigrationStatus.complete;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar migração Spending', error: e);
      return MigrationStatus.unknown;
    }
  }

  /// Executa setup automático se necessário
  Future<bool> ensureMigration() async {
    final status = await checkMigrationStatus();
    
    switch (status) {
      case MigrationStatus.tableMissing:
        LoggerService.instance.e('❌ Tabela spending_gamification_states não existe');
        LoggerService.instance.i('📋 Execute a migration SQL: 008_create_spending_gamification_states.sql');
        LoggerService.instance.i('📋 Ou execute manualmente no painel do Supabase');
        return false;
        
      case MigrationStatus.rlsMissing:
        LoggerService.instance.e('❌ Políticas RLS não configuradas');
        LoggerService.instance.i('📋 Verifique as políticas de segurança no Supabase');
        return false;
        
      case MigrationStatus.complete:
        LoggerService.instance.i('✅ Supabase Spending pronto para uso');
        return true;
        
      case MigrationStatus.unknown:
        LoggerService.instance.e('❌ Erro desconhecido na verificação');
        return false;
    }
  }

  /// Testa conexão completa com Supabase
  Future<bool> testFullConnection() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        LoggerService.instance.w('Usuário não autenticado para teste completo');
        return false;
      }

      // Testa inserção
      final testData = {
        'user_id': userId,
        'state_data': {
          'test': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
      };

      final result = await supabase
          .from('spending_gamification_states')
          .insert(testData)
          .select('id')
          .limit(1);

      if (result.isEmpty) {
        LoggerService.instance.e('Falha ao inserir teste');
        return false;
      }

      final testId = result.first['id'];

      // Testa leitura
      final readResult = await supabase
          .from('spending_gamification_states')
          .select('state_data')
          .eq('id', testId)
          .maybeSingle();

      if (readResult == null) {
        LoggerService.instance.e('Falha ao ler teste');
        return false;
      }

      // Testa atualização
      await supabase
          .from('spending_gamification_states')
          .update({
            'state_data': {
              'test': false,
              'updated': DateTime.now().toIso8601String(),
            }
          })
          .eq('id', testId);

      // Testa deleção
      final deleteResult = await supabase
          .from('spending_gamification_states')
          .delete()
          .eq('id', testId);

      if (deleteResult == null || deleteResult.isEmpty) {
        LoggerService.instance.e('Falha ao deletar teste');
        return false;
      }

      LoggerService.instance.i('✅ Teste completo do Supabase Spending OK');
      return true;
    } catch (e) {
      LoggerService.instance.e('Erro no teste completo do Supabase Spending', error: e);
      return false;
    }
  }

  /// Verifica se o usuário tem dados existentes
  Future<bool> hasExistingData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        return false;
      }

      final result = await supabase
          .from('spending_gamification_states')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar dados existentes', error: e);
      return false;
    }
  }

  /// Obtém informações sobre a tabela
  Future<Map<String, dynamic>?> getTableInfo() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Verifica se tabela existe e obtém informações básicas
      await supabase
          .from('spending_gamification_states')
          .select('count')
          .limit(1);

      return {
        'table_exists': true,
        'accessible': true,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'table_exists': false,
        'accessible': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
