import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_credentials.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_result.dart';
import 'package:disciplinum/features/auth/domain/entities/user.dart';
import 'package:disciplinum/features/auth/domain/repositories/auth_repository.dart';

/// Repositório de autenticação e perfil 100% local utilizando ObjectBox.
/// 
/// Elimina dependência de backend remoto, garantindo privacidade,
/// funcionamento offline nativo e carregamento instantâneo.
class LocalAuthRepository implements AuthRepository {
  final ObjectBoxPreferencesRepository _prefs;
  final LoggerService _logger;

  static const String _kUserId = 'local_profile_user_id';
  static const String _kUserName = 'local_profile_name';
  static const String _kUserEmail = 'local_profile_email';
  static const String _kUserPassword = 'local_profile_password';
  static const String _kIsLoggedIn = 'local_profile_is_logged_in';
  static const String _kUserBio = 'local_profile_bio';
  static const String _kUserAvatar = 'local_profile_avatar_path';
  static const String _kUserGender = 'local_profile_gender';
  static const String _kShowEmail = 'local_profile_show_email';
  static const String _kShowAvatar = 'local_profile_show_avatar';
  static const String _kAuthProvider = 'local_profile_auth_provider';
  static const String _kCreatedAt = 'local_profile_created_at';

  final StreamController<User?> _userChangesController =
      StreamController<User?>.broadcast();

  LocalAuthRepository({
    required ObjectBoxPreferencesRepository prefs,
    required LoggerService logger,
  })  : _prefs = prefs,
        _logger = logger {
    _ensureDefaultUser();
  }

  Future<void> _ensureDefaultUser() async {
    final existingId = await _prefs.getString(_kUserId);
    final isLoggedIn = await _prefs.getBool(_kIsLoggedIn);
    // Migração suave: se já havia um id gravado mas a flag de login ainda não existia, mantém logado
    if (existingId != null && isLoggedIn == null) {
      await _prefs.setBool(_kIsLoggedIn, true);
    }
  }

  @override
  bool get isAuthenticated {
    return _prefs.getStringSync(_kUserId) != null &&
        (_prefs.getStringSync(_kIsLoggedIn) == 'true');
  }

  @override
  Stream<User?> get userChanges => _userChangesController.stream;

  @override
  Future<User?> getCurrentUser() async {
    final isLoggedIn = await _prefs.getBool(_kIsLoggedIn) ?? false;
    final id = await _prefs.getString(_kUserId);
    if (!isLoggedIn || id == null || id.isEmpty) {
      return null;
    }

    final name = await _prefs.getString(_kUserName) ?? 'Usuário';
    final email = await _prefs.getString(_kUserEmail) ?? '';
    final bio = await _prefs.getString(_kUserBio);
    final avatar = await _prefs.getString(_kUserAvatar);
    final gender = await _prefs.getString(_kUserGender);
    final authProvider = await _prefs.getString(_kAuthProvider) ?? 'local';
    final createdStr = await _prefs.getString(_kCreatedAt);
    final createdAt = createdStr != null ? DateTime.tryParse(createdStr) : DateTime.now();

    return User(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatar,
      createdAt: createdAt,
      isEmailVerified: true,
      metadata: {
        'bio': bio,
        'gender': gender,
        'auth_provider': authProvider,
      },
    );
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final name = await _prefs.getString(_kUserName) ?? 'Usuário';
    final email = await _prefs.getString(_kUserEmail) ?? '';
    final bio = await _prefs.getString(_kUserBio) ?? '';
    final avatarUrl = await _prefs.getString(_kUserAvatar);
    final gender = await _prefs.getString(_kUserGender);
    final showAvatar = await _prefs.getBool(_kShowAvatar) ?? true;
    final showEmail = await _prefs.getBool(_kShowEmail) ?? true;
    final authProvider = await _prefs.getString(_kAuthProvider) ?? '';

    return {
      'id': userId,
      'name': name,
      'email': email,
      'bio': bio,
      'gender': gender,
      'avatar_url': avatarUrl,
      'show_avatar': showAvatar,
      'show_email': showEmail,
      'auth_provider': authProvider,
    };
  }

