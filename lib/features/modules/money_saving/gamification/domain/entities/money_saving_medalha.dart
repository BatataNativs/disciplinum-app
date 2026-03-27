/// Medalhas do módulo Money Saving Challenge
/// Baseadas em insignias Disciplinum e metas financeiras alcançadas
enum MoneySavingMedalha {
  // Nível 1: Bronze
  bronzeEconomista(
    'Bronze Economista',
    'Primeira medalha financeira. Economia básica dominada!',
    'assets/images/medalhas/money_saving_bronze.png',
    1, // Requer 1 insignia Disciplinum
  ),
  
  // Nível 2: Prata
  prataGuardiao(
    'Prata Guardião',
    'Protetor do orçamento familiar. Finanças sob controle!',
    'assets/images/medalhas/money_saving_prata.png',
    3, // Requer 3 insignias Disciplinum
  ),
  
  // Nível 3: Ouro
  ouroMestre(
    'Ouro Mestre',
    'Mestre da arte de economizar. Riqueza garantida!',
    'assets/images/medalhas/money_saving_ouro.png',
    6, // Requer 6 insignias Disciplinum
  ),
  
  // Nível 4: Diamante
  diamanteFinanceiro(
    'Diamante Financeiro',
    'Lenda da poupança. Status financeiro imbatível!',
    'assets/images/medalhas/money_saving_diamante.png',
    10, // Requer 10 insignias Disciplinum
  );

  const MoneySavingMedalha(
    this.name,
    this.description,
    this.assetPath,
    this.requiredDisciplinumInsignias,
  );

  final String name;
  final String description;
  final String assetPath;
  final int requiredDisciplinumInsignias;

  /// Verifica se esta medalha pode ser concedida
  bool canBeAwarded(int disciplinumCount, List<String> earnedMedalhas) {
    // Se já conquistou, não pode conquistar novamente
    if (earnedMedalhas.contains(name)) return false;
    
    // Verifica se tem insignias Disciplinum suficientes
    if (disciplinumCount < requiredDisciplinumInsignias) return false;
    
    // Verifica se conquistou todas as medalhas anteriores
    final allMedalhas = MoneySavingMedalha.values;
    final currentIndex = allMedalhas.indexOf(this);
    
    for (int i = 0; i < currentIndex; i++) {
      final previousMedalha = allMedalhas[i];
      if (!earnedMedalhas.contains(previousMedalha.name)) {
        return false;
      }
    }
    
    return true;
  }

  /// Obtém a próxima medalha a ser conquistada
  static MoneySavingMedalha? getNextMedalha(List<String> earnedMedalhas) {
    final allMedalhas = MoneySavingMedalha.values;
    
    for (final medalha in allMedalhas) {
      if (!earnedMedalhas.contains(medalha.name)) {
        return medalha;
      }
    }
    
    return null; // Todas as medalhas conquistadas
  }

  /// Calcula o progresso para a próxima medalha
  static double calculateProgress(int disciplinumCount, List<String> earnedMedalhas) {
    final nextMedalha = getNextMedalha(earnedMedalhas);
    if (nextMedalha == null) return 1.0; // 100% completo
    
    final previousMedalhas = MoneySavingMedalha.values
        .where((medalha) => earnedMedalhas.contains(medalha.name))
        .toList();
    
    if (previousMedalhas.isEmpty) {
      return disciplinumCount / nextMedalha.requiredDisciplinumInsignias;
    }
    
    final lastMedalha = previousMedalhas.last;
    final insigniasSinceLastMedalha = disciplinumCount - lastMedalha.requiredDisciplinumInsignias;
    final insigniasToNextMedalha = nextMedalha.requiredDisciplinumInsignias - lastMedalha.requiredDisciplinumInsignias;
    
    return (insigniasSinceLastMedalha / insigniasToNextMedalha).clamp(0.0, 1.0);
  }

  /// Obtém todas as medalhas disponíveis
  static List<MoneySavingMedalha> getAllMedalhas() {
    return MoneySavingMedalha.values;
  }

  /// Obtém medalhas conquistadas
  static List<MoneySavingMedalha> getEarnedMedalhas(List<String> earnedMedalhaNames) {
    return getAllMedalhas()
        .where((medalha) => earnedMedalhaNames.contains(medalha.name))
        .toList();
  }

  /// Verifica se conquistou medalha Diamante
  static bool hasDiamondMedalha(List<String> earnedMedalhas) {
    return earnedMedalhas.contains(diamanteFinanceiro.name);
  }

  /// Conta medalhas por nível
  static Map<String, int> countMedalhasByLevel(List<String> earnedMedalhaNames) {
    final earnedMedalhas = getEarnedMedalhas(earnedMedalhaNames);
    
    return {
      'bronze': earnedMedalhas.where((m) => m == bronzeEconomista).length,
      'prata': earnedMedalhas.where((m) => m == prataGuardiao).length,
      'ouro': earnedMedalhas.where((m) => m == ouroMestre).length,
      'diamante': earnedMedalhas.where((m) => m == diamanteFinanceiro).length,
    };
  }
}
