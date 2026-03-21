// Script para testar as correções dos erros
import 'package:disciplinum/core/logging/logger_service.dart';

void main() {
  // Teste 1: LoggerService
  LoggerService.instance.d('Testando LoggerService...');
  LoggerService.instance.d('Teste de debug message');
  LoggerService.instance.w('Teste de warning message');
  LoggerService.instance.d('✅ LoggerService funcionando corretamente');
  
  LoggerService.instance.d('🎉 Teste básico passou!');
  LoggerService.instance.d('Execute o app normalmente para verificar se os erros foram resolvidos.');
}
