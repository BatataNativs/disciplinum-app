import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/features/auth/domain/entities/user.dart' as auth;
import 'package:disciplinum/features/auth/domain/entities/auth_credentials.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_result.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class SupabaseAuthDatasource {
  final SupabaseClient _supabase;
  final LoggerService _logger;

  SupabaseAuthDatasource({
    required SupabaseClient supabase,
    required LoggerService logger,
  })  : _supabase = supabase,
        _logger = logger;

  Future<AuthResult> signInWithEmail(AuthCredentials credentials) async {
    try {
      _logger.i('Iniciando signin com email: ${credentials.email}');

      final response = await _supabase.auth.signInWithPassword(
        email: credentials.email,
        password: credentials.password,
      );

      final user = response.user;
      if (user == null) {
        return AuthResult.error('Usuario nao encontrado', errorType: AuthErrorType.userNotFound);
      }

      _logger.i('Login bem-sucedido para usuario: ${user.id}');
      return AuthResult.success(_convertSupabaseUser(user));
    } on AuthException catch (e) {
      _logger.e('Erro de autenticacao: ${e.message}');
      return _handleAuthException(e);
    } catch (e) {
      _logger.e('Erro inesperado no signin: $e');
      return AuthResult.error('Erro ao fazer login', errorType: AuthErrorType.unknown);
    }
  }

  Future<AuthResult> signUpWithEmail(AuthCredentials credentials) async {
    try {
      _logger.i('Iniciando signup para email: ${credentials.email}');

      final response = await _supabase.auth.signUp(
        email: credentials.email,
        password: credentials.password,
        data: {'name': credentials.name},
      );

      final user = response.user;
      if (user == null) {
        return AuthResult.error('Erro ao criar usuario', errorType: AuthErrorType.serverError);
      }

      _logger.i('Cadastro bem-sucedido para usuario: ${user.id}');
      return AuthResult.success(_convertSupabaseUser(user));
    } on AuthException catch (e) {
      _logger.e('Erro de cadastro: ${e.message}');
      return _handleAuthException(e);
    } catch (e) {
      _logger.e('Erro inesperado no signup: $e');
      return AuthResult.error('Erro ao fazer cadastro', errorType: AuthErrorType.unknown);
    }
  }

  Future<AuthResult> signInWithSocial(AuthCredentials credentials) async {
    try {
      _logger.i('Iniciando login social: ${credentials.authType.name}');

      late final OAuthProvider provider;
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
          return AuthResult.error('Provedor nao suportado', errorType: AuthErrorType.socialAuthError);
      }

      await _supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.disciplinum://auth/callback',
      );

      _logger.i('Login social iniciado, aguardando callback do provedor');
      return AuthResult.oauthInitiated();
    } on AuthException catch (e) {
      _logger.e('Erro de autenticacao social: ${e.message}');
      return _handleAuthException(e);
    } catch (e) {
      _logger.e('Erro inesperado no login social: $e');
      return AuthResult.error('Erro ao fazer login social', errorType: AuthErrorType.socialAuthError);
    }
  }

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

  Future<void> resetPassword(String email) async {
    try {
      _logger.i('Enviando email de recuperacao para: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      _logger.i('Email de recuperacao enviado');
    } catch (e) {
      _logger.e('Erro ao enviar email de recuperacao: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      _logger.i('Atualizando senha do usuario autenticado');
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _logger.i('Senha atualizada com sucesso');
    } catch (e) {
      _logger.e('Erro ao atualizar senha: $e');
      rethrow;
    }
  }

  Future<auth.User?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      return _convertSupabaseUser(user);
    } catch (e) {
      _logger.e('Erro ao obter usuario atual: $e');
      return null;
    }
  }

  Future<auth.User> updateProfile(String userId, {String? name, String? avatarUrl, String? bio, bool? showAvatar, bool? showEmail}) async {
    try {
      _logger.i('Atualizando perfil do usuario: $userId');

      final updates = <String, dynamic>{};
      if (name != null) {
        updates['name'] = name;
      }
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }
      if (bio != null) {
        updates['bio'] = bio;
      }
      if (showAvatar != null) {
        updates['show_avatar'] = showAvatar;
      }
      if (showEmail != null) {
        updates['show_email'] = showEmail;
      }

      final response = await _supabase.auth.updateUser(
        UserAttributes(data: updates),
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Erro ao atualizar perfil: usuario nao encontrado');
      }

      _logger.i('Perfil atualizado com sucesso: ${user.id}');
      return _convertSupabaseUser(user);
    } catch (e) {
      _logger.e('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  Stream<auth.User?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return _convertSupabaseUser(user);
    });
  }

  Future<bool> isEmailVerified(String userId) async {
    try {
      _logger.i('Verificando se email esta verificado para usuario: $userId');

      final user = _supabase.auth.currentUser;
      if (user == null || user.id != userId) {
        return false;
      }

      final isVerified = user.emailConfirmedAt != null;
      _logger.i('Email verificado: $isVerified para usuario: $userId');
      return isVerified;
    } catch (e) {
      _logger.e('Erro ao verificar email: $e');
      return false;
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      _logger.i('Reenviando verificacao de email');
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: _supabase.auth.currentUser?.email ?? '',
      );
      _logger.i('Verificacao de email reenviada com sucesso');
    } catch (e) {
      _logger.e('Erro ao reenviar verificacao de email: $e');
      rethrow;
    }
  }

 Future<void> deleteAccount(String userId) async {
  try {
    _logger.i('Excluindo conta do usuario: $userId');

    if (userId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    // Garante que só podemos excluir a conta atualmente autenticada.
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null || currentUser.id != userId) {
      throw Exception(
        'Usuario autenticado diferente do usuario a ser excluido',
      );
    }

    // 1. Remove o avatar do Storage.
    //
    // O AvatarService grava sempre em:
    // avatars/{userId}/avatar.png
    try {
      await _supabase.storage
          .from('avatars')
          .remove(['$userId/avatar.png']);

      _logger.i('Avatar removido do Storage: $userId/avatar.png');
    } catch (storageError) {
      // Não continuamos se o Storage falhar.
      //
      // Isso evita excluir a conta deixando um objeto órfão
      // no Storage.
      _logger.e(
        'Erro ao remover avatar do Storage: $storageError',
      );
      rethrow;
    }

    // 2. Exclui a conta através da RPC.
    //
    // A RPC valida novamente:
    // auth.uid() == userId
    //
    // Depois remove auth.users, e os registros relacionados
    // são removidos pelos ON DELETE CASCADE.
    await _supabase.rpc(
      'delete_user',
      params: {'user_id': userId},
    );

    // 3. Encerra a sessão local.
    try {
      await _supabase.auth.signOut();
    } catch (signOutError) {
      _logger.w(
        'Falha ao fazer signOut apos delete_user: $signOutError',
      );
    }

    _logger.i('Conta excluida com sucesso');
  } catch (e) {
    _logger.e('Erro ao excluir conta: $e');
    rethrow;
  }
}

  SupabaseClient get supabaseClient => _supabase;

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

  AuthResult _handleAuthException(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return AuthResult.error('Credenciais invalidas', errorType: AuthErrorType.invalidCredentials);
    }
    if (message.contains('email not confirmed')) {
      return AuthResult.error('Email nao confirmado', errorType: AuthErrorType.emailNotVerified);
    }
    if (message.contains('user already registered')) {
      return AuthResult.error('Email ja cadastrado', errorType: AuthErrorType.emailAlreadyExists);
    }
    if (message.contains('password should be at least')) {
      return AuthResult.error('Senha fraca', errorType: AuthErrorType.weakPassword);
    }
    if (message.contains('invalid email')) {
      return AuthResult.error('Email invalido', errorType: AuthErrorType.invalidEmail);
    }
    if (message.contains('network')) {
      return AuthResult.error('Erro de conexao', errorType: AuthErrorType.networkError);
    }

    return AuthResult.error(e.message, errorType: AuthErrorType.unknown);
  }
}
