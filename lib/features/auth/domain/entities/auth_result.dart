import 'package:equatable/equatable.dart';
import 'user.dart';

/// Entidade que representa o resultado de uma operação de autenticação
class AuthResult extends Equatable {
  final User? user;
  final bool success;
  final String? errorMessage;
  final AuthErrorType? errorType;

  const AuthResult({
    this.user,
    this.success = false,
    this.errorMessage,
    this.errorType,
  });

  /// Cria resultado de sucesso
  factory AuthResult.success(User user) {
    return AuthResult(
      user: user,
      success: true,
    );
  }

  /// Cria resultado de sucesso para OAuth (usuário será processado pelo stream)
  factory AuthResult.oauthInitiated() {
    return AuthResult(
      user: null,
      success: true,
    );
  }

  /// Cria resultado de erro
  factory AuthResult.error(
    String message, {
    AuthErrorType errorType = AuthErrorType.unknown,
  }) {
    return AuthResult(
      success: false,
      errorMessage: message,
      errorType: errorType,
    );
  }

  /// Verifica se é sucesso
  bool get isSuccess => success && user != null;

  /// Verifica se é erro
  bool get isError => !success;

  @override
  List<Object?> get props => [user, success, errorMessage, errorType];

  @override
  String toString() {
    return 'AuthResult(success: $success, user: $user, error: $errorMessage)';
  }
}

/// Tipos de erro de autenticação
enum AuthErrorType {
  unknown,
  invalidCredentials,
  userNotFound,
  emailAlreadyExists,
  weakPassword,
  invalidEmail,
  networkError,
  serverError,
  emailNotVerified,
  accountDisabled,
  socialAuthError,
  sessionExpired,
}

extension AuthErrorTypeExtension on AuthErrorType {
  String get userMessage {
    switch (this) {
      case AuthErrorType.invalidCredentials:
        return 'E-mail ou senha incorretos';
      case AuthErrorType.userNotFound:
        return 'Usuário não encontrado';
      case AuthErrorType.emailAlreadyExists:
        return 'Este e-mail já está cadastrado';
      case AuthErrorType.weakPassword:
        return 'A senha deve ter pelo menos 8 caracteres';
      case AuthErrorType.invalidEmail:
        return 'E-mail inválido';
      case AuthErrorType.networkError:
        return 'Verifique sua conexão com a internet';
      case AuthErrorType.serverError:
        return 'Erro no servidor. Tente novamente mais tarde';
      case AuthErrorType.emailNotVerified:
        return 'Verifique seu e-mail para ativar sua conta';
      case AuthErrorType.accountDisabled:
        return 'Sua conta foi desativada';
      case AuthErrorType.socialAuthError:
        return 'Erro na autenticação social';
      case AuthErrorType.sessionExpired:
        return 'Sessão expirada. Faça login novamente';
      case AuthErrorType.unknown:
        return 'Ocorreu um erro inesperado';
    }
  }

  String get technicalMessage {
    switch (this) {
      case AuthErrorType.invalidCredentials:
        return 'Invalid credentials';
      case AuthErrorType.userNotFound:
        return 'User not found';
      case AuthErrorType.emailAlreadyExists:
        return 'Email already exists';
      case AuthErrorType.weakPassword:
        return 'Password too weak';
      case AuthErrorType.invalidEmail:
        return 'Invalid email format';
      case AuthErrorType.networkError:
        return 'Network connection error';
      case AuthErrorType.serverError:
        return 'Internal server error';
      case AuthErrorType.emailNotVerified:
        return 'Email not verified';
      case AuthErrorType.accountDisabled:
        return 'Account disabled';
      case AuthErrorType.socialAuthError:
        return 'Social authentication error';
      case AuthErrorType.sessionExpired:
        return 'Session expired';
      case AuthErrorType.unknown:
        return 'Unknown error';
    }
  }
}
