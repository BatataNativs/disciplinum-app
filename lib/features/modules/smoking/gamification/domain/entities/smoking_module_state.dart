/// Entidade de estado do módulo Smoking para gamificação
/// Contém informações sobre conquistas e progresso
class SmokingModuleState {
  /// Lista de insígnias conquistadas
  final List<String> _earnedInsignias = [];
  
  /// Lista de medalhas conquistadas
  final List<String> _earnedMedalhas = [];
  
  /// Dias consecutivos com check-in positivo
  int consecutivePositiveDays = 0;
  
  /// Contador de insígnias Disciplinum conquistadas
  int disciplinumCount = 0;
  
  /// Data do último check-in positivo
  DateTime? lastPositiveCheckIn;
  
  /// Data de início da jornada sem fumar
  DateTime? startDate;
  
  /// Valor diário economizado (configurado pelo usuário)
  double dailyCost = 0.0;
  
  /// Valor de um maço de cigarros (configurado pelo usuário)
  double packCost = 0.0;

  /// Construtor padrão
  SmokingModuleState();

  /// Construtor a partir de JSON
  SmokingModuleState.fromJson(Map<String, dynamic> json)
      : consecutivePositiveDays = json['consecutivePositiveDays'] ?? 0,
        disciplinumCount = json['disciplinumCount'] ?? 0,
        dailyCost = (json['dailyCost'] ?? 0.0).toDouble(),
        packCost = (json['packCost'] ?? 0.0).toDouble(),
        lastPositiveCheckIn = json['lastPositiveCheckIn'] != null
            ? DateTime.parse(json['lastPositiveCheckIn'])
            : null,
        startDate = json['startDate'] != null
            ? DateTime.parse(json['startDate'])
            : null {
    _earnedInsignias.addAll(List<String>.from(json['earnedInsignias'] ?? []));
    _earnedMedalhas.addAll(List<String>.from(json['earnedMedalhas'] ?? []));
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'earnedInsignias': _earnedInsignias,
      'earnedMedalhas': _earnedMedalhas,
      'consecutivePositiveDays': consecutivePositiveDays,
      'disciplinumCount': disciplinumCount,
      'lastPositiveCheckIn': lastPositiveCheckIn?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'dailyCost': dailyCost,
      'packCost': packCost,
    };
  }

  /// Copia o estado com alterações
  SmokingModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? consecutivePositiveDays,
    int? disciplinumCount,
    DateTime? lastPositiveCheckIn,
    DateTime? startDate,
    double? dailyCost,
    double? packCost,
  }) {
    final newState = SmokingModuleState();
    newState._earnedInsignias.addAll(earnedInsignias ?? _earnedInsignias);
    newState._earnedMedalhas.addAll(earnedMedalhas ?? _earnedMedalhas);
    newState.consecutivePositiveDays = consecutivePositiveDays ?? this.consecutivePositiveDays;
    newState.disciplinumCount = disciplinumCount ?? this.disciplinumCount;
    newState.lastPositiveCheckIn = lastPositiveCheckIn ?? this.lastPositiveCheckIn;
    newState.startDate = startDate ?? this.startDate;
    newState.dailyCost = dailyCost ?? this.dailyCost;
    newState.packCost = packCost ?? this.packCost;
    return newState;
  }

  /// Obtém lista de insígnias conquistadas (somente leitura)
  List<String> get earnedInsignias => List.unmodifiable(_earnedInsignias);

  /// Obtém lista de medalhas conquistadas (somente leitura)
  List<String> get earnedMedalhas => List.unmodifiable(_earnedMedalhas);

  /// Verifica se tem uma insígnia específica
  bool hasInsignia(String insigniaId) {
    return _earnedInsignias.contains(insigniaId);
  }

  /// Verifica se tem uma medalha específica
  bool hasMedalha(String medalhaId) {
    return _earnedMedalhas.contains(medalhaId);
  }

  /// Concede uma insígnia
  void awardInsignia(String insigniaId) {
    if (!_earnedInsignias.contains(insigniaId)) {
      _earnedInsignias.add(insigniaId);
      
      // Se for insígnia Disciplinum, incrementa contador
      if (insigniaId == 'disciplinum') {
        disciplinumCount++;
      }
    }
  }

  /// Revoga uma insígnia
  void revokeInsignia(String insigniaId) {
    _earnedInsignias.remove(insigniaId);
    
    // Se for insígnia Disciplinum, decrementa contador
    if (insigniaId == 'disciplinum' && disciplinumCount > 0) {
      disciplinumCount--;
    }
  }

  /// Concede uma medalha
  void awardMedalha(String medalhaId) {
    if (!_earnedMedalhas.contains(medalhaId)) {
      _earnedMedalhas.add(medalhaId);
    }
  }

  /// Revoga uma medalha
  void revokeMedalha(String medalhaId) {
    _earnedMedalhas.remove(medalhaId);
  }

  /// Reseta todo o progresso
  void reset() {
    _earnedInsignias.clear();
    _earnedMedalhas.clear();
    consecutivePositiveDays = 0;
    disciplinumCount = 0;
    lastPositiveCheckIn = null;
    startDate = null;
  }

  /// Reseta apenas as insígnias
  void resetInsignias() {
    _earnedInsignias.clear();
    disciplinumCount = 0;
  }

  /// Reseta apenas as medalhas
  void resetMedalhas() {
    _earnedMedalhas.clear();
  }

  /// Calcula o total de dias sem fumar
  int getTotalDaysWithoutSmoking() {
    if (startDate == null) return 0;
    return DateTime.now().difference(startDate!).inDays;
  }

  /// Calcula o dinheiro total economizado
  double getTotalMoneySaved() {
    return dailyCost * consecutivePositiveDays;
  }

  /// Calcula o número de maços economizados
  int getPacksSaved() {
    if (packCost <= 0) return 0;
    return (getTotalMoneySaved() / packCost).floor();
  }

  /// Verifica se está em streak (consecutivo)
  bool get isInStreak => consecutivePositiveDays > 0;

  /// Verifica se o streak é significativo
  bool get hasSignificantStreak => consecutivePositiveDays >= 7;

  /// Obtém o nível do usuário baseado nas conquistas
  String getUserLevel() {
    if (disciplinumCount >= 4) return 'Mestre';
    if (disciplinumCount >= 3) return 'Expert';
    if (disciplinumCount >= 2) return 'Avançado';
    if (disciplinumCount >= 1) return 'Intermediário';
    if (consecutivePositiveDays >= 10) return 'Dedicado';
    if (consecutivePositiveDays >= 5) return 'Iniciante';
    return 'Novato';
  }

  /// Obtém a cor do tema baseada no nível
  String getLevelColor() {
    switch (getUserLevel()) {
      case 'Mestre':
        return '#FFD700'; // Dourado
      case 'Expert':
        return '#9C27B0'; // Roxo
      case 'Avançado':
        return '#2196F3'; // Azul
      case 'Intermediário':
        return '#4CAF50'; // Verde
      case 'Dedicado':
        return '#FF9800'; // Laranja
      case 'Iniciante':
        return '#607D8B'; // Azul acinzentado
      default:
        return '#9E9E9E'; // Cinza
    }
  }

  /// Verifica se há conquistas recentes (últimos 7 dias)
  bool hasRecentAchievements() {
    if (lastPositiveCheckIn == null) return false;
    final daysSinceLastCheckIn = DateTime.now().difference(lastPositiveCheckIn!).inDays;
    return daysSinceLastCheckIn <= 7;
  }

  /// Obtém estatísticas completas
  Map<String, dynamic> getStatistics() {
    return {
      'consecutiveDays': consecutivePositiveDays,
      'totalDays': getTotalDaysWithoutSmoking(),
      'totalInsignias': _earnedInsignias.length,
      'totalMedalhas': _earnedMedalhas.length,
      'disciplinumCount': disciplinumCount,
      'moneySaved': getTotalMoneySaved(),
      'packsSaved': getPacksSaved(),
      'userLevel': getUserLevel(),
      'levelColor': getLevelColor(),
      'isInStreak': isInStreak,
      'hasSignificantStreak': hasSignificantStreak,
      'hasRecentAchievements': hasRecentAchievements(),
      'startDate': startDate?.toIso8601String(),
      'lastCheckIn': lastPositiveCheckIn?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SmokingModuleState('
        'consecutiveDays: $consecutivePositiveDays, '
        'insignias: ${_earnedInsignias.length}, '
        'medalhas: ${_earnedMedalhas.length}, '
        'disciplinum: $disciplinumCount, '
        'level: ${getUserLevel()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmokingModuleState &&
        other.consecutivePositiveDays == consecutivePositiveDays &&
        other.disciplinumCount == disciplinumCount &&
        other.dailyCost == dailyCost &&
        other.packCost == packCost &&
        other.lastPositiveCheckIn == lastPositiveCheckIn &&
        other.startDate == startDate &&
        _earnedInsignias.length == other._earnedInsignias.length &&
        _earnedMedalhas.length == other._earnedMedalhas.length;
  }

  @override
  int get hashCode {
    return consecutivePositiveDays.hashCode ^
        disciplinumCount.hashCode ^
        dailyCost.hashCode ^
        packCost.hashCode ^
        lastPositiveCheckIn.hashCode ^
        startDate.hashCode ^
        _earnedInsignias.length.hashCode ^
        _earnedMedalhas.length.hashCode;
  }
}
