enum DietMedal { bronze, prata, ouro, diamante }

extension DietMedalExtension on DietMedal {
  String get nameBr {
    switch (this) {
      case DietMedal.bronze:
        return 'Bronze';
      case DietMedal.prata:
        return 'Prata';
      case DietMedal.ouro:
        return 'Ouro';
      case DietMedal.diamante:
        return 'Diamante';
    }
  }

  String get asset {
    switch (this) {
      case DietMedal.bronze:
        return 'assets/medal_bronze.png';
      case DietMedal.prata:
        return 'assets/medal_silver.png';
      case DietMedal.ouro:
        return 'assets/medal_gold.png';
      case DietMedal.diamante:
        return 'assets/medal_diamond.png';
    }
  }
}
