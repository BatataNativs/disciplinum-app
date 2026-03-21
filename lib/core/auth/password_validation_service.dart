import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço de validação de senhas com integração Supabase
/// Versão melhorada sem conflitos com auth.users
class PasswordValidationService {
  static final supabase = Supabase.instance.client;

  /// Verifica força da senha no servidor
  /// Retorna mapa com 'is_strong' e 'reason'
  static Future<Map<String, dynamic>> verifyPasswordStrength(String password) async {
    try {
      final response = await supabase.rpc('verify_password_strength', 
        params: {'password_text': password});
      
      if (response is List && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }
      
      return {'is_strong': false, 'reason': 'Erro na verificação'};
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar força da senha', error: e);
      return {'is_strong': false, 'reason': 'Erro de conexão'};
    }
  }

  /// Valida senha para usuário específico
  /// Usado durante signup ou change password
  static Future<bool> validateUserPassword(String userId, String password) async {
    try {
      final result = await supabase.rpc('validate_user_password_safe',
        params: {'user_id': userId, 'password_text': password});
      
      return result == true;
    } catch (e) {
      LoggerService.instance.e('Erro ao validar senha do usuário', error: e);
      return false;
    }
  }

  /// Verificação local rápida (antes de enviar ao servidor)
  static Map<String, dynamic> quickLocalCheck(String password) {
    if (password.length < 8) {
      return {
        'is_strong': false, 
        'reason': 'Senha deve ter pelo menos 8 caracteres'
      };
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return {
        'is_strong': false, 
        'reason': 'Senha deve conter letras maiúsculas'
      };
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return {
        'is_strong': false, 
        'reason': 'Senha deve conter letras minúsculas'
      };
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return {
        'is_strong': false, 
        'reason': 'Senha deve conter números'
      };
    }

    // Senhas muito comuns (verificação local básica)
    final commonPasswords = [
      'password', '12345678', '123456789', 'qwerty', 'abc123',
      'password123', 'admin123', 'letmein', 'welcome', 'monkey'
    ];

    if (commonPasswords.contains(password.toLowerCase())) {
      return {
        'is_strong': false, 
        'reason': 'Senha muito comum. Escolha uma mais original'
      };
    }

    return {'is_strong': true, 'reason': 'Senha parece forte'};
  }

  /// Validação completa (local + servidor)
  /// Ideal para signup
  static Future<Map<String, dynamic>> fullValidation(String password) async {
    // Verificação local rápida primeiro
    final localResult = quickLocalCheck(password);
    if (!localResult['is_strong']) {
      return localResult;
    }

    // Verificação no servidor (senhas comprometidas)
    final serverResult = await verifyPasswordStrength(password);
    return serverResult;
  }
}
