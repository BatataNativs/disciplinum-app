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
  static const String _kUserBio = 'local_profile_bio';
  static const String _kUserAvatar = 'local_profile_avatar_path';
  static const String _kShowEmail = 'local_profile_show_email';
  static const String _kShowAvatar = 'local_profile_show_avatar';
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
    if (existingId == null) {
      const defaultId = 'local_user';
      await _prefs.setString(_kUserId, defaultId);
      await _prefs.setString(_kUserName, 'Usuário');
      await _prefs.setString(_kUserBio, '');
      await _prefs.setBool(_kShowAvatar, true);
      await _prefs.setBool(_kShowEmail, false);
      await _prefs.setString(_kCreatedAt, DateTime.now().toIso8601String());
    }
  }

  @override
  bool get isAuthenticated => true;

  @override
  Stream<User?> get userChanges => _userChangesController.stream;

  @override
  Future<User?> getCurrentUser() async {
    final id = await _prefs.getString(_kUserId) ?? 'local_user';
    final name = await _prefs.getString(_kUserName) ?? 'Usuário';
    final bio = await _prefs.getString(_kUserBio);
    final avatar = await _prefs.getString(_kUserAvatar);
    final createdStr = await _prefs.getString(_kCreatedAt);
    final createdAt = createdStr != null ? DateTime.tryParse(createdStr) : DateTime.now();

    return User(
      id: id,
      email: '',
      name: name,
      avatarUrl: avatar,
      createdAt: createdAt,
      isEmailVerified: true,
      metadata: {
        'bio': bio,
      },
    );
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final name = await _prefs.getString(_kUserName) ?? 'Usuário';
    final bio = await _prefs.getString(_kUserBio) ?? '';
    final avatarUrl = await _prefs.getString(_kUserAvatar);
    final showAvatar = await _prefs.getBool(_kShowAvatar) ?? true;
    final showEmail = await _prefs.getBool(_kShowEmail) ?? false;

    return {
      'id': userId,
      'name': name,
      'bio': bio,
      'avatar_url': avatarUrl,
      'show_avatar': showAvatar,
      'show_email': showEmail,
    };
  }

  @override
  Future<User> updateProfile(
    String userId, {
    String? name,
    String? avatarUrl,
    String? bio,
    bool? showEmail,
    bool? showAvatar,
  }) async {
    try {
      _logger.i('LocalAuthRepository: Atualizando perfil local do usuário');

      if (name != null) {
        await _prefs.setString(_kUserName, name);
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
    final user = await getCurrentUser();
    return AuthResult.success(user!);
  }

  @override
  Future<AuthResult> signUp(AuthCredentials credentials) async {
    _logger.i('LocalAuthRepository: SignUp local com nome: ${credentials.name}');
    if (credentials.name != null && credentials.name!.isNotEmpty) {
      await _prefs.setString(_kUserName, credentials.name!);
    }
    final user = await getCurrentUser();
    return AuthResult.success(user!);
  }

  @override
  Future<AuthResult> signInWithSocial(AuthCredentials credentials) async {
    final user = await getCurrentUser();
    return AuthResult.success(user!);
  }

  @override
  Future<void> signOut() async {
    _logger.i('LocalAuthRepository: SignOut local');
  }

  @override
  Future<void> resetPassword(String email) async {
    _logger.i('LocalAuthRepository: Reset password');
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    _logger.i('LocalAuthRepository: Update password');
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
    _logger.w('LocalAuthRepository: Resetando dados de conta');
    await _prefs.setString(_kUserName, 'Usuário');
    await _prefs.setString(_kUserBio, '');
    await _prefs.remove(_kUserAvatar);
    final user = await getCurrentUser();
    _userChangesController.add(user);
  }
}
