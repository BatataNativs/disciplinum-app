/// Entidade de medalhas específicas do módulo Focus
/// Baseada em milestones específicos de insígnias
enum FocusMedalha {
  bronze,    // Ganha insígnia Latão
  prata,     // Ganha insígnia Ouro  
  ouro,      // Ganha insígnia Diamante
  diamante   // Ganha insígnia Disciplinum
}

extension FocusMedalhaExtension on FocusMedalha {
  String get nameBr {
    switch (this) {
      case FocusMedalha.bronze:
        return 'Medalha de Bronze';
      case FocusMedalha.prata:
        return 'Medalha de Prata';
      case FocusMedalha.ouro:
        return 'Medalha de Ouro';
      case FocusMedalha.diamante:
        return 'Medalha de Diamante';
    }
  }

  String get asset {
    const prefix = 'assets/gamification/medals/focus/';
    switch (this) {
      case FocusMedalha.bronze:
        return '${prefix}bronze.png';
      case FocusMedalha.prata:
        return '${prefix}silver.png';
      case FocusMedalha.ouro:
        return '${prefix}gold.png';
      case FocusMedalha.diamante:
        return '${prefix}diamond.png';
    }
  }

  String get requirementDescription {
    switch (this) {
      case FocusMedalha.bronze:
        return 'Conquiste a insígnia Latão (3 períodos de foco respeitados)';
      case FocusMedalha.prata:
        return 'Conquiste a insígnia Ouro (6 períodos de foco respeitados)';
      case FocusMedalha.ouro:
        return 'Conquiste a insígnia Diamante (9 períodos de foco respeitados)';
      case FocusMedalha.diamante:
        return 'Conquiste a insígnia Disciplinum (10 períodos de foco respeitados)';
    }
  }

  /// Verifica se esta medalha pode ser concedida com base nas insígnias conquistadas
  bool canBeAwarded(List<String> earnedInsignias) {
    switch (this) {
      case FocusMedalha.bronze:
        return earnedInsignias.contains('latao');
      case FocusMedalha.prata:
        return earnedInsignias.contains('ouro');
      case FocusMedalha.ouro:
        return earnedInsignias.contains('diamante');
      case FocusMedalha.diamante:
        return earnedInsignias.contains('disciplinum');
    }
  }

  String get name => nameBr;
  String get description => requirementDescription;
  String get icon => asset;

  /// Obtém a insígnia necessária para esta medalha
  String get requiredInsignia {
    switch (this) {
      case FocusMedalha.bronze:
        return 'latao';
      case FocusMedalha.prata:
        return 'ouro';
      case FocusMedalha.ouro:
        return 'diamante';
      case FocusMedalha.diamante:
        return 'disciplinum';
    }
  }
}
