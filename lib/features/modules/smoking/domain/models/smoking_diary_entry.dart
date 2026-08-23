/// Modelo para entrada no Diário de Pensamentos & Ansiedade do Módulo Smoking
class SmokingDiaryEntry {
  final String id;
  final String dateKey; // Formato yyyy-MM-dd
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? mood; // ex: 'calm', 'anxious', 'craving', 'proud', 'angry'

  const SmokingDiaryEntry({
    required this.id,
    required this.dateKey,
    required this.text,
    required this.createdAt,
    this.updatedAt,
    this.mood,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateKey': dateKey,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'mood': mood,
    };
  }

  factory SmokingDiaryEntry.fromJson(Map<String, dynamic> json) {
    return SmokingDiaryEntry(
      id: json['id'] as String? ?? '',
      dateKey: json['dateKey'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      mood: json['mood'] as String?,
    );
  }

  SmokingDiaryEntry copyWith({
    String? id,
    String? dateKey,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mood,
  }) {
    return SmokingDiaryEntry(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mood: mood ?? this.mood,
    );
  }
}

