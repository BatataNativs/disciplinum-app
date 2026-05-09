import 'package:objectbox/objectbox.dart';

/// Entidade de Quebra de Jejum Digital
/// Representa um "passe" que pode ser usado para burlar limites do app
@Entity()
class DigitalDetoxFastingBreakInfo {
  @Id()
  int id = 0;

  /// ID do usuÃ¡rio dono da quebra
  String userId;

  /// Data de criaÃ§Ã£o
  @Property(type: PropertyType.date)
  DateTime createdAt;

  /// Data em que a quebra expira
  @Property(type: PropertyType.date)
  DateTime? expiresAt;

  /// NÃºmero de dias disciplinados necessÃ¡rios para ganhar esta quebra
  int requiredDays;

  /// Status atual da quebra (armazenado como String)
  String status = 'available';

  /// Data em que foi usada (null se ainda nÃ£o foi usada)
  @Property(type: PropertyType.date)
  DateTime? usedAt;

  /// Se a quebra estÃ¡ ativa (nÃƒO expirada e nÃ£o usada)
  bool get isActive => 
      status == 'available' && 
      (expiresAt == null || DateTime.now().isBefore(expiresAt!));

  /// Se a quebra estÃ¡ expirada
  bool get isExpired => 
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Dias restantes atÃ© expirar
  int get daysUntilExpiry {
    if (expiresAt == null) return -1;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  DigitalDetoxFastingBreakInfo({
    required this.userId,
    required this.createdAt,
    this.expiresAt,
    required this.requiredDays,
    required String status,
    this.usedAt,
  });

  DigitalDetoxFastingBreakInfo copyWith({
    String? userId,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? requiredDays,
    String? status,
    DateTime? usedAt,
  }) {
    return DigitalDetoxFastingBreakInfo(
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      requiredDays: requiredDays ?? this.requiredDays,
      status: status ?? this.status,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  /// Cria uma nova quebra disponÃ­vel
  factory DigitalDetoxFastingBreakInfo.create({
    required String userId,
    required int requiredDays,
    int? validityDays,
  }) {
    final now = DateTime.now();
    return DigitalDetoxFastingBreakInfo(
      userId: userId,
      createdAt: now,
      expiresAt: validityDays != null 
          ? now.add(Duration(days: validityDays))
          : null,
      requiredDays: requiredDays,
      status: 'available',
    );
  }

  /// Marca a quebra como usada
  DigitalDetoxFastingBreakInfo markAsUsed() {
    return copyWith(
      status: 'used',
      usedAt: DateTime.now(),
    );
  }

  /// Marca a quebra como expirada
  DigitalDetoxFastingBreakInfo markAsExpired() {
    return copyWith(
      status: 'expired',
    );
  }

  /// FormataÃ§Ã£o para exibiÃ§Ã£o
  String get formattedRequiredDays => '$requiredDays dias';
  String get formattedCreatedAt => _formatDate(createdAt);
  String get formattedExpiresAt => expiresAt != null ? _formatDate(expiresAt!) : 'Nunca';
  String get formattedUsedAt => usedAt != null ? _formatDate(usedAt!) : 'NÃ£o usada';

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}

/// Status de uma Quebra de Jejum
enum FastingBreakStatus {
  /// DisponÃ­vel para uso
  available,
  
  /// JÃ¡ foi usada
  used,
  
  /// Expirou sem ser usada
  expired,
  
  /// Cancelada pelo sistema
  cancelled;

  String get displayName {
    switch (this) {
      case FastingBreakStatus.available:
        return 'DisponÃ­vel';
      case FastingBreakStatus.used:
        return 'Usada';
      case FastingBreakStatus.expired:
        return 'Expirada';
      case FastingBreakStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get description {
    switch (this) {
      case FastingBreakStatus.available:
        return 'Pronta para usar';
      case FastingBreakStatus.used:
        return 'JÃ¡ foi utilizada';
      case FastingBreakStatus.expired:
        return 'Expirou sem uso';
      case FastingBreakStatus.cancelled:
        return 'Cancelada pelo sistema';
    }
  }
}
