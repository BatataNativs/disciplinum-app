import 'package:equatable/equatable.dart';

/// Entidade que representa um usuário do sistema
/// Mapeia para tabela: auth.users
class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final bool isEmailVerified;
  final Map<String, dynamic>? metadata;
  
  const User({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.lastSignInAt,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        lastSignInAt,
        isEmailVerified,
        metadata,
      ];

  @override
  bool operator ==(Object other) {
    if (other is! User) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Converte para Map para persistência
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
        'created_at': createdAt?.toIso8601String(),
        'last_sign_in_at': lastSignInAt?.toIso8601String(),
        'is_email_verified': isEmailVerified,
        'metadata': metadata,
      };

  /// Cria do Map persistido
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        displayName: json['display_name'],
        photoUrl: json['photo_url'],
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'])
            : null,
        lastSignInAt: json['last_sign_in_at'] != null 
            ? DateTime.parse(json['last_sign_in_at'])
            : null,
        isEmailVerified: json['is_email_verified'] ?? false,
        metadata: json['metadata'],
      );
}
