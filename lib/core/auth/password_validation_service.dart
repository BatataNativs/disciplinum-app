/// Resultado da validação local de senha
class PasswordValidationResult {
  final bool isValid;
  final String? errorMessage;

  const PasswordValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory PasswordValidationResult.valid() =>
      const PasswordValidationResult(isValid: true);

  factory PasswordValidationResult.invalid(String message) =>
      PasswordValidationResult(
        isValid: false,
        errorMessage: message,
      );
}

/// Serviço de validação de senha 100% local (Local-First).
/// 
/// Executa instantaneamente no dispositivo, sem chamadas de rede, sem latência
/// e sem dependências externas.
class PasswordValidationService {
  static const int minLength = 8;

  // Lista local de senhas triviais e previsíveis mais comuns
  static const List<String> _commonPasswords = [
    'password',
    'password123',
    '12345678',
    '123456789',
    '1234567890',
    'qwerty123',
    'disciplinum',
  ];

  /// Valida complexidade e estrutura da senha localmente
  static PasswordValidationResult validate(String password) {
    if (password.length < minLength) {
      return PasswordValidationResult.invalid(
        'A senha deve ter pelo menos $minLength caracteres.',
      );
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return PasswordValidationResult.invalid(
        'A senha deve conter pelo menos uma letra maiúscula.',
      );
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return PasswordValidationResult.invalid(
        'A senha deve conter pelo menos uma letra minúscula.',
      );
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return PasswordValidationResult.invalid(
        'A senha deve conter pelo menos um número.',
      );
    }

    if (_commonPasswords.contains(password.toLowerCase().trim())) {
      return PasswordValidationResult.invalid(
        'Esta senha é muito previsível. Escolha uma senha mais segura.',
      );
    }

    return PasswordValidationResult.valid();
  }
}
