import 'package:flutter_test/flutter_test.dart';
import 'package:disciplinum/core/auth/password_validation_service.dart';

void main() {
  group('PasswordValidationService - Validação de Complexidade Local', () {
    test('Rejeita senhas com menos de 8 caracteres', () {
      final result = PasswordValidationService.validate('Ab1!');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('pelo menos 8 caracteres'));
    });

    test('Rejeita senhas sem letras maiúsculas', () {
      final result = PasswordValidationService.validate('senhaforte123');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('maiúscula'));
    });

    test('Rejeita senhas sem letras minúsculas', () {
      final result = PasswordValidationService.validate('SENHAFORTE123');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('minúscula'));
    });

    test('Rejeita senhas sem números', () {
      final result = PasswordValidationService.validate('SenhaSemNumero');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('número'));
    });

    test('Rejeita senhas da lista de senhas previsíveis/comuns', () {
      final result = PasswordValidationService.validate('Password123');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('previsível'));
    });

    test('Aceita senha com boa estrutura e complexidade', () {
      final result = PasswordValidationService.validate('K9#mQz\$7vL2pX');
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });
  });
}
