/// Entidade de insígnias específicas do módulo Binge Eating
/// Baseada em check-ins diários positivos consecutivos
enum BingeEatingInsignia {
  madeira,    // Apenas por configurar e ativar o módulo
  ferro,      // 1 dia com check-in positivo
  aluminio,   // 2 dias com check-in positivo
  latao,      // 3 dias com check-in positivo
  bronze,     // 5 dias com check-in positivo
  prata,      // 10 dias com check-in positivo
  ouro,       // 15 dias com check-in positivo
  diamante,   // 20 dias com check-in positivo
  disciplinum; // 30 dias com check-in positivo
}

extension BingeEatingInsigniaExtension on BingeEatingInsignia {
  String get nameBr {
    switch (this) {
      case BingeEatingInsignia.madeira:
        return 'Madeira';
      case BingeEatingInsignia.ferro:
        return 'Ferro';
      case BingeEatingInsignia.aluminio:
        return 'Alumínio';
      case BingeEatingInsignia.latao:
        return 'Latão';
      case BingeEatingInsignia.bronze:
        return 'Bronze';
      case BingeEatingInsignia.prata:
        return 'Prata';
      case BingeEatingInsignia.ouro:
        return 'Ouro';
      case BingeEatingInsignia.diamante:
        return 'Diamante';
      case BingeEatingInsignia.disciplinum:
        return 'Disciplinum';
    }
  }

  String get description {
    switch (this) {
      case BingeEatingInsignia.madeira:
        return 'Módulo configurado e ativado';
      case BingeEatingInsignia.ferro:
        return '1 dia com check-in positivo';
      case BingeEatingInsignia.aluminio:
        return '2 dias com check-in positivo';
      case BingeEatingInsignia.latao:
        return '3 dias com check-in positivo';
      case BingeEatingInsignia.bronze:
        return '5 dias com check-in positivo';
      case BingeEatingInsignia.prata:
        return '10 dias com check-in positivo';
      case BingeEatingInsignia.ouro:
        return '15 dias com check-in positivo';
      case BingeEatingInsignia.diamante:
        return '20 dias com check-in positivo';
      case BingeEatingInsignia.disciplinum:
        return '30 dias com check-in positivo';
    }
  }

  int get requiredDays {
    switch (this) {
      case BingeEatingInsignia.madeira:
        return 0;
      case BingeEatingInsignia.ferro:
        return 1;
      case BingeEatingInsignia.aluminio:
        return 2;
      case BingeEatingInsignia.latao:
        return 3;
      case BingeEatingInsignia.bronze:
        return 5;
      case BingeEatingInsignia.prata:
        return 10;
      case BingeEatingInsignia.ouro:
        return 15;
      case BingeEatingInsignia.diamante:
        return 20;
      case BingeEatingInsignia.disciplinum:
        return 30;
    }
  }

  bool canBeAwarded(List<String> earnedInsignias) {
    if (earnedInsignias.contains(name)) return false;

    // Verifica se tem as insígnias anteriores
    final previousInsignias = <BingeEatingInsignia>[];
    for (final insignia in BingeEatingInsignia.values) {
      if (insignia == this) break;
      previousInsignias.add(insignia);
    }

    for (final previous in previousInsignias) {
      if (!earnedInsignias.contains(previous.name)) return false;
    }

    return true;
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/insignias/binge_eating/';
    switch (this) {
      case BingeEatingInsignia.madeira:
        return '${prefix}madeira.png';
      case BingeEatingInsignia.ferro:
        return '${prefix}ferro.png';
      case BingeEatingInsignia.aluminio:
        return '${prefix}aluminio.png';
      case BingeEatingInsignia.latao:
        return '${prefix}latao.png';
      case BingeEatingInsignia.bronze:
        return '${prefix}bronze.png';
      case BingeEatingInsignia.prata:
        return '${prefix}prata.png';
      case BingeEatingInsignia.ouro:
        return '${prefix}ouro.png';
      case BingeEatingInsignia.diamante:
        return '${prefix}diamante.png';
      case BingeEatingInsignia.disciplinum:
        return '${prefix}disciplinum.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case BingeEatingInsignia.madeira:
        return 'Ative o módulo Binge Eating';
      case BingeEatingInsignia.ferro:
        return '1 dia com check-in positivo';
      case BingeEatingInsignia.aluminio:
        return '2 dias com check-in positivo';
      case BingeEatingInsignia.latao:
        return '3 dias com check-in positivo';
      case BingeEatingInsignia.bronze:
        return '5 dias com check-in positivo';
      case BingeEatingInsignia.prata:
        return '10 dias com check-in positivo';
      case BingeEatingInsignia.ouro:
        return '15 dias com check-in positivo';
      case BingeEatingInsignia.diamante:
        return '20 dias com check-in positivo';
      case BingeEatingInsignia.disciplinum:
        return '30 dias com check-in positivo';
    }
  }
}
