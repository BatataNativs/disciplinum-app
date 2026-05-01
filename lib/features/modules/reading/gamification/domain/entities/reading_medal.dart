/// Entidade de medalhas específicas do módulo Reading
/// Baseada em quantidade de insígnias Disciplinum conquistadas
enum ReadingMedalEntity {
  bronze,     // 1 insígnia Disciplinum
  prata,      // 2 insígnias Disciplinum
  ouro,       // 3 insígnias Disciplinum
  diamante;   // 4 insígnias Disciplinum
}

extension ReadingMedalEntityExtension on ReadingMedalEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case ReadingMedalEntity.bronze:
        return 'bronze';
      case ReadingMedalEntity.prata:
        return 'prata';
      case ReadingMedalEntity.ouro:
        return 'ouro';
      case ReadingMedalEntity.diamante:
        return 'diamante';
    }
  }

  /// Obtém o número de insígnias Disciplinum necessárias
  int get requiredDisciplinumInsignias {
    switch (this) {
      case ReadingMedalEntity.bronze:
        return 1; // 1 insígnia Disciplinum
      case ReadingMedalEntity.prata:
        return 2; // 2 insígnias Disciplinum
      case ReadingMedalEntity.ouro:
        return 3; // 3 insígnias Disciplinum
      case ReadingMedalEntity.diamante:
        return 4; // 4 insígnias Disciplinum
    }
  }

  /// Obtém o progresso percentual até esta medalha
  double get progressPercentage {
    switch (this) {
      case ReadingMedalEntity.bronze:
        return 25.0;
      case ReadingMedalEntity.prata:
        return 50.0;
      case ReadingMedalEntity.ouro:
        return 75.0;
      case ReadingMedalEntity.diamante:
        return 100.0;
    }
  }

  /// Obtém a descrição do benefício
  String get benefitDescription {
    switch (this) {
      case ReadingMedalEntity.bronze:
        return 'Primeira conquista Disciplinum alcançada!';
      case ReadingMedalEntity.prata:
        return 'Segunda conquista Disciplinum alcançada!';
      case ReadingMedalEntity.ouro:
        return 'Terceira conquista Disciplinum alcançada!';
      case ReadingMedalEntity.diamante:
        return 'Quarta conquista Disciplinum alcançada!';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case ReadingMedalEntity.bronze:
        return 'Medalha de Bronze';
      case ReadingMedalEntity.prata:
        return 'Medalha de Prata';
      case ReadingMedalEntity.ouro:
        return 'Medalha de Ouro';
      case ReadingMedalEntity.diamante:
        return 'Medalha de Diamante';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/medals/reading/';
    switch (this) {
      case ReadingMedalEntity.bronze:
        return '${prefix}bronze.png';
      case ReadingMedalEntity.prata:
        return '${prefix}prata.png';
      case ReadingMedalEntity.ouro:
        return '${prefix}ouro.png';
      case ReadingMedalEntity.diamante:
        return '${prefix}diamante.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case ReadingMedalEntity.bronze:
        return 'Conquiste 1 insígnia Disciplinum';
      case ReadingMedalEntity.prata:
        return 'Conquiste 2 insígnias Disciplinum';
      case ReadingMedalEntity.ouro:
        return 'Conquiste 3 insígnias Disciplinum';
      case ReadingMedalEntity.diamante:
        return 'Conquiste 4 insígnias Disciplinum';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case ReadingMedalEntity.bronze:
        return '🥉';
      case ReadingMedalEntity.prata:
        return '🥈';
      case ReadingMedalEntity.ouro:
        return '🥇';
      case ReadingMedalEntity.diamante:
        return '💎';
    }
  }

  /// Obtém a categoria da medalha
  String get category {
    switch (this) {
      case ReadingMedalEntity.bronze:
        return 'Básica';
      case ReadingMedalEntity.prata:
        return 'Intermediária';
      case ReadingMedalEntity.ouro:
        return 'Avançada';
      case ReadingMedalEntity.diamante:
        return 'Máxima';
    }
  }

  /// Verifica se a medalha é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta medalha
  String get themeColor {
    switch (this) {
      case ReadingMedalEntity.bronze:
        return '#CD7F32'; // Bronze
      case ReadingMedalEntity.prata:
        return '#C0C0C0'; // Prata
      case ReadingMedalEntity.ouro:
        return '#FFD700'; // Dourado
      case ReadingMedalEntity.diamante:
        return '#B9F2FF'; // Azul claro
    }
  }

  /// Verifica se esta medalha pode ser concedida com base nas insígnias conquistadas
  bool canBeAwarded(List<String> earnedInsignias) {
    final disciplinumCount = earnedInsignias.where((i) => i == 'disciplinum').length;

    switch (this) {
      case ReadingMedalEntity.bronze:
        return disciplinumCount >= 1;
      case ReadingMedalEntity.prata:
        return disciplinumCount >= 2;
      case ReadingMedalEntity.ouro:
        return disciplinumCount >= 3;
      case ReadingMedalEntity.diamante:
        return disciplinumCount >= 4;
    }
  }
}
