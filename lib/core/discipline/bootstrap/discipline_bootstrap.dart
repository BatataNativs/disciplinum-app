import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/discipline/discipline_initializer.dart';
import 'package:disciplinum/core/discipline/module_registry.dart';
import 'package:disciplinum/core/discipline/module_discipline_engine.dart';
import 'package:disciplinum/features/modules/focus/discipline/focus_discipline_module.dart';
import 'package:disciplinum/features/modules/adult_content/discipline/adult_content_discipline_module.dart';
import 'package:disciplinum/features/modules/diet/discipline/diet_discipline_module.dart';
import 'package:disciplinum/features/modules/smoking/discipline/smoking_discipline_module.dart';
import 'package:disciplinum/features/modules/reading/discipline/reading_discipline_module.dart';
import 'package:disciplinum/features/modules/money_saving/discipline/money_saving_discipline_module.dart';
import 'package:disciplinum/features/modules/procrastination/discipline/procrastination_discipline_module.dart';
import 'package:disciplinum/features/modules/binge_eating/discipline/binge_eating_discipline_module.dart';
import 'package:disciplinum/features/modules/spending/discipline/spending_discipline_module.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service.dart';
import 'package:disciplinum/features/modules/diet/domain/services/diet_service.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Bootstrap para inicializar todos os módulos de disciplina
/// Substitui o DisciplineEngineInitializer original
class DisciplineBootstrap {
  /// Inicializa todos os 9 módulos do sistema
  static Future<void> initializeAllModules(WidgetRef ref) async {
    try {
      // Obtém serviços necessários
      final awardEngine = ref.read(gamificationAwardEngineProvider);
      
      // 1. Módulos já existentes no sistema original
      final focusModule = FocusDisciplineModule(
        focusService: ref.read(focusServiceProvider),
        awardEngine: awardEngine,
      );
      
      final adultContentModule = AdultContentDisciplineModule(
        adultContentService: ref.read(adultContentServiceProvider),
        awardEngine: awardEngine,
      );
      
      final dietModule = DietDisciplineModule(
        dietService: ref.read(dietServiceProvider),
        awardEngine: awardEngine,
      );
      
      // 2. Novos módulos criados - usando providers existentes
      final smokingModule = SmokingDisciplineModule(
        smokingService: ref.read(smokingServiceProvider),
        awardEngine: awardEngine,
      );
      
      final readingModule = ReadingDisciplineModule(
        readingService: ref.read(readingServiceProvider),
        awardEngine: awardEngine,
      );
      
      final moneySavingModule = MoneySavingDisciplineModule(
        moneySavingService: ref.read(moneySavingChallengeServiceProvider),
        awardEngine: awardEngine,
      );
      
      final procrastinationModule = ProcrastinationDisciplineModule(
        procrastinationService: ref.read(procrastinationServiceProvider),
        awardEngine: awardEngine,
      );
      
      final bingeEatingModule = BingeEatingDisciplineModule(
        bingeEatingService: ref.read(bingeEatingServiceProvider),
        awardEngine: awardEngine,
      );
      
      final spendingModule = SpendingDisciplineModule(
        spendingService: ref.read(spendingServiceProvider),
        awardEngine: awardEngine,
      );
      
      // 3. Registra todos os módulos disponíveis
      await DisciplineInitializer.registerModules([
        focusModule,
        adultContentModule,
        dietModule,
        smokingModule,
        readingModule,
        moneySavingModule,
        procrastinationModule,
        bingeEatingModule,
        spendingModule,
        // Todos os 9 módulos agora ativos
      ]);
      
      // 4. Inicializa o sistema
      await DisciplineInitializer.initialize();
      
    } catch (e) {
      // Em caso de erro, tenta inicializar apenas com os módulos básicos
      await _initializeBasicModules(ref);
      rethrow;
    }
  }
  
  /// Inicialização básica apenas com os módulos que funcionam
  static Future<void> _initializeBasicModules(WidgetRef ref) async {
    try {
      final awardEngine = ref.read(gamificationAwardEngineProvider);
      
      final focusModule = FocusDisciplineModule(
        focusService: ref.read(focusServiceProvider),
        awardEngine: awardEngine,
      );
      
      final adultContentModule = AdultContentDisciplineModule(
        adultContentService: AdultContentService(ref.read(isarPreferencesRepositoryProvider)),
        awardEngine: awardEngine,
      );
      
      final dietModule = DietDisciplineModule(
        dietService: DietService(ref.read(isarPreferencesRepositoryProvider)),
        awardEngine: awardEngine,
      );
      
      await DisciplineInitializer.registerModules([
        focusModule,
        adultContentModule,
        dietModule,
      ]);
      
      await DisciplineInitializer.initialize();
      
    } catch (e) {
      // Último recurso: inicializa sem módulos
      await DisciplineInitializer.initialize();
    }
  }
  
  /// Obtém estatísticas do sistema
  static Map<String, dynamic> getSystemStats() {
    return DisciplineInitializer.getStatistics();
  }
  
  /// Verifica saúde do sistema
  static Map<String, dynamic> checkSystemHealth() {
    final registryHealth = ModuleRegistry.instance.checkHealth();
    final engineStats = ModuleDisciplineEngine.instance.getStatistics();
    
    return {
      'registry_health': registryHealth,
      'engine_stats': engineStats,
      'total_modules': engineStats['total_modules'] ?? 0,
      'total_rules': engineStats['total_rules'] ?? 0,
      'healthy': registryHealth['healthy'] ?? false,
    };
  }
  
  /// Limpa o sistema
  static Future<void> dispose() async {
    await DisciplineInitializer.dispose();
  }
}
