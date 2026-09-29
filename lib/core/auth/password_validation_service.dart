import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Resultado detalhado da validação de senha
class PasswordValidationResult {
  final bool isValid;
  final String? errorMessage;
  final int? breachCount;

  const PasswordValidationResult({
    required this.isValid,
    this.errorMessage,
    this.breachCount,
  });

  factory PasswordValidationResult.valid() =>
      const PasswordValidationResult(isValid: true);

  factory PasswordValidationResult.invalid(String message, {int? breachCount}) =>
      PasswordValidationResult(
        isValid: false,
        errorMessage: message,
        breachCount: breachCount,
      );
}

/// Serviço de validação de senhas com proteção OWASP e HaveIBeenPwned (k-Anonymity).
/// 
/// Não trafega nem salva senhas em texto puro em banco de dados ou logs.
class PasswordValidationService {
  static const int minLength = 8;
  static const String _hibpDomain = 'api.pwnedpasswords.com';
  static const Duration _hibpTimeout = Duration(seconds: 4);

  // Lista local das senhas mais vulneráveis/triviais
  static const List<String> _commonPasswords = [
    'password',
    'password123',
    '12345678',
    '123456789',
    '1234567890',
    'qwerty123',
    'abc12345',
    'admin123',
    'letmein1',
    'disciplinum',
  ];

  /// Valida complexidade e regras mínimas de segurança localmente
  static PasswordValidationResult validateComplexity(String password) {
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
        'Esta senha é muito previsível. Escolha uma senha mais original.',
      );
    }

    return PasswordValidationResult.valid();
  }

  /// Verifica se a senha consta em vazamentos de dados públicos via HaveIBeenPwned.
  /// 
  /// Utiliza k-Anonymity: a senha NUNCA sai do dispositivo.
  /// Apenas os 5 primeiros caracteres do SHA-1 são enviados.
  static Future<int> checkBreachCount(String password) async {
    HttpClient? client;
    try {
      final bytes = utf8.encode(password);
      final digest = sha1.convert(bytes);
      final hashUpper = digest.toString().toUpperCase();

      final prefix = hashUpper.substring(0, 5);
      final suffix = hashUpper.substring(5);

      client = HttpClient();
      client.connectionTimeout = _hibpTimeout;

      final uri = Uri.https(_hibpDomain, '/range/$prefix');
      final request = await client.getUrl(uri);

      // Headers recomendados pela API do HaveIBeenPwned
      request.headers.set(HttpHeaders.userAgentHeader, 'Disciplinum-App');
      request.headers.set('Add-Padding', 'true');

      final response = await request.close().timeout(_hibpTimeout);

      if (response.statusCode != HttpStatus.ok) {
        LoggerService.instance.w(
          'HaveIBeenPwned retornou status ${response.statusCode}',
        );
        return 0;
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final lines = const LineSplitter().convert(responseBody);

      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length >= 2 && parts[0].trim().toUpperCase() == suffix) {
          final count = int.tryParse(parts[1].trim()) ?? 1;
          return count;
        }
      }

      return 0;
    } catch (e) {
      // Degradação graciosa: se o dispositivo estiver offline ou der timeout,
      // não bloqueia a criação de conta/login do usuário
      LoggerService.instance.w('Verificação HaveIBeenPwned indisponível: $e');
      return 0;
    } finally {
      client?.close();
    }
  }

  /// Validação completa para criação ou redefinição de senha:
  /// 1. Valida requisitos de formato e complexidade localmente
  /// 2. Consulta API de vazamentos do HaveIBeenPwned (k-Anonymity)
  static Future<PasswordValidationResult> validateNewPassword(
    String password,
  ) async {
    final complexityResult = validateComplexity(password);
    if (!complexityResult.isValid) {
      return complexityResult;
    }

    final breachCount = await checkBreachCount(password);
    if (breachCount > 0) {
      return PasswordValidationResult.invalid(
        'Esta senha já apareceu em vazamentos públicos de dados ($breachCount vezes). Por segurança, escolha outra.',
        breachCount: breachCount,
      );
    }

    return PasswordValidationResult.valid();
  }
}
