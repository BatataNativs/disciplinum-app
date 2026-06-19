enum DigitalDetoxInsignia {
  madeira(
    name: 'madeira',
    nameBr: 'Madeira',
    asset: 'assets/gamification/insignias/digitalDetox/madeira.png',
    requirementDescription: 'Ative o módulo',
  ),
  ferro(
    name: 'ferro',
    nameBr: 'Ferro',
    asset: 'assets/gamification/insignias/digitalDetox/ferro.png',
    requirementDescription: '1 dia disciplinado',
  ),
  aluminio(
    name: 'aluminio',
    nameBr: 'Alumínio',
    asset: 'assets/gamification/insignias/digitalDetox/aluminio.png',
    requirementDescription: '2 dias disciplinados',
  ),
  latao(
    name: 'latao',
    nameBr: 'Latão',
    asset: 'assets/gamification/insignias/digitalDetox/latao.png',
    requirementDescription: '3 dias disciplinados',
  ),
  bronze(
    name: 'bronze',
    nameBr: 'Bronze',
    asset: 'assets/gamification/insignias/digitalDetox/bronze.png',
    requirementDescription: '5 dias disciplinados',
  ),
  prata(
    name: 'prata',
    nameBr: 'Prata',
    asset: 'assets/gamification/insignias/digitalDetox/prata.png',
    requirementDescription: '10 dias disciplinados',
  ),
  ouro(
    name: 'ouro',
    nameBr: 'Ouro',
    asset: 'assets/gamification/insignias/digitalDetox/ouro.png',
    requirementDescription: '15 dias disciplinados',
  ),
  diamante(
    name: 'diamante',
    nameBr: 'Diamante',
    asset: 'assets/gamification/insignias/digitalDetox/diamante.png',
    requirementDescription: '20 dias disciplinados',
  ),
  disciplinum(
    name: 'disciplinum',
    nameBr: 'Disciplinum',
    asset: 'assets/gamification/insignias/digitalDetox/disciplinum.png',
    requirementDescription: '30 dias disciplinados',
  );

  final String name;
  final String nameBr;
  final String asset;
  final String requirementDescription;

  const DigitalDetoxInsignia({
    required this.name,
    required this.nameBr,
    required this.asset,
    required this.requirementDescription,
  });
}
