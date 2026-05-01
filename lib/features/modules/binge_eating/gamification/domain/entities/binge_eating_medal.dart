/// Entidade de medalhas específicas do módulo Binge Eating
/// Baseada em conquistas de insígnias Disciplinum
enum BingeEatingMedal {
  bronze,    // 1 insígnia Disciplinum
  prata,     // 2 insígnias Disciplinum
  ouro,      // 3 insígnias Disciplinum
  diamante;  // 4 insígnias Disciplinum
}

extension BingeEatingMedalExtension on BingeEatingMedal {
  String get nameBr {
    switch (this) {
      case BingeEatingMedal.bronze:
        return 'Medalha de Bronze';
      case BingeEatingMedal.prata:
        return 'Medalha de Prata';
      case BingeEatingMedal.ouro:
        return 'Medalha de Ouro';
      case BingeEatingMedal.diamante:
        return 'Medalha de Diamante';
    }
  }

  String get description {
    switch (this) {
      case BingeEatingMedal.bronze:
        return 'Conquistou 1 insígnia Disciplinum';
      case BingeEatingMedal.prata:
        return 'Conquistou 2 insígnias Disciplinum';
      case BingeEatingMedal.ouro:
        return 'Conquistou 3 insígnias Disciplinum';
      case BingeEatingMedal.diamante:
        return 'Conquistou 4 insígnias Disciplinum';
    }
  }

  int get requiredDisciplinumInsignias {
    switch (this) {
      case BingeEatingMedal.bronze:
        return 1;
      case BingeEatingMedal.prata:
        return 2;
      case BingeEatingMedal.ouro:
        return 3;
      case BingeEatingMedal.diamante:
        return 4;
    }
  }

  String get asset {
    const prefix = 'assets/gamification/medals/binge_eating/';
    switch (this) {
      case BingeEatingMedal.bronze:
        return '${prefix}bronze.png';
      case BingeEatingMedal.prata:
        return '${prefix}silver.png';
      case BingeEatingMedal.ouro:
        return '${prefix}gold.png';
      case BingeEatingMedal.diamante:
        return '${prefix}diamond.png';
    }
  }

  bool canBeAwarded(int disciplinumCount) {
    switch (this) {
      case BingeEatingMedal.bronze:
        return disciplinumCount >= 1;
      case BingeEatingMedal.prata:
        return disciplinumCount >= 2;
      case BingeEatingMedal.ouro:
        return disciplinumCount >= 3;
      case BingeEatingMedal.diamante:
        return disciplinumCount >= 4;
    }
  }

  /// Sobrecarga para compatibilidade com List de Strings
  bool canBeAwardedFromList(List<String> earnedInsignias) {
    final disciplinumCount = earnedInsignias.where((i) => i == 'disciplinum').length;
    return canBeAwarded(disciplinumCount);
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case BingeEatingMedal.bronze:
        return '1 insígnia Disciplinum';
      case BingeEatingMedal.prata:
        return '2 insígnias Disciplinum';
      case BingeEatingMedal.ouro:
        return '3 insígnias Disciplinum';
      case BingeEatingMedal.diamante:
        return '4 insígnias Disciplinum';
    }
  }
}
