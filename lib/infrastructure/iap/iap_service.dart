import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';

class IapService extends ChangeNotifier {
  final CloudSyncService _cloudSync;
  final IsarPreferencesRepository _prefsRepo;
  final InAppPurchase _iap = InAppPurchase.instance;

  IapService(this._cloudSync, this._prefsRepo);
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // IDs dos produtos
  static const String productIdDarkMode = 'dark_mode_unlock';
  static const String productIdAdFree = 'ad_free_unlock';
  static const String productIdAdFreeLite =
      'ad_free_lite'; // Produto 7 dias (Consumível)
  static const String productIdCustomNotif = 'custom_notifications_unlock';
  static const String productIdMotivationPhrases = 'motivation_phrases_unlock';

  // Chaves de preferência (Agora via Isar)
  static const String _kPrefsDarkMode = 'entitlement_dark_mode';
  static const String _kPrefsAdFree = 'entitlement_ad_free';
  static const String _kPrefsAdFreeLiteExp = 'entitlement_ad_free_lite_exp';
  static const String _kPrefsCustomNotif = 'entitlement_custom_notifications';
  static const String _kPrefsMotivationPhrases =
      'entitlement_motivation_phrases';

  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  bool _darkModeUnlocked = false;
  bool _adFreePermanent = false;
  DateTime? _adFreeLiteExpiration; // Controle interno da data do Lite
  bool _customNotifUnlocked = false;
  bool _motivationPhrasesUnlocked = false;

  // Getters públicos
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get isDarkModeUnlocked => _darkModeUnlocked;
  bool get isCustomNotifUnlocked => _customNotifUnlocked;
  bool get isMotivationPhrasesUnlocked => _motivationPhrasesUnlocked;

  // Getter para saber se é permanente (útil para UI saber se esconde o botão de compra permanente)
  bool get isAdFreePermanent => _adFreePermanent;

  // Getter da data de expiração (para mostrar na UI)
  DateTime? get adFreeLiteExpiration => _adFreeLiteExpiration;

  // É AdFree se tiver o permanente OU se o Lite não expirou
  bool get isAdFree {
    if (_adFreePermanent) return true;
    if (_adFreeLiteExpiration != null &&
        _adFreeLiteExpiration!.isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }

  // Getter auxiliar: Retorna true APENAS se estiver rodando no modo Lite (e não tiver o permanente)
  bool get isAdFreeLiteActive =>
      !_adFreePermanent &&
      _adFreeLiteExpiration != null &&
      _adFreeLiteExpiration!.isAfter(DateTime.now());

  Function(bool success)? onPurchaseResult;

  Future<void> initialize() async {
    _darkModeUnlocked = await _prefsRepo.getBool(_kPrefsDarkMode) ?? false;
    _adFreePermanent = await _prefsRepo.getBool(_kPrefsAdFree) ?? false;
    _customNotifUnlocked = await _prefsRepo.getBool(_kPrefsCustomNotif) ?? false;
    _motivationPhrasesUnlocked =
        await _prefsRepo.getBool(_kPrefsMotivationPhrases) ?? false;

    // Carrega a expiração do Lite
    final liteExpStr = await _prefsRepo.getString(_kPrefsAdFreeLiteExp);
    if (liteExpStr != null) {
      _adFreeLiteExpiration = DateTime.tryParse(liteExpStr);
    }

    _subscription = _iap.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) => LoggerService.instance.e('Erro no Stream de compras', error: error),
    );

    await _checkStoreAvailability();
    notifyListeners();
  }

  Future<void> _checkStoreAvailability() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    const Set<String> kIds = {
      productIdDarkMode,
      productIdAdFree,
      productIdAdFreeLite,
      productIdCustomNotif,
      productIdMotivationPhrases,
    };

    final response = await _iap.queryProductDetails(kIds);

    if (response.error == null) {
      _products = response.productDetails;
    } else {
      LoggerService.instance.e('Erro queryProductDetails', error: response.error);
    }
  }

  ProductDetails? productById(String productId) {
    for (final p in _products) {
      if (p.id == productId) return p;
    }
    return null;
  }

  // Atalhos de compra
  void buyDarkMode() => buyByProductId(productIdDarkMode);
  void buyAdFree() => buyByProductId(productIdAdFree);
  void buyAdFreeLite() => buyByProductId(productIdAdFreeLite);
  void buyCustomNotif() => buyByProductId(productIdCustomNotif);
  void buyMotivationPhrases() => buyByProductId(productIdMotivationPhrases);

  void buyByProductId(String productId) {
    if (_products.isEmpty) {
      LoggerService.instance.w("Nenhum produto carregado.");
      onPurchaseResult?.call(false);
      return;
    }

    final ProductDetails? product = _products
        .where((p) => p.id == productId)
        .cast<ProductDetails?>()
        .firstWhere(
          (p) => p != null,
          orElse: () => null,
        );

    if (product == null) {
      LoggerService.instance.w("Produto '$productId' não encontrado.");
      onPurchaseResult?.call(false);
      return;
    }

    final param = PurchaseParam(productDetails: product);

    // --- CORREÇÃO AQUI: Lógica diferenciada para Consumível vs Não Consumível ---
    if (productId == productIdAdFreeLite) {
      // O Lite é consumível (pode comprar de novo quando acabar)
      _iap.buyConsumable(purchaseParam: param);
    } else {
      // Os outros são permanentes (compra única)
      _iap.buyNonConsumable(purchaseParam: param);
    }
  }

  void restorePurchases() {
    _iap.restorePurchases();
  }

  Future<void> _setEntitlement(String productId) async {
    final prefs = _prefsRepo;

    String? entitlementType;
    DateTime? expiresAt;

    if (productId == productIdDarkMode) {
      _darkModeUnlocked = true;
      await prefs.setBool(_kPrefsDarkMode, true);
      entitlementType = 'dark_mode';
    } else if (productId == productIdAdFree) {
      _adFreePermanent = true;
      await prefs.setBool(_kPrefsAdFree, true);
      entitlementType = 'ad_free';
    } else if (productId == productIdAdFreeLite) {
      _adFreeLiteExpiration = DateTime.now().add(const Duration(days: 7));
      await prefs.setString(_kPrefsAdFreeLiteExp, _adFreeLiteExpiration!.toIso8601String());
      entitlementType = 'ad_free_lite';
      expiresAt = _adFreeLiteExpiration;
    } else if (productId == productIdCustomNotif) {
      _customNotifUnlocked = true;
      await prefs.setBool(_kPrefsCustomNotif, true);
      entitlementType = 'custom_notifications';
    } else if (productId == productIdMotivationPhrases) {
      _motivationPhrasesUnlocked = true;
      await prefs.setBool(_kPrefsMotivationPhrases, true);
      entitlementType = 'motivation_phrases';
    }

    // Sincroniza com a nuvem se for um entitlement válido
    if (entitlementType != null) {
      try {
        await _cloudSync.addEntitlement(
          entitlementType: entitlementType,
          source: 'iap',
          expiresAt: expiresAt,
          metadata: {'product_id': productId},
        );
      } catch (e) {
        LoggerService.instance.e('Erro ao sincronizar entitlement $entitlementType', error: e);
      }
    }

    notifyListeners();
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        onPurchaseResult?.call(false);
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _setEntitlement(purchase.productID);

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }

        onPurchaseResult?.call(true);
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
