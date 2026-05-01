/// Entidade de medalhas específicas do módulo Adult Content
/// Baseada em quantidade de insígnias Disciplinum conquistadas
enum AdultContentMedalEntity {
  bronze,     // 1 insígnia Disciplinum
  prata,      // 2 insígnias Disciplinum
  ouro,       // 3 insígnias Disciplinum
  diamante;   // 4 insígnias Disciplinum
}

extension AdultContentMedalEntityExtension on AdultContentMedalEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case AdultContentMedalEntity.bronze:
        return 'bronze';
      case AdultContentMedalEntity.prata:
        return 'prata';
      case AdultContentMedalEntity.ouro:
        return 'ouro';
      case AdultContentMedalEntity.diamante:
        return 'diamante';
    }
  }

  /// Obtém o número de insígnias Disciplinum necessárias
  int get requiredDisciplinumInsignias {
    switch (this) {
      case AdultContentMedalEntity.bronze:
        return 1; // 1 insígnia Disciplinum
      case AdultContentMedalEntity.prata:
        return 2; // 2 insígnias Disciplinum
      case AdultContentMedalEntity.ouro:
        return 3; // 3 insígnias Disciplinum
      case AdultContentMedalEntity.diamante:
        return 4; // 4 insígnias Disciplinum
    }
  }

  /// Obtém o progresso percentual até esta medalha
  double get progressPercentage {
    switch (this) {
      case AdultContentMedalEntity.bronze:
        return 25.0;
      case AdultContentMedalEntity.prata:
        return 50.0;
      case AdultContentMedalEntity.ouro:
        return 75.0;
      case AdultContentMedalEntity.diamante:
        return 100.0;
    }
  }

  /// Obtém a descrição do benefício
  String get benefitDescription {
    switch (this) {
      case AdultContentMedalEntity.bronze:
        return 'Primeira conquista Disciplinum alcançada!';
      case AdultContentMedalEntity.prata:
        return 'Segunda conquista Disciplinum alcançada!';
      case AdultContentMedalEntity.ouro:
        return 'Terceira conquista Disciplinum alcançada!';
      case AdultContentMedalEntity.diamante:
        return 'Quarta conquista Disciplinum alcançada!';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case AdultContentMedalEntity.bronze:
        return 'Medalha de Bronze';
      case AdultContentMedalEntity.prata:
        return 'Medalha de Prata';
      case AdultContentMedalEntity.ouro:
        return 'Medalha de Ouro';
      case AdultContentMedalEntity.diamante:
        return 'Medalha de Diamante';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/medals/adult_content/';
    switch (this) {
      case AdultContentMedalEntity.bronze:
        return '${prefix}bronze.png';
      case AdultContentMedalEntity.prata:
        return '${prefix}prata.png';
      case AdultContentMedalEntity.ouro:
        return '${prefix}ouro.png';
      case AdultContentMedalEntity.diamante:
        return '${prefix}diamante.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case AdultContentMedalEntity.bronze:
        return 'Conquiste 1 insígnia Disciplinum';
      case AdultContentMedalEntity.prata:
        return 'Conquiste 2 insígnias Disciplinum';
      case AdultContentMedalEntity.ouro:
        return 'Conquiste 3 insígnias Disciplinum';
      case AdultContentMedalEntity.diamante:
        return 'Conquiste 4 insígnias Disciplinum';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case AdultContentMedalEntity.bronze:
        return '🥉';
      case AdultContentMedalEntity.prata:
        return '🥈';
      case AdultContentMedalEntity.ouro:
        return '🥇';
      case AdultContentMedalEntity.diamante:
        return '💎';
    }
  }

  /// Obtém a categoria da medalha
  String get category {
    switch (this) {
      case AdultContentMedalEntity.bronze:
        return 'Básica';
      case AdultContentMedalEntity.prata:
        return 'Intermediária';
      case AdultContentMedalEntity.ouro:
        return 'Avançada';
      case AdultContentMedalEntity.diamante:
        return 'Máxima';
    }
  }

  /// Verifica se a medalha é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta medalha
  String get themeColor {
    switch (this) {
      case AdultContentMedalEntity.bronze:
        return '#CD7F32'; // Bronze
      case AdultContentMedalEntity.prata:
        return '#C0C0C0'; // Prata
      case AdultContentMedalEntity.ouro:
        return '#FFD700'; // Dourado
      case AdultContentMedalEntity.diamante:
        return '#B9F2FF'; // Azul claro
    }
  }

  /// Verifica se esta medalha pode ser concedida com base nas insígnias conquistadas
  bool canBeAwarded(List<String> earnedInsignias) {
    final disciplinumCount = earnedInsignias.where((i) => i == 'disciplinum').length;

    switch (this) {
      case AdultContentMedalEntity.bronze:
        return disciplinumCount >= 1;
      case AdultContentMedalEntity.prata:
        return disciplinumCount >= 2;
      case AdultContentMedalEntity.ouro:
        return disciplinumCount >= 3;
      case AdultContentMedalEntity.diamante:
        return disciplinumCount >= 4;
    }
  }
}
