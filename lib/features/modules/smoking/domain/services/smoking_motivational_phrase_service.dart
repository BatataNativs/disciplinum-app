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
    // Marcos de saúde baseados em evidências científicas
    if (days == 1) {
      return '⏱️ 24 horas sem fumar: Seu coração já bate mais devagar e sua pressão diminuiu.';
    } else if (days == 2) {
      return '🫁 48 horas: Seus nervos estão se regenerando. O paladar e olfato melhoram!';
    } else if (days == 3) {
      return '💨 3 dias: A nicotina saiu completamente do seu corpo. Respire fundo!';
    } else if (days == 7) {
      return '🌟 Uma semana sem fumar! Seu pulmão está 10% mais limpo.';
    } else if (days == 14) {
      return '💪 Duas semanas! Circulação melhorada - menos fadiga e dor no peito.';
    } else if (days == 30) {
      return '🫁 Um mês! Capacidade pulmonar aumentou em até 30%. Respire livre!';
    } else if (days == 90) {
      return '❤️ Três meses! Risco de ataque cardíaco já diminuiu significativamente.';
    } else if (days == 180) {
      return '🌟 Seis meses sem fumar! Risco de doença cardíaca caiu pela metade.';
    } else if (days == 365) {
      return '🎉 UM ANO! Risco de doença cardíaca igual a de não-fumante. Você venceu!';
    }
    return null;
  }

  /// Frases por período do dia (fallback)
  String _getPhraseByTimeOfDay(TimeOfDay time) {
    final hour = time.hour;

    if (hour >= 5 && hour < 12) {
      // Manhã (5h - 12h)
      return _getRandomPhrase([
        '🌅 Bom dia! Comece o dia sem fumar e com muita energia positiva.',
        '☀️ Novo dia, nova oportunidade de cuidar da sua saúde.',
        '🌄 Manhã de vitória! Mantenha o foco no seu objetivo.',
        '💪 Acordar sem a necessidade de fumar é uma sensação incrível, né?',
        '🎯 Bom dia! Cada manhã sem fumar é um presente para seu corpo.',
      ]);
    } else if (hour >= 12 && hour < 18) {
      // Tarde (12h - 18h)
      return _getRandomPhrase([
        '☀️ Boa tarde! Mantenha a disciplina no meio do dia.',
        '💪 Você está indo bem! Não deixe o cansaço vencer.',
        '🌤️ Tarde de conquistas! Cada hora sem fumar é progresso.',
        '⭐ Lembre-se do seu "porquê". A disciplina vale a pena!',
        '🎯 Boa tarde! Respire fundo e sinta seu corpo agradecendo.',
      ]);
    } else {
      // Noite (18h - 5h)
      return _getRandomPhrase([
        '🌙 Boa noite! Termine o dia com orgulho da sua disciplina.',
        '⭐ Um dia sem fumar é uma vitória. Descanse sabendo que venceu!',
        '🌌 Noite de paz! Seu corpo agradece cada dia de liberdade.',
        '💪 O dia acabou e você venceu! Prepare-se para amanhã.',
        '🌜 Boa noite! Sonhe com uma vida cada vez mais saudável.',
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
