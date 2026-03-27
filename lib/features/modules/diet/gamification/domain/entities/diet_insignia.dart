/// Insignias do módulo Dieta
/// Progressão baseada em dias consecutivos de acompanhamento nutricional
enum DietInsignia {
  // Insignia inicial - concedida ao ativar o módulo
  madeira('Madeira', 'Início da Jornada', 'Começou a acompanhar sua alimentação', 0),
  
  // Insignias baseadas em dias consecutivos
  ferro('Ferro', 'Determinação Inicial', '1 dia seguido de plano', 1),
  aluminio('Alumínio', 'Consistência Semanal', '7 dias seguidos de plano', 7),
  latao('Latão', 'Compromisso Quinzenal', '15 dias seguidos de plano', 15),
  bronze('Bronze', 'Hábito Estabelecido', '30 dias seguidos de plano', 30),
  prata('Prata', 'Maestria Nutricional', '60 dias seguidos de plano', 60),
  ouro('Ouro', 'Disciplina Plena', '90 dias seguidos de plano', 90),
  diamante('Diamante', 'Lenda Nutricional', '180 dias seguidos de plano', 180),
  
  // Insignia especial por metas completas
  disciplinum('Disciplinum', 'Mestre Nutricional', '365 dias seguidos + todas as metas mensais', 365);

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
