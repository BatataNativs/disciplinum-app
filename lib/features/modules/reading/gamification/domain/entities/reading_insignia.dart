/// Entidade de insígnias específicas do módulo Reading
/// Baseada em progresso de leitura (páginas/livros)
enum ReadingInsigniaEntity {
  madeira,    // Apenas por configurar e ativar o módulo
  ferro,      // 2% lido do primeiro livro
  aluminio,   // 5% lido do primeiro livro
  latao,      // 10% lido do primeiro livro
  bronze,     // 50% de um livro concluído
  prata,      // 80% livro concluído
  ouro,       // 1 livro concluído
  diamante,   // 2 livros concluídos
  disciplinum; // 3 livros concluídos
}

extension ReadingInsigniaEntityExtension on ReadingInsigniaEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case ReadingInsigniaEntity.madeira:
        return 'madeira';
      case ReadingInsigniaEntity.ferro:
        return 'ferro';
      case ReadingInsigniaEntity.aluminio:
        return 'aluminio';
      case ReadingInsigniaEntity.latao:
        return 'latao';
      case ReadingInsigniaEntity.bronze:
        return 'bronze';
      case ReadingInsigniaEntity.prata:
        return 'prata';
      case ReadingInsigniaEntity.ouro:
        return 'ouro';
      case ReadingInsigniaEntity.diamante:
        return 'diamante';
      case ReadingInsigniaEntity.disciplinum:
        return 'disciplinum';
    }
  }

  /// Verifica se esta é a insígnia Disciplinum
  bool get isDisciplinum => this == ReadingInsigniaEntity.disciplinum;

  /// Verifica se esta é a insígnia inicial (Madeira)
  bool get isInitial => this == ReadingInsigniaEntity.madeira;

  /// Obtém o progresso percentual até esta insígnia
  double get progressPercentage {
    switch (this) {
      case ReadingInsigniaEntity.madeira:
        return 0.0;
      case ReadingInsigniaEntity.ferro:
        return 2.0; // 2%
      case ReadingInsigniaEntity.aluminio:
        return 5.0; // 5%
      case ReadingInsigniaEntity.latao:
        return 10.0; // 10%
      case ReadingInsigniaEntity.bronze:
        return 25.0; // 50% livro
      case ReadingInsigniaEntity.prata:
        return 40.0; // 80% livro
      case ReadingInsigniaEntity.ouro:
        return 60.0; // 1 livro
      case ReadingInsigniaEntity.diamante:
        return 80.0; // 2 livros
      case ReadingInsigniaEntity.disciplinum:
        return 100.0; // 3 livros
    }
  }

  /// Obtém a descrição do requisito em percentual/livros
  String get requirementDescription {
    switch (this) {
      case ReadingInsigniaEntity.madeira:
        return 'Ative o módulo Leitura';
      case ReadingInsigniaEntity.ferro:
        return '2% lido do primeiro livro';
      case ReadingInsigniaEntity.aluminio:
        return '5% lido do primeiro livro';
      case ReadingInsigniaEntity.latao:
        return '10% lido do primeiro livro';
      case ReadingInsigniaEntity.bronze:
        return '50% de um livro concluído';
      case ReadingInsigniaEntity.prata:
        return '80% livro concluído';
      case ReadingInsigniaEntity.ouro:
        return '1 livro concluído';
      case ReadingInsigniaEntity.diamante:
        return '2 livros concluídos';
      case ReadingInsigniaEntity.disciplinum:
        return '3 livros concluídos';
    }
  }

  /// Obtém a descrição do benefício
  String get benefitDescription {
    switch (this) {
      case ReadingInsigniaEntity.madeira:
        return 'Módulo configurado e ativado';
      case ReadingInsigniaEntity.ferro:
        return 'Primeiros passos na leitura!';
      case ReadingInsigniaEntity.aluminio:
        return 'Progresso inicial contínuo!';
      case ReadingInsigniaEntity.latao:
        return 'Bom avanço no primeiro livro!';
      case ReadingInsigniaEntity.bronze:
        return 'Metade do caminho percorrida!';
      case ReadingInsigniaEntity.prata:
        return 'Quase terminando o livro!';
      case ReadingInsigniaEntity.ouro:
        return 'Primeiro livro concluído!';
      case ReadingInsigniaEntity.diamante:
        return 'Dois livros concluídos!';
      case ReadingInsigniaEntity.disciplinum:
        return 'Três livros concluídos!';
    }
  }

  /// Obtém o nome em português
  String get nameBr {
    switch (this) {
      case ReadingInsigniaEntity.madeira:
        return 'Madeira';
      case ReadingInsigniaEntity.ferro:
        return 'Ferro';
      case ReadingInsigniaEntity.aluminio:
        return 'Alumínio';
      case ReadingInsigniaEntity.latao:
        return 'Latão';
      case ReadingInsigniaEntity.bronze:
        return 'Bronze';
      case ReadingInsigniaEntity.prata:
        return 'Prata';
      case ReadingInsigniaEntity.ouro:
        return 'Ouro';
      case ReadingInsigniaEntity.diamante:
        return 'Diamante';
      case ReadingInsigniaEntity.disciplinum:
        return 'Disciplinum';
    }
  }

  /// Obtém o caminho do asset
  String get asset {
    const prefix = 'assets/gamification/insignias/reading/';
    switch (this) {
      case ReadingInsigniaEntity.madeira:
        return '${prefix}madeira.png';
      case ReadingInsigniaEntity.ferro:
        return '${prefix}ferro.png';
      case ReadingInsigniaEntity.aluminio:
        return '${prefix}aluminio.png';
      case ReadingInsigniaEntity.latao:
        return '${prefix}latao.png';
      case ReadingInsigniaEntity.bronze:
        return '${prefix}bronze.png';
      case ReadingInsigniaEntity.prata:
        return '${prefix}prata.png';
      case ReadingInsigniaEntity.ouro:
        return '${prefix}ouro.png';
      case ReadingInsigniaEntity.diamante:
        return '${prefix}diamante.png';
      case ReadingInsigniaEntity.disciplinum:
        return '${prefix}disciplinum.png';
    }
  }

  /// Obtém o emoji correspondente
  String get emoji {
    switch (this) {
      case ReadingInsigniaEntity.madeira:
        return '🪵';
      case ReadingInsigniaEntity.ferro:
        return '🥈';
      case ReadingInsigniaEntity.aluminio:
        return '🥈';
      case ReadingInsigniaEntity.latao:
        return '🥇';
      case ReadingInsigniaEntity.bronze:
        return '🥉';
      case ReadingInsigniaEntity.prata:
        return '🥈';
      case ReadingInsigniaEntity.ouro:
        return '🥇';
      case ReadingInsigniaEntity.diamante:
        return '💎';
      case ReadingInsigniaEntity.disciplinum:
        return '🏆';
    }
  }

  /// Obtém a categoria da insígnia
  String get category {
    switch (this) {
      case ReadingInsigniaEntity.madeira:
        return 'Inicial';
      case ReadingInsigniaEntity.ferro:
      case ReadingInsigniaEntity.aluminio:
        return 'Básica';
      case ReadingInsigniaEntity.latao:
      case ReadingInsigniaEntity.bronze:
        return 'Intermediária';
      case ReadingInsigniaEntity.prata:
      case ReadingInsigniaEntity.ouro:
        return 'Avançada';
      case ReadingInsigniaEntity.diamante:
      case ReadingInsigniaEntity.disciplinum:
        return 'Máxima';
    }
  }

  /// Verifica se a insígnia é de categoria máxima
  bool get isMaximumCategory => category == 'Máxima';

  /// Obtém a cor do tema para esta insígnia
  String get themeColor {
    switch (this) {
      case ReadingInsigniaEntity.madeira:
        return '#8B4513'; // Marrom
      case ReadingInsigniaEntity.ferro:
        return '#B87333'; // Bronze escuro
      case ReadingInsigniaEntity.aluminio:
        return '#C0C0C0'; // Prata
      case ReadingInsigniaEntity.latao:
        return '#B87333'; // Latão
      case ReadingInsigniaEntity.bronze:
        return '#CD7F32'; // Bronze
      case ReadingInsigniaEntity.prata:
        return '#C0C0C0'; // Prata
      case ReadingInsigniaEntity.ouro:
        return '#FFD700'; // Dourado
      case ReadingInsigniaEntity.diamante:
        return '#B9F2FF'; // Azul claro
      case ReadingInsigniaEntity.disciplinum:
        return '#FF6B6B'; // Vermelho suave
    }
  }

  /// Verifica se a insígnia pode ser concedida baseada no progresso
  bool canBeAwarded({
    required int currentPage,
    required int totalPagesFirstBook,
    required int completedBooks,
  }) {
    switch (this) {
      case ReadingInsigniaEntity.madeira:
        return true; // Ganha ao ativar
      case ReadingInsigniaEntity.ferro:
        return totalPagesFirstBook > 0 && (currentPage / totalPagesFirstBook * 100) >= 2;
      case ReadingInsigniaEntity.aluminio:
        return totalPagesFirstBook > 0 && (currentPage / totalPagesFirstBook * 100) >= 5;
      case ReadingInsigniaEntity.latao:
        return totalPagesFirstBook > 0 && (currentPage / totalPagesFirstBook * 100) >= 10;
      case ReadingInsigniaEntity.bronze:
        return totalPagesFirstBook > 0 && (currentPage / totalPagesFirstBook * 100) >= 50;
      case ReadingInsigniaEntity.prata:
        return totalPagesFirstBook > 0 && (currentPage / totalPagesFirstBook * 100) >= 80;
      case ReadingInsigniaEntity.ouro:
        return completedBooks >= 1;
      case ReadingInsigniaEntity.diamante:
        return completedBooks >= 2;
      case ReadingInsigniaEntity.disciplinum:
        return completedBooks >= 3;
    }
  }
}
