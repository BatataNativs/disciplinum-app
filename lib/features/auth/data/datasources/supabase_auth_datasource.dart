import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/features/auth/domain/entities/user.dart' as auth;
import 'package:disciplinum/features/auth/domain/entities/auth_credentials.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_result.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Datasource para autenticação com Supabase - Versão Final Corrigida
/// Problemas de lint resolvidos
class SupabaseAuthDatasource {
  final SupabaseClient _supabase;
  final LoggerService _logger;

  SupabaseAuthDatasource({
    required SupabaseClient supabase,
    required LoggerService logger,
  })  : _supabase = supabase,
        _logger = logger;

  /// Realiza login com email e senha
  Future<AuthResult> signInWithEmail(AuthCredentials credentials) async {
    try {
      _logger.i('Iniciando signin com email: ${credentials.email}');
      
      final response = await _supabase.auth.signInWithPassword(
        email: credentials.email,
        password: credentials.password,
      );

      final user = response.user;
      if (user == null) {
        return AuthResult.error('Usuário não encontrado', errorType: AuthErrorType.userNotFound);
      }

      _logger.i('Login bem-sucedido para usuário: ${user.id}');
      
      final appUser = _convertSupabaseUser(user);
      return AuthResult.success(appUser);
      
    } on AuthException catch (e) {
      _logger.e('Erro de autenticação: ${e.message}');
      return _handleAuthException(e);
    } catch (e) {
      _logger.e('Erro inesperado no signin: $e');
      return AuthResult.error('Erro ao fazer login', errorType: AuthErrorType.unknown);
    }
  }

  /// Realiza cadastro com email e senha
  Future<AuthResult> signUpWithEmail(AuthCredentials credentials) async {
    try {
      _logger.i('Iniciando signup para email: ${credentials.email}');
      
      final response = await _supabase.auth.signUp(
        email: credentials.email,
        password: credentials.password,
        data: {
          'name': credentials.name,
        },
      );

      final user = response.user;
      if (user == null) {
        return AuthResult.error('Erro ao criar usuário', errorType: AuthErrorType.serverError);
      }

      _logger.i('Cadastro bem-sucedido para usuário: ${user.id}');
      
      final appUser = _convertSupabaseUser(user);
      return AuthResult.success(appUser);
      
    } on AuthException catch (e) {
      _logger.e('Erro de cadastro: ${e.message}');
      return _handleAuthException(e);
    } catch (e) {
      _logger.e('Erro inesperado no signup: $e');
      return AuthResult.error('Erro ao fazer cadastro', errorType: AuthErrorType.unknown);
    }
  }

