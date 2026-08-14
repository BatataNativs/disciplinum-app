import 'package:disciplinum/features/auth/domain/repositories/auth_repository.dart';
import 'package:disciplinum/features/auth/domain/entities/user.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_credentials.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_result.dart';

abstract class BaseAuthRepository implements AuthRepository {
  @override
  Future<AuthResult> signIn(AuthCredentials credentials) async {
    throw UnimplementedError('signIn not implemented');
  }

  @override
  Future<AuthResult> signUp(AuthCredentials credentials) async {
    throw UnimplementedError('signUp not implemented');
  }

  @override
  Future<AuthResult> signInWithSocial(AuthCredentials credentials) async {
    throw UnimplementedError('signInWithSocial not implemented');
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError('signOut not implemented');
  }

  @override
  Future<void> resetPassword(String email) async {
    throw UnimplementedError('resetPassword not implemented');
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    throw UnimplementedError('updatePassword not implemented');
  }

  @override
  Future<User> updateProfile(String userId, {String? name, String? avatarUrl, String? bio, bool? showAvatar, bool? showEmail}) async {
    throw UnimplementedError('updateProfile not implemented');
  }

  @override
  Future<User?> getCurrentUser() async {
    throw UnimplementedError('getCurrentUser not implemented');
  }

  @override
  Stream<User?> get userChanges {
    throw UnimplementedError('userChanges not implemented');
  }

  @override
  bool get isAuthenticated {
    throw UnimplementedError('isAuthenticated not implemented');
  }

  @override
  Future<String?> getAccessToken() async {
    throw UnimplementedError('getAccessToken not implemented');
  }

  @override
  Future<String?> refreshToken() async {
    throw UnimplementedError('refreshToken not implemented');
  }

  @override
  Future<bool> isEmailVerified(String userId) async {
    throw UnimplementedError('isEmailVerified not implemented');
  }

  @override
  Future<void> resendEmailVerification() async {
    throw UnimplementedError('resendEmailVerification not implemented');
  }

  @override
  Future<void> deleteAccount(String userId) async {
    throw UnimplementedError('deleteAccount not implemented');
  }
}
