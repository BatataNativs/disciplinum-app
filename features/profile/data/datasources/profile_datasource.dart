import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Datasource para operações de perfil com Supabase
/// Lida diretamente com o banco de dados para dados de perfil
abstract class ProfileDataSource {
  Future<Map<String, dynamic>?> getUserProfile(String userId);
  Future<void> updateUserMetadata(String userId, Map<String, dynamic> metadata);
  Future<String> uploadAvatar(String userId, String filePath);
  Future<Map<String, dynamic>?> getUserStats(String userId);
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences);
}

class SupabaseProfileDataSource implements ProfileDataSource {
  final SupabaseClient _supabase;
  final LoggerService _logger;

  SupabaseProfileDataSource({
    required SupabaseClient supabase,
    required LoggerService logger,
  })  : _supabase = supabase,
        _logger = logger;

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      _logger.d('SupabaseProfileDataSource: Obtendo perfil: $userId');
      
      // Buscar dados adicionais do perfil na tabela user_profiles
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null) {
        _logger.d('SupabaseProfileDataSource: Perfil encontrado');
        return response;
      }
      
      // Se não encontrar, criar perfil básico
      _logger.d('SupabaseProfileDataSource: Criando perfil básico');
      final basicProfile = {
        'user_id': userId,
        'bio': '',
        'preferences': {},
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase.from('user_profiles').insert(basicProfile);
      return basicProfile;
    } catch (e) {
      _logger.e('SupabaseProfileDataSource: Erro ao obter perfil: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserMetadata(String userId, Map<String, dynamic> metadata) async {
    try {
      _logger.i('SupabaseProfileDataSource: Atualizando metadados: $userId');
      
      await _supabase.auth.updateUser(
        UserAttributes(data: metadata),
      );
      
      _logger.i('SupabaseProfileDataSource: Metadados atualizados com sucesso');
    } catch (e) {
      _logger.e('SupabaseProfileDataSource: Erro ao atualizar metadados: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      _logger.i('SupabaseProfileDataSource: Fazendo upload de avatar: $userId');
      
      final file = File(filePath);
      final fileName = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload para o Supabase Storage
      await _supabase.storage.from('avatars').upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      
      // Obter URL pública
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      
      _logger.i('SupabaseProfileDataSource: Avatar upload concluído: $publicUrl');
      return publicUrl;
    } catch (e) {
      _logger.e('SupabaseProfileDataSource: Erro no upload de avatar: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      _logger.d('SupabaseProfileDataSource: Obtendo estatísticas: $userId');
      
      // Buscar estatísticas consolidadas
      final response = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null) {
        _logger.d('SupabaseProfileDataSource: Estatísticas encontradas');
        return response;
      }
      
      // Se não encontrar, criar estatísticas básicas
      _logger.d('SupabaseProfileDataSource: Criando estatísticas básicas');
      final basicStats = {
        'user_id': userId,
        'total_days': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'modules_completed': 0,
        'achievements_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase.from('user_stats').insert(basicStats);
      return basicStats;
    } catch (e) {
      _logger.e('SupabaseProfileDataSource: Erro ao obter estatísticas: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      _logger.i('SupabaseProfileDataSource: Atualizando preferências: $userId');
      
      await _supabase
          .from('user_profiles')
          .update({
            'preferences': preferences,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _logger.i('SupabaseProfileDataSource: Preferências atualizadas com sucesso');
    } catch (e) {
      _logger.e('SupabaseProfileDataSource: Erro ao atualizar preferências: $e');
      rethrow;
    }
  }
}
