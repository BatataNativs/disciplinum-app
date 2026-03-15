import 'package:disciplinum/features/modules/reading/domain/services/reading_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/core/storage/local_storage_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';

/// Factory para criar adapters com injeção de dependências do Riverpod
/// 
/// Resolve problemas de compatibilidade usando padrão Factory
/// Evita dependências diretas de services que usam singleton
class ServiceFactory {
  
  /// Cria ReadingService com injeção de dependências
  static ReadingService createReadingService({
    required LocalStorageService localStorage,
    required GamificationService gamificationService,
  }) {
    // Por enquanto, retorna singleton existente
    // Implementar adapter completo quando ReadingService suportar injeção
    return throw UnimplementedError('ReadingService singleton access - implementar getter público');
  }

  /// Cria ProcrastinationService com injeção de dependências
  static ProcrastinationService createProcrastinationService({
    required LocalStorageService localStorage,
    required GamificationService gamificationService,
  }) {
    // Por enquanto, retorna singleton existente
    // Implementar adapter completo quando ProcrastinationService suportar injeção
    return throw UnimplementedError('ProcrastinationService singleton access - implementar getter público');
  }

  /// Cria GamificationService com injeção de dependências
  static GamificationService createGamificationService() {
    return GamificationService();
  }

  /// Wrapper para log de operações
  static void logOperation(
    LocalStorageService localStorage,
    String serviceName,
    String operation,
    String? details,
  ) {
    final message = details != null 
        ? '[$serviceName] $operation: $details'
        : '[$serviceName] $operation';
    
    // Usar LocalStorageService para log em vez de print
    localStorage.save('service_factory_log', message);
  }
}

/// Classe base para adapters comuns
abstract class ServiceAdapterBase<T> {
  final LocalStorageService localStorage;
  final T originalService;

  ServiceAdapterBase(this.localStorage, this.originalService);

  /// Log de operações padronizado
  void logOperation(String operation, [String? details]) {
    ServiceFactory.logOperation(
      localStorage,
      originalService.runtimeType.toString(),
      operation,
      details,
    );
  }
}
