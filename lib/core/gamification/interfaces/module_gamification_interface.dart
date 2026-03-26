import 'package:disciplinum/core/gamification/interfaces/module_insignia_interface.dart';
import 'package:disciplinum/core/gamification/interfaces/module_medalha_interface.dart';

/// Interface base para todos os sistemas de gamificação de módulos
/// 
/// Cada módulo (smoking, focus, reading, etc.) deve implementar esta interface
/// para fornecer sua própria lógica de gamificação de forma autônoma.
abstract class ModuleGamificationInterface {
  /// Identificador único do módulo
  String get moduleId;
  
  /// Nome do módulo para exibição
  String get moduleName;
  
  /// Service de insígnias do módulo
  ModuleInsigniaInterface get insigniaService;
  
  /// Service de medalhas do módulo
  ModuleMedalhaInterface get medalhaService;
  
  /// Inicializa o sistema de gamificação do módulo
  Future<void> initialize();
  
  /// Processa um evento do módulo (check-in, progresso, etc.)
  Future<void> processModuleEvent(Map<String, dynamic> eventData);
  
  /// Reseta todo o progresso do módulo
  Future<void> resetProgress();
  
  /// Obtém o estado atual da gamificação
  Future<Map<String, dynamic>> getCurrentState();
  
  /// Verifica se há novas conquistas a serem concedidas
  Future<void> checkForNewAchievements();
  
  /// Envia notificações especiais do módulo
  Future<void> sendSpecialNotifications();
}
