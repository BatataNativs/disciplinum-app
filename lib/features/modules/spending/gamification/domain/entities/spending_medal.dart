/// Entidade de medalhas específicas do módulo Spending
/// Baseada em insignias específicas conquistadas
enum SpendingMedalEntity {
  bronze,     // Ganhou insígnia Latão
  prata,      // Ganhou insígnia Ouro
  ouro,       // Ganhou insígnia Diamante
  diamante;   // Ganhou insígnia Disciplinum
}

extension SpendingMedalEntityExtension on SpendingMedalEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case SpendingMedalEntity.bronze:
        return 'bronze';
      case SpendingMedalEntity.prata:
        return 'prata';
      case SpendingMedalEntity.ouro:
        return 'ouro';
      case SpendingMedalEntity.diamante:
        return 'diamante';
    }
  }

  /// Obtém a insígnia necessária para esta medalha
  String get requiredInsignia {
    switch (this) {
      case SpendingMedalEntity.bronze:
        return 'latao'; // Ganhou insígnia Latão
      case SpendingMedalEntity.prata:
        return 'ouro'; // Ganhou insígnia Ouro
      case SpendingMedalEntity.ouro:
        return 'diamante'; // Ganhou insígnia Diamante
      case SpendingMedalEntity.diamante:
        return 'disciplinum'; // Ganhou insígnia Disciplinum
    }
  }

  /// Obtém o progresso percentual até esta medalha
  double get progressPercentage {
    switch (this) {
      case SpendingMedalEntity.bronze:
        return 25.0;
      case SpendingMedalEntity.prata:
        return 50.0;
      case SpendingMedalEntity.ouro:
        return 75.0;
      case SpendingMedalEntity.diamante:
        return 100.0;
    }
  }

  /// Obtém a descrição do benefício
  String get benefitDescription {
    switch (this) {
      case SpendingMedalEntity.bronze:
        return 'Conquistou a insígnia Latão - 3 meses de contas em dia!';
      case SpendingMedalEntity.prata:
        return 'Conquistou a insígnia Ouro - 8 meses de contas em dia!';
      case SpendingMedalEntity.ouro:
        return 'Conquistou a insígnia Diamante - 10 meses de contas em dia!';
      case SpendingMedalEntity.diamante:
        return 'Conquistou a insígnia Disciplinum - 12 meses de contas em dia!';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case SpendingMedalEntity.bronze:
        return 'Medalha de Bronze';
      case SpendingMedalEntity.prata:
        return 'Medalha de Prata';
      case SpendingMedalEntity.ouro:
        return 'Medalha de Ouro';
      case SpendingMedalEntity.diamante:
        return 'Medalha de Diamante';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/medals/spending/';
    switch (this) {
      case SpendingMedalEntity.bronze:
        return '${prefix}bronze.png';
      case SpendingMedalEntity.prata:
        return '${prefix}prata.png';
      case SpendingMedalEntity.ouro:
        return '${prefix}ouro.png';
      case SpendingMedalEntity.diamante:
        return '${prefix}diamante.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case SpendingMedalEntity.bronze:
        return 'Conquiste a insígnia Latão';
      case SpendingMedalEntity.prata:
        return 'Conquiste a insígnia Ouro';
      case SpendingMedalEntity.ouro:
        return 'Conquiste a insígnia Diamante';
      case SpendingMedalEntity.diamante:
        return 'Conquiste a insígnia Disciplinum';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case SpendingMedalEntity.bronze:
        return '🥉';
      case SpendingMedalEntity.prata:
        return '🥈';
      case SpendingMedalEntity.ouro:
        return '🥇';
      case SpendingMedalEntity.diamante:
        return '💎';
    }
  }

  /// Obtém a categoria da medalha
  String get category {
    switch (this) {
      case SpendingMedalEntity.bronze:
        return 'Básica';
      case SpendingMedalEntity.prata:
        return 'Intermediária';
      case SpendingMedalEntity.ouro:
        return 'Avançada';
      case SpendingMedalEntity.diamante:
        return 'Máxima';
    }
  }

  /// Verifica se a medalha é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta medalha
  String get themeColor {
    switch (this) {
      case SpendingMedalEntity.bronze:
        return '#CD7F32'; // Bronze
      case SpendingMedalEntity.prata:
        return '#C0C0C0'; // Prata
      case SpendingMedalEntity.ouro:
        return '#FFD700'; // Dourado
      case SpendingMedalEntity.diamante:
        return '#B9F2FF'; // Azul claro
    }
  }

  /// Verifica se esta medalha pode ser concedida com base nas insígnias conquistadas
  bool canBeAwarded(List<String> earnedInsignias) {
    return earnedInsignias.contains(requiredInsignia);
  }
}
