/// Entidade de insígnias específicas do módulo Adult Content
/// Baseada em dias consecutivos com check-ins positivos
enum AdultContentInsigniaEntity {
  madeira,    // Apenas por configurar e ativar o módulo
  ferro,      // 1 dia com check-in positivo
  aluminio,   // 2 dias com check-in positivo
  latao,      // 3 dias com check-in positivo
  bronze,     // 5 dias com check-in positivo
  prata,      // 10 dias com check-in positivo
  ouro,       // 15 dias com check-in positivo
  diamante,   // 20 dias com check-in positivo
  disciplinum; // 30 dias com check-in positivo
}

extension AdultContentInsigniaEntityExtension on AdultContentInsigniaEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case AdultContentInsigniaEntity.madeira:
        return 'madeira';
      case AdultContentInsigniaEntity.ferro:
        return 'ferro';
      case AdultContentInsigniaEntity.aluminio:
        return 'aluminio';
      case AdultContentInsigniaEntity.latao:
        return 'latao';
      case AdultContentInsigniaEntity.bronze:
        return 'bronze';
      case AdultContentInsigniaEntity.prata:
        return 'prata';
      case AdultContentInsigniaEntity.ouro:
        return 'ouro';
      case AdultContentInsigniaEntity.diamante:
        return 'diamante';
      case AdultContentInsigniaEntity.disciplinum:
        return 'disciplinum';
    }
  }

  /// Verifica se esta é a insígnia Disciplinum
  bool get isDisciplinum => this == AdultContentInsigniaEntity.disciplinum;

  /// Verifica se esta é a insígnia inicial (Madeira)
  bool get isInitial => this == AdultContentInsigniaEntity.madeira;

  /// Obtém o progresso percentual até esta insígnia
  double get progressPercentage {
    switch (this) {
      case AdultContentInsigniaEntity.madeira:
        return 0.0;
      case AdultContentInsigniaEntity.ferro:
        return 3.33; // 1/30
      case AdultContentInsigniaEntity.aluminio:
        return 6.67; // 2/30
      case AdultContentInsigniaEntity.latao:
        return 10.0; // 3/30
      case AdultContentInsigniaEntity.bronze:
        return 16.67; // 5/30
      case AdultContentInsigniaEntity.prata:
        return 33.33; // 10/30
      case AdultContentInsigniaEntity.ouro:
        return 50.0; // 15/30
      case AdultContentInsigniaEntity.diamante:
        return 66.67; // 20/30
      case AdultContentInsigniaEntity.disciplinum:
        return 100.0; // 30/30
    }
  }

  /// Obtém os dias necessários para esta insígnia
  int get requiredDays {
    switch (this) {
      case AdultContentInsigniaEntity.madeira:
        return 0; // Ganha ao configurar e ativar o módulo
      case AdultContentInsigniaEntity.ferro:
        return 1; // 1 dia com check-in positivo
      case AdultContentInsigniaEntity.aluminio:
        return 2; // 2 dias com check-in positivo
      case AdultContentInsigniaEntity.latao:
        return 3; // 3 dias com check-in positivo
      case AdultContentInsigniaEntity.bronze:
        return 5; // 5 dias com check-in positivo
      case AdultContentInsigniaEntity.prata:
        return 10; // 10 dias com check-in positivo
      case AdultContentInsigniaEntity.ouro:
        return 15; // 15 dias com check-in positivo
      case AdultContentInsigniaEntity.diamante:
        return 20; // 20 dias com check-in positivo
      case AdultContentInsigniaEntity.disciplinum:
        return 30; // 30 dias com check-in positivo
    }
  }

  /// Obtém a descrição do benefício
  String get benefitDescription {
    switch (this) {
      case AdultContentInsigniaEntity.madeira:
        return 'Módulo configurado e ativado';
      case AdultContentInsigniaEntity.ferro:
        return '1 dia com check-in positivo';
      case AdultContentInsigniaEntity.aluminio:
        return '2 dias com check-in positivo';
      case AdultContentInsigniaEntity.latao:
        return '3 dias com check-in positivo';
      case AdultContentInsigniaEntity.bronze:
        return '5 dias com check-in positivo';
      case AdultContentInsigniaEntity.prata:
        return '10 dias com check-in positivo';
      case AdultContentInsigniaEntity.ouro:
        return '15 dias com check-in positivo';
      case AdultContentInsigniaEntity.diamante:
        return '20 dias com check-in positivo';
      case AdultContentInsigniaEntity.disciplinum:
        return '30 dias com check-in positivo';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case AdultContentInsigniaEntity.madeira:
        return 'Madeira';
      case AdultContentInsigniaEntity.ferro:
        return 'Ferro';
      case AdultContentInsigniaEntity.aluminio:
        return 'Alumínio';
      case AdultContentInsigniaEntity.latao:
        return 'Latão';
      case AdultContentInsigniaEntity.bronze:
        return 'Bronze';
      case AdultContentInsigniaEntity.prata:
        return 'Prata';
      case AdultContentInsigniaEntity.ouro:
        return 'Ouro';
      case AdultContentInsigniaEntity.diamante:
        return 'Diamante';
      case AdultContentInsigniaEntity.disciplinum:
        return 'Disciplinum';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/insignias/adultContent/';
    switch (this) {
      case AdultContentInsigniaEntity.madeira:
        return '${prefix}madeira.png';
      case AdultContentInsigniaEntity.ferro:
        return '${prefix}ferro.png';
      case AdultContentInsigniaEntity.aluminio:
        return '${prefix}aluminio.png';
      case AdultContentInsigniaEntity.latao:
        return '${prefix}latao.png';
      case AdultContentInsigniaEntity.bronze:
        return '${prefix}bronze.png';
      case AdultContentInsigniaEntity.prata:
        return '${prefix}prata.png';
      case AdultContentInsigniaEntity.ouro:
        return '${prefix}ouro.png';
      case AdultContentInsigniaEntity.diamante:
        return '${prefix}diamante.png';
      case AdultContentInsigniaEntity.disciplinum:
        return '${prefix}disciplinum.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case AdultContentInsigniaEntity.madeira:
        return 'Ative o módulo Evitar Conteúdo Adulto';
      case AdultContentInsigniaEntity.ferro:
        return '1 dia sem acessar conteúdo adulto';
      case AdultContentInsigniaEntity.aluminio:
        return '2 dias sem acessar conteúdo adulto';
      case AdultContentInsigniaEntity.latao:
        return '3 dias sem acessar conteúdo adulto';
      case AdultContentInsigniaEntity.bronze:
        return '5 dias sem acessar conteúdo adulto';
      case AdultContentInsigniaEntity.prata:
        return '10 dias sem acessar conteúdo adulto';
      case AdultContentInsigniaEntity.ouro:
        return '15 dias sem acessar conteúdo adulto';
      case AdultContentInsigniaEntity.diamante:
        return '20 dias sem acessar conteúdo adulto';
      case AdultContentInsigniaEntity.disciplinum:
        return '30 dias sem acessar conteúdo adulto';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case AdultContentInsigniaEntity.madeira:
        return '🪵';
      case AdultContentInsigniaEntity.ferro:
        return '🥈';
      case AdultContentInsigniaEntity.aluminio:
        return '🥈';
      case AdultContentInsigniaEntity.latao:
        return '🥇';
      case AdultContentInsigniaEntity.bronze:
        return '🥉';
      case AdultContentInsigniaEntity.prata:
        return '🥈';
      case AdultContentInsigniaEntity.ouro:
        return '🥇';
      case AdultContentInsigniaEntity.diamante:
        return '💎';
      case AdultContentInsigniaEntity.disciplinum:
        return '🏆';
    }
  }

  /// Obtém a categoria da insígnia
  String get category {
    switch (this) {
      case AdultContentInsigniaEntity.madeira:
        return 'Inicial';
      case AdultContentInsigniaEntity.ferro:
      case AdultContentInsigniaEntity.aluminio:
        return 'Básica';
      case AdultContentInsigniaEntity.latao:
      case AdultContentInsigniaEntity.bronze:
        return 'Intermediária';
      case AdultContentInsigniaEntity.prata:
      case AdultContentInsigniaEntity.ouro:
        return 'Avançada';
      case AdultContentInsigniaEntity.diamante:
      case AdultContentInsigniaEntity.disciplinum:
        return 'Máxima';
    }
  }

  /// Verifica se a insígnia é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta insígnia
  String get themeColor {
    switch (this) {
      case AdultContentInsigniaEntity.madeira:
        return '#8B4513'; // Marrom
      case AdultContentInsigniaEntity.ferro:
        return '#B87333'; // Bronze escuro
      case AdultContentInsigniaEntity.aluminio:
        return '#C0C0C0'; // Prata
      case AdultContentInsigniaEntity.latao:
        return '#B87333'; // Latão
      case AdultContentInsigniaEntity.bronze:
        return '#CD7F32'; // Bronze
      case AdultContentInsigniaEntity.prata:
        return '#C0C0C0'; // Prata
      case AdultContentInsigniaEntity.ouro:
        return '#FFD700'; // Dourado
      case AdultContentInsigniaEntity.diamante:
        return '#B9F2FF'; // Azul claro
      case AdultContentInsigniaEntity.disciplinum:
        return '#FF6B6B'; // Vermelho suave
    }
  }
}
