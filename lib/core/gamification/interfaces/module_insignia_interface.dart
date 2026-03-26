/// Interface base para sistemas de insígnias de módulos
/// 
/// Cada módulo implementa esta interface para definir suas próprias
/// insígnias e regras de concessão
abstract class ModuleInsigniaInterface {
  /// Lista todas as insígnias disponíveis no módulo
  List<String> getAllInsigniaIds();
  
  /// Obtém o nome da insígnia para exibição
  String getInsigniaName(String insigniaId);
  
  /// Obtém o caminho do asset da insígnia
  String getInsigniaAsset(String insigniaId);
  
  /// Obtém a descrição dos requisitos da insígnia
  String getInsigniaRequirement(String insigniaId);
  
  /// Verifica se o usuário já conquistou esta insígnia
  Future<bool> hasEarnedInsignia(String insigniaId);
  
  /// Concede uma insígnia ao usuário
  Future<void> awardInsignia(String insigniaId);
  
  /// Remove uma insígnia do usuário
  Future<void> revokeInsignia(String insigniaId);
  
  /// Obtém lista de insígnias conquistadas
  Future<List<String>> getEarnedInsignias();
  
  /// Verifica se há novas insígnias para conceder
  Future<List<String>> checkForNewInsignias(Map<String, dynamic> moduleData);
  
  /// Reseta todas as insígnias (mantém apenas a inicial se houver)
  Future<void> resetInsignias();
}
