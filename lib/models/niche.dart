import 'niche_id.dart';

// Definição dos nichos/módulos
class Niche {
  final NicheId id;
  final String name;
  final String iconPath;
  final String homePhrase; // Frase para o card da Home

  final NicheType type;
  final int? maxSlots;
  final String? appCategory;

  const Niche({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.homePhrase,
    required this.type,
    this.maxSlots,
    this.appCategory,
    this.scale = 1.0,
  });

  final double scale;
}

enum NicheType {
  schedule,
  apps,
  timeInterval,
}

class NicheRepository {
  static List<Niche> getAll() {
    return const [
      Niche(
        id: NicheId.smoking,
        name: 'Parar de fumar',
        iconPath: 'assets/icons/niche_cigarro.png',
        homePhrase: 'Controle o vício e melhore sua saúde.',
        type: NicheType.schedule,
        maxSlots: 8,
        scale: 1.5,
      ),
      Niche(
        id: NicheId.bingeEating,
        name: 'Compulsão alimentar',
        iconPath: 'assets/icons/niche_compulsao.png',
        homePhrase: 'Reduza impulsos e tenha mais autocontrole.',
        type: NicheType.apps,
        appCategory: 'delivery_food',
        scale: 1.5,
      ),
      Niche(
        id: NicheId.diet,
        name: 'Manter dieta',
        iconPath: 'assets/icons/niche_dieta.png',
        homePhrase: 'Organize suas refeições e mantenha o foco.',
        type: NicheType.schedule,
        maxSlots: 6,
        scale: 1.5,
      ),
      Niche(
        id: NicheId.spending,
        name: 'Controlar gastos',
        iconPath: 'assets/icons/niche_dinheiro.png',
        homePhrase: 'Evite gastos desnecessários e/ou não planejados.',
        type: NicheType.apps,
        appCategory: 'shopping_delivery',
        scale: 1.5,
      ),
      Niche(
        id: NicheId.focus,
        name: 'Foco e produtividade',
        iconPath: 'assets/icons/niche_foco.png',
        homePhrase: 'Elimine distrações e foque em seus objetivos.',
        type: NicheType.timeInterval,
        scale: 1.5,
      ),
      Niche(
        id: NicheId.adultContent,
        name: 'Evitar conteúdo adulto',
        iconPath: 'assets/icons/niche_adult_content.png',
        homePhrase: 'Fortaleça sua disciplina e sua mente.',

        type: NicheType.apps,
        appCategory: 'browsers',
        scale: 1.5, // Configuração individual de tamanho
      ),
    ];
  }

  static Niche getById(NicheId id) {
    return getAll().firstWhere((n) => n.id == id,
        orElse: () => throw Exception('Niche not found: $id'));
  }
}
