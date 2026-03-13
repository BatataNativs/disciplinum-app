import '../../../auth/domain/entities/user.dart' as auth;

/// Repository para operações de perfil do usuário
/// Abstrai acesso a dados relacionados ao perfil
abstract class ProfileRepository {
  /// Obtém o usuário atual
  Future<auth.User?> getCurrentUser();
  
  /// Obtém o perfil completo do usuário
  Future<Map<String, dynamic>?> getUserProfile();
  
  /// Atualiza o perfil do usuário (nome, avatar, etc)
  Future<auth.User> updateProfile(String userId, {String? name, String? avatarUrl});
  
  /// Atualiza metadados do usuário
  Future<void> updateUserMetadata(String userId, Map<String, dynamic> metadata);
  
  /// Faz upload de avatar
  Future<String> uploadAvatar(String userId, String filePath);
  
  /// Verifica se email está verificado
  Future<bool> isEmailVerified(String userId);
  
  /// Reenvia verificação de email
  Future<void> resendEmailVerification();
  
  /// Exclui conta do usuário
  Future<void> deleteAccount(String userId);
  
  /// Obtém estatísticas do usuário
  Future<Map<String, dynamic>?> getUserStats(String userId);
  
  /// Atualiza preferências do usuário
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences);
  
  /// Faz logout
  Future<void> signOut();
}
