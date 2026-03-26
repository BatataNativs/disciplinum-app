import 'package:isar/isar.dart';
import 'dart:convert';

part 'smoking_gamification_entity.g.dart';

/// Entidade Isar para gamificação do módulo Smoking
/// Armazena estado completo de gamificação com persistência local
@collection
class SmokingGamificationEntity {
  /// ID único do registro
  Id id = Isar.autoIncrement;

  /// Lista de insígnias conquistadas (JSON)
  String earnedInsignias = '[]';

  /// Lista de medalhas conquistadas (JSON)
  String earnedMedalhas = '[]';

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

  /// Data de criação do registro
  DateTime createdAt = DateTime.now();

  /// Data da última atualização
  DateTime updatedAt = DateTime.now();

  /// Construtor padrão
  SmokingGamificationEntity();

  /// Construtor a partir do SmokingModuleState
  factory SmokingGamificationEntity.fromModuleState(dynamic moduleState) {
    final entity = SmokingGamificationEntity();
    // Implementação já está sendo feita no repositório
    return entity;
  }

  /// Converte para JSON (para compatibilidade)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'earnedInsignias': earnedInsignias,
      'earnedMedalhas': earnedMedalhas,
      'consecutivePositiveDays': consecutivePositiveDays,
      'disciplinumCount': disciplinumCount,
      'lastPositiveCheckIn': lastPositiveCheckIn?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'dailyCost': dailyCost,
      'packCost': packCost,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria a partir do JSON
  factory SmokingGamificationEntity.fromJson(Map<String, dynamic> json) {
    final entity = SmokingGamificationEntity();
    
    entity.id = json['id'] ?? Isar.autoIncrement;
    entity.earnedInsignias = json['earnedInsignias'] ?? '[]';
    entity.earnedMedalhas = json['earnedMedalhas'] ?? '[]';
    entity.consecutivePositiveDays = json['consecutivePositiveDays'] ?? 0;
    entity.disciplinumCount = json['disciplinumCount'] ?? 0;
    entity.lastPositiveCheckIn = json['lastPositiveCheckIn'] != null
        ? DateTime.parse(json['lastPositiveCheckIn'])
        : null;
    entity.startDate = json['startDate'] != null
        ? DateTime.parse(json['startDate'])
        : null;
    entity.dailyCost = (json['dailyCost'] ?? 0.0).toDouble();
    entity.packCost = (json['packCost'] ?? 0.0).toDouble();
    entity.createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now();
    entity.updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : DateTime.now();
    
    return entity;
  }

  /// Atualiza timestamp de modificação
  void touch() {
    updatedAt = DateTime.now();
  }

  /// Obtém lista de insígnias como `List<String>`
  List<String> get earnedInsigniasList {
    try {
      final List<dynamic> decoded = json.decode(earnedInsignias);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Define lista de insígnias
  set earnedInsigniasList(List<String> insignias) {
    earnedInsignias = json.encode(insignias);
    touch();
  }

  /// Obtém lista de medalhas como `List<String>`
  List<String> get earnedMedalhasList {
    try {
      final List<dynamic> decoded = json.decode(earnedMedalhas);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Define lista de medalhas
  set earnedMedalhasList(List<String> medalhas) {
    earnedMedalhas = json.encode(medalhas);
    touch();
  }

  /// Verifica se tem uma insígnia específica
  bool hasInsignia(String insigniaId) {
    return earnedInsigniasList.contains(insigniaId);
  }

  /// Adiciona uma insígnia
  void addInsignia(String insigniaId) {
    final list = earnedInsigniasList;
    if (!list.contains(insigniaId)) {
      list.add(insigniaId);
      earnedInsigniasList = list;
      
      // Se for insígnia Disciplinum, incrementa contador
      if (insigniaId == 'disciplinum') {
        disciplinumCount++;
      }
    }
  }

  /// Remove uma insígnia
  void removeInsignia(String insigniaId) {
    final list = earnedInsigniasList;
    list.remove(insigniaId);
    earnedInsigniasList = list;
    
    // Se for insígnia Disciplinum, decrementa contador
    if (insigniaId == 'disciplinum' && disciplinumCount > 0) {
      disciplinumCount--;
    }
  }

  /// Verifica se tem uma medalha específica
  bool hasMedalha(String medalhaId) {
    return earnedMedalhasList.contains(medalhaId);
  }

  /// Adiciona uma medalha
  void addMedalha(String medalhaId) {
    final list = earnedMedalhasList;
    if (!list.contains(medalhaId)) {
      list.add(medalhaId);
      earnedMedalhasList = list;
    }
  }

  /// Remove uma medalha
  void removeMedalha(String medalhaId) {
    final list = earnedMedalhasList;
    list.remove(medalhaId);
    earnedMedalhasList = list;
  }

  /// Reseta todo o progresso
  void reset() {
    earnedInsigniasList = [];
    earnedMedalhasList = [];
    consecutivePositiveDays = 0;
    disciplinumCount = 0;
    lastPositiveCheckIn = null;
    startDate = null;
    touch();
  }

  /// Reseta apenas as insígnias
  void resetInsignias() {
    earnedInsigniasList = [];
    disciplinumCount = 0;
    touch();
  }

  /// Reseta apenas as medalhas
  void resetMedalhas() {
    earnedMedalhasList = [];
    touch();
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

  /// Verifica se há conquistas recentes (últimos 7 dias)
  bool hasRecentAchievements() {
    if (lastPositiveCheckIn == null) return false;
    final daysSinceLastCheckIn = DateTime.now().difference(lastPositiveCheckIn!).inDays;
    return daysSinceLastCheckIn <= 7;
  }

  @override
  String toString() {
    return 'SmokingGamificationEntity('
        'id: $id, '
        'consecutiveDays: $consecutivePositiveDays, '
        'insignias: ${earnedInsigniasList.length}, '
        'medalhas: ${earnedMedalhasList.length}, '
        'disciplinum: $disciplinumCount, '
        'level: ${getUserLevel()})';
  }
}
