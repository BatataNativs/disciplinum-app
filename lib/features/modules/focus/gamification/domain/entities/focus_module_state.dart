/// Estado completo da gamificação do módulo Focus
class FocusModuleState {
  final List<String> earnedInsignias;
  final List<String> earnedMedalhas;
  final int respectedPeriods;
  final DateTime lastUpdated;
  final bool isActive;

  const FocusModuleState({
    this.earnedInsignias = const [],
    this.earnedMedalhas = const [],
    this.respectedPeriods = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

  /// Cria estado inicial ao ativar o módulo
  factory FocusModuleState.initial() {
    return FocusModuleState(
      earnedInsignias: ['madeira'], // Ganha Madeira automaticamente
      lastUpdated: DateTime.now(),
    );
  }

  /// Cria estado zerado (reset completo)
  factory FocusModuleState.reset() {
    return FocusModuleState(
      earnedInsignias: ['madeira'], // Mantém apenas Madeira
      earnedMedalhas: [], // Perde todas as medalhas
      respectedPeriods: 0,
      lastUpdated: DateTime.now(),
      isActive: false,
    );
  }

  /// Cria cópia com valores atualizados
  FocusModuleState copyWith({
    List<String>? earnedInsignias,
    List<String>? earnedMedalhas,
    int? respectedPeriods,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return FocusModuleState(
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      earnedMedalhas: earnedMedalhas ?? this.earnedMedalhas,
      respectedPeriods: respectedPeriods ?? this.respectedPeriods,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Verifica se tem insígnia específica
  bool hasInsignia(String insigniaId) {
    return earnedInsignias.contains(insigniaId);
  }

  /// Verifica se tem medalha específica
  bool hasMedalha(String medalhaId) {
    return earnedMedalhas.contains(medalhaId);
  }

  /// Conta quantas insígnias Disciplinum foram conquistadas
  int get disciplinumCount {
    return earnedInsignias.where((id) => id == 'disciplinum').length;
  }

  /// Verifica se pode conceder nova insígnia com base nos períodos
  String? get nextInsignia {
    if (respectedPeriods >= 10 && !hasInsignia('disciplinum')) {
      return 'disciplinum';
    } else if (respectedPeriods >= 9 && !hasInsignia('diamante')) {
      return 'diamante';
    } else if (respectedPeriods >= 6 && !hasInsignia('ouro')) {
      return 'ouro';
    } else if (respectedPeriods >= 5 && !hasInsignia('prata')) {
      return 'prata';
    } else if (respectedPeriods >= 4 && !hasInsignia('bronze')) {
      return 'bronze';
    } else if (respectedPeriods >= 3 && !hasInsignia('latao')) {
      return 'latao';
    } else if (respectedPeriods >= 2 && !hasInsignia('aluminio')) {
      return 'aluminio';
    } else if (respectedPeriods >= 1 && !hasInsignia('ferro')) {
      return 'ferro';
    }
    return null;
  }

  /// Converte para JSON para persistência
  Map<String, dynamic> toJson() {
    return {
      'earnedInsignias': earnedInsignias,
      'earnedMedalhas': earnedMedalhas,
      'respectedPeriods': respectedPeriods,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Cria estado a partir de JSON
  factory FocusModuleState.fromJson(Map<String, dynamic> json) {
    return FocusModuleState(
      earnedInsignias: List<String>.from(json['earnedInsignias'] ?? []),
      earnedMedalhas: List<String>.from(json['earnedMedalhas'] ?? []),
      respectedPeriods: json['respectedPeriods'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isActive: json['isActive'] ?? true,
    );
  }
}
