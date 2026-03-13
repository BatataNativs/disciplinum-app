import 'package:equatable/equatable.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Entidade que representa os horários de lembrete para um nicho do usuário
/// Mapeia para tabela: user_niche_times (JÁ EXISTE no Supabase)
/// Estrutura real baseada em CloudSyncService
class UserNicheTime extends Equatable {
  final String id;
  final String userId;
  final int nicheId;
  final int hour;
  final int minute;
  final String? phrase;
  final DateTime createdAt;

  const UserNicheTime({
    required this.id,
    required this.userId,
    required this.nicheId,
    required this.hour,
    required this.minute,
    this.phrase,
    required this.createdAt,
  });

  /// Cria a partir de dados do Supabase
  factory UserNicheTime.fromSupabase(Map<String, dynamic> data) {
    return UserNicheTime(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      nicheId: data['niche_id'] as int,
      hour: data['hour'] as int,
      minute: data['minute'] as int,
      phrase: data['phrase'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  /// Converte para JSON para salvar no Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'niche_id': nicheId,
      'hour': hour,
      'minute': minute,
      'phrase': phrase,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Cria a partir de JSON
  factory UserNicheTime.fromJson(Map<String, dynamic> json) {
    return UserNicheTime(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nicheId: json['niche_id'] as int,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      phrase: json['phrase'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Cria novo UserNicheTime
  factory UserNicheTime.create({
    required String userId,
    required int nicheId,
    required int hour,
    required int minute,
    String? phrase,
  }) {
    return UserNicheTime(
      id: '', // Será gerado pelo Supabase
      userId: userId,
      nicheId: nicheId,
      hour: hour,
      minute: minute,
      phrase: phrase,
      createdAt: DateTime.now(),
    );
  }

  /// CopyWith para updates imutáveis
  UserNicheTime copyWith({
    String? id,
    String? userId,
    int? nicheId,
    int? hour,
    int? minute,
    String? phrase,
    DateTime? createdAt,
  }) {
    return UserNicheTime(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nicheId: nicheId ?? this.nicheId,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      phrase: phrase ?? this.phrase,
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

  /// Obtém horário formatado
  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Verifica se horário é válido
  bool get isValidTime {
    return hour >= 0 && hour < 24 && minute >= 0 && minute < 60;
  }

  /// Verifica se é horário de lembrete agora
  bool isReminderTimeNow() {
    if (!isValidTime) return false;
    
    final now = DateTime.now();
    return now.hour == hour && now.minute == minute;
  }

  /// Verifica se tem frase motivacional
  bool get hasPhrase => phrase != null && phrase!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        userId,
        nicheId,
        hour,
        minute,
        phrase,
        createdAt,
      ];

  @override
  String toString() {
    return 'UserNicheTime(id: $id, userId: $userId, nicheId: $nicheId, time: $formattedTime)';
  }
}
