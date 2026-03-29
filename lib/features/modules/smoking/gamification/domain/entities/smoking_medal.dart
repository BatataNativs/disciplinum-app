/// Entidade de medalhas específicas do módulo Smoking
/// Baseada em quantidade de insígnias Disciplinum conquistadas
enum SmokingMedalEntity {
  bronze,     // 1 insígnia Disciplinum
  prata,      // 2 insígnias Disciplinum
  ouro,       // 3 insígnias Disciplinum
  diamante;   // 4 insígnias Disciplinum
}

extension SmokingMedalEntityExtension on SmokingMedalEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case SmokingMedalEntity.bronze:
        return 'bronze';
      case SmokingMedalEntity.prata:
        return 'prata';
      case SmokingMedalEntity.ouro:
        return 'ouro';
      case SmokingMedalEntity.diamante:
        return 'diamante';
    }
  }

  /// Obtém o número de insígnias Disciplinum necessárias
  int get requiredDisciplinumInsignias {
    switch (this) {
      case SmokingMedalEntity.bronze:
        return 1; // 1 insígnia Disciplinum
      case SmokingMedalEntity.prata:
        return 2; // 2 insígnias Disciplinum
      case SmokingMedalEntity.ouro:
        return 3; // 3 insígnias Disciplinum
      case SmokingMedalEntity.diamante:
        return 4; // 4 insígnias Disciplinum
    }
  }

  /// Obtém o progresso percentual até esta medalha
  double get progressPercentage {
    switch (this) {
      case SmokingMedalEntity.bronze:
        return 25.0;
      case SmokingMedalEntity.prata:
        return 50.0;
      case SmokingMedalEntity.ouro:
        return 75.0;
      case SmokingMedalEntity.diamante:
        return 100.0;
    }
  }

  /// Obtém a descrição do benefício
  String get benefitDescription {
    switch (this) {
      case SmokingMedalEntity.bronze:
        return 'Primeira conquista Disciplinum alcançada!';
      case SmokingMedalEntity.prata:
        return 'Segunda conquista Disciplinum alcançada!';
      case SmokingMedalEntity.ouro:
        return 'Terceira conquista Disciplinum alcançada!';
      case SmokingMedalEntity.diamante:
        return 'Quarta conquista Disciplinum alcançada!';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case SmokingMedalEntity.bronze:
        return 'Bronze';
      case SmokingMedalEntity.prata:
        return 'Prata';
      case SmokingMedalEntity.ouro:
        return 'Ouro';
      case SmokingMedalEntity.diamante:
        return 'Diamante';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/medals/smoking/';
    switch (this) {
      case SmokingMedalEntity.bronze:
        return '${prefix}bronze.png';
      case SmokingMedalEntity.prata:
        return '${prefix}prata.png';
      case SmokingMedalEntity.ouro:
        return '${prefix}ouro.png';
      case SmokingMedalEntity.diamante:
        return '${prefix}diamante.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case SmokingMedalEntity.bronze:
        return 'Conquiste 1 insígnia Disciplinum';
      case SmokingMedalEntity.prata:
        return 'Conquiste 2 insígnias Disciplinum';
      case SmokingMedalEntity.ouro:
        return 'Conquiste 3 insígnias Disciplinum';
      case SmokingMedalEntity.diamante:
        return 'Conquiste 4 insígnias Disciplinum';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case SmokingMedalEntity.bronze:
        return '🥉';
      case SmokingMedalEntity.prata:
        return '🥈';
      case SmokingMedalEntity.ouro:
        return '🥇';
      case SmokingMedalEntity.diamante:
        return '💎';
    }
  }

  /// Obtém a categoria da medalha
  String get category {
    switch (this) {
      case SmokingMedalEntity.bronze:
        return 'Básica';
      case SmokingMedalEntity.prata:
        return 'Intermediária';
      case SmokingMedalEntity.ouro:
        return 'Avançada';
      case SmokingMedalEntity.diamante:
        return 'Máxima';
    }
  }

  /// Verifica se a medalha é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta medalha
  String get themeColor {
    switch (this) {
      case SmokingMedalEntity.bronze:
        return '#CD7F32'; // Bronze
      case SmokingMedalEntity.prata:
        return '#C0C0C0'; // Prata
      case SmokingMedalEntity.ouro:
        return '#FFD700'; // Dourado
      case SmokingMedalEntity.diamante:
        return '#B9F2FF'; // Azul claro
    }
  }
}
