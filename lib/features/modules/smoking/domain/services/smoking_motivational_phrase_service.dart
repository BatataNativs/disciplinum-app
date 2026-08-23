/// Serviço de frases motivacionais atreladas às conquistas do módulo Smoking
/// 
/// Gera frases contextualizadas baseadas nas insígnias e medalhas conquistadas,
/// priorizando conquistas recentes. Se não houver conquistas recentes,
/// usa frases por período do dia (manhã/tarde/noite).
/// 
/// Dias das insígnias (conforme documentação):
/// - Ferro: 1 dia
/// - Alumínio: 2 dias
/// - Latão: 3 dias
/// - Bronze: 5 dias
/// - Prata: 10 dias
/// - Ouro: 15 dias
/// - Diamante: 20 dias
/// - Disciplinum: 30 dias
library;

import 'dart:math';
import 'package:flutter/material.dart';

class SmokingMotivationalPhraseService {
  static final SmokingMotivationalPhraseService _instance = SmokingMotivationalPhraseService._internal();
  factory SmokingMotivationalPhraseService() => _instance;
  SmokingMotivationalPhraseService._internal();

  final Random _random = Random();

  /// Janela de tempo para considerar uma conquista "recente" (em dias)
  static const int _recentAchievementWindowDays = 7;

  /// Gera uma frase motivacional contextualizada
  /// 
  /// Prioridade:
  /// 1. Conquistas recentes (últimos 7 dias)
  /// 2. Marcos de saúde significativos
  /// 3. Período do dia (manhã/tarde/noite)
  String generateMotivationalPhrase({
    required List<String> earnedInsignias,
    required List<String> earnedMedalhas,
    required int daysWithoutSmoking,
    TimeOfDay? currentTime,
  }) {
    final time = currentTime ?? TimeOfDay.now();
    
    // 1. Verifica conquistas recentes de insígnias
    final recentInsigniaPhrase = _getPhraseForRecentInsignia(earnedInsignias, daysWithoutSmoking);
    if (recentInsigniaPhrase != null) {
      return recentInsigniaPhrase;
    }

    // 2. Verifica medalhas recentes
    final recentMedalhaPhrase = _getPhraseForRecentMedalha(earnedMedalhas);
    if (recentMedalhaPhrase != null) {
      return recentMedalhaPhrase;
    }

    // 3. Verifica marcos de saúde significativos
    final healthMilestonePhrase = _getPhraseForHealthMilestone(daysWithoutSmoking);
    if (healthMilestonePhrase != null) {
      return healthMilestonePhrase;
    }

    // 4. Fallback: frases por período do dia
    return _getPhraseByTimeOfDay(time);
  }

  /// Gera frase específica para insígnia recentemente conquistada
  String? _getPhraseForRecentInsignia(List<String> earnedInsignias, int daysWithoutSmoking) {
    if (earnedInsignias.isEmpty) return null;

    // Ordena insígnias por "peso" (dias necessários) e pega a mais avançada
    final sortedInsignias = _sortInsigniasByProgress(earnedInsignias);
    if (sortedInsignias.isEmpty) return null;

    final latestInsignia = sortedInsignias.last;

    // Frases específicas por insígnia
    final phrases = _getPhrasesForInsignia(latestInsignia, daysWithoutSmoking);
    if (phrases.isEmpty) return null;

    return phrases[_random.nextInt(phrases.length)];
  }

  /// Retorna dias necessários para cada insígnia
  int _getDaysForInsignia(String insigniaName) {
    switch (insigniaName.toUpperCase()) {
      case 'FERRO':
        return 1;
      case 'ALUMINIO':
      case 'ALUMÍNIO':
        return 2;
      case 'LATAO':
      case 'LATÃO':
        return 3;
      case 'BRONZE':
        return 5;
      case 'PRATA':
        return 10;
      case 'OURO':
        return 15;
      case 'DIAMANTE':
        return 20;
      case 'DISCIPLINUM':
        return 30;
      default:
        return 0;
    }
  }

  /// Ordena insígnias pelo progresso (dias necessários)
  List<String> _sortInsigniasByProgress(List<String> insignias) {
    final sorted = List<String>.from(insignias);
    sorted.sort((a, b) => _getDaysForInsignia(a).compareTo(_getDaysForInsignia(b)));
    return sorted;
  }

