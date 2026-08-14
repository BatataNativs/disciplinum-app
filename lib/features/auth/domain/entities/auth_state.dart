import 'user.dart';

class AuthState {
  static const Object _unset = Object();

  final User? currentUser;
  final Map<String, dynamic>? userProfile;
  final bool isLoading;
  final bool isPasswordRecovery;
  final bool isSocialLoginInProgress;
  final String? errorMessage;

  const AuthState({
    this.currentUser,
    this.userProfile,
    this.isLoading = false,
    this.isPasswordRecovery = false,
    this.isSocialLoginInProgress = false,
    this.errorMessage,
  });

  AuthState copyWith({
    Object? currentUser = _unset,
    Object? userProfile = _unset,
    bool? isLoading,
    bool? isPasswordRecovery,
    bool? isSocialLoginInProgress,
    Object? errorMessage = _unset,
  }) {
    return AuthState(
      currentUser:
          identical(currentUser, _unset) ? this.currentUser : currentUser as User?,
      userProfile:
          identical(userProfile, _unset) ? this.userProfile : userProfile as Map<String, dynamic>?,
      isLoading: isLoading ?? this.isLoading,
      isPasswordRecovery: isPasswordRecovery ?? this.isPasswordRecovery,
      isSocialLoginInProgress:
          isSocialLoginInProgress ?? this.isSocialLoginInProgress,
      errorMessage:
          identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  bool get isAuthenticated => currentUser != null;
}
