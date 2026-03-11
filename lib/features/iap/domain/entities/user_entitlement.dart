class UserEntitlement {
  final String id;
  final String userId;
  final String entitlementType;
  final int? nicheId;
  final String source;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;

  UserEntitlement({
    required this.id,
    required this.userId,
    required this.entitlementType,
    this.nicheId,
    required this.source,
    required this.createdAt,
    this.expiresAt,
    required this.metadata,
  });

  factory UserEntitlement.fromJson(Map<String, dynamic> json) {
    return UserEntitlement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      entitlementType: json['entitlement_type'] as String,
      nicheId: json['niche_id'] as int?,
      source: json['source'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'entitlement_type': entitlementType,
      'niche_id': nicheId,
      'source': source,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  UserEntitlement copyWith({
    String? id,
    String? userId,
    String? entitlementType,
    int? nicheId,
    String? source,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserEntitlement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      entitlementType: entitlementType ?? this.entitlementType,
      nicheId: nicheId ?? this.nicheId,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid {
    return !isExpired;
  }
}
