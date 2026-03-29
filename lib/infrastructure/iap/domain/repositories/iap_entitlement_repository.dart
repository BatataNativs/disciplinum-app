import 'package:isar/isar.dart';
import 'package:disciplinum/infrastructure/iap/domain/entities/iap_entitlement.dart';

/// Repositório Isar puro para entitlements IAP
/// Substitui o uso genérico de IsarPreferencesRepository
class IapEntitlementRepository {
  final Isar _isar;

  IapEntitlementRepository(this._isar);

  /// Salva ou atualiza um entitlement
  Future<void> saveEntitlement(IapEntitlement entitlement) async {
    await _isar.writeTxn(() async {
      await _isar.iapEntitlements.put(entitlement);
    });
  }

  /// Obtém um entitlement por productId
  Future<IapEntitlement?> getEntitlement(String productId) async {
    return await _isar.iapEntitlements
        .filter()
        .productIdEqualTo(productId)
        .findFirst();
  }

  /// Verifica se um produto foi comprado
  Future<bool> isPurchased(String productId) async {
    final entitlement = await getEntitlement(productId);
    return entitlement?.isValid ?? false;
  }

  /// Obtém todos os entitlements válidos
  Future<List<IapEntitlement>> getValidEntitlements() async {
    return await _isar.iapEntitlements
        .filter()
        .isPurchasedEqualTo(true)
        .isVerifiedEqualTo(true)
        .findAll();
  }

  /// Obtém entitlements por tipo (permanentes vs temporários)
  Future<List<IapEntitlement>> getEntitlementsByType({bool? isPermanent}) async {
    var query = _isar.iapEntitlements
        .filter()
        .isPurchasedEqualTo(true)
        .isVerifiedEqualTo(true);
    
    if (isPermanent != null) {
      if (isPermanent) {
        query = query.expirationDateIsNull();
      } else {
        query = query.expirationDateIsNotNull();
      }
    }
    
    return await query.findAll();
  }

  /// Marca entitlement como verificado
  Future<void> markAsVerified(String productId, {String? verificationToken}) async {
    final entitlement = await getEntitlement(productId);
    if (entitlement != null) {
      final updated = entitlement.copyWith(
        isVerified: true,
        verificationToken: verificationToken,
      );
      await saveEntitlement(updated);
    }
  }

  /// Expira um entitlement (para cancelamentos)
  Future<void> expireEntitlement(String productId) async {
    final entitlement = await getEntitlement(productId);
    if (entitlement != null) {
      final updated = entitlement.copyWith(
        expirationDate: DateTime.now().subtract(const Duration(seconds: 1)),
      );
      await saveEntitlement(updated);
    }
  }

  /// Remove um entitlement
  Future<void> removeEntitlement(String productId) async {
    await _isar.writeTxn(() async {
      await _isar.iapEntitlements
          .filter()
          .productIdEqualTo(productId)
          .deleteAll();
    });
  }

  /// Limpa todos os entitlements (para reset)
  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.iapEntitlements.clear();
    });
  }

  /// Migra dados do IsarPreferencesRepository (legado)
  Future<void> migrateFromLegacy(Map<String, dynamic> legacyData) async {
    await _isar.writeTxn(() async {
      for (final entry in legacyData.entries) {
        final productId = entry.key;
        final data = entry.value as Map<String, dynamic>;
        
        // Converter dados legados para novo formato
        final entitlement = IapEntitlement(
          productId: productId,
          isPurchased: data['purchased'] ?? false,
          expirationDate: data['expiration'] != null 
              ? DateTime.tryParse(data['expiration'])
              : null,
          purchaseDate: data['purchaseDate'] != null
              ? DateTime.tryParse(data['purchaseDate']) ?? DateTime.now()
              : DateTime.now(),
          isVerified: true, // Se estava no legado, assume verificado
        );
        
        await _isar.iapEntitlements.put(entitlement);
      }
    });
  }

  /// Obtém estatísticas dos entitlements
  Future<Map<String, dynamic>> getStats() async {
    final all = await _isar.iapEntitlements.where().findAll();
    final valid = all.where((e) => e.isValid).toList();
    final permanent = valid.where((e) => e.isPermanent).toList();
    final temporary = valid.where((e) => !e.isPermanent).toList();
    
    return {
      'total': all.length,
      'valid': valid.length,
      'permanent': permanent.length,
      'temporary': temporary.length,
      'expired': all.where((e) => e.isExpired).length,
      'unverified': all.where((e) => !e.isVerified).length,
    };
  }
}
