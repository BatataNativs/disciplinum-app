/// Insignias do módulo Money Saving Challenge
/// Baseadas em percentual da grid de desafio preenchida
enum MoneySavingInsignia {
  // Nível 1: Inicial
  madeira(
    'Madeira',
    'Início da Jornada. Ativou o módulo Desafio da Poupança!',
    0,
  ),
  
  // Nível 2: Básico
  ferro(
    'Ferro',
    '5% da grid de um desafio preenchida. Primeiros passos!',
    5,
  ),
  
  // Nível 3: Intermediário
  aluminio(
    'Alumínio',
    '10% da grid de um desafio preenchida. Bom progresso!',
    10,
  ),
  
  // Nível 4: Comprometido
  latao(
    'Latão',
    '15% da grid de um desafio preenchida. Continue assim!',
    15,
  ),
  
  // Nível 5: Bronze
  bronze(
    'Bronze',
    '20% da grid de um desafio preenchida. Metade do caminho!',
    20,
  ),
  
  // Nível 6: Prata
  prata(
    'Prata',
    '40% da grid de um desafio preenchida. Quase lá!',
    40,
  ),
  
  // Nível 7: Ouro
  ouro(
    'Ouro',
    '60% da grid de um desafio preenchida. Excelente!',
    60,
  ),
  
  // Nível 8: Diamante
  diamante(
    'Diamante',
    '80% da grid de um desafio preenchida. Quase completo!',
    80,
  ),
  
  // Nível 9: Disciplinum
  disciplinum(
    'Disciplinum',
    '100% da grid de um desafio preenchida. Desafio completo!',
    100,
  );

  const MoneySavingInsignia(
    this.name,
    this.description,
    this.requiredGridPercentage,
  );

  final String name;
  final String description;
  final int requiredGridPercentage;

  /// Verifica se esta insignia pode ser concedida baseada no percentual da grid
  bool canBeAwarded(int gridPercentage, List<String> earnedInsignias) {
    // Se já conquistou, não pode conquistar novamente
    if (earnedInsignias.contains(name)) return false;
    
    // Verifica se tem percentual suficiente
    if (gridPercentage < requiredGridPercentage) return false;
    
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
  static double calculateProgress(int gridPercentage, List<String> earnedInsignias) {
    final nextInsignia = getNextInsignia(earnedInsignias);
    if (nextInsignia == null) return 1.0; // 100% completo
    
    final previousInsignias = MoneySavingInsignia.values
        .where((insignia) => earnedInsignias.contains(insignia.name))
        .toList();
    
    if (previousInsignias.isEmpty) {
      return gridPercentage / nextInsignia.requiredGridPercentage;
    }
    
    final lastInsignia = previousInsignias.last;
    final percentageSinceLastInsignia = gridPercentage - lastInsignia.requiredGridPercentage;
    final percentageToNextInsignia = nextInsignia.requiredGridPercentage - lastInsignia.requiredGridPercentage;
    
    return (percentageSinceLastInsignia / percentageToNextInsignia).clamp(0.0, 1.0);
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
    return earnedInsignias.contains(disciplinum.name);
  }

  /// Conta quantas insignias Disciplinum foram conquistadas
  static int countDisciplinumInsignias(List<String> earnedInsignias) {
    return earnedInsignias.where((name) => name == disciplinum.name).length;
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/insignias/moneySaving/';
    switch (this) {
      case MoneySavingInsignia.madeira:
        return '${prefix}madeira.png';
      case MoneySavingInsignia.ferro:
        return '${prefix}ferro.png';
      case MoneySavingInsignia.aluminio:
        return '${prefix}aluminio.png';
      case MoneySavingInsignia.latao:
        return '${prefix}latao.png';
      case MoneySavingInsignia.bronze:
        return '${prefix}bronze.png';
      case MoneySavingInsignia.prata:
        return '${prefix}prata.png';
      case MoneySavingInsignia.ouro:
        return '${prefix}ouro.png';
      case MoneySavingInsignia.diamante:
        return '${prefix}diamante.png';
      case MoneySavingInsignia.disciplinum:
        return '${prefix}disciplinum.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case MoneySavingInsignia.madeira:
        return 'Ative o módulo Desafio da Poupança';
      case MoneySavingInsignia.ferro:
        return '5% da grid de um desafio preenchida';
      case MoneySavingInsignia.aluminio:
        return '10% da grid de um desafio preenchida';
      case MoneySavingInsignia.latao:
        return '15% da grid de um desafio preenchida';
      case MoneySavingInsignia.bronze:
        return '20% da grid de um desafio preenchida';
      case MoneySavingInsignia.prata:
        return '40% da grid de um desafio preenchida';
      case MoneySavingInsignia.ouro:
        return '60% da grid de um desafio preenchida';
      case MoneySavingInsignia.diamante:
        return '80% da grid de um desafio preenchida';
      case MoneySavingInsignia.disciplinum:
        return '100% da grid de um desafio preenchida';
    }
  }
}
