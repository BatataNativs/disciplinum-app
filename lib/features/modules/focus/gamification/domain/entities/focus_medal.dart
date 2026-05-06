/// Entidade de medalhas específicas do módulo Focus
/// Baseada em milestones específicos de insígnias
enum FocusMedalEntity {
  bronze,    // Ganha insígnia Latão
  prata,     // Ganha insígnia Ouro  
  ouro,      // Ganha insígnia Diamante
  diamante   // Ganha insígnia Disciplinum
}

extension FocusMedalEntityExtension on FocusMedalEntity {
  String get nameBr {
    switch (this) {
      case FocusMedalEntity.bronze:
        return 'Medalha de Bronze';
      case FocusMedalEntity.prata:
        return 'Medalha de Prata';
      case FocusMedalEntity.ouro:
        return 'Medalha de Ouro';
      case FocusMedalEntity.diamante:
        return 'Medalha de Diamante';
    }
  }

  String get asset {
    const prefix = 'assets/gamification/medals/focus/';
    switch (this) {
      case FocusMedalEntity.bronze:
        return '${prefix}bronze.png';
      case FocusMedalEntity.prata:
        return '${prefix}silver.png';
      case FocusMedalEntity.ouro:
        return '${prefix}gold.png';
      case FocusMedalEntity.diamante:
        return '${prefix}diamond.png';
    }
  }

  String get requirementDescription {
    switch (this) {
      case FocusMedalEntity.bronze:
        return 'Conquiste a insígnia Latão (3 períodos de foco respeitados)';
      case FocusMedalEntity.prata:
        return 'Conquiste a insígnia Ouro (6 períodos de foco respeitados)';
      case FocusMedalEntity.ouro:
        return 'Conquiste a insígnia Diamante (9 períodos de foco respeitados)';
      case FocusMedalEntity.diamante:
        return 'Conquiste a insígnia Disciplinum (10 períodos de foco respeitados)';
    }
  }

  /// Verifica se esta medalha pode ser concedida com base nas insígnias conquistadas
  bool canBeAwarded(List<String> earnedInsignias) {
    switch (this) {
      case FocusMedalEntity.bronze:
        return earnedInsignias.contains('latao');
      case FocusMedalEntity.prata:
        return earnedInsignias.contains('ouro');
      case FocusMedalEntity.ouro:
        return earnedInsignias.contains('diamante');
      case FocusMedalEntity.diamante:
        return earnedInsignias.contains('disciplinum');
    }
  }

  String get name => nameBr;
  String get description => requirementDescription;
  String get icon => asset;

  /// Obtém a insígnia necessária para esta medalha
  String get requiredInsignia {
    switch (this) {
      case FocusMedalEntity.bronze:
        return 'latao';
      case FocusMedalEntity.prata:
        return 'ouro';
      case FocusMedalEntity.ouro:
        return 'diamante';
      case FocusMedalEntity.diamante:
        return 'disciplinum';
    }
  }
}
