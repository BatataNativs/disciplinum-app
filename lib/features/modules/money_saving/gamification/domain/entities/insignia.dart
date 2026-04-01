/// Entidade de insignias do módulo Money Saving
/// Duplicada da gamificação central para independência total do módulo
enum MoneySavingInsignia {
  madeira,
  ferro,
  aluminio,
  latao,
  bronze,
  prata,
  ouro,
  diamante,
  disciplinum
}

extension MoneySavingInsigniaExtension on MoneySavingInsignia {
  String get nameBr {
    switch (this) {
      case MoneySavingInsignia.madeira:
        return 'Economizador Madeira';
      case MoneySavingInsignia.ferro:
        return 'Economizador Ferro';
      case MoneySavingInsignia.aluminio:
        return 'Economizador Alumínio';
      case MoneySavingInsignia.latao:
        return 'Economizador Latão';
      case MoneySavingInsignia.bronze:
        return 'Economizador Bronze';
      case MoneySavingInsignia.prata:
        return 'Economizador Prata';
      case MoneySavingInsignia.ouro:
        return 'Economizador Ouro';
      case MoneySavingInsignia.diamante:
        return 'Economizador Diamante';
      case MoneySavingInsignia.disciplinum:
        return 'Economizador Disciplinum';
    }
  }

  String get asset {
    const prefix = 'assets/gamification/insignias/money_saving/';
    switch (this) {
      case MoneySavingInsignia.madeira:
        return '${prefix}madeira.png';
      case MoneySavingInsignia.ferro:
        return '${prefix}ferro.png';
      case MoneySavingInsignia.aluminio:
        return '${prefix}aluminio.png';
      case MoneySavingInsignia.latao:
        return '${prefix}latao.png';
      case MoneySavingInsignia.bronze:
        return '${prefix}bronze.png';
      case MoneySavingInsignia.prata:
        return '${prefix}prata.png';
      case MoneySavingInsignia.ouro:
        return '${prefix}ouro.png';
      case MoneySavingInsignia.diamante:
        return '${prefix}diamante.png';
      case MoneySavingInsignia.disciplinum:
        return '${prefix}disciplinum.png';
    }
  }

  int get requiredDays {
    switch (this) {
      case MoneySavingInsignia.madeira:
        return 0; // Ganha ao configurar e ativar o módulo
      case MoneySavingInsignia.ferro:
        return 1;
      case MoneySavingInsignia.aluminio:
        return 2;
      case MoneySavingInsignia.latao:
        return 3;
      case MoneySavingInsignia.bronze:
        return 4;
      case MoneySavingInsignia.prata:
        return 5;
      case MoneySavingInsignia.ouro:
        return 6;
      case MoneySavingInsignia.diamante:
        return 9;
      case MoneySavingInsignia.disciplinum:
        return 10;
    }
  }

  String get requirementDescription {
    switch (this) {
      case MoneySavingInsignia.madeira:
        return 'Ative o módulo de Economia';
      case MoneySavingInsignia.ferro:
        return '1 dia economizando';
      case MoneySavingInsignia.aluminio:
        return '2 dias seguidos economizando';
      case MoneySavingInsignia.latao:
        return '3 dias seguidos economizando';
      case MoneySavingInsignia.bronze:
        return '4 dias seguidos economizando';
      case MoneySavingInsignia.prata:
        return '5 dias seguidos economizando';
      case MoneySavingInsignia.ouro:
        return '6 dias seguidos economizando';
      case MoneySavingInsignia.diamante:
        return '9 dias seguidos economizando';
      case MoneySavingInsignia.disciplinum:
        return '10 dias seguidos economizando';
    }
  }

  String get name => nameBr;
  String get description => requirementDescription;
  String get icon => asset;

  /// Calcula o progresso percentual (0.0 a 1.0) para esta insígnia
  /// baseado nos dias economizando
  double calculateProgress(int days) {
    if (days <= 0 && this == MoneySavingInsignia.madeira) return 1.0;
    if (requiredDays == 0) return 1.0;
    return (days / requiredDays).clamp(0.0, 1.0);
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case MoneySavingInsignia.madeira:
        return '🪵';
      case MoneySavingInsignia.ferro:
        return '⚙️';
      case MoneySavingInsignia.aluminio:
        return '🔘';
      case MoneySavingInsignia.latao:
        return '🔩';
      case MoneySavingInsignia.bronze:
        return '🥉';
      case MoneySavingInsignia.prata:
        return '🥈';
      case MoneySavingInsignia.ouro:
        return '🥇';
      case MoneySavingInsignia.diamante:
        return '💎';
      case MoneySavingInsignia.disciplinum:
        return '🏆';
    }
  }

  /// Verifica se é a insignia mais alta
  bool get isHighest => this == MoneySavingInsignia.disciplinum;

  /// Obtém a próxima insignia
  MoneySavingInsignia? get next {
    switch (this) {
      case MoneySavingInsignia.madeira:
        return MoneySavingInsignia.ferro;
      case MoneySavingInsignia.ferro:
        return MoneySavingInsignia.aluminio;
      case MoneySavingInsignia.aluminio:
        return MoneySavingInsignia.latao;
      case MoneySavingInsignia.latao:
        return MoneySavingInsignia.bronze;
      case MoneySavingInsignia.bronze:
        return MoneySavingInsignia.prata;
      case MoneySavingInsignia.prata:
        return MoneySavingInsignia.ouro;
      case MoneySavingInsignia.ouro:
        return MoneySavingInsignia.diamante;
      case MoneySavingInsignia.diamante:
        return MoneySavingInsignia.disciplinum;
      case MoneySavingInsignia.disciplinum:
        return null; // Já é a mais alta
    }
  }

  /// Converte de string para enum
  static MoneySavingInsignia? fromString(String? value) {
    switch (value) {
      case 'madeira':
        return MoneySavingInsignia.madeira;
      case 'ferro':
        return MoneySavingInsignia.ferro;
      case 'aluminio':
        return MoneySavingInsignia.aluminio;
      case 'latao':
        return MoneySavingInsignia.latao;
      case 'bronze':
        return MoneySavingInsignia.bronze;
      case 'prata':
        return MoneySavingInsignia.prata;
      case 'ouro':
        return MoneySavingInsignia.ouro;
      case 'diamante':
        return MoneySavingInsignia.diamante;
      case 'disciplinum':
        return MoneySavingInsignia.disciplinum;
      default:
        return null;
    }
  }
}
