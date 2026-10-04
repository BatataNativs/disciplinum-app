import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Mensagens de gamificação específicas do módulo Money Saving
/// Duplicadas da gamificação central e fragmentadas para independência total
final Map<NicheId, String> moneySavingDefaultModuleMessages = {
  NicheId.moneySavingChallenge:
      '🚀 Desafio da Poupança! Não esqueça de registrar seu progresso e ficar focado na meta!',
};

/// Mensagens motivacionais para diferentes situações do Money Saving
class MoneySavingGamificationMessages {
  /// Mensagens para streaks de economia
  static const List<String> streakMessages = [
    '🔥 Ótimo! Você está economizando há {days} dias seguidos!',
    '💪 Incrível! Sua disciplina com dinheiro está impressionante!',
    '🎯 Excelente! Continue focado na sua meta financeira!',
    '⭐ Fantástico! Você está construindo um futuro próspero!',
    '🏆 Extraordinário! Sua força de vontade é inspiradora!',
  ];

  /// Mensagens para conquistas de medalhas
  static const Map<String, String> medalMessages = {
    'bronze': '🥉 Parabéns! Você conquistou sua primeira medalha de economia!',
    'prata': '🥈 Excelente! Sua consistência está sendo recompensada!',
    'ouro': '🥇 Magnífico! Você é um mestre da economia!',
    'diamante': '💎 Lendário! Você alcançou o topo da disciplina financeira!',
  };

  /// Mensagens para insignias
  static const Map<String, String> insigniaMessages = {
    'madeira': '🪵 Módulo ativado. Início da sua jornada de economia.',
    'ferro': '⚙️ Primeiros passos dados. O hábito começa a se formar.',
    'aluminio': '🔘 Bom progresso. Mantendo a regularidade no desafio.',
    'latao': '🔩 Constância mantida. Sua rotina de economia segue firme.',
    'bronze':
        '🥉 Base estabelecida. Uma parte importante do desafio foi concluída.',
    'prata': '🥈 Avanço consistente. A disciplina financeira se consolida.',
    'ouro': '🥇 Grande avanço. Reta final do desafio se aproximando.',
    'diamante':
        '💎 Quase concluído. Excelente controle financeiro demonstrado.',
    'disciplinum':
        '🏆 Um ciclo de desafio foi concluído. Parabéns por alcançar a insígnia Disciplinum!',
  };

  /// Mensagens para recaídas (gastos excessivos)
  static const List<String> relapseMessages = [
    '💭 Acontece! O importante é recomeçar com força total.',
    '🌱 Cada dia é uma nova chance de cuidar do seu futuro.',
    '🔄 Use isso como aprendizado para ficar mais forte!',
    '💡 Identifique o gatilho e prepare-se para o próximo desafio.',
    '🎯 Sua meta continua lá, esperando por você!',
  ];

  /// Mensagens para metas alcançadas
  static const List<String> goalAchievedMessages = [
    '🎉 Meta alcançada! Você provou que é possível!',
    '🏆 Conquista fantástica! Celebre seu sucesso!',
    '⭐ Missão cumprida! Você é um exemplo de disciplina!',
    '🎊 Objetivo batido! Sua dedicação valeu a pena!',
    '🌟 Sucesso absoluto! Você é inspirador!',
  ];

  /// Mensagens para check-ins diários
  static const List<String> checkInMessages = [
    '✅ Check-in registrado! Continue assim!',
    '👏 Ótimo trabalho! Sua consistência é admirável!',
    '📈 Progresso anotado! Você está no caminho certo!',
    '💾 Dia registrado! Sua disciplina está sendo construída!',
    '🎯 Foco mantido! Seu futuro agradece!',
  ];

  /// Obtém mensagem de streak baseada nos dias
  static String getStreakMessage(int days) {
    if (days <= 0) return '';
    final index = (days - 1) % streakMessages.length;
    return streakMessages[index].replaceAll('{days}', days.toString());
  }

  /// Obtém mensagem de medalha
  static String getMedalMessage(String medalType) {
    return medalMessages[medalType] ?? '🏅 Medalha conquistada!';
  }

  /// Obtém mensagem de insignia
  static String getInsigniaMessage(String insigniaType) {
    return insigniaMessages[insigniaType] ?? '🎖️ Insignia desbloqueada!';
  }

  /// Obtém mensagem de recaída aleatória
  static String getRelapseMessage() {
    final random = DateTime.now().millisecond % relapseMessages.length;
    return relapseMessages[random];
  }

  /// Obtém mensagem de meta alcançada aleatória
  static String getGoalAchievedMessage() {
    final random = DateTime.now().millisecond % goalAchievedMessages.length;
    return goalAchievedMessages[random];
  }

  /// Obtém mensagem de check-in aleatória
  static String getCheckInMessage() {
    final random = DateTime.now().millisecond % checkInMessages.length;
    return checkInMessages[random];
  }

  /// Mensagem padrão do módulo
  static String getDefaultMessage() {
    return moneySavingDefaultModuleMessages[NicheId.moneySavingChallenge] ??
        '🚀 Desafio da Poupança! Continue focado na sua meta!';
  }
}
