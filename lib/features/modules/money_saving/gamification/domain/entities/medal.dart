/// Entidade de medalhas do módulo Money Saving
/// Duplicada da gamificação central para independência total do módulo
enum MoneySavingGamificationMedal { bronze, prata, ouro, diamante }

extension MoneySavingGamificationMedalExtension on MoneySavingGamificationMedal {
  String get nameBr {
    switch (this) {
      case MoneySavingGamificationMedal.bronze:
        return 'Bronze';
      case MoneySavingGamificationMedal.prata:
        return 'Prata';
      case MoneySavingGamificationMedal.ouro:
        return 'Ouro';
      case MoneySavingGamificationMedal.diamante:
        return 'Diamante';
    }
  }

  String get asset {
    switch (this) {
      case MoneySavingGamificationMedal.bronze:
        return 'assets/medal_bronze.png';
      case MoneySavingGamificationMedal.prata:
        return 'assets/medal_silver.png';
      case MoneySavingGamificationMedal.ouro:
        return 'assets/medal_gold.png';
      case MoneySavingGamificationMedal.diamante:
        return 'assets/medal_diamond.png';
    }
  }

  /// Obtém a descrição específica para Money Saving
  String get description {
    switch (this) {
      case MoneySavingGamificationMedal.bronze:
        return 'Primeiros passos na economia! Você começou bem!';
      case MoneySavingGamificationMedal.prata:
        return 'Consistência em economizar! Você está no caminho certo!';
      case MoneySavingGamificationMedal.ouro:
        return 'Maestria financeira! Sua disciplina é exemplar!';
      case MoneySavingGamificationMedal.diamante:
        return 'Lenda da poupança! Você é um inspirador!';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case MoneySavingGamificationMedal.bronze:
        return '🥉';
      case MoneySavingGamificationMedal.prata:
        return '🥈';
      case MoneySavingGamificationMedal.ouro:
        return '🥇';
      case MoneySavingGamificationMedal.diamante:
        return '💎';
    }
  }

  /// Verifica se é a medalha mais alta
  bool get isHighest => this == MoneySavingGamificationMedal.diamante;

  /// Obtém a próxima medalha
  MoneySavingGamificationMedal? get next {
    switch (this) {
      case MoneySavingGamificationMedal.bronze:
        return MoneySavingGamificationMedal.prata;
      case MoneySavingGamificationMedal.prata:
        return MoneySavingGamificationMedal.ouro;
      case MoneySavingGamificationMedal.ouro:
        return MoneySavingGamificationMedal.diamante;
      case MoneySavingGamificationMedal.diamante:
        return null; // Já é a mais alta
    }
  }

  /// Converte de string para enum
  static MoneySavingGamificationMedal? fromString(String? value) {
    switch (value) {
      case 'bronze':
        return MoneySavingGamificationMedal.bronze;
      case 'prata':
        return MoneySavingGamificationMedal.prata;
      case 'ouro':
        return MoneySavingGamificationMedal.ouro;
      case 'diamante':
        return MoneySavingGamificationMedal.diamante;
      default:
        return null;
    }
  }
}
