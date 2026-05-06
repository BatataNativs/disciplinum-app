/// Entidade de medalhas específicas do módulo Diet
/// Baseada em quantidade de insígnias Disciplinum conquistadas
enum DietMedal {
  bronze,     // 1 insígnia Disciplinum
  prata,      // 2 insígnias Disciplinum
  ouro,       // 3 insígnias Disciplinum
  diamante    // 4 insígnias Disciplinum
}

extension DietMedalExtension on DietMedal {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case DietMedal.bronze:
        return 'bronze';
      case DietMedal.prata:
        return 'prata';
      case DietMedal.ouro:
        return 'ouro';
      case DietMedal.diamante:
        return 'diamante';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case DietMedal.bronze:
        return 'Medalha de Bronze';
      case DietMedal.prata:
        return 'Medalha de Prata';
      case DietMedal.ouro:
        return 'Medalha de Ouro';
      case DietMedal.diamante:
        return 'Medalha de Diamante';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/medals/diet/';
    switch (this) {
      case DietMedal.bronze:
        return '${prefix}bronze.png';
      case DietMedal.prata:
        return '${prefix}silver.png';
      case DietMedal.ouro:
        return '${prefix}gold.png';
      case DietMedal.diamante:
        return '${prefix}diamond.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case DietMedal.bronze:
        return '1 insígnia Disciplinum';
      case DietMedal.prata:
        return '2 insígnias Disciplinum';
      case DietMedal.ouro:
        return '3 insígnias Disciplinum';
      case DietMedal.diamante:
        return '4 insígnias Disciplinum';
    }
  }

  /// Verifica se esta medalha pode ser concedida com base nas insígnias conquistadas
  bool canBeAwarded(List<String> earnedInsignias) {
    final disciplinumCount = earnedInsignias.where((i) => i == 'disciplinum').length;

    switch (this) {
      case DietMedal.bronze:
        return disciplinumCount >= 1;
      case DietMedal.prata:
        return disciplinumCount >= 2;
      case DietMedal.ouro:
        return disciplinumCount >= 3;
      case DietMedal.diamante:
        return disciplinumCount >= 4;
    }
  }

  /// Descrição da medalha (alias para requirementDescription)
  String get description => requirementDescription;

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case DietMedal.bronze:
        return '🥉';
      case DietMedal.prata:
        return '🥈';
      case DietMedal.ouro:
        return '🥇';
      case DietMedal.diamante:
        return '💎';
    }
  }
}
