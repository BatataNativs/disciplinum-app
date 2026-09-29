import 'package:flutter_test/flutter_test.dart';
import 'package:disciplinum/core/auth/password_validation_service.dart';

void main() {
  group('PasswordValidationService - Validação de Complexidade Local', () {
    test('Rejeita senhas com menos de 8 caracteres', () {
      final result = PasswordValidationService.validateComplexity('Ab1!');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('pelo menos 8 caracteres'));
    });

    test('Rejeita senhas sem letras maiúsculas', () {
      final result = PasswordValidationService.validateComplexity('senhaforte123');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('maiúscula'));
    });

    test('Rejeita senhas sem letras minúsculas', () {
      final result = PasswordValidationService.validateComplexity('SENHAFORTE123');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('minúscula'));
    });

    test('Rejeita senhas sem números', () {
      final result = PasswordValidationService.validateComplexity('SenhaSemNumero');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('número'));
    });

    test('Rejeita senhas da lista de senhas previsíveis/comuns', () {
      final result = PasswordValidationService.validateComplexity('Password123');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('previsível'));
    });

    test('Aceita senha com boa estrutura e complexidade', () {
      final result = PasswordValidationService.validateComplexity('K9#mQz\$7vL2pX');
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });
  });

  group('PasswordValidationService - HaveIBeenPwned k-Anonymity', () {
    test('Detecta vazamento de senha notoriamente comprometida ("password123")', () async {
      final breachCount = await PasswordValidationService.checkBreachCount('password123');
      // "password123" tem centenas de milhares de vazamentos no HIBP
      expect(breachCount, greaterThan(0));
    });

    test('Validação completa bloqueia senha vazada', () async {
      // Passa na regra básica de regex, mas está vazada no HIBP
      final result = await PasswordValidationService.validateNewPassword('Password1234');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('vazamentos públicos'));
    });
  });
}
