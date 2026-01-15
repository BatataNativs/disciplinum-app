import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IapService extends ChangeNotifier {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // IDs dos produtos
  static const String productIdDarkMode = 'dark_mode_unlock';
  static const String productIdAdFree = 'ad_free_unlock';
  static const String productIdAdFreeLite = 'ad_free_lite'; // Produto 7 dias
  static const String productIdCustomNotif = 'custom_notifications_unlock';
  static const String productIdMotivationPhrases = 'motivation_phrases_unlock';

  // Chaves do SharedPreferences
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
    final prefs = await SharedPreferences.getInstance();
    _darkModeUnlocked =
        prefs.getBool(_kPrefsDarkMode) ?? false; // mudar para true para testes
    _adFreePermanent =
        prefs.getBool(_kPrefsAdFree) ?? false; // mudar para true para testes
    _customNotifUnlocked = prefs.getBool(_kPrefsCustomNotif) ??
        false; // mudar para true para testes
    _motivationPhrasesUnlocked = prefs.getBool(_kPrefsMotivationPhrases) ??
        false; // mudar para true para testes

    // Carrega a expiração do Lite
    final liteExpMillis = prefs.getInt(_kPrefsAdFreeLiteExp);
    if (liteExpMillis != null) {
      _adFreeLiteExpiration =
          DateTime.fromMillisecondsSinceEpoch(liteExpMillis);
    }

    _subscription = _iap.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Erro no Stream de compras: $error'),
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
      debugPrint('Erro queryProductDetails: ${response.error}');
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
      debugPrint("Nenhum produto carregado.");
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
      debugPrint("Produto '$productId' não encontrado.");
      onPurchaseResult?.call(false);
      return;
    }

    final param = PurchaseParam(productDetails: product);

    // Usamos NonConsumable para simplificar a lógica de compra única por período
    _iap.buyNonConsumable(purchaseParam: param);
  }

  void restorePurchases() {
    _iap.restorePurchases();
  }

  Future<void> _setEntitlement(String productId) async {
    final prefs = await SharedPreferences.getInstance();

    if (productId == productIdDarkMode) {
      _darkModeUnlocked = true;
      await prefs.setBool(_kPrefsDarkMode, true);
    }

    if (productId == productIdAdFree) {
      _adFreePermanent = true;
      await prefs.setBool(_kPrefsAdFree, true);
    }

    // Lógica do AdFree Lite (7 Dias)
    if (productId == productIdAdFreeLite) {
      // Define a data de agora + 7 dias
      final newExpiration = DateTime.now().add(const Duration(days: 7));
      _adFreeLiteExpiration = newExpiration;

      // Salva em millis
      await prefs.setInt(
          _kPrefsAdFreeLiteExp, newExpiration.millisecondsSinceEpoch);
    }

    if (productId == productIdCustomNotif) {
      _customNotifUnlocked = true;
      await prefs.setBool(_kPrefsCustomNotif, true);
    }

    if (productId == productIdMotivationPhrases) {
      _motivationPhrasesUnlocked = true;
      await prefs.setBool(_kPrefsMotivationPhrases, true);
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
