import '../entities/user.dart';
import '../entities/auth_credentials.dart';
import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> signIn(AuthCredentials credentials);
  Future<AuthResult> signUp(AuthCredentials credentials);
  Future<AuthResult> signInWithSocial(AuthCredentials credentials);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> updatePassword(String newPassword);

  Future<User> updateProfile(
    String userId, {
    String? name,
    String? avatarUrl,
    String? bio,
    bool? showEmail,
    bool? showAvatar,
  });

  Future<User?> getCurrentUser();

  Future<Map<String, dynamic>?> getUserProfile(String userId);

  Stream<User?> get userChanges;
  bool get isAuthenticated;
  Future<String?> getAccessToken();
  Future<String?> refreshToken();
  Future<bool> isEmailVerified(String userId);
  Future<void> resendEmailVerification();
  Future<void> deleteAccount(String userId);
}
