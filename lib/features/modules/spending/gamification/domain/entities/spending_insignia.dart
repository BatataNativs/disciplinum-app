/// Entidade de insígnias específicas do módulo Spending
/// Baseada em meses consecutivos com todas as contas pagas
enum SpendingInsigniaEntity {
  madeira,    // Apenas por configurar e ativar o módulo
  ferro,      // 1 mês com todas as contas pagas
  aluminio,   // 2 meses com todas as contas pagas
  latao,      // 3 meses com todas as contas pagas
  bronze,     // 4 meses com todas as contas pagas
  prata,      // 6 meses com todas as contas pagas
  ouro,       // 8 meses com todas as contas pagas
  diamante,   // 10 meses com todas as contas pagas
  disciplinum; // 12 meses com todas as contas pagas
}

extension SpendingInsigniaEntityExtension on SpendingInsigniaEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case SpendingInsigniaEntity.madeira:
        return 'madeira';
      case SpendingInsigniaEntity.ferro:
        return 'ferro';
      case SpendingInsigniaEntity.aluminio:
        return 'aluminio';
      case SpendingInsigniaEntity.latao:
        return 'latao';
      case SpendingInsigniaEntity.bronze:
        return 'bronze';
      case SpendingInsigniaEntity.prata:
        return 'prata';
      case SpendingInsigniaEntity.ouro:
        return 'ouro';
      case SpendingInsigniaEntity.diamante:
        return 'diamante';
      case SpendingInsigniaEntity.disciplinum:
        return 'disciplinum';
    }
  }

  /// Verifica se esta é a insígnia Disciplinum
  bool get isDisciplinum => this == SpendingInsigniaEntity.disciplinum;

  /// Verifica se esta é a insígnia inicial (Madeira)
  bool get isInitial => this == SpendingInsigniaEntity.madeira;

  /// Obtém o progresso percentual até esta insígnia
  double get progressPercentage {
    switch (this) {
      case SpendingInsigniaEntity.madeira:
        return 0.0;
      case SpendingInsigniaEntity.ferro:
        return 8.33; // 1/12
      case SpendingInsigniaEntity.aluminio:
        return 16.67; // 2/12
      case SpendingInsigniaEntity.latao:
        return 25.0; // 3/12
      case SpendingInsigniaEntity.bronze:
        return 33.33; // 4/12
      case SpendingInsigniaEntity.prata:
        return 50.0; // 6/12
      case SpendingInsigniaEntity.ouro:
        return 66.67; // 8/12
      case SpendingInsigniaEntity.diamante:
        return 83.33; // 10/12
      case SpendingInsigniaEntity.disciplinum:
        return 100.0; // 12/12
    }
  }

  /// Obtém os meses necessários para esta insígnia
  int get requiredMonths {
    switch (this) {
      case SpendingInsigniaEntity.madeira:
        return 0; // Ganha ao configurar e ativar o módulo
      case SpendingInsigniaEntity.ferro:
        return 1; // 1 mês com todas as contas pagas
      case SpendingInsigniaEntity.aluminio:
        return 2; // 2 meses com todas as contas pagas
      case SpendingInsigniaEntity.latao:
        return 3; // 3 meses com todas as contas pagas
      case SpendingInsigniaEntity.bronze:
        return 4; // 4 meses com todas as contas pagas
      case SpendingInsigniaEntity.prata:
        return 6; // 6 meses com todas as contas pagas
      case SpendingInsigniaEntity.ouro:
        return 8; // 8 meses com todas as contas pagas
      case SpendingInsigniaEntity.diamante:
        return 10; // 10 meses com todas as contas pagas
      case SpendingInsigniaEntity.disciplinum:
        return 12; // 12 meses com todas as contas pagas
    }
  }

  /// Obtém a descrição do benefício
  String get benefitDescription {
    switch (this) {
      case SpendingInsigniaEntity.madeira:
        return 'Módulo configurado e ativado';
      case SpendingInsigniaEntity.ferro:
        return '1 mês com todas as contas pagas';
      case SpendingInsigniaEntity.aluminio:
        return '2 meses com todas as contas pagas';
      case SpendingInsigniaEntity.latao:
        return '3 meses com todas as contas pagas';
      case SpendingInsigniaEntity.bronze:
        return '4 meses com todas as contas pagas';
      case SpendingInsigniaEntity.prata:
        return '6 meses com todas as contas pagas';
      case SpendingInsigniaEntity.ouro:
        return '8 meses com todas as contas pagas';
      case SpendingInsigniaEntity.diamante:
        return '10 meses com todas as contas pagas';
      case SpendingInsigniaEntity.disciplinum:
        return '12 meses com todas as contas pagas';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case SpendingInsigniaEntity.madeira:
        return 'Madeira';
      case SpendingInsigniaEntity.ferro:
        return 'Ferro';
      case SpendingInsigniaEntity.aluminio:
        return 'Alumínio';
      case SpendingInsigniaEntity.latao:
        return 'Latão';
      case SpendingInsigniaEntity.bronze:
        return 'Bronze';
      case SpendingInsigniaEntity.prata:
        return 'Prata';
      case SpendingInsigniaEntity.ouro:
        return 'Ouro';
      case SpendingInsigniaEntity.diamante:
        return 'Diamante';
      case SpendingInsigniaEntity.disciplinum:
        return 'Disciplinum';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/insignias/spending/';
    switch (this) {
      case SpendingInsigniaEntity.madeira:
        return '${prefix}madeira.png';
      case SpendingInsigniaEntity.ferro:
        return '${prefix}ferro.png';
      case SpendingInsigniaEntity.aluminio:
        return '${prefix}aluminio.png';
      case SpendingInsigniaEntity.latao:
        return '${prefix}latao.png';
      case SpendingInsigniaEntity.bronze:
        return '${prefix}bronze.png';
      case SpendingInsigniaEntity.prata:
        return '${prefix}prata.png';
      case SpendingInsigniaEntity.ouro:
        return '${prefix}ouro.png';
      case SpendingInsigniaEntity.diamante:
        return '${prefix}diamante.png';
      case SpendingInsigniaEntity.disciplinum:
        return '${prefix}disciplinum.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case SpendingInsigniaEntity.madeira:
        return 'Ative o módulo Controle de Gastos';
      case SpendingInsigniaEntity.ferro:
        return 'Pague todas as contas por 1 mês';
      case SpendingInsigniaEntity.aluminio:
        return 'Pague todas as contas por 2 meses';
      case SpendingInsigniaEntity.latao:
        return 'Pague todas as contas por 3 meses';
      case SpendingInsigniaEntity.bronze:
        return 'Pague todas as contas por 4 meses';
      case SpendingInsigniaEntity.prata:
        return 'Pague todas as contas por 6 meses';
      case SpendingInsigniaEntity.ouro:
        return 'Pague todas as contas por 8 meses';
      case SpendingInsigniaEntity.diamante:
        return 'Pague todas as contas por 10 meses';
      case SpendingInsigniaEntity.disciplinum:
        return 'Pague todas as contas por 12 meses';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case SpendingInsigniaEntity.madeira:
        return '🪵';
      case SpendingInsigniaEntity.ferro:
        return '🥈';
      case SpendingInsigniaEntity.aluminio:
        return '🥈';
      case SpendingInsigniaEntity.latao:
        return '🥇';
      case SpendingInsigniaEntity.bronze:
        return '🥉';
      case SpendingInsigniaEntity.prata:
        return '🥈';
      case SpendingInsigniaEntity.ouro:
        return '🥇';
      case SpendingInsigniaEntity.diamante:
        return '💎';
      case SpendingInsigniaEntity.disciplinum:
        return '🏆';
    }
  }

  /// Obtém a categoria da insígnia
  String get category {
    switch (this) {
      case SpendingInsigniaEntity.madeira:
        return 'Inicial';
      case SpendingInsigniaEntity.ferro:
      case SpendingInsigniaEntity.aluminio:
        return 'Básica';
      case SpendingInsigniaEntity.latao:
      case SpendingInsigniaEntity.bronze:
        return 'Intermediária';
      case SpendingInsigniaEntity.prata:
      case SpendingInsigniaEntity.ouro:
        return 'Avançada';
      case SpendingInsigniaEntity.diamante:
      case SpendingInsigniaEntity.disciplinum:
        return 'Máxima';
    }
  }

  /// Verifica se a insígnia é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta insígnia
  String get themeColor {
    switch (this) {
      case SpendingInsigniaEntity.madeira:
        return '#8B4513'; // Marrom
      case SpendingInsigniaEntity.ferro:
        return '#B87333'; // Bronze escuro
      case SpendingInsigniaEntity.aluminio:
        return '#C0C0C0'; // Prata
      case SpendingInsigniaEntity.latao:
        return '#B87333'; // Latão
      case SpendingInsigniaEntity.bronze:
        return '#CD7F32'; // Bronze
      case SpendingInsigniaEntity.prata:
        return '#C0C0C0'; // Prata
      case SpendingInsigniaEntity.ouro:
        return '#FFD700'; // Dourado
      case SpendingInsigniaEntity.diamante:
        return '#B9F2FF'; // Azul claro
      case SpendingInsigniaEntity.disciplinum:
        return '#FF6B6B'; // Vermelho suave
    }
  }
}
