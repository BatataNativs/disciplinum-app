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
        iconPath: 'assets/icons/icon_no_smoking.png',
        homePhrase: 'Controle o vício e melhore sua saúde.',
        type: NicheType.schedule,
        maxSlots: 8,
        scale: 2.9,
      ),
      Niche(
        id: NicheId.bingeEating,
        name: 'Compulsão alimentar',
        iconPath: 'assets/icons/icon_binge_eating.png',
        homePhrase: 'Reduza impulsos e tenha mais autocontrole.',
        type: NicheType.apps,
        appCategory: 'delivery_food',
        scale: 2.9,
      ),
      Niche(
        id: NicheId.diet,
        name: 'Manter dieta',
        iconPath: 'assets/icons/icon_diet.png',
        homePhrase: 'Organize suas refeições e mantenha o foco.',
        type: NicheType.schedule,
        maxSlots: 6,
        scale: 2.9,
      ),
      Niche(
        id: NicheId.spending,
        name: 'Controlar gastos',
        iconPath: 'assets/icons/niche_dinheiro.png',
        homePhrase: 'Evite gastos desnecessários e/ou não planejados.',
        type: NicheType.apps,
        appCategory: 'shopping_delivery',
        scale: 2.2,
      ),
      Niche(
        id: NicheId.focus,
        name: 'Foco e produtividade',
        iconPath: 'assets/icons/niche_foco.png',
        homePhrase: 'Elimine distrações e foque em seus objetivos.',
        type: NicheType.timeInterval,
        scale: 2.7,
      ),
      Niche(
        id: NicheId.adultContent,
        name: 'Evitar conteúdo adulto',
        iconPath: 'assets/icons/niche_adult_content.png',
        homePhrase: 'Fortaleça sua mente e tenha mais autocontrole.',
        type: NicheType.apps,
        appCategory: 'browsers',
        scale: 2.9, // Configuração individual de tamanho
      ),
      Niche(
        id: NicheId.moneySavingChallenge,
        name: 'Desafio da poupança',
        iconPath: 'assets/icons/niche_poupanca.png',
        homePhrase: 'Economize de forma lúdica e visual.',
        type: NicheType.timeInterval,
        scale: 1.9,
      ),
      Niche(
        id: NicheId.procrastination,
        name: 'Evitar procrastinação',
        iconPath: 'assets/icons/niche_procrastination.png',
        homePhrase: 'Gerencie tarefas e evite a procrastinação.',
        type: NicheType.schedule,
        scale: 2.7,
      ),
    ];
  }

  static Niche getById(NicheId id) {
    return getAll().firstWhere((n) => n.id == id,
        orElse: () => throw Exception('Niche not found: $id'));
  }
}

// --- ESTRUTURA DE CATEGORIAS DA HOME ---

class NicheCategory {
  final String title;
  final String idPrefix; // Usado para gerar a heroTag única (ex: 'saude')
  final List<NicheId> nicheIds;

  const NicheCategory({
    required this.title,
    required this.idPrefix,
    required this.nicheIds,
  });
}

class NicheCategoryRepository {
  static List<NicheCategory> getCategories() {
    return const [
      NicheCategory(
        title: 'Saúde e Fitness',
        idPrefix: 'saude',
        nicheIds: [
          NicheId.smoking,
          NicheId.bingeEating,
          NicheId.diet,
        ],
      ),
      NicheCategory(
        title: 'Mente e Hábitos',
        idPrefix: 'mente',
        nicheIds: [
          NicheId.smoking,
          NicheId.focus,
          NicheId.procrastination, // Novo
          NicheId.adultContent,
          NicheId.bingeEating,
          NicheId.spending,
          NicheId.moneySavingChallenge,
        ],
      ),
      NicheCategory(
        title: 'Finanças',
        idPrefix: 'financas',
        nicheIds: [
          NicheId.spending,
          NicheId.moneySavingChallenge,
          NicheId.bingeEating, // Gastos com comida
        ],
      ),
    ];
  }
}
