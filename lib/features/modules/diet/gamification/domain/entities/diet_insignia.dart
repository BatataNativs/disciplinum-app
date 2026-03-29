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
}
