import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

// Mensagens padrão por módulo
final Map<NicheId, String> defaultModuleMessages = {
  NicheId.smoking:
      '⚠️ Seja forte! Uma tragada a menos hoje são mais dias de vida amanhã.',
  NicheId.bingeEating:
      '🥑 Seja forte! Resista hoje e terá mais saúde amanhã (além de economizar dinheiro!).',
  NicheId.diet:
      '🥗 Hoje é um ótimo dia para nutrir seu corpo com sabedoria! Foco no seu objetivo!',
  NicheId.spending:
      '💰 Cada centavo conta! Pense no seu futuro e evite gastos desnecessários hoje.',
  NicheId.focus:
      '🎯 Concentração total! Elimine as distrações e foque no que realmente importa.',
  NicheId.adultContent:
      '🛡️ Mantenha sua mente limpa e seu propósito firme. Você é capaz!',
  NicheId.moneySavingChallenge:
      '🚀 Desafio da Poupança! Não esqueça de registrar seu progresso e ficar focado na meta!',
  NicheId.procrastination:
      '⌛ O melhor momento para começar é agora. Não deixe para depois o que transforma seu futuro!',
  NicheId.reading:
      '📚 Que tal ler algumas páginas agora? O conhecimento é o seu maior poder!',
};

class GamificationMessages {
  /// Retorna a frase motivacional baseada no nicho e opcionalmente em um horário específico.
  static String getMotivationalPhrase(
    dynamic nicheId, {
    String? timeStr,
    bool isUnlocked = false,
    Map<int, List<String>>? customPhrases,
    Map<int, List<String>>? motivationSchedules, // Reservado para uso futuro
    Map<NicheId, String>? customMessages,
  }) {
    final int id = (nicheId is NicheId) ? nicheId.id : (nicheId as int);

    // 1. Tentar buscar frase customizada do usuário para este nicho se estiver desbloqueado
    if (isUnlocked &&
        customPhrases != null &&
        customPhrases.containsKey(id) &&
        customPhrases[id]!.isNotEmpty) {
      return customPhrases[id]!.first;
    }

    // 2. Tentar Mensagem Customizada (se desbloqueado)
    if (isUnlocked && customMessages != null) {
      final nid = (nicheId is NicheId) ? nicheId : NicheId.tryFromInt(id);
      if (nid != null && customMessages.containsKey(nid)) {
        return customMessages[nid]!;
      }
    }

    // 3. Fallback para mensagem padrão do sistema
    final niche = (nicheId is NicheId) ? nicheId : NicheId.tryFromInt(id);
    if (niche != null) {
      return defaultModuleMessages[niche] ?? 'Continue firme no seu propósito!';
    }

    return 'Continue firme no seu propósito!';
  }

  /// Retorna a mensagem personalizada do módulo ou a padrão.
  static String getModuleMessage(
    NicheId nicheId, {
    bool isUnlocked = false,
    Map<NicheId, String>? customMessages,
  }) {
    if (isUnlocked &&
        customMessages != null &&
        customMessages.containsKey(nicheId)) {
      return customMessages[nicheId]!;
    }
    return defaultModuleMessages[nicheId] ?? 'Continue firme no seu propósito!';
  }

  /// Retorna sugestões de horários padrão para notificações de motivação por nicho.
  static List<TimeOfDay> getDefaultMotivationTimes(NicheId nicheId) {
    switch (nicheId) {
      case NicheId.smoking:
      case NicheId.bingeEating:
      case NicheId.diet:
        return [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 14, minute: 30),
          const TimeOfDay(hour: 19, minute: 0),
        ];
      case NicheId.focus:
        return [
          const TimeOfDay(hour: 8, minute: 30),
          const TimeOfDay(hour: 14, minute: 0),
        ];
      default:
        return [const TimeOfDay(hour: 10, minute: 0)];
    }
  }
}
