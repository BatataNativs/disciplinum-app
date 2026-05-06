import 'package:objectbox/objectbox.dart';

/// Entidade ObjectBox para armazenar conquistas pendentes de exibição
/// 
/// Quando o usuário ganha uma insígnia ou medalha (especialmente
/// quando o app está fechado), a conquista é salva aqui para ser
/// exibida quando o usuário abrir o app.
@Entity()
class PendingAchievementEntity {
  /// ID único gerado pelo ObjectBox
  @Id()
  int id = 0;

  /// ID do usuário que ganhou a conquista
  late String userId;

  /// Tipo de conquista: 'insignia', 'medalha', 'special'
  late String type;

  /// ID do módulo onde a conquista foi obtida (ex: 'smoking', 'focus')
  late String moduleId;

  /// ID da conquista (ex: 'ouro', 'disciplina_de_ferro')
  late String achievementId;

  /// Nome exibível da conquista
  late String achievementName;

  /// Descrição opcional da conquista
  String? achievementDescription;

  /// Caminho do asset (ícone/imagem) opcional
  String? assetPath;

  /// Raridade da conquista (para medalhas): 'comum', 'rara', 'epica', 'lendaria'
  String? rarity;

  /// Quando a conquista foi obtida
  DateTime? earnedAt;

  /// Se já foi exibida ao usuário
  bool wasShown = false;

  /// Quando foi exibida (para limpeza automática)
  DateTime? shownAt;

  /// Construtor padrão
  PendingAchievementEntity({
    required this.userId,
    required this.type,
    required this.moduleId,
    required this.achievementId,
    required this.achievementName,
    this.achievementDescription,
    this.assetPath,
    this.rarity,
    this.earnedAt,
    this.wasShown = false,
    this.shownAt,
  });

  /// Cria uma cópia com novos valores
  PendingAchievementEntity copyWith({
    String? userId,
    String? type,
    String? moduleId,
    String? achievementId,
    String? achievementName,
    String? achievementDescription,
    String? assetPath,
    String? rarity,
    DateTime? earnedAt,
    bool? wasShown,
    DateTime? shownAt,
  }) {
    return PendingAchievementEntity(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      moduleId: moduleId ?? this.moduleId,
      achievementId: achievementId ?? this.achievementId,
      achievementName: achievementName ?? this.achievementName,
      achievementDescription: achievementDescription ?? this.achievementDescription,
      assetPath: assetPath ?? this.assetPath,
      rarity: rarity ?? this.rarity,
      earnedAt: earnedAt ?? this.earnedAt,
      wasShown: wasShown ?? this.wasShown,
      shownAt: shownAt ?? this.shownAt,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'moduleId': moduleId,
      'achievementId': achievementId,
      'achievementName': achievementName,
      'achievementDescription': achievementDescription,
      'assetPath': assetPath,
      'rarity': rarity,
      'earnedAt': earnedAt?.toIso8601String(),
      'wasShown': wasShown,
      'shownAt': shownAt?.toIso8601String(),
    };
  }

  /// Cria a partir de JSON
  factory PendingAchievementEntity.fromJson(Map<String, dynamic> json) {
    return PendingAchievementEntity(
      userId: json['userId'] as String,
      type: json['type'] as String,
      moduleId: json['moduleId'] as String,
      achievementId: json['achievementId'] as String,
      achievementName: json['achievementName'] as String,
      achievementDescription: json['achievementDescription'] as String?,
      assetPath: json['assetPath'] as String?,
      rarity: json['rarity'] as String?,
      earnedAt: json['earnedAt'] != null 
          ? DateTime.parse(json['earnedAt'] as String) 
          : null,
      wasShown: json['wasShown'] as bool? ?? false,
      shownAt: json['shownAt'] != null 
          ? DateTime.parse(json['shownAt'] as String) 
          : null,
    );
  }

  @override
  String toString() {
    return 'PendingAchievementEntity(id: $id, userId: $userId, type: $type, '
        'moduleId: $moduleId, achievementId: $achievementId, '
        'achievementName: $achievementName, wasShown: $wasShown)';
  }
}
