import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/features/gamification/domain/entities/user_module_status.dart';

/// DataSource para dados em nuvem usando Supabase
/// Responsável pela sincronização com o backend
class CloudModuleDatasource {
  final SupabaseClient _supabase;
  static const String _tableName = 'user_module_status';

  CloudModuleDatasource() : _supabase = Supabase.instance.client;

  /// Obtém status do módulo do Supabase
  Future<UserModuleStatus?> getModuleStatus(int nicheId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return null;

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('niche_id', nicheId)
          .maybeSingle();

      if (response == null) return null;

      return UserModuleStatus.fromJson(response);
    } catch (e) {
      return null; // Fallback silencioso para erros de rede
    }
  }

  /// Salva status do módulo no Supabase
  Future<void> saveModuleStatus(UserModuleStatus status) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      final data = status.toJson();
      data['user_id'] = userId;

      // Upsert: atualiza se existe, insere se não existe
      await _supabase
          .from(_tableName)
          .upsert(data, onConflict: 'user_id, niche_id');
    } catch (e) {
      rethrow;
    }
  }

  /// Remove módulo do Supabase
  Future<void> removeModule(int nicheId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from(_tableName)
          .delete()
          .eq('user_id', userId)
          .eq('niche_id', nicheId);
    } catch (e) {
      rethrow;
    }
  }

  /// Lista todos os módulos ativos do usuário no Supabase
  Future<List<UserModuleStatus>> getActiveModules() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return [];

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_active', true);

      return response.map<UserModuleStatus>((json) {
        return UserModuleStatus.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Sincroniza múltiplos módulos de uma vez
  Future<void> syncMultipleModules(List<UserModuleStatus> modules) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      final data = modules.map((status) {
        final json = status.toJson();
        json['user_id'] = userId;
        return json;
      }).toList();

      await _supabase
          .from(_tableName)
          .upsert(data, onConflict: 'user_id, niche_id');
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica se usuário está autenticado e obtém ID
  String? _getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Força sincronização completa (para refresh manual)
  Future<void> forceSync() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      // Buscar todos os dados do usuário para forçar refresh
      await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