  /// Frases específicas para cada insígnia
  List<String> _getPhrasesForInsignia(String insignia, int currentDays) {
    final name = insignia.toUpperCase();
    
    switch (name) {
      case 'FERRO':
        return [
          '🎯 Primeiro dia conquistado! O começo é sempre o mais difícil. Você já provou que pode!',
          '💪 24 horas sem fumar! Seu corpo já começa a agradecer.',
          '🌟 Um dia de vitória! Cada segundo sem fumar é uma conquista.',
        ];
      case 'ALUMINIO':
      case 'ALUMÍNIO':
        return [
          '🔥 2 dias sem fumar! Sua determinação está crescendo.',
          '✨ Dois dias de liberdade! Continue assim, você está no caminho certo.',
          '🚀 Segundo dia conquistado! O vício está perdendo força.',
        ];
      case 'LATAO':
      case 'LATÃO':
        return [
          '🏆 3 dias! Você superou a fase mais crítica. Orgulhe-se!',
          '⭐ Três dias sem fumar! Seu corpo está se recuperando.',
          '🎉 Terceiro dia conquistado! A vontade de fumar já diminuiu muito.',
        ];
      case 'BRONZE':
        return [
          '🥉 Insígnia Bronze! 5 dias de disciplina e força de vontade.',
          '💎 5 dias sem fumar! Você está construindo um novo hábito saudável.',
          '🌟 Quase uma semana! Sua persistência é inspiradora.',
        ];
      case 'PRATA':
        return [
          '🥈 Insígnia Prata! 10 dias provando que você é mais forte que o vício.',
          '✨ Dez dias de vitória! Sua determinação está transformando sua vida.',
          '🎯 10 dias sem fumar! Você está no controle total.',
        ];
      case 'OURO':
        return [
          '🥇 Insígnia Ouro! 15 dias de pura determinação e conquista.',
          '🏆 Quinze dias sem fumar! Você é um exemplo de perseverança.',
          '💫 15 dias de liberdade! A vida sem cigarros é muito melhor, né?',
        ];
      case 'DIAMANTE':
        return [
          '💎 Insígnia Diamante! 20 dias de disciplina inabalável.',
          '🌟 Vinte dias sem fumar! Você conquistou algo extraordinário.',
          '⭐ Diamante na veia! 20 dias provando que tudo é possível com foco.',
        ];
      case 'DISCIPLINUM':
        return [
          '🏅 Insígnia Disciplinum! 30 dias de disciplina máxima!',
          '🎖️ Um mês de vitória! Você é um guerreiro da disciplina.',
          '💪 Trinta dias sem fumar! Você conquistou sua liberdade de volta.',
          '🌟 Disciplinum: O topo da conquista! 30 dias de puro orgulho.',
        ];
      default:
        return [];
    }
  }

  /// Gera frase para medalha recente
  String? _getPhraseForRecentMedalha(List<String> earnedMedalhas) {
    if (earnedMedalhas.isEmpty) return null;

    final phrases = <String>[];
    
    for (final medalha in earnedMedalhas) {
      final name = medalha.toUpperCase();
      switch (name) {
        case 'BRONZE':
          phrases.addAll([
            '🏅 Medalha Bronze! Múltiplas conquistas mostram sua dedicação.',
            '🥉 Medalha de Bronze conquistada! Você está em uma sequência incrível.',
          ]);
          break;
        case 'PRATA':
          phrases.addAll([
            '🥈 Medalha Prata! Sua consistência está te levando longe.',
            '🏅 Medalha de Prata! Você provou que pode manter o foco.',
          ]);
          break;
        case 'OURO':
          phrases.addAll([
            '🥇 Medalha Ouro! Poucos chegam tão longe. Você é especial.',
            '🏆 Medalha de Ouro conquistada! Excelência em disciplina.',
          ]);
          break;
        case 'DIAMANTE':
          phrases.addAll([
            '💎 Medalha Diamante! O ápice da disciplina conquistado.',
            '🌟 Medalha de Diamante! Você é um exemplo máximo de perseverança.',
          ]);
          break;
      }
    }

    if (phrases.isEmpty) return null;
    return phrases[_random.nextInt(phrases.length)];
  }

