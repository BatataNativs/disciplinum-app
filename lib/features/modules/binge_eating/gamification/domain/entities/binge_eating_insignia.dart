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
        return 'Controle Iniciado';
      case BingeEatingInsignia.ferro:
        return 'Primeiro Dia';
      case BingeEatingInsignia.aluminio:
        return 'Dois Dias';
      case BingeEatingInsignia.latao:
        return 'Três Dias';
      case BingeEatingInsignia.bronze:
        return 'Cinco Dias';
      case BingeEatingInsignia.prata:
        return 'Dez Dias';
      case BingeEatingInsignia.ouro:
        return 'Quinze Dias';
      case BingeEatingInsignia.diamante:
        return 'Vinte Dias';
      case BingeEatingInsignia.disciplinum:
        return 'Trinta Dias';
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
}
