/// Insignias do módulo Money Saving Challenge
/// Baseadas em dias consecutivos de economia e metas alcançadas
enum MoneySavingInsignia {
  // Nível 1: Iniciante
  economistaInicial(
    'Economista Inicial',
    'Primeiro dia de economia! Começo de uma jornada financeira sólida.',
    1,
  ),
  
  // Nível 2: Consistente
  poupadorSemanal(
    'Poupador Semanal',
    '7 dias consecutivos economizando. Hábito financeiro se formando!',
    7,
  ),
  
  // Nível 3: Determinado
  guardiaoFinanceiro(
    'Guardião Financeiro',
    '15 dias consecutivos. Sua disciplina financeira é impressionante!',
    15,
  ),
  
  // Nível 4: Focado
  mestreDaEconomia(
    'Mestre da Economia',
    '30 dias consecutivos. Você domina a arte de poupar!',
    30,
  ),
  
  // Nível 5: Comprometido
  investidorDedicado(
    'Investidor Dedicado',
    '60 dias consecutivos. Seu futuro financeiro está garantido!',
    60,
  ),
  
  // Nível 6: Especialista
    acumuladorExpert(
    'Acumulador Expert',
    '90 dias consecutivos. Você é referência em economia!',
    90,
  ),
  
  // Nível 7: Mestre
    financeiroMaster(
    'Financeiro Master',
    '180 dias consecutivos. Lenda da disciplina financeira!',
    180,
  ),
  
  // Nível 8: Lenda
    lendaDaPoupanca(
    'Lenda da Poupança',
    '365 dias consecutivos. Imortal na arte de economizar!',
    365,
  ),
  
  // Nível 9: Disciplinum
    disciplinumFinanceiro(
    'Disciplinum Financeiro',
    'Conquista máxima. Você transcendeu a economia!',
    1000,
  );

  const MoneySavingInsignia(
    this.name,
    this.description,
    this.requiredConsecutiveDays,
  );

  final String name;
  final String description;
  final int requiredConsecutiveDays;

  /// Verifica se esta insignia pode ser concedida baseada nos dias consecutivos
  bool canBeAwarded(int consecutiveDays, List<String> earnedInsignias) {
    // Se já conquistou, não pode conquistar novamente
    if (earnedInsignias.contains(name)) return false;
    
    // Verifica se tem dias consecutivos suficientes
    if (consecutiveDays < requiredConsecutiveDays) return false;
    
    // Verifica se conquistou todas as insignias anteriores
    final allInsignias = MoneySavingInsignia.values;
    final currentIndex = allInsignias.indexOf(this);
    
    for (int i = 0; i < currentIndex; i++) {
      final previousInsignia = allInsignias[i];
      if (!earnedInsignias.contains(previousInsignia.name)) {
        return false;
      }
    }
    
    return true;
  }

  /// Obtém a próxima insignia a ser conquistada
  static MoneySavingInsignia? getNextInsignia(List<String> earnedInsignias) {
    final allInsignias = MoneySavingInsignia.values;
    
    for (final insignia in allInsignias) {
      if (!earnedInsignias.contains(insignia.name)) {
        return insignia;
      }
    }
    
    return null; // Todas as insignias conquistadas
  }

  /// Calcula o progresso para a próxima insignia
  static double calculateProgress(int consecutiveDays, List<String> earnedInsignias) {
    final nextInsignia = getNextInsignia(earnedInsignias);
    if (nextInsignia == null) return 1.0; // 100% completo
    
    final previousInsignias = MoneySavingInsignia.values
        .where((insignia) => earnedInsignias.contains(insignia.name))
        .toList();
    
    if (previousInsignias.isEmpty) {
      return consecutiveDays / nextInsignia.requiredConsecutiveDays;
    }
    
    final lastInsignia = previousInsignias.last;
    final daysSinceLastInsignia = consecutiveDays - lastInsignia.requiredConsecutiveDays;
    final daysToNextInsignia = nextInsignia.requiredConsecutiveDays - lastInsignia.requiredConsecutiveDays;
    
    return (daysSinceLastInsignia / daysToNextInsignia).clamp(0.0, 1.0);
  }

  /// Obtém todas as insignias disponíveis
  static List<MoneySavingInsignia> getAllInsignias() {
    return MoneySavingInsignia.values;
  }

  /// Obtém insignias conquistadas
  static List<MoneySavingInsignia> getEarnedInsignias(List<String> earnedInsigniaNames) {
    return getAllInsignias()
        .where((insignia) => earnedInsigniaNames.contains(insignia.name))
        .toList();
  }

  /// Verifica se conquistou insignia Disciplinum
  static bool hasDisciplinum(List<String> earnedInsignias) {
    return earnedInsignias.contains(disciplinumFinanceiro.name);
  }

  /// Conta quantas insignias Disciplinum foram conquistadas
  static int countDisciplinumInsignias(List<String> earnedInsignias) {
    return earnedInsignias.where((name) => name == disciplinumFinanceiro.name).length;
  }
}
