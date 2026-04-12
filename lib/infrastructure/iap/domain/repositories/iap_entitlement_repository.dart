import 'package:disciplinum/infrastructure/iap/domain/entities/iap_entitlement.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Repositório ObjectBox puro para entitlements IAP
/// Substitui o uso genérico de Isar
class IapEntitlementRepository {
  final Box<IapEntitlement> _box;

  IapEntitlementRepository(Store store) : _box = store.box<IapEntitlement>();

  /// Salva ou atualiza um entitlement
  Future<void> saveEntitlement(IapEntitlement entitlement) async {
    _box.put(entitlement);
  }

  /// Obtém um entitlement por productId
  Future<IapEntitlement?> getEntitlement(String productId) async {
    return _box.query(IapEntitlement_.productId.equals(productId)).build().findFirst();
  }

  /// Verifica se um produto foi comprado
  Future<bool> isPurchased(String productId) async {
    final entitlement = await getEntitlement(productId);
    return entitlement?.isValid ?? false;
  }

  /// Obtém todos os entitlements válidos
  Future<List<IapEntitlement>> getValidEntitlements() async {
    return _box.query(IapEntitlement_.isPurchased.equals(true)
        .and(IapEntitlement_.isVerified.equals(true)))
        .build()
        .find();
  }

  /// Obtém entitlements por tipo (permanentes vs temporários)
  Future<List<IapEntitlement>> getEntitlementsByType({bool? isPermanent}) async {
    if (isPermanent == null) {
      return _box.getAll();
    }

    // Query all and filter in memory for null check
    final all = _box.getAll();
    if (isPermanent) {
      return all.where((e) => e.expirationDate == null).toList();
    } else {
      return all.where((e) => e.expirationDate != null).toList();
    }
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
    final entitlement = await getEntitlement(productId);
    if (entitlement != null) {
      _box.remove(entitlement.id);
    }
  }

  /// Limpa todos os entitlements (para reset)
  Future<void> clearAll() async {
    _box.removeAll();
  }

  /// Migra dados do ObjectBoxPreferencesRepository (legado)
  Future<void> migrateFromLegacy(Map<String, dynamic> legacyData) async {
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
      
      _box.put(entitlement);
    }
  }

  /// Obtém estatísticas dos entitlements
  Future<Map<String, dynamic>> getStats() async {
    final all = _box.getAll();
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
