import '../entities/user.dart';
import '../entities/auth_credentials.dart';
import '../entities/auth_result.dart';

/// Repository abstrato para autenticação
/// Segue o Repository Pattern com interface limpa
abstract class AuthRepository {
  /// Realiza login do usuário
  Future<AuthResult> signIn(AuthCredentials credentials);
  
  /// Realiza cadastro do usuário
  Future<AuthResult> signUp(AuthCredentials credentials);
  
  /// Realiza login social
  Future<AuthResult> signInWithSocial(AuthCredentials credentials);
  
  /// Realiza logout
  Future<void> signOut();
  
  /// Recupera senha
  Future<void> resetPassword(String email);
  
  /// Atualiza perfil do usuário
  Future<User> updateProfile(String userId, {String? name, String? avatarUrl});
  
  /// Obtém usuário atual
  Future<User?> getCurrentUser();
  
  /// Stream de mudanças de usuário
  Stream<User?> get userChanges;
  
  /// Verifica se usuário está autenticado
  bool get isAuthenticated;
  
  /// Obtém token de acesso
  Future<String?> getAccessToken();
  
  /// Atualiza token (refresh)
  Future<String?> refreshToken();
  
  /// Verifica se email é verificado
  Future<bool> isEmailVerified(String userId);
  
  /// Reenvia verificação de email
  Future<void> resendEmailVerification();
  
  /// Exclui conta do usuário
  Future<void> deleteAccount(String userId);
}
