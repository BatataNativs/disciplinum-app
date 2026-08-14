import 'package:equatable/equatable.dart';

/// Entidade para credenciais de autenticação
class AuthCredentials extends Equatable {
  final String email;
  final String password;
  final String? name;
  final AuthType authType;

  const AuthCredentials({
    required this.email,
    required this.password,
    this.name,
    this.authType = AuthType.email,
  });

  /// Cria credenciais para signup
  factory AuthCredentials.forSignup({
    required String email,
    required String password,
    required String name,
  }) {
    return AuthCredentials(
      email: email,
      password: password,
      name: name,
      authType: AuthType.email,
    );
  }

  /// Cria credenciais para signin
  factory AuthCredentials.forSignin({
    required String email,
    required String password,
  }) {
    return AuthCredentials(
      email: email,
      password: password,
      authType: AuthType.email,
    );
  }

  /// Cria credenciais para social login
  factory AuthCredentials.forSocial({
    required String email,
    required AuthType authType,
    String? name,
  }) {
    return AuthCredentials(
      email: email,
      password: '', // Social login não usa password
      name: name,
      authType: authType,
    );
  }

  /// Validação básica de email
  bool get isEmailValid {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  /// Validação básica de password
  bool get isPasswordValid {
    return password.length >= 8;
  }

  /// Validação para signup
  bool get isValidForSignup {
    return isEmailValid && 
           isPasswordValid && 
           name != null && 
           name!.isNotEmpty;
  }

  /// Validação para signin
  bool get isValidForSignin {
    return isEmailValid && isPasswordValid;
  }

  @override
  List<Object?> get props => [email, password, name, authType];

  @override
  String toString() {
    return 'AuthCredentials(email: $email, authType: $authType)';
  }
}

/// Tipos de autenticação suportados
enum AuthType {
  email,
  google,
  apple,
  facebook,
}

extension AuthTypeExtension on AuthType {
  String get displayName {
    switch (this) {
      case AuthType.email:
        return 'E-mail';
      case AuthType.google:
        return 'Google';
      case AuthType.apple:
        return 'Apple';
      case AuthType.facebook:
        return 'Facebook';
    }
  }

  String get asset {
    switch (this) {
      case AuthType.email:
        return 'assets/icons/email.png';
      case AuthType.google:
        return 'assets/icons/google.png';
      case AuthType.apple:
        return 'assets/icons/apple.png';
      case AuthType.facebook:
        return 'assets/icons/facebook.png';
    }
  }
}
