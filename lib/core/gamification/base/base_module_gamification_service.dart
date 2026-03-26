import 'package:disciplinum/core/gamification/interfaces/module_gamification_interface.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Classe base abstrata para serviços de gamificação de módulos
/// 
/// Fornece implementação comum para todos os módulos, reduzindo
/// código duplicado e garantindo consistência
abstract class BaseModuleGamificationService implements ModuleGamificationInterface {
  @override
  String get moduleId;
  
  @override
  String get moduleName;
  
  @override
  Future<void> initialize() async {
    LoggerService.instance.gamification('Inicializando gamificação do módulo: $moduleName');
    await initializeModuleSpecific();
  }
  
  @override
  Future<void> processModuleEvent(Map<String, dynamic> eventData) async {
    LoggerService.instance.gamification('Processando evento no módulo $moduleName: $eventData');
    
    // Processa evento específico do módulo
    await processModuleSpecificEvent(eventData);
    
    // Verifica por novas conquistas
    await checkForNewAchievements();
    
    // Envia notificações especiais se necessário
    await sendSpecialNotifications();
  }
  
  @override
  Future<void> resetProgress() async {
    LoggerService.instance.gamification('Resetando progresso do módulo: $moduleName');
    
    await insigniaService.resetInsignias();
    await medalhaService.resetMedalhas();
    
    await resetModuleSpecificProgress();
  }
  
  @override
  Future<void> checkForNewAchievements() async {
    try {
      final currentState = await getCurrentState();
      
      // Verifica novas insígnias
      final newInsignias = await insigniaService.checkForNewInsignias(currentState);
      for (final insigniaId in newInsignias) {
        await insigniaService.awardInsignia(insigniaId);
        LoggerService.instance.gamification('Nova insígnia concedida em $moduleName: $insigniaId');
      }
      
      // Verifica novas medalhas
      final newMedalhas = await medalhaService.checkForNewMedalhas(currentState);
      for (final medalhaId in newMedalhas) {
        await medalhaService.awardMedalha(medalhaId);
        LoggerService.instance.gamification('Nova medalha concedida em $moduleName: $medalhaId');
      }
      
    } catch (e) {
      LoggerService.instance.e('Erro ao verificar conquistas em $moduleName', error: e);
    }
  }
  
  // Métodos abstratos que cada módulo deve implementar
  Future<void> initializeModuleSpecific();
  Future<void> processModuleSpecificEvent(Map<String, dynamic> eventData);
  Future<void> resetModuleSpecificProgress();
}
