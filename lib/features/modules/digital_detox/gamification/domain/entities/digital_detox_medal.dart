enum DigitalDetoxMedal {
  bronze(
    name: 'bronze',
    nameBr: 'Bronze',
    asset: 'assets/gamification/medals/digitalDetox/bronze.png',
    requirementDescription: 'Complete 30 dias no ciclo',
  ),
  silver(
    name: 'silver',
    nameBr: 'Prata',
    asset: 'assets/gamification/medals/digitalDetox/silver.png',
    requirementDescription: 'Complete 60 dias no ciclo',
  ),
  gold(
    name: 'gold',
    nameBr: 'Ouro',
    asset: 'assets/gamification/medals/digitalDetox/gold.png',
    requirementDescription: 'Complete 90 dias no ciclo',
  ),
  diamond(
    name: 'diamond',
    nameBr: 'Diamante',
    asset: 'assets/gamification/medals/digitalDetox/diamond.png',
    requirementDescription: 'Complete 120 dias no ciclo',
  );

  final String name;
  final String nameBr;
  final String asset;
  final String requirementDescription;

  const DigitalDetoxMedal({
    required this.name,
    required this.nameBr,
    required this.asset,
    required this.requirementDescription,
  });

  bool canBeAwarded(List<String> earnedInsignias) {
    // Medalha Bronze: precisa de 1 insígnia Disciplinum
    if (this == bronze) {
      return earnedInsignias.any((insignia) => insignia.contains('Disciplinum'));
    }
    // Medalha Silver: precisa de 2 insígnias Disciplinum
    if (this == silver) {
      return earnedInsignias.where((insignia) => insignia.contains('Disciplinum')).length >= 2;
    }
    // Medalha Gold: precisa de 3 insígnias Disciplinum
    if (this == gold) {
      return earnedInsignias.where((insignia) => insignia.contains('Disciplinum')).length >= 3;
    }
    // Medalha Diamond: precisa de 4 insígnias Disciplinum
    if (this == diamond) {
      return earnedInsignias.where((insignia) => insignia.contains('Disciplinum')).length >= 4;
    }
    return false;
  }
}
