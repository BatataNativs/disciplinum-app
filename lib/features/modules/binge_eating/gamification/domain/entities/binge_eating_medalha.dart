/// Entidade de medalhas específicas do módulo Binge Eating
/// Baseada em conquistas de insígnias Disciplinum
enum BingeEatingMedalha {
  bronze,    // 1 insígnia Disciplinum
  prata,     // 2 insígnias Disciplinum
  ouro,      // 3 insígnias Disciplinum
  diamante;  // 4 insígnias Disciplinum
}

extension BingeEatingMedalhaExtension on BingeEatingMedalha {
  String get nameBr {
    switch (this) {
      case BingeEatingMedalha.bronze:
        return 'Controle Bronze';
      case BingeEatingMedalha.prata:
        return 'Controle Prata';
      case BingeEatingMedalha.ouro:
        return 'Controle Ouro';
      case BingeEatingMedalha.diamante:
        return 'Controle Diamante';
    }
  }

  String get description {
    switch (this) {
      case BingeEatingMedalha.bronze:
        return 'Conquistou 1 insígnia Disciplinum';
      case BingeEatingMedalha.prata:
        return 'Conquistou 2 insígnias Disciplinum';
      case BingeEatingMedalha.ouro:
        return 'Conquistou 3 insígnias Disciplinum';
      case BingeEatingMedalha.diamante:
        return 'Conquistou 4 insígnias Disciplinum';
    }
  }

  int get requiredDisciplinumInsignias {
    switch (this) {
      case BingeEatingMedalha.bronze:
        return 1;
      case BingeEatingMedalha.prata:
        return 2;
      case BingeEatingMedalha.ouro:
        return 3;
      case BingeEatingMedalha.diamante:
        return 4;
    }
  }

  String get asset {
    const prefix = 'assets/gamification/medals/binge_eating/';
    switch (this) {
      case BingeEatingMedalha.bronze:
        return '${prefix}bronze.png';
      case BingeEatingMedalha.prata:
        return '${prefix}silver.png';
      case BingeEatingMedalha.ouro:
        return '${prefix}gold.png';
      case BingeEatingMedalha.diamante:
        return '${prefix}diamond.png';
    }
  }

  bool canBeAwarded(int disciplinumCount) {
    switch (this) {
      case BingeEatingMedalha.bronze:
        return disciplinumCount >= 1;
      case BingeEatingMedalha.prata:
        return disciplinumCount >= 2;
      case BingeEatingMedalha.ouro:
        return disciplinumCount >= 3;
      case BingeEatingMedalha.diamante:
        return disciplinumCount >= 4;
    }
  }
}
