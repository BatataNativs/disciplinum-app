/// Interface base para sistemas de medalhas de módulos
/// 
/// Cada módulo implementa esta interface para definir suas próprias
/// medalhas e regras de concessão baseadas em conquistas
abstract class ModuleMedalhaInterface {
  /// Lista todas as medalhas disponíveis no módulo
  List<String> getAllMedalhaIds();
  
  /// Obtém o nome da medalha para exibição
  String getMedalhaName(String medalhaId);
  
  /// Obtém o caminho do asset da medalha
  String getMedalhaAsset(String medalhaId);
  
  /// Obtém a descrição dos requisitos da medalha
  String getMedalhaRequirement(String medalhaId);
  
  /// Verifica se o usuário já conquistou esta medalha
  Future<bool> hasEarnedMedalha(String medalhaId);
  
  /// Concede uma medalha ao usuário
  Future<void> awardMedalha(String medalhaId);
  
  /// Remove uma medalha do usuário
  Future<void> revokeMedalha(String medalhaId);
  
  /// Obtém lista de medalhas conquistadas
  Future<List<String>> getEarnedMedalhas();
  
  /// Verifica se há novas medalhas para conceder
  Future<List<String>> checkForNewMedalhas(Map<String, dynamic> moduleData);
  
  /// Reseta todas as medalhas
  Future<void> resetMedalhas();
  
  /// Obtém o contador de conquistas específicas (ex: insígnias Disciplinum)
  Future<int> getConquestCounter();
  
  /// Incrementa o contador de conquistas
  Future<void> incrementConquestCounter();
}
