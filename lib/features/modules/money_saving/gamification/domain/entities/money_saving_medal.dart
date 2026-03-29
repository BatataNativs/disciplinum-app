/// Entidade de medalhas específicas do módulo Money Saving
/// Baseada em desafios concluídos
enum MoneySavingMedalEntity {
  bronze,     // 1 desafio concluído
  prata,      // 2 desafios concluídos
  ouro,       // 3 desafios concluídos
  diamante;   // 4 desafios concluídos
}

extension MoneySavingMedalEntityExtension on MoneySavingMedalEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case MoneySavingMedalEntity.bronze:
        return 'bronze';
      case MoneySavingMedalEntity.prata:
        return 'prata';
      case MoneySavingMedalEntity.ouro:
        return 'ouro';
      case MoneySavingMedalEntity.diamante:
        return 'diamante';
    }
  }

  /// Obtém o número de desafios necessários
  int get requiredChallenges {
    switch (this) {
      case MoneySavingMedalEntity.bronze:
        return 1; // 1 desafio concluído
      case MoneySavingMedalEntity.prata:
        return 2; // 2 desafios concluídos
      case MoneySavingMedalEntity.ouro:
        return 3; // 3 desafios concluídos
      case MoneySavingMedalEntity.diamante:
        return 4; // 4 desafios concluídos
    }
  }

  /// Obtém o progresso percentual até esta medalha
  double get progressPercentage {
    switch (this) {
      case MoneySavingMedalEntity.bronze:
        return 25.0;
      case MoneySavingMedalEntity.prata:
        return 50.0;
      case MoneySavingMedalEntity.ouro:
        return 75.0;
      case MoneySavingMedalEntity.diamante:
        return 100.0;
    }
  }

  /// Obtém a descrição do benefício
  String get benefitDescription {
    switch (this) {
      case MoneySavingMedalEntity.bronze:
        return 'Primeiro desafio concluído com sucesso!';
      case MoneySavingMedalEntity.prata:
        return 'Segundo desafio concluído - você está no caminho certo!';
      case MoneySavingMedalEntity.ouro:
        return 'Terceiro desafio concluído - maestria em economia!';
      case MoneySavingMedalEntity.diamante:
        return 'Quarto desafio concluído - lenda da poupança!';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case MoneySavingMedalEntity.bronze:
        return 'Bronze';
      case MoneySavingMedalEntity.prata:
        return 'Prata';
      case MoneySavingMedalEntity.ouro:
        return 'Ouro';
      case MoneySavingMedalEntity.diamante:
        return 'Diamante';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/medals/money_saving/';
    switch (this) {
      case MoneySavingMedalEntity.bronze:
        return '${prefix}bronze.png';
      case MoneySavingMedalEntity.prata:
        return '${prefix}prata.png';
      case MoneySavingMedalEntity.ouro:
        return '${prefix}ouro.png';
      case MoneySavingMedalEntity.diamante:
        return '${prefix}diamante.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case MoneySavingMedalEntity.bronze:
        return 'Conclua 1 desafio';
      case MoneySavingMedalEntity.prata:
        return 'Conclua 2 desafios';
      case MoneySavingMedalEntity.ouro:
        return 'Conclua 3 desafios';
      case MoneySavingMedalEntity.diamante:
        return 'Conclua 4 desafios';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case MoneySavingMedalEntity.bronze:
        return '🥉';
      case MoneySavingMedalEntity.prata:
        return '🥈';
      case MoneySavingMedalEntity.ouro:
        return '🥇';
      case MoneySavingMedalEntity.diamante:
        return '💎';
    }
  }

  /// Obtém a categoria da medalha
  String get category {
    switch (this) {
      case MoneySavingMedalEntity.bronze:
        return 'Básica';
      case MoneySavingMedalEntity.prata:
        return 'Intermediária';
      case MoneySavingMedalEntity.ouro:
        return 'Avançada';
      case MoneySavingMedalEntity.diamante:
        return 'Máxima';
    }
  }

  /// Verifica se a medalha é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta medalha
  String get themeColor {
    switch (this) {
      case MoneySavingMedalEntity.bronze:
        return '#CD7F32'; // Bronze
      case MoneySavingMedalEntity.prata:
        return '#C0C0C0'; // Prata
      case MoneySavingMedalEntity.ouro:
        return '#FFD700'; // Dourado
      case MoneySavingMedalEntity.diamante:
        return '#B9F2FF'; // Azul claro
    }
  }
}