  /// Gera frase para marcos de saúde significativos
String? _getPhraseForHealthMilestone(int days) {
  // Marcos baseados em informações de saúde pública e literatura
  // sobre os benefícios de parar de fumar.
  if (days == 1) {
    return '⏱️ 24 horas sem fumar: Seu corpo já está eliminando o monóxido de carbono e iniciando a recuperação.';
  } else if (days == 2) {
    return '👃 48 horas: Seu paladar e seu olfato começam a melhorar. Aos poucos, você volta a sentir mais do mundo.';
  } else if (days == 3) {
    return '🫁 3 dias: A nicotina já foi eliminada do organismo e sua respiração pode começar a ficar mais fácil.';
  } else if (days == 7) {
    return '🌟 Uma semana sem fumar! Você já atravessou uma das fases mais difíceis. Continue firme.';
  } else if (days == 14) {
    return '💪 Duas semanas: Sua circulação começa a melhorar e sua função pulmonar já pode estar se recuperando.';
  } else if (days == 30) {
    return '🏆 Um mês sem fumar! Tosse e falta de ar tendem a melhorar ao longo dos próximos meses.';
  } else if (days == 90) {
    return '🫁 Três meses: Sua circulação e sua função pulmonar continuam melhorando. Cada dia conta.';
  } else if (days == 180) {
    return '🌟 Seis meses sem fumar! Tosse, chiado e falta de ar podem estar bem menores. Seu corpo continua se recuperando.';
  } else if (days == 365) {
    return '🎉 UM ANO! O risco adicional de doença coronariana caiu aproximadamente pela metade em comparação com quem continua fumando.';
  }

  return null;
}

/// Frases por período do dia (fallback)
String _getPhraseByTimeOfDay(TimeOfDay time) {
  final hour = time.hour;

  if (hour >= 5 && hour < 12) {
    // Manhã (5h - 11h59)
    return _getRandomPhrase([
      '🌅 Bom dia! Mais uma manhã sem fumar. Continue construindo essa nova rotina.',
      '☀️ Novo dia, nova oportunidade de cuidar de você.',
      '🌄 Bom dia! Hoje você não precisa repetir os hábitos de ontem.',
      '💪 Acordar sem depender do cigarro é mais uma pequena vitória.',
      '🎯 Bom dia! Lembre-se do motivo que fez você decidir parar.',
      '🌱 Cada manhã sem fumar é mais um passo para uma rotina mais livre.',
      '☀️ Você já venceu o primeiro desafio do dia: começar sem fumar.',
      '🔥 O cigarro ficou no passado. Hoje é mais um dia para seguir em frente.',
      '🏆 Mais uma manhã conquistada. Não negocie com a vontade de fumar.',
      '🫁 Respire fundo. Seu dia começou, e você continua no controle.',
      '💚 Seu corpo trabalha a seu favor enquanto você mantém a decisão.',
      '🚀 Comece o dia lembrando: vontade passa, decisão permanece.',
      '🎯 Não pense em nunca mais. Pense em não fumar hoje.',
      '🌤️ Uma manhã de cada vez. Um dia de cada vez. Uma vitória de cada vez.',
      '💪 Você não precisa de um cigarro para começar bem o dia.',
    ]);
  } else if (hour >= 12 && hour < 18) {
    // Tarde (12h - 17h59)
    return _getRandomPhrase([
      '☀️ Boa tarde! Continue firme. O seu objetivo ainda vale a pena.',
      '💪 Você chegou até aqui sem fumar. Não deixe uma vontade momentânea decidir por você.',
      '🌤️ Mais uma tarde livre do cigarro. Continue no comando.',
      '⭐ Lembre-se do seu "porquê". A disciplina vale a pena.',
      '🎯 Boa tarde! Respire fundo e deixe a vontade passar.',
      '🏆 Cada hora sem fumar é mais uma hora vencida.',
      '💚 Seu esforço de hoje está construindo um hábito novo.',
      '🔥 A vontade pode aparecer, mas você não é obrigado a obedecê-la.',
      '🫁 Pare por alguns segundos, respire fundo e siga em frente.',
      '🚫 Não troque uma conquista por alguns minutos de vontade.',
      '💪 A tarde está passando. Você também vai passar por essa vontade.',
      '🌱 Mudanças grandes são feitas de decisões pequenas repetidas todos os dias.',
      '🎯 Seu objetivo não mudou só porque hoje ficou difícil.',
      '⭐ Mais uma tarde sem cigarro. Mais uma prova de que você consegue.',
      '🚀 Continue. O desconforto é passageiro, mas a conquista fica.',
    ]);
  } else {
    // Noite (18h - 4h59)
    return _getRandomPhrase([
      '🌙 Boa noite! Termine o dia com orgulho da decisão que tomou.',
      '⭐ Mais um dia sem fumar. Isso é uma vitória real.',
      '🌌 O dia está acabando, e você continua no controle.',
      '💪 Você chegou ao fim de mais um dia sem precisar voltar ao cigarro.',
      '🌜 Boa noite! Amanhã você terá mais um dia para continuar essa conquista.',
      '🏆 Feche o dia contando mais uma vitória: você não fumou.',
      '🫁 Respire fundo. Seu corpo agradece cada dia longe da fumaça.',
      '🌙 A vontade pode aparecer, mas a noite também vai passar.',
      '💚 Descanse sabendo que hoje você manteve sua decisão.',
      '🎯 Um dia de cada vez. Hoje você conseguiu.',
      '⭐ Não precisa vencer o resto da vida hoje. Só precisa vencer esta noite.',
      '🔥 Mais um dia no placar. Continue aumentando essa sequência.',
      '🌌 Deixe o cigarro fora da sua noite. Amanhã é outra oportunidade de vencer.',
      '💪 Você não chegou até aqui por acaso. Continue.',
      '🏁 Mais um dia concluído sem fumar. Amanhã começamos outra rodada.',
    ]);
  }
}

  String _getRandomPhrase(List<String> phrases) {
    return phrases[_random.nextInt(phrases.length)];
  }

  /// Verifica se há conquistas recentes (últimos X dias)
  bool hasRecentAchievements({
    required List<String> earnedInsignias,
    required List<String> earnedMedalhas,
    required DateTime? lastCheckIn,
  }) {
    if (lastCheckIn == null) return false;
    
    final daysSinceLastCheckIn = DateTime.now().difference(lastCheckIn).inDays;
    return daysSinceLastCheckIn <= _recentAchievementWindowDays && 
           (earnedInsignias.isNotEmpty || earnedMedalhas.isNotEmpty);
  }
}
