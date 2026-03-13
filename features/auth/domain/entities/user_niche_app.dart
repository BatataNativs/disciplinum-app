import 'package:equatable/equatable.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Entidade que representa os apps bloqueados para um nicho do usuário
/// Mapeia para tabela: user_niche_apps (JÁ EXISTE no Supabase)
/// Estrutura real baseada em CloudSyncService
class UserNicheApp extends Equatable {
  final String id;
  final String userId;
  final int nicheId;
  final String appPackage;
  final DateTime createdAt;

  const UserNicheApp({
    required this.id,
    required this.userId,
    required this.nicheId,
    required this.appPackage,
    required this.createdAt,
  });

  /// Cria a partir de dados do Supabase
  factory UserNicheApp.fromSupabase(Map<String, dynamic> data) {
    return UserNicheApp(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      nicheId: data['niche_id'] as int,
      appPackage: data['app_package'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  /// Converte para JSON para salvar no Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'niche_id': nicheId,
      'app_package': appPackage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Cria a partir de JSON
  factory UserNicheApp.fromJson(Map<String, dynamic> json) {
    return UserNicheApp(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nicheId: json['niche_id'] as int,
      appPackage: json['app_package'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Cria novo UserNicheApp
  factory UserNicheApp.create({
    required String userId,
    required int nicheId,
    required String appPackage,
  }) {
    return UserNicheApp(
      id: '', // Será gerado pelo Supabase
      userId: userId,
      nicheId: nicheId,
      appPackage: appPackage,
      createdAt: DateTime.now(),
    );
  }

  /// CopyWith para updates imutáveis
  UserNicheApp copyWith({
    String? id,
    String? userId,
    int? nicheId,
    String? appPackage,
    DateTime? createdAt,
  }) {
    return UserNicheApp(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nicheId: nicheId ?? this.nicheId,
      appPackage: appPackage ?? this.appPackage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Obtém o NicheId a partir do nicheId inteiro
  NicheId get niche {
    switch (nicheId) {
      case 1:
        return NicheId.smoking;
      case 2:
        return NicheId.bingeEating;
      case 3:
        return NicheId.diet;
      case 4:
        return NicheId.spending;
      case 5:
        return NicheId.focus;
      case 6:
        return NicheId.adultContent;
      case 7:
        return NicheId.moneySavingChallenge;
      case 8:
        return NicheId.procrastination;
      case 9:
        return NicheId.reading;
      default:
        throw ArgumentError('Invalid nicheId: $nicheId');
    }
  }

  /// Verifica se é um app Android válido
  bool get isValidAndroidApp {
    return appPackage.contains('.') && appPackage.length > 5;
  }

  /// Obtém o nome formatado do app
  String get formattedAppName {
    final parts = appPackage.split('.');
    return parts.isNotEmpty ? parts.last : appPackage;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        nicheId,
        appPackage,
        createdAt,
      ];

  @override
  String toString() {
    return 'UserNicheApp(id: $id, userId: $userId, nicheId: $nicheId, package: $appPackage)';
  }
}
