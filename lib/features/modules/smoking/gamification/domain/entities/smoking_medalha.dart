/// Entidade de medalhas específicas do módulo Smoking
/// Baseada exatamente nas especificações do usuário
enum SmokingMedalhaEntity {
  bronze,
  prata,
  ouro,
  diamante
}

extension SmokingMedalhaEntityExtension on SmokingMedalhaEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case SmokingMedalhaEntity.bronze:
        return 'bronze';
      case SmokingMedalhaEntity.prata:
        return 'prata';
      case SmokingMedalhaEntity.ouro:
        return 'ouro';
      case SmokingMedalhaEntity.diamante:
        return 'diamante';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case SmokingMedalhaEntity.bronze:
        return 'Medalha de Bronze';
      case SmokingMedalhaEntity.prata:
        return 'Medalha de Prata';
      case SmokingMedalhaEntity.ouro:
        return 'Medalha de Ouro';
      case SmokingMedalhaEntity.diamante:
        return 'Medalha de Diamante';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/medals/smoking/';
    switch (this) {
      case SmokingMedalhaEntity.bronze:
        return '${prefix}bronze.png';
      case SmokingMedalhaEntity.prata:
        return '${prefix}silver.png';
      case SmokingMedalhaEntity.ouro:
        return '${prefix}gold.png';
      case SmokingMedalhaEntity.diamante:
        return '${prefix}diamond.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case SmokingMedalhaEntity.bronze:
        return '1 insígnia Disciplinum';
      case SmokingMedalhaEntity.prata:
        return '2 insígnias Disciplinum';
      case SmokingMedalhaEntity.ouro:
        return '3 insígnias Disciplinum';
      case SmokingMedalhaEntity.diamante:
        return '4 insígnias Disciplinum';
    }
  }

  /// Obtém a descrição completa
  String get description {
    switch (this) {
      case SmokingMedalhaEntity.bronze:
        return 'Primeira medalha de conquista! Você alcançou 1 insígnia Disciplinum.';
      case SmokingMedalhaEntity.prata:
        return 'Progresso excelente! Você alcançou 2 insígnias Disciplinum.';
      case SmokingMedalhaEntity.ouro:
        return 'Conquista impressionante! Você alcançou 3 insígnias Disciplinum.';
      case SmokingMedalhaEntity.diamante:
        return 'Máxima conquista! Você alcançou 4 insígnias Disciplinum.';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case SmokingMedalhaEntity.bronze:
        return '🥉';
      case SmokingMedalhaEntity.prata:
        return '🥈';
      case SmokingMedalhaEntity.ouro:
        return '🥇';
      case SmokingMedalhaEntity.diamante:
        return '💎';
    }
  }

  /// Obtém a categoria da medalha
  String get category {
    return 'Conquista';
  }

  /// Obtém a cor do tema para esta medalha
  String get themeColor {
    switch (this) {
      case SmokingMedalhaEntity.bronze:
        return '#CD7F32'; // Bronze
      case SmokingMedalhaEntity.prata:
        return '#C0C0C0'; // Prata
      case SmokingMedalhaEntity.ouro:
        return '#FFD700'; // Ouro
      case SmokingMedalhaEntity.diamante:
        return '#B9F2FF'; // Azul claro
    }
  }

  /// Obtém o nível de raridade
  String get rarity {
    switch (this) {
      case SmokingMedalhaEntity.bronze:
        return 'Incomum';
      case SmokingMedalhaEntity.prata:
        return 'Raro';
      case SmokingMedalhaEntity.ouro:
        return 'Épico';
      case SmokingMedalhaEntity.diamante:
        return 'Lendário';
    }
  }

  /// Verifica se a medalha é de categoria máxima
  bool get isMaximumCategory => this == SmokingMedalhaEntity.diamante;

  /// Verifica se a medalha é lendária
  bool get isLegendary => rarity == 'Lendário';

  /// Obtém as insígnias necessárias para esta medalha
  List<String> get requiredInsignias {
    switch (this) {
      case SmokingMedalhaEntity.bronze:
        return ['disciplinum'];
      case SmokingMedalhaEntity.prata:
        return ['disciplinum', 'disciplinum'];
      case SmokingMedalhaEntity.ouro:
        return ['disciplinum', 'disciplinum', 'disciplinum'];
      case SmokingMedalhaEntity.diamante:
        return ['disciplinum', 'disciplinum', 'disciplinum', 'disciplinum'];
    }
  }

  /// Verifica se esta medalha pode ser concedida com base nas insígnias conquistadas
  bool canBeAwarded(List<String> earnedInsignias) {
    final disciplinumCount = earnedInsignias.where((i) => i == 'disciplinum').length;
    
    switch (this) {
      case SmokingMedalhaEntity.bronze:
        return disciplinumCount >= 1;
      case SmokingMedalhaEntity.prata:
        return disciplinumCount >= 2;
      case SmokingMedalhaEntity.ouro:
        return disciplinumCount >= 3;
      case SmokingMedalhaEntity.diamante:
        return disciplinumCount >= 4;
    }
  }
}
