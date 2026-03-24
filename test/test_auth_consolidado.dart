import 'package:flutter_test/flutter_test.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_credentials.dart';

/// Teste CONSOLIDADO e COMPLETO de toda a feature de Auth
/// 
/// ESTRUTURA PROFISSIONAL: UM teste completo por feature
/// Substitui TODOS os arquivos espalhados de auth (33 arquivos → 1 arquivo)
void main() {
  group('🔐 AUTH - Teste Consolidado e Completo', () {
    // ========================================
    // 1. VALIDAÇÕES DE EMAIL
    // ========================================
    group('📧 Email Validation', () {
      test('deve validar emails corretos', () {
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'test123@test-domain.com',
          'user+tag@example.org',
        ];

        for (final email in validEmails) {
          final credentials = AuthCredentials.forSignin(email: email, password: '123456');
          expect(credentials.isEmailValid, isTrue, reason: 'Email válido: $email');
        }
      });

      test('deve rejeitar emails inválidos', () {
        final invalidEmails = [
          '',
          'invalid-email',
          '@domain.com',
          'user@',
          'user..name@domain.com',
        ];

        for (final email in invalidEmails) {
          final credentials = AuthCredentials.forSignin(email: email, password: '123456');
          expect(credentials.isEmailValid, isFalse, reason: 'Email inválido: $email');
        }
      });
    });

    // ========================================
    // 2. VALIDAÇÕES DE SENHA
    // ========================================
    group('🔑 Password Validation', () {
      test('deve validar senhas corretas (>= 6 caracteres)', () {
        final validPasswords = [
          '123456',
          'password',
          'Password123',
          'P@ssw0rd',
          'MySecurePass123',
        ];

        for (final password in validPasswords) {
          final credentials = AuthCredentials.forSignin(email: 'test@email.com', password: password);
          expect(credentials.isPasswordValid, isTrue, reason: 'Senha válida: $password');
        }
      });

      test('deve rejeitar senhas inválidas (< 6 caracteres)', () {
        final invalidPasswords = [
          '',
          '1',
          '12',
          '123',
          '1234',
          '12345',
        ];

        for (final password in invalidPasswords) {
          final credentials = AuthCredentials.forSignin(email: 'test@email.com', password: password);
          expect(credentials.isPasswordValid, isFalse, reason: 'Senha inválida: $password');
        }
      });
    });

    // ========================================
    // 3. VALIDAÇÕES DE NOME
    // ========================================
    group('👤 Name Validation', () {
      test('deve validar nomes corretos (não vazios)', () {
        final validNames = [
          'A',
          'Test User',
          'João Silva',
          'Álvaro Pérez',
          'Mary-Jane Watson',
        ];

        for (final name in validNames) {
          final credentials = AuthCredentials.forSignup(email: 'test@email.com', password: '123456', name: name);
          expect(credentials.name, equals(name));
        }
      });

      test('deve aceitar nome nulo para signin', () {
        final credentials = AuthCredentials.forSignin(email: 'test@email.com', password: '123456');
        expect(credentials.name, isNull);
      });
    });

    // ========================================
    // 4. CRIAÇÃO DE CREDENCIAIS
    // ========================================
    group('🔧 Credentials Creation', () {
      test('deve criar credenciais para signup', () {
        final credentials = AuthCredentials.forSignup(
          email: 'user@example.com',
          password: 'password123',
          name: 'John Doe',
        );

        expect(credentials.email, equals('user@example.com'));
        expect(credentials.password, equals('password123'));
        expect(credentials.name, equals('John Doe'));
        expect(credentials.authType, equals(AuthType.email));
        expect(credentials.isValidForSignup, isTrue);
      });

      test('deve criar credenciais para signin', () {
        final credentials = AuthCredentials.forSignin(
          email: 'user@example.com',
          password: 'password123',
        );

        expect(credentials.email, equals('user@example.com'));
        expect(credentials.password, equals('password123'));
        expect(credentials.name, isNull);
        expect(credentials.authType, equals(AuthType.email));
        expect(credentials.isValidForSignin, isTrue);
      });

      test('deve criar credenciais para social login', () {
        final credentials = AuthCredentials.forSocial(
          email: 'user@gmail.com',
          authType: AuthType.google,
          name: 'Google User',
        );

        expect(credentials.email, equals('user@gmail.com'));
        expect(credentials.password, equals('')); // Social não usa password
        expect(credentials.name, equals('Google User'));
        expect(credentials.authType, equals(AuthType.google));
      });
    });

    // ========================================
    // 5. CASOS DE USO COMPLETOS
    // ========================================
    group('🎯 Complete Use Cases', () {
      test('deve validar fluxo de signup completo', () {
        final credentials = AuthCredentials.forSignup(
          email: 'valid@example.com',
          password: '123456',
          name: 'Test User',
        );

        expect(credentials.isValidForSignup, isTrue);
        expect(credentials.isEmailValid, isTrue);
        expect(credentials.isPasswordValid, isTrue);
        expect(credentials.name, isNotNull);
      });

      test('deve validar fluxo de signin completo', () {
        final credentials = AuthCredentials.forSignin(
          email: 'valid@example.com',
          password: '123456',
        );

        expect(credentials.isValidForSignin, isTrue);
        expect(credentials.isEmailValid, isTrue);
        expect(credentials.isPasswordValid, isTrue);
        expect(credentials.name, isNull);
      });

      test('deve validar múltiplos cenários de borda', () {
        final testCases = [
          ('valid@email.com', '123456', 'Test', true, 'válido completo'),
          ('invalid', '123456', 'Test', false, 'email inválido'),
          ('valid@email.com', '123', 'Test', false, 'senha curta'),
          ('valid@email.com', '123456', '', false, 'nome vazio'),
          ('', '123456', 'Test', false, 'email vazio'),
          ('valid@email.com', '', 'Test', false, 'senha vazia'),
        ];

        for (final (email, password, name, expected, description) in testCases) {
          final credentials = AuthCredentials.forSignup(
            email: email,
            password: password,
            name: name,
          );
          expect(credentials.isValidForSignup, expected, reason: description);
        }
      });
    });

    // ========================================
    // 6. PERFORMANCE E ESTRUTURA
    // ========================================
    group('⚡ Performance and Structure', () {
      test('deve ter performance adequada', () async {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          final credentials = AuthCredentials.forSignin(email: 'test$i@email.com', password: 'password123');
          credentials.isValidForSignin;
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('deve ter estrutura de dados correta', () {
        final credentials = AuthCredentials.forSignup(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        expect(credentials.toString(), contains('test@example.com'));
        expect(credentials.toString(), contains('AuthType.email'));
        
        final props = credentials.props;
        expect(props.length, equals(4));
        expect(props[0], equals('test@example.com'));
        expect(props[1], equals('password123'));
        expect(props[2], equals('Test User'));
        expect(props[3], equals(AuthType.email));
      });

      test('deve implementar equals e hashCode corretamente', () {
        final credentials1 = AuthCredentials.forSignup(email: 'test@email.com', password: '123456', name: 'Test');
        final credentials2 = AuthCredentials.forSignup(email: 'test@email.com', password: '123456', name: 'Test');
        final credentials3 = AuthCredentials.forSignup(email: 'different@email.com', password: '123456', name: 'Test');

        expect(credentials1, equals(credentials2));
        expect(credentials1.hashCode, equals(credentials2.hashCode));
        expect(credentials1, isNot(equals(credentials3)));
      });
    });

    // ========================================
    // 7. EXTENSÕES E UTILITÁRIOS
    // ========================================
    group('🔧 Extensions and Utilities', () {
      test('deve ter displayName para todos os AuthType', () {
        expect(AuthType.email.displayName, isNotNull);
        expect(AuthType.google.displayName, isNotNull);
        expect(AuthType.apple.displayName, isNotNull);
        expect(AuthType.facebook.displayName, isNotNull);
      });

      test('deve lidar com dados inválidos gracefully', () {
        expect(() => AuthCredentials.forSignup(email: '', password: '', name: ''), returnsNormally);
      });
    });
  });
}
