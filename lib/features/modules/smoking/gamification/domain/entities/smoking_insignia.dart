/// Entidade de insígnias específicas do módulo Smoking
/// Baseada em check-ins diários positivos consecutivos
enum SmokingInsigniaEntity {
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

extension SmokingInsigniaEntityExtension on SmokingInsigniaEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return 'madeira';
      case SmokingInsigniaEntity.ferro:
        return 'ferro';
      case SmokingInsigniaEntity.aluminio:
        return 'aluminio';
      case SmokingInsigniaEntity.latao:
        return 'latao';
      case SmokingInsigniaEntity.bronze:
        return 'bronze';
      case SmokingInsigniaEntity.prata:
        return 'prata';
      case SmokingInsigniaEntity.ouro:
        return 'ouro';
      case SmokingInsigniaEntity.diamante:
        return 'diamante';
      case SmokingInsigniaEntity.disciplinum:
        return 'disciplinum';
    }
  }

  /// Verifica se esta é a insígnia Disciplinum
  bool get isDisciplinum => this == SmokingInsigniaEntity.disciplinum;

  /// Verifica se esta é a insígnia inicial (Madeira)
  bool get isInitial => this == SmokingInsigniaEntity.madeira;

  /// Obtém o progresso percentual até esta insígnia
  double get progressPercentage {
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return 0.0;
      case SmokingInsigniaEntity.ferro:
        return 10.0;
      case SmokingInsigniaEntity.aluminio:
        return 20.0;
      case SmokingInsigniaEntity.latao:
        return 30.0;
      case SmokingInsigniaEntity.bronze:
        return 40.0;
      case SmokingInsigniaEntity.prata:
        return 50.0;
      case SmokingInsigniaEntity.ouro:
        return 70.0;
      case SmokingInsigniaEntity.diamante:
        return 90.0;
      case SmokingInsigniaEntity.disciplinum:
        return 100.0;
    }
  }

  /// Obtém os dias necessários para esta insígnia (baseado em check-ins positivos consecutivos)
  int get requiredDays {
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return 0; // Ganha ao configurar e ativar o módulo
      case SmokingInsigniaEntity.ferro:
        return 1; // 1 dia com check-in positivo
      case SmokingInsigniaEntity.aluminio:
        return 2; // 2 dias com check-in positivo
      case SmokingInsigniaEntity.latao:
        return 3; // 3 dias com check-in positivo
      case SmokingInsigniaEntity.bronze:
        return 5; // 5 dias com check-in positivo
      case SmokingInsigniaEntity.prata:
        return 10; // 10 dias com check-in positivo
      case SmokingInsigniaEntity.ouro:
        return 15; // 15 dias com check-in positivo
      case SmokingInsigniaEntity.diamante:
        return 20; // 20 dias com check-in positivo
      case SmokingInsigniaEntity.disciplinum:
        return 30; // 30 dias com check-in positivo
    }
  }

  /// Obtém a descrição do benefício de saúde
  String get healthBenefit {
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return 'Módulo configurado e ativado';
      case SmokingInsigniaEntity.ferro:
        return '1 dia com check-in positivo';
      case SmokingInsigniaEntity.aluminio:
        return '2 dias com check-in positivo';
      case SmokingInsigniaEntity.latao:
        return '3 dias com check-in positivo';
      case SmokingInsigniaEntity.bronze:
        return '5 dias com check-in positivo';
      case SmokingInsigniaEntity.prata:
        return '10 dias com check-in positivo';
      case SmokingInsigniaEntity.ouro:
        return '15 dias com check-in positivo';
      case SmokingInsigniaEntity.diamante:
        return '20 dias com check-in positivo';
      case SmokingInsigniaEntity.disciplinum:
        return '30 dias com check-in positivo';
    }
  }

  /// Obtém a descrição do benefício econômico
  String get economicBenefit {
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return 'Comece a economizar desde o primeiro dia!';
      case SmokingInsigniaEntity.ferro:
        return 'Economia de 1 dia: Você já começou a guardar dinheiro!';
      case SmokingInsigniaEntity.aluminio:
        return 'Economia de 3 dias: Dinheiro suficiente para um café!';
      case SmokingInsigniaEntity.latao:
        return 'Economia de 7 dias: Dinheiro para um lanche especial!';
      case SmokingInsigniaEntity.bronze:
        return 'Economia de 14 dias: Valor para um livro ou filme!';
      case SmokingInsigniaEntity.prata:
        return 'Economia de 30 dias: Quantia significativa para seu orçamento!';
      case SmokingInsigniaEntity.ouro:
        return 'Economia de 60 dias: Dinheiro para uma recompensa grande!';
      case SmokingInsigniaEntity.diamante:
        return 'Economia de 90 dias: Valor para uma pequena viagem!';
      case SmokingInsigniaEntity.disciplinum:
        return 'Economia de 120 dias: Economia suficiente para um grande objetivo!';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return 'Madeira';
      case SmokingInsigniaEntity.ferro:
        return 'Ferro';
      case SmokingInsigniaEntity.aluminio:
        return 'Alumínio';
      case SmokingInsigniaEntity.latao:
        return 'Latão';
      case SmokingInsigniaEntity.bronze:
        return 'Bronze';
      case SmokingInsigniaEntity.prata:
        return 'Prata';
      case SmokingInsigniaEntity.ouro:
        return 'Ouro';
      case SmokingInsigniaEntity.diamante:
        return 'Diamante';
      case SmokingInsigniaEntity.disciplinum:
        return 'Disciplinum';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/insignias/smoking/';
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return '${prefix}madeira.png';
      case SmokingInsigniaEntity.ferro:
        return '${prefix}ferro.png';
      case SmokingInsigniaEntity.aluminio:
        return '${prefix}aluminio.png';
      case SmokingInsigniaEntity.latao:
        return '${prefix}latao.png';
      case SmokingInsigniaEntity.bronze:
        return '${prefix}bronze.png';
      case SmokingInsigniaEntity.prata:
        return '${prefix}prata.png';
      case SmokingInsigniaEntity.ouro:
        return '${prefix}ouro.png';
      case SmokingInsigniaEntity.diamante:
        return '${prefix}diamante.png';
      case SmokingInsigniaEntity.disciplinum:
        return '${prefix}disciplinum.png';
    }
  }

  /// Obtém a descrição dos requisitos
  String get requirementDescription {
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return 'Ative o módulo Parar de Fumar';
      case SmokingInsigniaEntity.ferro:
        return '1 dia sem fumar';
      case SmokingInsigniaEntity.aluminio:
        return '2 dias sem fumar';
      case SmokingInsigniaEntity.latao:
        return '3 dias sem fumar';
      case SmokingInsigniaEntity.bronze:
        return '5 dias sem fumar';
      case SmokingInsigniaEntity.prata:
        return '10 dias sem fumar';
      case SmokingInsigniaEntity.ouro:
        return '15 dias sem fumar';
      case SmokingInsigniaEntity.diamante:
        return '20 dias sem fumar';
      case SmokingInsigniaEntity.disciplinum:
        return '30 dias sem fumar';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return '🪵';
      case SmokingInsigniaEntity.ferro:
        return '🥈';
      case SmokingInsigniaEntity.aluminio:
        return '🥈';
      case SmokingInsigniaEntity.latao:
        return '🥇';
      case SmokingInsigniaEntity.bronze:
        return '🥉';
      case SmokingInsigniaEntity.prata:
        return '🥈';
      case SmokingInsigniaEntity.ouro:
        return '🥇';
      case SmokingInsigniaEntity.diamante:
        return '💎';
      case SmokingInsigniaEntity.disciplinum:
        return '🏆';
    }
  }

  /// Obtém a categoria da insígnia
  String get category {
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return 'Inicial';
      case SmokingInsigniaEntity.ferro:
      case SmokingInsigniaEntity.aluminio:
        return 'Básica';
      case SmokingInsigniaEntity.latao:
      case SmokingInsigniaEntity.bronze:
        return 'Intermediária';
      case SmokingInsigniaEntity.prata:
      case SmokingInsigniaEntity.ouro:
        return 'Avançada';
      case SmokingInsigniaEntity.diamante:
      case SmokingInsigniaEntity.disciplinum:
        return 'Máxima';
    }
  }

  /// Verifica se a insígnia é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta insígnia
  String get themeColor {
    switch (this) {
      case SmokingInsigniaEntity.madeira:
        return '#8B4513'; // Marrom
      case SmokingInsigniaEntity.ferro:
        return '#B87333'; // Bronze escuro
      case SmokingInsigniaEntity.aluminio:
        return '#C0C0C0'; // Prata
      case SmokingInsigniaEntity.latao:
        return '#B87333'; // Latão
      case SmokingInsigniaEntity.bronze:
        return '#CD7F32'; // Bronze
      case SmokingInsigniaEntity.prata:
        return '#C0C0C0'; // Prata
      case SmokingInsigniaEntity.ouro:
        return '#FFD700'; // Dourado
      case SmokingInsigniaEntity.diamante:
        return '#B9F2FF'; // Azul claro
      case SmokingInsigniaEntity.disciplinum:
        return '#FF6B6B'; // Vermelho suave
    }
  }
}
