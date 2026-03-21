import 'package:disciplinum/shared/models/enums/niche_id.dart';

class NicheCategory {
  final int id;
  final String name;
  final String description;
  final String? icon;
  final String? color;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Additional properties for UI compatibility
  String get title => name;
  List<NicheId> get nicheIds => _getNicheIdsForCategory(id);
  String get idPrefix => 'category_$id';

  const NicheCategory({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.color,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory NicheCategory.fromJson(Map<String, dynamic> json) {
    return NicheCategory(
      id: json['id'] as int,
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
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  NicheCategory copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NicheCategory(
      id: id ?? this.id,
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
    return other is NicheCategory &&
        other.id == id &&
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
      name,
      description,
      icon,
      color,
      isActive,
    );
  }

  @override
  String toString() {
    return 'NicheCategory(id: $id, name: $name, description: $description)';
  }

  // Helper method to get niche IDs for a category
  static List<NicheId> _getNicheIdsForCategory(int categoryId) {
    switch (categoryId) {
      case 1: // Saúde
        return [NicheId.smoking, NicheId.bingeEating, NicheId.diet];
      case 2: // Finanças
        return [NicheId.spending, NicheId.moneySavingChallenge];
      case 3: // Produtividade
        return [NicheId.focus, NicheId.procrastination];
      case 4: // Mente e autocontrole
        return [NicheId.adultContent, NicheId.reading];
      default:
        return [];
    }
  }
}
