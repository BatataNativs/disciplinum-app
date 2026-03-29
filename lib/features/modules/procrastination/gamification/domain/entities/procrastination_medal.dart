/// Entidade de medalhas específicas do módulo Procrastination
/// Baseada em quantidade de insígnias Disciplinum conquistadas
enum ProcrastinationMedalEntity {
  bronze,     // 1 insígnia Disciplinum
  prata,      // 2 insígnias Disciplinum
  ouro,       // 3 insígnias Disciplinum
  diamante;   // 4 insígnias Disciplinum
}

extension ProcrastinationMedalEntityExtension on ProcrastinationMedalEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case ProcrastinationMedalEntity.bronze:
        return 'bronze';
      case ProcrastinationMedalEntity.prata:
        return 'prata';
      case ProcrastinationMedalEntity.ouro:
        return 'ouro';
      case ProcrastinationMedalEntity.diamante:
        return 'diamante';
    }
  }

  /// Obtém o número de insígnias Disciplinum necessárias
  int get requiredDisciplinumInsignias {
    switch (this) {
      case ProcrastinationMedalEntity.bronze:
        return 1; // 1 insígnia Disciplinum
      case ProcrastinationMedalEntity.prata:
        return 2; // 2 insígnias Disciplinum
      case ProcrastinationMedalEntity.ouro:
        return 3; // 3 insígnias Disciplinum
      case ProcrastinationMedalEntity.diamante:
        return 4; // 4 insígnias Disciplinum
    }
  }

  /// Obtém o progresso percentual até esta medalha
  double get progressPercentage {
    switch (this) {
      case ProcrastinationMedalEntity.bronze:
        return 25.0;
      case ProcrastinationMedalEntity.prata:
        return 50.0;
      case ProcrastinationMedalEntity.ouro:
        return 75.0;
      case ProcrastinationMedalEntity.diamante:
        return 100.0;
    }
  }

  /// Obtém a descrição do benefício
  String get benefitDescription {
    switch (this) {
      case ProcrastinationMedalEntity.bronze:
        return 'Primeira conquista Disciplinum alcançada!';
      case ProcrastinationMedalEntity.prata:
        return 'Segunda conquista Disciplinum alcançada!';
      case ProcrastinationMedalEntity.ouro:
        return 'Terceira conquista Disciplinum alcançada!';
      case ProcrastinationMedalEntity.diamante:
        return 'Quarta conquista Disciplinum alcançada!';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case ProcrastinationMedalEntity.bronze:
        return 'Bronze';
      case ProcrastinationMedalEntity.prata:
        return 'Prata';
      case ProcrastinationMedalEntity.ouro:
        return 'Ouro';
      case ProcrastinationMedalEntity.diamante:
        return 'Diamante';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/medals/procrastination/';
    switch (this) {
      case ProcrastinationMedalEntity.bronze:
        return '${prefix}bronze.png';
      case ProcrastinationMedalEntity.prata:
        return '${prefix}prata.png';
      case ProcrastinationMedalEntity.ouro:
        return '${prefix}ouro.png';
      case ProcrastinationMedalEntity.diamante:
        return '${prefix}diamante.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case ProcrastinationMedalEntity.bronze:
        return 'Conquiste 1 insígnia Disciplinum';
      case ProcrastinationMedalEntity.prata:
        return 'Conquiste 2 insígnias Disciplinum';
      case ProcrastinationMedalEntity.ouro:
        return 'Conquiste 3 insígnias Disciplinum';
      case ProcrastinationMedalEntity.diamante:
        return 'Conquiste 4 insígnias Disciplinum';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case ProcrastinationMedalEntity.bronze:
        return '🥉';
      case ProcrastinationMedalEntity.prata:
        return '🥈';
      case ProcrastinationMedalEntity.ouro:
        return '🥇';
      case ProcrastinationMedalEntity.diamante:
        return '💎';
    }
  }

  /// Obtém a categoria da medalha
  String get category {
    switch (this) {
      case ProcrastinationMedalEntity.bronze:
        return 'Básica';
      case ProcrastinationMedalEntity.prata:
        return 'Intermediária';
      case ProcrastinationMedalEntity.ouro:
        return 'Avançada';
      case ProcrastinationMedalEntity.diamante:
        return 'Máxima';
    }
  }

  /// Verifica se a medalha é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta medalha
  String get themeColor {
    switch (this) {
      case ProcrastinationMedalEntity.bronze:
        return '#CD7F32'; // Bronze
      case ProcrastinationMedalEntity.prata:
        return '#C0C0C0'; // Prata
      case ProcrastinationMedalEntity.ouro:
        return '#FFD700'; // Dourado
      case ProcrastinationMedalEntity.diamante:
        return '#B9F2FF'; // Azul claro
    }
  }
}
