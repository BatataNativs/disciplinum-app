/// Medalhas do módulo Dieta
/// Baseadas em insignias Disciplinum conquistadas
enum DietMedalha {
  bronze('Bronze', 'Nutricionista Iniciante', '1 insignia Disciplinum conquistada', 'assets/gamification/medalhas/diet/bronze.png', 1),
  prata('Prata', 'Nutricionista Intermediário', '3 insignias Disciplinum conquistadas', 'assets/gamification/medalhas/diet/prata.png', 3),
  ouro('Ouro', 'Nutricionista Avançado', '6 insignias Disciplinum conquistadas', 'assets/gamification/medalhas/diet/ouro.png', 6),
  diamante('Diamante', 'Mestre Nutricionista', '10 insignias Disciplinum conquistadas', 'assets/gamification/medalhas/diet/diamante.png', 10);

  const DietMedalha(this.name, this.nameBr, this.description, this.asset, this.requiredDisciplinumBadges);

  final String name;
  final String nameBr;
  final String description;
  final String asset;
  final int requiredDisciplinumBadges;

  /// Verifica se esta medalha pode ser concedida
  bool canBeAwarded(int disciplinumCount) {
    return disciplinumCount >= requiredDisciplinumBadges;
  }
}
