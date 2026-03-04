enum GamificationMedal { bronze, prata, ouro, diamante }

extension GamificationMedalExtension on GamificationMedal {
  String get nameBr {
    switch (this) {
      case GamificationMedal.bronze:
        return 'Bronze';
      case GamificationMedal.prata:
        return 'Prata';
      case GamificationMedal.ouro:
        return 'Ouro';
      case GamificationMedal.diamante:
        return 'Diamante';
    }
  }

  String get asset {
    switch (this) {
      case GamificationMedal.bronze:
        return 'assets/medal_bronze.png';
      case GamificationMedal.prata:
        return 'assets/medal_silver.png';
      case GamificationMedal.ouro:
        return 'assets/medal_gold.png';
      case GamificationMedal.diamante:
        return 'assets/medal_diamond.png';
    }
  }
}