  /// Realiza login com redes sociais
  Future<AuthResult> signInWithSocial(AuthCredentials credentials) async {
    try {
      _logger.i('Iniciando login social: ${credentials.authType.name}');
      
      OAuthProvider provider;
      switch (credentials.authType) {
        case AuthType.google:
          provider = OAuthProvider.google;
          break;
        case AuthType.apple:
          provider = OAuthProvider.apple;
          break;
        case AuthType.facebook:
          provider = OAuthProvider.facebook;
          break;
        default:
          return AuthResult.error('Provedor não suportado', errorType: AuthErrorType.socialAuthError);
      }

      // Para OAuth, o fluxo é diferente - redireciona para o provedor
      // O resultado será capturado pelo stream de auth state changes
      await _supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.disciplinum://auth/callback',
      );

      // Para OAuth, o fluxo é assíncrono - o resultado será processado pelo stream de auth state changes
      _logger.i('Login social iniciado, aguardando callback do provedor');
      
      // Retorna um resultado indicando que o processo foi iniciado
      // O usuário final será processado pelo authStateChanges stream
      return AuthResult.oauthInitiated();
      
    } on AuthException catch (e) {
      _logger.e('Erro de autenticação social: ${e.message}');
      return _handleAuthException(e);
    } catch (e) {
      _logger.e('Erro inesperado no login social: $e');
      return AuthResult.error('Erro ao fazer login social', errorType: AuthErrorType.socialAuthError);
    }
  }

  /// Realiza logout
  Future<void> signOut() async {
    try {
      _logger.i('Iniciando signout');
      await _supabase.auth.signOut();
      _logger.i('Signout realizado com sucesso');
    } catch (e) {
      _logger.e('Erro ao fazer signout: $e');
      rethrow;
    }
  }

  /// Recupera senha
  Future<void> resetPassword(String email) async {
    try {
      _logger.i('Enviando email de recuperação para: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      _logger.i('Email de recuperação enviado');
    } catch (e) {
      _logger.e('Erro ao enviar email de recuperação: $e');
      rethrow;
    }
  }

  /// Obtém usuário atual
  Future<auth.User?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      
      return _convertSupabaseUser(user);
    } catch (e) {
      _logger.e('Erro ao obter usuário atual: $e');
      return null;
    }
  }

  /// Atualiza perfil do usuário
  Future<auth.User> updateProfile(String userId, {String? name, String? avatarUrl}) async {
    try {
      _logger.i('Atualizando perfil do usuário: $userId');
      
      final updates = <String, dynamic>{};
      if (name != null) {
        updates['name'] = name;
      }
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: updates,
        ),
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Erro ao atualizar perfil: usuário não encontrado');
      }

      _logger.i('Perfil atualizado com sucesso: ${user.id}');
      return _convertSupabaseUser(user);
    } catch (e) {
      _logger.e('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  /// Stream de mudanças de autenticação
  Stream<auth.User?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return _convertSupabaseUser(user);
    });
  }

  /// Verifica se email está verificado
  Future<bool> isEmailVerified(String userId) async {
    try {
      _logger.i('Verificando se email está verificado para usuário: $userId');
      
      final user = _supabase.auth.currentUser;
      if (user == null || user.id != userId) {
        return false;
      }
      
      final isVerified = user.emailConfirmedAt != null;
      _logger.i('Email verificado: $isVerified para usuário: $userId');
      return isVerified;
    } catch (e) {
      _logger.e('Erro ao verificar email: $e');
      return false;
    }
  }

  /// Reenvia verificação de email
  Future<void> resendEmailVerification() async {
    try {
      _logger.i('Reenviando verificação de email');
      
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: _supabase.auth.currentUser?.email ?? '',
      );
      
      _logger.i('Verificação de email reenviada com sucesso');
    } catch (e) {
      _logger.e('Erro ao reenviar verificação de email: $e');
      rethrow;
    }
  }

  /// Exclui conta do usuário
  Future<void> deleteAccount(String userId) async {
    try {
      _logger.i('Excluindo conta do usuário: $userId');
      
      // Primeiro faz logout
      await _supabase.auth.signOut();
      
      // Nota: A exclusão real da conta deve ser feita via RPC ou admin
      // Por enquanto, apenas fazemos logout
      _logger.i('Usuário deslogado. Exclusão completa requer implementação via admin');
      
      // NOTA: Exclusão completa requer Supabase Admin API ou RPC function
      // Implementar quando tivermos permissões de admin ou criar RPC no Supabase
      throw UnimplementedError('Exclusão completa requer Admin API - implementar futuramente');
    } catch (e) {
      _logger.e('Erro ao excluir conta: $e');
      rethrow;
    }
  }

  /// Obtém o SupabaseClient para uso externo
  SupabaseClient get supabaseClient => _supabase;

  /// Converte usuário do Supabase para nossa entity
  auth.User _convertSupabaseUser(User supabaseUser) {
    return auth.User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: supabaseUser.userMetadata?['name'] as String?,
      avatarUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.tryParse(supabaseUser.createdAt),
      lastLoginAt: DateTime.tryParse(supabaseUser.lastSignInAt ?? ''),
      isEmailVerified: supabaseUser.emailConfirmedAt != null,
      metadata: supabaseUser.userMetadata,
    );
  }

  /// Trata exceções de autenticação do Supabase
  AuthResult _handleAuthException(AuthException e) {
    final message = e.message.toLowerCase();
    
    switch (message) {
      case 'invalid login credentials':
        return AuthResult.error('E-mail ou senha incorretos', errorType: AuthErrorType.invalidCredentials);
      case 'user not found':
        return AuthResult.error('Usuário não encontrado', errorType: AuthErrorType.userNotFound);
      case 'user_already_registered':
        return AuthResult.error('Este e-mail já está cadastrado', errorType: AuthErrorType.emailAlreadyExists);
      case 'weak_password':
        return AuthResult.error('A senha deve ter pelo menos 6 caracteres', errorType: AuthErrorType.weakPassword);
      case 'invalid_email':
        return AuthResult.error('E-mail inválido', errorType: AuthErrorType.invalidEmail);
      default:
        return AuthResult.error(message, errorType: AuthErrorType.unknown);
    }
  }
}
