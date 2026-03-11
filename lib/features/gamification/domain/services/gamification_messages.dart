import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:flutter/material.dart';

// Mensagens padrão por módulo
final Map<NicheId, String> defaultModuleMessages = {
  NicheId.smoking:
      '⚠️ Seja forte! Uma tragada a menos hoje são mais dias de vida amanhã.',
  NicheId.bingeEating:
      '🥑 Seja forte! Resista hoje e terá mais saúde amanhã (além de economizar dinheiro!).',
  NicheId.diet:
      '🍎 Seja forte! A regularidade é a chave. Mantenha sua dieta e verá os resultados!',
  NicheId.spending:
      '💲 Uma comprinha agora é realmente necessária? Pense bem antes de gastar!',
  NicheId.focus:
      '⏳ Atenção aos objetivos. Mantenha o foco e a disciplina para alcançar seu objetivo!',
  NicheId.adultContent:
      '🔞 Vai fazer isso mesmo? Cuidado com os efeitos negativos a longo prazo!',
  NicheId.moneySavingChallenge:
      '💰 Hoje é dia de se aproximar mais da sua meta! Que tal marcar mais um quadradinho hoje?',
  NicheId.procrastination:
      '🗓️ Não esqueça dos seus compromissos agendados. Verifique suas tarefas e compromissos para hoje!',
  NicheId.reading:
      '📚 Hora da leitura diária! Vamos viajar mais um pouco no mundo dos livros?',
};

class GamificationMessages {
  static String getModuleMessage(
    NicheId nicheId, {
    required bool isUnlocked,
    required Map<NicheId, String> customMessages,
  }) {
    if (isUnlocked) {
      final custom = customMessages[nicheId];
      if (custom != null && custom.isNotEmpty) return custom;
    }
    return defaultModuleMessages[nicheId] ?? 'Conquista em progresso!';
  }

  static String getMotivationalPhrase(
    NicheId nicheId,
    TimeOfDay time, {
    required bool isUnlocked,
    required Map<NicheId, List<TimeOfDay>> motivationSchedules,
    required Map<NicheId, List<String>> customPhrases,
    required Map<NicheId, String> customMessages,
  }) {
    // 1. Tenta pegar a lista de horários
    final schedules = motivationSchedules[nicheId];

    // 2. Se estiver desbloqueado (IAP ou Ad), tenta pegar a frase customizada correspondente ao índice
    if (isUnlocked) {
      final phrases = customPhrases[nicheId];
      if (phrases != null && schedules != null && phrases.isNotEmpty) {
        // Encontra qual "slot" é esse horário
        final index = schedules.indexOf(time);
        if (index >= 0 && index < phrases.length) {
          final customPhrase = phrases[index];
          if (customPhrase.isNotEmpty) return customPhrase;
        }
      }

      // Fallback para mensagem única customizada (legado)
      final customSingle = customMessages[nicheId];
      if (customSingle != null && customSingle.isNotEmpty) return customSingle;
    }

    // 3. Fallback Padrão (Free ou se não tiver custom)
    return defaultModuleMessages[nicheId] ?? 'Mantenha o foco e a disciplina!';
  }
}
