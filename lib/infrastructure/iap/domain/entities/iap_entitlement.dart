import 'package:objectbox/objectbox.dart';

@Entity()
class IapEntitlement {
  @Id()
  int id = 0;
  
  @Unique()
  String productId;
  
  bool isPurchased;
  DateTime? expirationDate;
  DateTime purchaseDate;
  bool isVerified;
  String? verificationToken;

  IapEntitlement({
    required this.productId,
    required this.isPurchased,
    this.expirationDate,
    required this.purchaseDate,
    this.isVerified = false,
    this.verificationToken,
  });

  bool get isValid {
    if (!isPurchased || !isVerified) return false;
    if (expirationDate != null && DateTime.now().isAfter(expirationDate!)) return false;
    return true;
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
