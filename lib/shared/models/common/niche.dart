import 'package:disciplinum/shared/models/enums/niche_id.dart';

class Niche {
  final int id;
  final NicheId nicheId;
  final String name;
  final String description;
  final String? icon;
  final String? color;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Additional properties for UI compatibility
  double get scale => 1.0;
  String get iconPath => icon ?? 'assets/icons/default.png';
  bool get isEmojiIcon => icon != null && !icon!.contains('/') && !icon!.contains('.');
  String get homePhrase => description;

  const Niche({
    required this.id,
    required this.nicheId,
    required this.name,
    required this.description,
    this.icon,
    this.color,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Niche.fromJson(Map<String, dynamic> json) {
    return Niche(
      id: json['id'] as int,
      nicheId: NicheId.tryFromInt(json['niche_id'] as int?) ?? NicheId.smoking,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'niche_id': nicheId.toString().split('.').last,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Niche copyWith({
    int? id,
    NicheId? nicheId,
    String? name,
    String? description,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Niche(
      id: id ?? this.id,
      nicheId: nicheId ?? this.nicheId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Niche &&
        other.id == id &&
        other.nicheId == nicheId &&
        other.name == name &&
        other.description == description &&
        other.icon == icon &&
        other.color == color &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nicheId,
      name,
      description,
      icon,
      color,
      isActive,
    );
  }

  @override
  String toString() {
    return 'Niche(id: $id, nicheId: $nicheId, name: $name, description: $description)';
  }
}
