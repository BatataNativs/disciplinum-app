/// Modelo para registro de crise de fissura / SOS no Módulo Smoking
class SmokingCravingRecord {
  final String id;
  final DateTime timestamp;
  final int intensity; // 1 a 5
  final String trigger; // 'Café', 'Estresse', 'Bebida alcoólica', 'Cansaço', 'Social', 'Hábito / Tédio', 'Pós-refeição', 'Outro'
  final String outcome; // 'overcome' (superei), 'persisted' (ainda sinto), 'relapsed' (fumei)
  final int durationSeconds; // Tempo enfrentando o craving
  final String? strategyUsed; // 'Respirar', 'Beber água', 'Distração mental', 'Caminhar', 'Diário', etc.
  final String? note;

  const SmokingCravingRecord({
    required this.id,
    required this.timestamp,
    required this.intensity,
    required this.trigger,
    required this.outcome,
    this.durationSeconds = 180,
    this.strategyUsed,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'intensity': intensity,
      'trigger': trigger,
      'outcome': outcome,
      'durationSeconds': durationSeconds,
      'strategyUsed': strategyUsed,
      'note': note,
    };
  }

  factory SmokingCravingRecord.fromJson(Map<String, dynamic> json) {
    return SmokingCravingRecord(
      id: json['id'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      intensity: (json['intensity'] as num?)?.toInt() ?? 3,
      trigger: json['trigger'] as String? ?? 'Estresse',
      outcome: json['outcome'] as String? ?? 'overcome',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 180,
      strategyUsed: json['strategyUsed'] as String?,
      note: json['note'] as String?,
    );
  }

  SmokingCravingRecord copyWith({
    String? id,
    DateTime? timestamp,
    int? intensity,
    String? trigger,
    String? outcome,
    int? durationSeconds,
    String? strategyUsed,
    String? note,
  }) {
    return SmokingCravingRecord(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      intensity: intensity ?? this.intensity,
      trigger: trigger ?? this.trigger,
      outcome: outcome ?? this.outcome,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      strategyUsed: strategyUsed ?? this.strategyUsed,
      note: note ?? this.note,
    );
  }
}

