import '../../domain/repositories/profile_repository.dart';
import 'package:disciplinum/features/auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/entities/user.dart' as auth;
import '../datasources/profile_datasource.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Implementação do ProfileRepository
/// Usa AuthRepository e ProfileDataSource para operações de perfil
class ProfileRepositoryImpl implements ProfileRepository {
  final AuthRepository _authRepository;
  final ProfileDataSource _dataSource;
  final LoggerService _logger;

  ProfileRepositoryImpl({
    required AuthRepository authRepository,
    required ProfileDataSource dataSource,
    required LoggerService logger,
  })  : _authRepository = authRepository,
        _dataSource = dataSource,
        _logger = logger;

  @override
  Future<auth.User?> getCurrentUser() async {
    try {
      _logger.d('ProfileRepository: Obtendo usuário atual');
      final user = await _authRepository.getCurrentUser();
      return user as auth.User?; // Cast para tipo correto
    } catch (e) {
      _logger.e('ProfileRepository: Erro ao obter usuário: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      _logger.d('ProfileRepository: Obtendo perfil do usuário');
      final user = await _authRepository.getCurrentUser();
      if (user == null) return null;
      
      return await _dataSource.getUserProfile(user.id);
    } catch (e) {
      _logger.e('ProfileRepository: Erro ao obter perfil: $e');
      rethrow;
    }
  }

  @override
  Future<auth.User> updateProfile(String userId, {String? name, String? avatarUrl}) async {
    try {
      _logger.i('ProfileRepository: Atualizando perfil: $userId');
      final user = await _authRepository.updateProfile(userId, name: name, avatarUrl: avatarUrl);
      return user as auth.User; // Cast para tipo correto
    } catch (e) {
      _logger.e('ProfileRepository: Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserMetadata(String userId, Map<String, dynamic> metadata) async {
    try {
      _logger.i('ProfileRepository: Atualizando metadados: $userId');
      await _dataSource.updateUserMetadata(userId, metadata);
    } catch (e) {
      _logger.e('ProfileRepository: Erro ao atualizar metadados: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      _logger.i('ProfileRepository: Fazendo upload de avatar: $userId');
      return await _dataSource.uploadAvatar(userId, filePath);
    } catch (e) {
      _logger.e('ProfileRepository: Erro no upload de avatar: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isEmailVerified(String userId) async {
    try {
      _logger.d('ProfileRepository: Verificando email: $userId');
      return await _authRepository.isEmailVerified(userId);
    } catch (e) {
      _logger.e('ProfileRepository: Erro ao verificar email: $e');
      rethrow;
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    try {
      _logger.i('ProfileRepository: Reenviando verificação de email');
      await _authRepository.resendEmailVerification();
    } catch (e) {
      _logger.e('ProfileRepository: Erro ao reenviar verificação: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      _logger.i('ProfileRepository: Excluindo conta: $userId');
      await _authRepository.deleteAccount(userId);
    } catch (e) {
      _logger.e('ProfileRepository: Erro ao excluir conta: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      _logger.d('ProfileRepository: Obtendo estatísticas: $userId');
      return await _dataSource.getUserStats(userId);
    } catch (e) {
      _logger.e('ProfileRepository: Erro ao obter estatísticas: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      _logger.i('ProfileRepository: Atualizando preferências: $userId');
      await _dataSource.updateUserPreferences(userId, preferences);
    } catch (e) {
      _logger.e('ProfileRepository: Erro ao atualizar preferências: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _logger.i('ProfileRepository: Fazendo logout');
      await _authRepository.signOut();
    } catch (e) {
      _logger.e('ProfileRepository: Erro ao fazer logout: $e');
      rethrow;
    }
  }
}
