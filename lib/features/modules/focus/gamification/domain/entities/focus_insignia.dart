/// Insígnias do módulo Focus - 100% independente
enum FocusInsignia {
  madeira,
  ferro,
  aluminio,
  latao,
  bronze,
  prata,
  ouro,
  diamante,
  disciplinum;

  /// Progresso para esta insígnia (0.0 a 1.0)
  double get progressPercentage {
    switch (this) {
      case FocusInsignia.madeira:
        return 0.15;
      case FocusInsignia.ferro:
        return 0.30;
      case FocusInsignia.aluminio:
        return 0.45;
      case FocusInsignia.latao:
        return 0.60;
      case FocusInsignia.bronze:
        return 0.75;
      case FocusInsignia.prata:
        return 0.85;
      case FocusInsignia.ouro:
        return 0.95;
      case FocusInsignia.diamante:
        return 1.0;
      case FocusInsignia.disciplinum:
        return 1.0;
    }
  }
}

extension FocusInsigniaExtension on FocusInsignia {
  String get nameBr {
    switch (this) {
      case FocusInsignia.madeira:
        return 'Focado Madeira';
      case FocusInsignia.ferro:
        return 'Focado Ferro';
      case FocusInsignia.aluminio:
        return 'Focado Alumínio';
      case FocusInsignia.latao:
        return 'Focado Latão';
      case FocusInsignia.bronze:
        return 'Focado Bronze';
      case FocusInsignia.prata:
        return 'Focado Prata';
      case FocusInsignia.ouro:
        return 'Focado Ouro';
      case FocusInsignia.diamante:
        return 'Focado Diamante';
      case FocusInsignia.disciplinum:
        return 'Focado Disciplinum';
    }
  }

  String get asset {
    const prefix = 'assets/gamification/insignias/focus/';
    switch (this) {
      case FocusInsignia.madeira:
        return '${prefix}madeira.png';
      case FocusInsignia.ferro:
        return '${prefix}ferro.png';
      case FocusInsignia.aluminio:
        return '${prefix}aluminio.png';
      case FocusInsignia.latao:
        return '${prefix}latao.png';
      case FocusInsignia.bronze:
        return '${prefix}bronze.png';
      case FocusInsignia.prata:
        return '${prefix}prata.png';
      case FocusInsignia.ouro:
        return '${prefix}ouro.png';
      case FocusInsignia.diamante:
        return '${prefix}diamante.png';
      case FocusInsignia.disciplinum:
        return '${prefix}disciplinum.png';
    }
  }

  int get requiredPeriods {
    switch (this) {
      case FocusInsignia.madeira:
        return 0; // Ganha ao configurar e ativar o módulo
      case FocusInsignia.ferro:
        return 1;
      case FocusInsignia.aluminio:
        return 2;
      case FocusInsignia.latao:
        return 3;
      case FocusInsignia.bronze:
        return 4;
      case FocusInsignia.prata:
        return 5;
      case FocusInsignia.ouro:
        return 6;
      case FocusInsignia.diamante:
        return 9;
      case FocusInsignia.disciplinum:
        return 10;
    }
  }

  String get requirementDescription {
    switch (this) {
      case FocusInsignia.madeira:
        return 'Ative o módulo de Foco';
      case FocusInsignia.ferro:
        return '1 período de foco respeitado';
      case FocusInsignia.aluminio:
        return '2 períodos de foco respeitados';
      case FocusInsignia.latao:
        return '3 períodos de foco respeitados';
      case FocusInsignia.bronze:
        return '4 períodos de foco respeitados';
      case FocusInsignia.prata:
        return '5 períodos de foco respeitados';
      case FocusInsignia.ouro:
        return '6 períodos de foco respeitados';
      case FocusInsignia.diamante:
        return '9 períodos de foco respeitados';
      case FocusInsignia.disciplinum:
        return '10 períodos de foco respeitados';
    }
  }

  String get name => nameBr;
  String get description => requirementDescription;
  String get icon => asset;

  /// Calcula o progresso percentual (0.0 a 1.0) para esta insígnia
  /// baseada nos períodos respeitados
  double calculateProgress(int respected) {
    if (respected <= 0 && this == FocusInsignia.madeira) return 1.0;
    if (requiredPeriods == 0) return 1.0;
    return (respected / requiredPeriods).clamp(0.0, 1.0);
  }
}
