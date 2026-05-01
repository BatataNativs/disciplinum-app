/// Insignias do módulo Dieta
/// Progressão baseada em dias consecutivos de check-ins positivos (refeições nos horários)
enum DietInsignia {
  // Insignia inicial - concedida ao ativar o módulo
  madeira('Madeira', 'Início da Jornada', 'Ativou o módulo Dieta', 0),
  
  // Insignias baseadas em dias consecutivos de check-ins positivos
  ferro('Ferro', 'Primeiro Dia', '1 dia com check-in positivo', 1),
  aluminio('Alumínio', 'Dois Dias', '2 dias com check-in positivo', 2),
  latao('Latão', 'Quatro Dias', '4 dias com check-in positivo', 4),
  bronze('Bronze', 'Oito Dias', '8 dias com check-in positivo', 8),
  prata('Prata', 'Doze Dias', '12 dias com check-in positivo', 12),
  ouro('Ouro', 'Dezoito Dias', '18 dias com check-in positivo', 18),
  diamante('Diamante', 'Vinte e Seis Dias', '26 dias com check-in positivo', 26),
  
  // Insignia especial
  disciplinum('Disciplinum', 'Trinta Dias', '30 dias com check-in positivo', 30);

  const DietInsignia(this.name, this.nameBr, this.description, this.requiredDays);

  final String name;
  final String nameBr;
  final String description;
  final int requiredDays;

  /// Verifica se esta insignia pode ser concedida com base nas já conquistadas
  bool canBeAwarded(List<String> earnedInsignias) {
    // Insignias devem ser concedidas em ordem
    for (final insignia in DietInsignia.values) {
      if (insignia == this) break;

      if (!earnedInsignias.contains(insignia.name)) {
        return false;
      }
    }
    return true;
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/insignias/diet/';
    switch (this) {
      case DietInsignia.madeira:
        return '${prefix}madeira.png';
      case DietInsignia.ferro:
        return '${prefix}ferro.png';
      case DietInsignia.aluminio:
        return '${prefix}aluminio.png';
      case DietInsignia.latao:
        return '${prefix}latao.png';
      case DietInsignia.bronze:
        return '${prefix}bronze.png';
      case DietInsignia.prata:
        return '${prefix}prata.png';
      case DietInsignia.ouro:
        return '${prefix}ouro.png';
      case DietInsignia.diamante:
        return '${prefix}diamante.png';
      case DietInsignia.disciplinum:
        return '${prefix}disciplinum.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case DietInsignia.madeira:
        return 'Ative o módulo Dieta';
      case DietInsignia.ferro:
        return '1 dia com check-in positivo';
      case DietInsignia.aluminio:
        return '2 dias com check-in positivo';
      case DietInsignia.latao:
        return '4 dias com check-in positivo';
      case DietInsignia.bronze:
        return '8 dias com check-in positivo';
      case DietInsignia.prata:
        return '12 dias com check-in positivo';
      case DietInsignia.ouro:
        return '18 dias com check-in positivo';
      case DietInsignia.diamante:
        return '26 dias com check-in positivo';
      case DietInsignia.disciplinum:
        return '30 dias com check-in positivo';
    }
  }
}
