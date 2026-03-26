import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Verificador de migrações do Supabase para Smoking Gamification
/// Garante que a tabela e políticas existam antes de usar
class SupabaseMigrationChecker {
  static SupabaseMigrationChecker? _instance;
  static SupabaseMigrationChecker get instance => _instance ??= SupabaseMigrationChecker._();
  
  SupabaseMigrationChecker._();

  /// Verifica se a tabela smoking_gamification_states existe
  Future<bool> _checkTableExists() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Tenta fazer uma consulta simples na tabela
      await supabase
          .from('smoking_gamification_states')
          .select('count')
          .limit(1);
      
      return true;
    } catch (e) {
      LoggerService.instance.e('Tabela smoking_gamification_states não encontrada', error: e);
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
          .from('smoking_gamification_states')
          .insert(testData)
          .select('id')
          .maybeSingle();

      // Se conseguiu inserir, remove o teste
      if (result != null) {
        await supabase
            .from('smoking_gamification_states')
            .delete()
            .eq('id', result['id']);
      }

      return true;
    } catch (e) {
      LoggerService.instance.e('Políticas RLS não configuradas corretamente', error: e);
      return false;
    }
  }

  /// Executa verificação completa
  Future<MigrationStatus> checkMigrationStatus() async {
    LoggerService.instance.i('🔍 Verificando migração do Supabase...');
    
    final tableExists = await _checkTableExists();
    if (!tableExists) {
      return MigrationStatus.tableMissing;
    }

    final rlsConfigured = await _checkRLSPolicies();
    if (!rlsConfigured) {
      return MigrationStatus.rlsMissing;
    }

    LoggerService.instance.i('✅ Migração do Supabase OK');
    return MigrationStatus.complete;
  }

  /// Executa setup automático se necessário
  Future<bool> ensureMigration() async {
    final status = await checkMigrationStatus();
    
    switch (status) {
      case MigrationStatus.tableMissing:
        LoggerService.instance.e('❌ Tabela smoking_gamification_states não existe');
        LoggerService.instance.i('📋 Execute a migration SQL no painel do Supabase');
        return false;
        
      case MigrationStatus.rlsMissing:
        LoggerService.instance.e('❌ Políticas RLS não configuradas');
        LoggerService.instance.i('📋 Verifique as políticas de segurança no Supabase');
        return false;
        
      case MigrationStatus.complete:
        LoggerService.instance.i('✅ Supabase pronto para uso');
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

      final inserted = await supabase
          .from('smoking_gamification_states')
          .insert(testData)
          .select()
          .single();

      // Testa consulta
      await supabase
          .from('smoking_gamification_states')
          .select('*')
          .eq('id', inserted['id'])
          .single();

      // Testa atualização
      await supabase
          .from('smoking_gamification_states')
          .update({'state_data': {'test': false}})
          .eq('id', inserted['id']);

      // Testa deleção
      await supabase
          .from('smoking_gamification_states')
          .delete()
          .eq('id', inserted['id']);

      LoggerService.instance.i('✅ Teste completo do Supabase bem-sucedido');
      return true;
    } catch (e) {
      LoggerService.instance.e('❌ Falha no teste completo do Supabase', error: e);
      return false;
    }
  }
}

/// Status da migração
enum MigrationStatus {
  /// Migração completa e funcionando
  complete,
  
  /// Tabela não existe
  tableMissing,
  
  /// Políticas RLS não configuradas
  rlsMissing,
  
  /// Erro desconhecido
  unknown,
}
