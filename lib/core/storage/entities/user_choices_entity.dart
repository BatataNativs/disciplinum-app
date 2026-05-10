import 'dart:convert';
import 'package:objectbox/objectbox.dart';

/// Entidade para armazenar escolhas e preferências do usuário
/// Persistência local com ObjectBox para acesso rápido e offline
@Entity()
class UserChoicesEntity {
  @Id()
  int id = 0;
  
  /// ID do usuário (para multi-usuário no mesmo dispositivo)
  @Property()
  String userId;
  
  /// Escolhas de visibilidade do perfil
  @Property()
  bool showEmail = true;
  
  @Property()
  bool showAvatar = true;
  
  /// Preferências de tema
  @Property()
  String theme = 'system'; // system, light, dark
  
  /// Configurações de notificações
  @Property()
  bool notificationsEnabled = true;
  
  @Property()
  String notificationTime = '09:00';
  
  /// Preferências de idioma
  @Property()
  String language = 'pt_BR';
  
  /// Configurações de modos (JSON string)
  @Property()
  String moduleVisibilityJson = '{}';
  
  /// Data da última sincronização com a nuvem
  @Property()
  DateTime? lastSyncAt;
  
  /// Versão dos dados para controle de migração
  @Property()
  int version = 1;
  
  /// Timestamp de criação/atualização
  @Property()
  DateTime createdAt;
  
  @Property()
  DateTime updatedAt;

  UserChoicesEntity({
    required this.userId,
    this.showEmail = true,
    this.showAvatar = true,
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.notificationTime = '09:00',
    this.language = 'pt_BR',
    this.moduleVisibilityJson = '{}',
    this.lastSyncAt,
    this.version = 1,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  /// Getter para moduleVisibility (converte do JSON)
  Map<String, bool> get moduleVisibility {
    try {
      if (moduleVisibilityJson.isEmpty) return {};
      final Map<String, dynamic> decoded = jsonDecode(moduleVisibilityJson);
      return decoded.map((key, value) => MapEntry(key, value is bool ? value : false));
    } catch (e) {
      return {};
    }
  }

  /// Setter para moduleVisibility (converte para JSON)
  set moduleVisibility(Map<String, bool> value) {
    moduleVisibilityJson = jsonEncode(value);
  }

  /// Converte para Map para sincronização com Supabase
  Map<String, dynamic> toCloudMap() {
    return {
      'user_id': userId,
      'show_email': showEmail,
      'show_avatar': showAvatar,
      'theme': theme,
      'notifications_enabled': notificationsEnabled,
      'notification_time': notificationTime,
      'language': language,
      'module_visibility': moduleVisibility,
      'version': version,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria entidade a partir dos dados da nuvem
  factory UserChoicesEntity.fromCloudMap(Map<String, dynamic> map) {
    return UserChoicesEntity(
      userId: map['user_id'] as String,
      showEmail: map['show_email'] as bool? ?? true,
      showAvatar: map['show_avatar'] as bool? ?? true,
      theme: map['theme'] as String? ?? 'system',
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
      notificationTime: map['notification_time'] as String? ?? '09:00',
      language: map['language'] as String? ?? 'pt_BR',
      moduleVisibilityJson: map['module_visibility'] != null 
          ? jsonEncode(map['module_visibility']) 
          : '{}',
      version: map['version'] as int? ?? 1,
    )..lastSyncAt = DateTime.tryParse(map['updated_at'] ?? '');
  }

  /// Cria cópia com atualizações
  UserChoicesEntity copyWith({
    bool? showEmail,
    bool? showAvatar,
    String? theme,
    bool? notificationsEnabled,
    String? notificationTime,
    String? language,
    Map<String, bool>? moduleVisibility,
    DateTime? lastSyncAt,
    int? version,
  }) {
    return UserChoicesEntity(
      userId: userId,
      showEmail: showEmail ?? this.showEmail,
      showAvatar: showAvatar ?? this.showAvatar,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      language: language ?? this.language,
      moduleVisibilityJson: moduleVisibility != null 
          ? jsonEncode(moduleVisibility) 
          : moduleVisibilityJson,
      version: version ?? this.version,
    )..lastSyncAt = lastSyncAt ?? this.lastSyncAt
     ..createdAt = createdAt
     ..updatedAt = DateTime.now();
  }

  @override
  String toString() {
    return 'UserChoicesEntity(userId: $userId, showEmail: $showEmail, showAvatar: $showAvatar, theme: $theme)';
  }
}
