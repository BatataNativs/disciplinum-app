import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Engine responsável por motivar o usuário, gerando ou selecionando frases
/// baseadas no módulo ativo e no contexto do usuário.
class MotivationEngine {
  static final MotivationEngine instance = MotivationEngine._internal();
  MotivationEngine._internal();

  // Banco de frases com fallback nativo, mas pode ser expandido/sobrescrito por nuvem.
  final Map<NicheId, List<String>> _defaultPhrases = {
    NicheId.smoking: [
      "Seus pulmões estão se curando a cada dia que passa.",
      "Você é mais forte que o vício.",
      "O desejo dura minutos, o orgulho dura para sempre."
    ],
    NicheId.bingeEating: [
      "Você tem controle sobre suas escolhas.",
      "Nutrição é amor próprio.",
      "Alimentos abastecem, não consolam ressentimentos."
    ],
    NicheId.focus: [
      "Foco é a ponte entre seus objetivos e suas realizações.",
      "Um passo de cada vez. Concentre-se no agora.",
      "Desligue as distrações e ligue seu potencial."
    ],
    NicheId.moneySavingChallenge: [
      "Economizar hoje é garantir sua liberdade de amanhã.",
      "Cada centavo poupado é um soldado para o seu futuro.",
      "A paciência é a melhor aliada dos investimentos."
    ]
  };

  /// Seleciona uma frase motivacional rotativa ou aleatória para o momento
  String getMotivationPhrase(NicheId nicheId, {List<String>? customPhrases}) {
    final pool = (customPhrases != null && customPhrases.isNotEmpty)
        ? customPhrases
        : (_defaultPhrases[nicheId] ?? ["Mantenha o foco. Você consegue!"]);

    // Baseia a escolha no dia do ano para rodízio previsível, ou aleatório
    final todayIndex = DateTime.now().difference(DateTime(2000)).inDays;
    return pool[todayIndex % pool.length];
  }
}
