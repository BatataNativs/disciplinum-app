/// Entidade de insígnias específicas do módulo Procrastination
/// Baseada em dias consecutivos com todas as tarefas concluídas
enum ProcrastinationInsigniaEntity {
  madeira,    // Apenas por configurar e ativar o módulo
  ferro,      // 1 dia com todas as tarefas concluídas
  aluminio,   // 2 dias com todas as tarefas concluídas
  latao,      // 3 dias com todas as tarefas concluídas
  bronze,     // 5 dias com todas as tarefas concluídas
  prata,      // 12 dias com todas as tarefas concluídas
  ouro,       // 18 dias com todas as tarefas concluídas
  diamante,   // 25 dias com todas as tarefas concluídas
  disciplinum; // 30 dias com todas as tarefas concluídas
}

extension ProcrastinationInsigniaEntityExtension on ProcrastinationInsigniaEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case ProcrastinationInsigniaEntity.madeira:
        return 'madeira';
      case ProcrastinationInsigniaEntity.ferro:
        return 'ferro';
      case ProcrastinationInsigniaEntity.aluminio:
        return 'aluminio';
      case ProcrastinationInsigniaEntity.latao:
        return 'latao';
      case ProcrastinationInsigniaEntity.bronze:
        return 'bronze';
      case ProcrastinationInsigniaEntity.prata:
        return 'prata';
      case ProcrastinationInsigniaEntity.ouro:
        return 'ouro';
      case ProcrastinationInsigniaEntity.diamante:
        return 'diamante';
      case ProcrastinationInsigniaEntity.disciplinum:
        return 'disciplinum';
    }
  }

  /// Verifica se esta é a insígnia Disciplinum
  bool get isDisciplinum => this == ProcrastinationInsigniaEntity.disciplinum;

  /// Verifica se esta é a insígnia inicial (Madeira)
  bool get isInitial => this == ProcrastinationInsigniaEntity.madeira;

  /// Obtém o progresso percentual até esta insígnia
  double get progressPercentage {
    switch (this) {
      case ProcrastinationInsigniaEntity.madeira:
        return 0.0;
      case ProcrastinationInsigniaEntity.ferro:
        return 3.33; // 1/30
      case ProcrastinationInsigniaEntity.aluminio:
        return 6.67; // 2/30
      case ProcrastinationInsigniaEntity.latao:
        return 10.0; // 3/30
      case ProcrastinationInsigniaEntity.bronze:
        return 16.67; // 5/30
      case ProcrastinationInsigniaEntity.prata:
        return 40.0; // 12/30
      case ProcrastinationInsigniaEntity.ouro:
        return 60.0; // 18/30
      case ProcrastinationInsigniaEntity.diamante:
        return 83.33; // 25/30
      case ProcrastinationInsigniaEntity.disciplinum:
        return 100.0; // 30/30
    }
  }

  /// Obtém os dias necessários para esta insígnia
  int get requiredDays {
    switch (this) {
      case ProcrastinationInsigniaEntity.madeira:
        return 0; // Ganha ao configurar e ativar o módulo
      case ProcrastinationInsigniaEntity.ferro:
        return 1; // 1 dia com todas as tarefas concluídas
      case ProcrastinationInsigniaEntity.aluminio:
        return 2; // 2 dias com todas as tarefas concluídas
      case ProcrastinationInsigniaEntity.latao:
        return 3; // 3 dias com todas as tarefas concluídas
      case ProcrastinationInsigniaEntity.bronze:
        return 5; // 5 dias com todas as tarefas concluídas
      case ProcrastinationInsigniaEntity.prata:
        return 12; // 12 dias com todas as tarefas concluídas
      case ProcrastinationInsigniaEntity.ouro:
        return 18; // 18 dias com todas as tarefas concluídas
      case ProcrastinationInsigniaEntity.diamante:
        return 25; // 25 dias com todas as tarefas concluídas
      case ProcrastinationInsigniaEntity.disciplinum:
        return 30; // 30 dias com todas as tarefas concluídas
    }
  }

  /// Obtém a descrição do benefício
  String get benefitDescription {
    switch (this) {
      case ProcrastinationInsigniaEntity.madeira:
        return 'Módulo configurado e ativado';
      case ProcrastinationInsigniaEntity.ferro:
        return '1 dia com todas as tarefas concluídas';
      case ProcrastinationInsigniaEntity.aluminio:
        return '2 dias com todas as tarefas concluídas';
      case ProcrastinationInsigniaEntity.latao:
        return '3 dias com todas as tarefas concluídas';
      case ProcrastinationInsigniaEntity.bronze:
        return '5 dias com todas as tarefas concluídas';
      case ProcrastinationInsigniaEntity.prata:
        return '12 dias com todas as tarefas concluídas';
      case ProcrastinationInsigniaEntity.ouro:
        return '18 dias com todas as tarefas concluídas';
      case ProcrastinationInsigniaEntity.diamante:
        return '25 dias com todas as tarefas concluídas';
      case ProcrastinationInsigniaEntity.disciplinum:
        return '30 dias com todas as tarefas concluídas';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case ProcrastinationInsigniaEntity.madeira:
        return 'Madeira';
      case ProcrastinationInsigniaEntity.ferro:
        return 'Ferro';
      case ProcrastinationInsigniaEntity.aluminio:
        return 'Alumínio';
      case ProcrastinationInsigniaEntity.latao:
        return 'Latão';
      case ProcrastinationInsigniaEntity.bronze:
        return 'Bronze';
      case ProcrastinationInsigniaEntity.prata:
        return 'Prata';
      case ProcrastinationInsigniaEntity.ouro:
        return 'Ouro';
      case ProcrastinationInsigniaEntity.diamante:
        return 'Diamante';
      case ProcrastinationInsigniaEntity.disciplinum:
        return 'Disciplinum';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/insignias/procrastination/';
    switch (this) {
      case ProcrastinationInsigniaEntity.madeira:
        return '${prefix}madeira.png';
      case ProcrastinationInsigniaEntity.ferro:
        return '${prefix}ferro.png';
      case ProcrastinationInsigniaEntity.aluminio:
        return '${prefix}aluminio.png';
      case ProcrastinationInsigniaEntity.latao:
        return '${prefix}latao.png';
      case ProcrastinationInsigniaEntity.bronze:
        return '${prefix}bronze.png';
      case ProcrastinationInsigniaEntity.prata:
        return '${prefix}prata.png';
      case ProcrastinationInsigniaEntity.ouro:
        return '${prefix}ouro.png';
      case ProcrastinationInsigniaEntity.diamante:
        return '${prefix}diamante.png';
      case ProcrastinationInsigniaEntity.disciplinum:
        return '${prefix}disciplinum.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case ProcrastinationInsigniaEntity.madeira:
        return 'Ative o módulo Evitar Procrastinação';
      case ProcrastinationInsigniaEntity.ferro:
        return 'Conclua todas as tarefas por 1 dia';
      case ProcrastinationInsigniaEntity.aluminio:
        return 'Conclua todas as tarefas por 2 dias';
      case ProcrastinationInsigniaEntity.latao:
        return 'Conclua todas as tarefas por 3 dias';
      case ProcrastinationInsigniaEntity.bronze:
        return 'Conclua todas as tarefas por 5 dias';
      case ProcrastinationInsigniaEntity.prata:
        return 'Conclua todas as tarefas por 12 dias';
      case ProcrastinationInsigniaEntity.ouro:
        return 'Conclua todas as tarefas por 18 dias';
      case ProcrastinationInsigniaEntity.diamante:
        return 'Conclua todas as tarefas por 25 dias';
      case ProcrastinationInsigniaEntity.disciplinum:
        return 'Conclua todas as tarefas por 30 dias';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case ProcrastinationInsigniaEntity.madeira:
        return '🪵';
      case ProcrastinationInsigniaEntity.ferro:
        return '🥈';
      case ProcrastinationInsigniaEntity.aluminio:
        return '🥈';
      case ProcrastinationInsigniaEntity.latao:
        return '🥇';
      case ProcrastinationInsigniaEntity.bronze:
        return '🥉';
      case ProcrastinationInsigniaEntity.prata:
        return '🥈';
      case ProcrastinationInsigniaEntity.ouro:
        return '🥇';
      case ProcrastinationInsigniaEntity.diamante:
        return '💎';
      case ProcrastinationInsigniaEntity.disciplinum:
        return '🏆';
    }
  }

  /// Obtém a categoria da insígnia
  String get category {
    switch (this) {
      case ProcrastinationInsigniaEntity.madeira:
        return 'Inicial';
      case ProcrastinationInsigniaEntity.ferro:
      case ProcrastinationInsigniaEntity.aluminio:
        return 'Básica';
      case ProcrastinationInsigniaEntity.latao:
      case ProcrastinationInsigniaEntity.bronze:
        return 'Intermediária';
      case ProcrastinationInsigniaEntity.prata:
      case ProcrastinationInsigniaEntity.ouro:
        return 'Avançada';
      case ProcrastinationInsigniaEntity.diamante:
      case ProcrastinationInsigniaEntity.disciplinum:
        return 'Máxima';
    }
  }

  /// Verifica se a insígnia é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta insígnia
  String get themeColor {
    switch (this) {
      case ProcrastinationInsigniaEntity.madeira:
        return '#8B4513'; // Marrom
      case ProcrastinationInsigniaEntity.ferro:
        return '#B87333'; // Bronze escuro
      case ProcrastinationInsigniaEntity.aluminio:
        return '#C0C0C0'; // Prata
      case ProcrastinationInsigniaEntity.latao:
        return '#B87333'; // Latão
      case ProcrastinationInsigniaEntity.bronze:
        return '#CD7F32'; // Bronze
      case ProcrastinationInsigniaEntity.prata:
        return '#C0C0C0'; // Prata
      case ProcrastinationInsigniaEntity.ouro:
        return '#FFD700'; // Dourado
      case ProcrastinationInsigniaEntity.diamante:
        return '#B9F2FF'; // Azul claro
      case ProcrastinationInsigniaEntity.disciplinum:
        return '#FF6B6B'; // Vermelho suave
    }
  }
}
