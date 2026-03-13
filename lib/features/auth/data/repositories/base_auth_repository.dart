import 'package:disciplinum/features/auth/domain/repositories/auth_repository.dart';
import 'package:disciplinum/features/auth/domain/entities/user.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_credentials.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_result.dart';

/// Classe base abstrata que implementa métodos comuns
/// Permite que AuthRepositoryImpl estenda sem erros de compilação
abstract class BaseAuthRepository implements AuthRepository {
  @override
  @override
  Future<AuthResult> signIn(AuthCredentials credentials) async {
    throw UnimplementedError('signIn não implementado');
  }

  @override
  @override
  Future<AuthResult> signUp(AuthCredentials credentials) async {
    throw UnimplementedError('signUp não implementado');
  }

  @override
  @override
  Future<AuthResult> signInWithSocial(AuthCredentials credentials) async {
    throw UnimplementedError('signInWithSocial não implementado');
  }

  @override
  @override
  Future<void> signOut() async {
    throw UnimplementedError('signOut não implementado');
  }

  @override
  @override
  Future<void> resetPassword(String email) async {
    throw UnimplementedError('resetPassword não implementado');
  }

  @override
  @override
  Future<User> updateProfile(String userId, {String? name, String? avatarUrl}) async {
    throw UnimplementedError('updateProfile não implementado');
  }

  @override
  @override
  Future<User?> getCurrentUser() async {
    throw UnimplementedError('getCurrentUser não implementado');
  }

  @override
  @override
  Stream<User?> get userChanges {
    throw UnimplementedError('userChanges não implementado');
  }

  @override
  @override
  bool get isAuthenticated {
    throw UnimplementedError('isAuthenticated não implementado');
  }
}
