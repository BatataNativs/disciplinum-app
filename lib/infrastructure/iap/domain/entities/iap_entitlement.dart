import 'package:isar/isar.dart';

part 'iap_entitlement.g.dart';

/// Entidade de entitlements IAP usando Isar puro
/// Substitui o uso genérico de IsarPreferencesRepository
@Collection()
class IapEntitlement {
  Id id = Isar.autoIncrement;
  
  /// ID do produto (ex: 'dark_mode_unlock')
  final String productId;
  
  /// Se o produto foi comprado
  final bool isPurchased;
  
  /// Data de expiração (para produtos temporários como AdFree Lite)
  final DateTime? expirationDate;
  
  /// Data da compra
  final DateTime purchaseDate;
  
  /// Se a compra foi verificada/restaurada
  final bool isVerified;
  
  /// Token de verificação da compra (opcional)
  final String? verificationToken;

  IapEntitlement({
    required this.productId,
    required this.isPurchased,
    this.expirationDate,
    required this.purchaseDate,
    this.isVerified = false,
    this.verificationToken,
  });

  /// Verifica se o entitlement está válido
  bool get isValid {
    if (!isPurchased || !isVerified) return false;
    if (expirationDate == null) return true; // Permanente
    return DateTime.now().isBefore(expirationDate!);
  }

  /// Verifica se é um produto permanente
  bool get isPermanent => expirationDate == null;

  /// Verifica se está expirado
  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  /// Dias restantes (para produtos temporários)
  int? get daysRemaining {
    if (expirationDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expirationDate!)) return 0;
    return expirationDate!.difference(now).inDays;
  }

  /// Cria cópia com atualização de status
  IapEntitlement copyWith({
    String? productId,
    bool? isPurchased,
    DateTime? expirationDate,
    DateTime? purchaseDate,
    bool? isVerified,
    String? verificationToken,
  }) {
    return IapEntitlement(
      productId: productId ?? this.productId,
      isPurchased: isPurchased ?? this.isPurchased,
      expirationDate: expirationDate ?? this.expirationDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      isVerified: isVerified ?? this.isVerified,
      verificationToken: verificationToken ?? this.verificationToken,
    );
  }

  @override
  String toString() {
    return 'IapEntitlement(productId: $productId, isPurchased: $isPurchased, '
           'isValid: $isValid, expirationDate: $expirationDate)';
  }
}