  @override
  Future<User> updateProfile(
    String userId, {
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    String? gender,
    bool? showEmail,
    bool? showAvatar,
  }) async {
    try {
      _logger.i('LocalAuthRepository: Atualizando perfil local do usuário');

      if (name != null) {
        await _prefs.setString(_kUserName, name);
      }
      if (email != null) {
        await _prefs.setString(_kUserEmail, email.trim());
      }
      if (gender != null) {
        await _prefs.setString(_kUserGender, gender);
      }
      if (avatarUrl != null) {
        await _prefs.setString(_kUserAvatar, avatarUrl);
      }
      if (bio != null) {
        await _prefs.setString(_kUserBio, bio);
      }
      if (showEmail != null) {
        await _prefs.setBool(_kShowEmail, showEmail);
      }
      if (showAvatar != null) {
        await _prefs.setBool(_kShowAvatar, showAvatar);
      }

      final user = await getCurrentUser();
      _userChangesController.add(user);
      return user!;
    } catch (e, st) {
      _logger.e('LocalAuthRepository: Erro ao atualizar perfil', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<AuthResult> signIn(AuthCredentials credentials) async {
    _logger.i('LocalAuthRepository: SignIn local');
    final storedEmail = await _prefs.getString(_kUserEmail);
    final storedPassword = await _prefs.getString(_kUserPassword);

    if (storedEmail != null && storedEmail.isNotEmpty && storedPassword != null && storedPassword.isNotEmpty) {
      if (storedEmail.toLowerCase() != credentials.email.trim().toLowerCase() ||
          storedPassword != credentials.password) {
        return AuthResult.error('E-mail ou senha incorretos.');
      }
    } else {
      await _prefs.setString(_kUserEmail, credentials.email.trim());
      if (credentials.password.isNotEmpty) {
        await _prefs.setString(_kUserPassword, credentials.password);
      }
    }

    await _prefs.setString(_kUserId, 'local_user');
    await _prefs.setString(_kAuthProvider, 'email');
    await _prefs.setBool(_kIsLoggedIn, true);
    final user = await getCurrentUser();
    if (user != null) {
      _userChangesController.add(user);
    }
    return AuthResult.success(user!);
  }

  @override
  Future<AuthResult> signUp(AuthCredentials credentials) async {
    _logger.i('LocalAuthRepository: SignUp local com nome: ${credentials.name}');
    const defaultId = 'local_user';
    await _prefs.setString(_kUserId, defaultId);
    if (credentials.name != null && credentials.name!.isNotEmpty) {
      await _prefs.setString(_kUserName, credentials.name!);
    }
    if (credentials.email.isNotEmpty) {
      await _prefs.setString(_kUserEmail, credentials.email.trim());
    }
    if (credentials.password.isNotEmpty) {
      await _prefs.setString(_kUserPassword, credentials.password);
    }
    await _prefs.setString(_kAuthProvider, 'email');
    await _prefs.setString(_kCreatedAt, DateTime.now().toIso8601String());
    await _prefs.setBool(_kIsLoggedIn, true);

    final user = await getCurrentUser();
    if (user != null) {
      _userChangesController.add(user);
    }
    return AuthResult.success(user!);
  }

  @override
  Future<AuthResult> signInWithSocial(AuthCredentials credentials) async {
    if (credentials.email.isNotEmpty) {
      await _prefs.setString(_kUserEmail, credentials.email.trim());
    }
    if (credentials.name != null && credentials.name!.isNotEmpty) {
      await _prefs.setString(_kUserName, credentials.name!);
    }
    await _prefs.setString(_kAuthProvider, credentials.authType.name);
    await _prefs.setString(_kUserId, 'local_user');
    await _prefs.setBool(_kIsLoggedIn, true);
    final user = await getCurrentUser();
    if (user != null) {
      _userChangesController.add(user);
    }
    return AuthResult.success(user!);
  }

  @override
  Future<User?> loginWithBiometrics() async {
    _logger.i('LocalAuthRepository: Login com biometria');
    final id = await _prefs.getString(_kUserId);
    final email = await _prefs.getString(_kUserEmail);
    final bioLoginEnabled = await _prefs.getBool('biometric_login_enabled') ?? false;

    // Se a conta não existe, foi deletada, ou o login biométrico não está ativo
    if (id == null || id.isEmpty || email == null || email.isEmpty || !bioLoginEnabled) {
      _logger.w(
          'LocalAuthRepository: Login biométrico negado - conta inexistente, deletada ou biometria desativada. id=$id, email=$email, bioEnabled=$bioLoginEnabled');
      return null;
    }

    await _prefs.setBool(_kIsLoggedIn, true);
    final user = await getCurrentUser();
    if (user != null) {
      _userChangesController.add(user);
    }
    return user;
  }

  @override
  Future<void> signOut() async {
    _logger.i('LocalAuthRepository: SignOut local');
    await _prefs.setBool(_kIsLoggedIn, false);
    _userChangesController.add(null);
  }

  @override
  Future<void> resetPassword(String email) async {
    _logger.i('LocalAuthRepository: Reset password');
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    _logger.i('LocalAuthRepository: Update password');
    await _prefs.setString(_kUserPassword, newPassword);
  }

  @override
  Future<String?> getAccessToken() async => 'local_token';

  @override
  Future<String?> refreshToken() async => 'local_token';

  @override
  Future<bool> isEmailVerified(String userId) async => true;

  @override
  Future<void> resendEmailVerification() async {}

  @override
  Future<void> deleteAccount(String userId) async {
    _logger.w('LocalAuthRepository: Deletando conta e limpando dados');
    await _prefs.remove(_kUserId);
    await _prefs.remove(_kUserName);
    await _prefs.remove(_kUserEmail);
    await _prefs.remove(_kUserPassword);
    await _prefs.remove(_kUserBio);
    await _prefs.remove(_kUserAvatar);
    await _prefs.remove(_kUserGender);
    await _prefs.remove(_kShowEmail);
    await _prefs.remove(_kShowAvatar);
    await _prefs.remove(_kAuthProvider);
    await _prefs.remove(_kCreatedAt);
    await _prefs.remove('biometric_lock_enabled');
    await _prefs.remove('biometric_login_enabled');
    await _prefs.remove('seen_onboarding');
    await _prefs.setBool(_kIsLoggedIn, false);
    _userChangesController.add(null);
  }
}
