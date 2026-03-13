import 'package:equatable/equatable.dart';

/// Entidade principal de usuário do sistema
class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final Map<String, dynamic>? metadata;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.metadata,
  });

  /// Cria usuário a partir de dados do Supabase (formato de mapa)
  factory User.fromSupabaseUser(Map<String, dynamic> userData) {
    return User(
      id: userData['id'] as String,
      email: userData['email'] as String,
      name: userData['user_metadata']?['name'] as String?,
      avatarUrl: userData['user_metadata']?['avatar_url'] as String?,
      createdAt: userData['created_at'] != null 
          ? DateTime.parse(userData['created_at'] as String)
          : null,
      lastLoginAt: userData['last_sign_in_at'] != null
          ? DateTime.parse(userData['last_sign_in_at'] as String)
          : null,
      isEmailVerified: userData['email_confirmed_at'] != null,
      metadata: userData['user_metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_email_verified': isEmailVerified,
      'metadata': metadata,
    };
  }

  /// Cria usuário a partir de JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// CopyWith para updates imutáveis
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica se usuário está completo
  bool get isComplete => name != null && name!.isNotEmpty;

  /// Verifica se usuário é novo (criado há menos de 24h)
  bool get isNew {
    if (createdAt == null) return false;
    final now = DateTime.now();
    return now.difference(createdAt!).inHours < 24;
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        createdAt,
        lastLoginAt,
        isEmailVerified,
        metadata,
      ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }
}
