import 'package:disciplinum/features/auth/domain/repositories/auth_repository.dart';
import 'package:disciplinum/features/auth/domain/entities/user.dart' as auth;
import 'package:disciplinum/features/auth/domain/entities/auth_credentials.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_result.dart';
import 'package:disciplinum/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Implementação do AuthRepository com Supabase
/// Conecta a interface abstrata com o datasource concreto
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDatasource _datasource;
  final LoggerService _logger;

  AuthRepositoryImpl({
    required SupabaseAuthDatasource datasource,
    required LoggerService logger,
  })  : _datasource = datasource,
        _logger = logger;

  @override
  Future<AuthResult> signIn(AuthCredentials credentials) async {
    try {
      _logger.i('Repository: Iniciando signin');
      return await _datasource.signInWithEmail(credentials);
    } catch (e) {
      _logger.e('Repository: Erro no signin: $e');
      return AuthResult.error('Erro ao fazer login', errorType: AuthErrorType.unknown);
    }
  }

  @override
  Future<AuthResult> signUp(AuthCredentials credentials) async {
    try {
      _logger.i('Repository: Iniciando signup');
      return await _datasource.signUpWithEmail(credentials);
    } catch (e) {
      _logger.e('Repository: Erro no signup: $e');
      return AuthResult.error('Erro ao fazer cadastro', errorType: AuthErrorType.unknown);
    }
  }

  @override
  Future<AuthResult> signInWithSocial(AuthCredentials credentials) async {
    try {
      _logger.i('Repository: Iniciando login social: ${credentials.authType.name}');
      
      // Implementar social auth usando o datasource
      final result = await _datasource.signInWithSocial(credentials);
      
      _logger.i('Repository: Login social finalizado: ${result.isSuccess ? 'sucesso' : 'erro'}');
      return result;
    } catch (e) {
      _logger.e('Repository: Erro no login social: $e');
      return AuthResult.error('Erro ao fazer login social', errorType: AuthErrorType.socialAuthError);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _logger.i('Repository: Iniciando signout');
      await _datasource.signOut();
    } catch (e) {
      _logger.e('Repository: Erro no signout: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      _logger.i('Repository: Enviando reset de senha');
      await _datasource.resetPassword(email);
    } catch (e) {
      _logger.e('Repository: Erro ao resetar senha: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      _logger.i('Repository: Atualizando senha');
      await _datasource.updatePassword(newPassword);
    } catch (e) {
      _logger.e('Repository: Erro ao atualizar senha: $e');
      rethrow;
    }
  }

  @override
  Future<auth.User> updateProfile(String userId, {String? name, String? avatarUrl, String? bio, bool? showAvatar, bool? showEmail}) async {
    try {
      _logger.i('Repository: Atualizando perfil do usuário: $userId');
      return await _datasource.updateProfile(userId, name: name, avatarUrl: avatarUrl, bio: bio, showAvatar: showAvatar, showEmail: showEmail);
    } catch (e) {
      _logger.e('Repository: Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  @override
  Future<auth.User?> getCurrentUser() async {
    try {
      _logger.d('Repository: Obtendo usuário atual');
      return await _datasource.getCurrentUser();
    } catch (e) {
      _logger.e('Repository: Erro ao obter usuário atual: $e');
      return null;
    }
  }

  @override
  Stream<auth.User?> get userChanges {
    _logger.d('Repository: Obtendo stream de mudanças');
    return _datasource.authStateChanges;
  }

  @override
  bool get isAuthenticated {
    final user = _datasource.supabaseClient.auth.currentUser;
    return user != null;
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      _logger.d('Repository: Obtendo access token');
      final session = _datasource.supabaseClient.auth.currentSession;
      return session?.accessToken;
    } catch (e) {
      _logger.e('Repository: Erro ao obter access token: $e');
      return null;
    }
  }

  @override
  Future<String?> refreshToken() async {
    try {
      _logger.d('Repository: Atualizando token');
      final session = _datasource.supabaseClient.auth.currentSession;
      if (session != null) {
        await _datasource.supabaseClient.auth.refreshSession();
        return _datasource.supabaseClient.auth.currentSession?.accessToken;
      }
      return null;
    } catch (e) {
      _logger.e('Repository: Erro ao atualizar token: $e');
      return null;
    }
  }

  @override
  Future<bool> isEmailVerified(String userId) async {
    try {
      _logger.d('Repository: Verificando se email está verificado');
      final user = _datasource.supabaseClient.auth.currentUser;
      return user?.emailConfirmedAt != null;
    } catch (e) {
      _logger.e('Repository: Erro ao verificar email: $e');
      return false;
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    try {
      _logger.i('Repository: Reenviando verificação de email');
      await _datasource.resendEmailVerification();
    } catch (e) {
      _logger.e('Repository: Erro ao reenviar verificação: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      _logger.i('Repository: Excluindo conta do usuário: $userId');
      await _datasource.deleteAccount(userId);
    } catch (e) {
      _logger.e('Repository: Erro ao excluir conta: $e');
      rethrow;
    }
  }
}
