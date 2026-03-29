import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:disciplinum/infrastructure/iap/domain/entities/iap_entitlement.dart';
import 'package:disciplinum/infrastructure/iap/domain/repositories/iap_entitlement_repository.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Estado do serviço de compras in-app
class IapState {
  final bool isDarkModeUnlocked;
  final bool isAdFreeUnlocked;
  final DateTime? adFreeLiteExpiration;
  final bool isCustomNotifUnlocked;
  final bool isMotivationPhrasesUnlocked;
  final bool isLoading;
  final String? error;
  final bool isAvailable;

  const IapState({
    this.isDarkModeUnlocked = false,
    this.isAdFreeUnlocked = false,
    this.adFreeLiteExpiration,
    this.isCustomNotifUnlocked = false,
    this.isMotivationPhrasesUnlocked = false,
    this.isLoading = false,
    this.error,
    this.isAvailable = false,
  });

  IapState copyWith({
    bool? isDarkModeUnlocked,
    bool? isAdFreeUnlocked,
    DateTime? adFreeLiteExpiration,
    bool? isCustomNotifUnlocked,
    bool? isMotivationPhrasesUnlocked,
    bool? isLoading,
    String? error,
    bool? isAvailable,
  }) {
    return IapState(
      isDarkModeUnlocked: isDarkModeUnlocked ?? this.isDarkModeUnlocked,
      isAdFreeUnlocked: isAdFreeUnlocked ?? this.isAdFreeUnlocked,
      adFreeLiteExpiration: adFreeLiteExpiration ?? this.adFreeLiteExpiration,
      isCustomNotifUnlocked: isCustomNotifUnlocked ?? this.isCustomNotifUnlocked,
      isMotivationPhrasesUnlocked: isMotivationPhrasesUnlocked ?? this.isMotivationPhrasesUnlocked,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

/// Serviço de compras in-app - VERSÃO RIVERPOD
/// Service puro sem ChangeNotifier - estado gerenciado pelo controller
class IapService extends StateNotifier<IapState> {
  final IapEntitlementRepository _repository;
  final InAppPurchase _iap = InAppPurchase.instance;

  IapService(this._repository) : super(const IapState()) {
    _initialize();
  }

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // IDs dos produtos
  static const String productIdDarkMode = 'dark_mode_unlock';
  static const String productIdAdFree = 'ad_free_unlock';
  static const String productIdAdFreeLite = 'ad_free_lite';
  static const String productIdCustomNotif = 'custom_notifications_unlock';
  static const String productIdMotivationPhrases = 'motivation_phrases_unlock';

  // Getters para compatibilidade
  bool get isDarkModeUnlocked => state.isDarkModeUnlocked;
  bool get isAdFreeUnlocked => state.isAdFreeUnlocked;
  DateTime? get adFreeLiteExpiration => state.adFreeLiteExpiration;
  bool get isCustomNotifUnlocked => state.isCustomNotifUnlocked;
  bool get isMotivationPhrasesUnlocked => state.isMotivationPhrasesUnlocked;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  bool get isAvailable => state.isAvailable;

  // Getters adicionais para compatibilidade
  bool get isAdFreePermanent => state.isAdFreeUnlocked;
  bool get isAdFreeLiteActive => isAdFreeLiteValid;
  bool get isAdFree => hasAnyAdFree;

  // Callbacks para compatibilidade
  Function(String, bool)? onPurchaseResult;

  // Métodos de compra para compatibilidade
  Future<bool> buyAdFree() => purchaseProduct(productIdAdFree);
  Future<bool> buyAdFreeLite() => purchaseProduct(productIdAdFreeLite);
  Future<bool> buyDarkMode() => purchaseProduct(productIdDarkMode);
  Future<bool> buyCustomNotif() => purchaseProduct(productIdCustomNotif);
  Future<bool> buyMotivationPhrases() => purchaseProduct(productIdMotivationPhrases);
  Future<bool> buyByProductId(String productId) => purchaseProduct(productId);

  /// Inicializa o serviço (compatibilidade)
  Future<void> initialize() async {
    await _initialize();
  }

  /// Inicializa o serviço
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Verifica disponibilidade da loja
      final bool isAvailable = await _iap.isAvailable();
      state = state.copyWith(isAvailable: isAvailable);

      if (isAvailable) {
        await _loadEntitlements();
        _listenToPurchaseUpdates();
      }

      LoggerService.instance.i('IapService inicializado - Loja disponível: $isAvailable');
    } catch (e) {
      state = state.copyWith(error: 'Falha ao inicializar IAP: $e');
      LoggerService.instance.e('Erro ao inicializar IapService', error: e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Carrega os entitlements salvos
  Future<void> _loadEntitlements() async {
    try {
      // Carregar do repositório Isar puro
      final darkModeEntitlement = await _repository.getEntitlement(productIdDarkMode);
      final adFreeEntitlement = await _repository.getEntitlement(productIdAdFree);
      final adFreeLiteEntitlement = await _repository.getEntitlement(productIdAdFreeLite);
      final customNotifEntitlement = await _repository.getEntitlement(productIdCustomNotif);
      final motivationPhrasesEntitlement = await _repository.getEntitlement(productIdMotivationPhrases);

      state = state.copyWith(
        isDarkModeUnlocked: darkModeEntitlement?.isValid ?? false,
        isAdFreeUnlocked: adFreeEntitlement?.isValid ?? false,
        adFreeLiteExpiration: adFreeLiteEntitlement?.expirationDate,
        isCustomNotifUnlocked: customNotifEntitlement?.isValid ?? false,
        isMotivationPhrasesUnlocked: motivationPhrasesEntitlement?.isValid ?? false,
      );

      LoggerService.instance.i('Entitlements carregados do Isar puro');
    } catch (e) {
      state = state.copyWith(error: 'Falha ao carregar entitlements: $e');
      LoggerService.instance.e('Erro ao carregar entitlements', error: e);
    }
  }

  /// Limpa todos os entitlements
  Future<void> clearAllEntitlements() async {
    try {
      await _repository.clearAll();

      state = state.copyWith(
        isDarkModeUnlocked: false,
        isAdFreeUnlocked: false,
        adFreeLiteExpiration: null,
        isCustomNotifUnlocked: false,
        isMotivationPhrasesUnlocked: false,
      );

      LoggerService.instance.i('Todos os entitlements foram resetados no Isar puro');
    } catch (e) {
      state = state.copyWith(error: 'Falha ao resetar entitlements: $e');
      LoggerService.instance.e('Erro ao resetar entitlements', error: e);
    }
  }

  /// Escuta atualizações de compra
  void _listenToPurchaseUpdates() {
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription = null,
      onError: (error) {
        LoggerService.instance.e('Erro no stream de compras', error: error);
        state = state.copyWith(error: 'Erro no stream de compras: $error');
      },
    );
  }

  /// Processa atualizações de compra
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetails) async {
    for (final purchase in purchaseDetails) {
      try {
        await _handlePurchase(purchase);
      } catch (e) {
        LoggerService.instance.e('Erro ao processar compra ${purchase.productID}', error: e);
      }
    }
  }

  /// Processa uma compra individual
  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _grantEntitlement(purchase);
        break;
      case PurchaseStatus.error:
        state = state.copyWith(error: 'Erro na compra: ${purchase.error?.message}');
        break;
      case PurchaseStatus.pending:
        LoggerService.instance.i('Compra pendente: ${purchase.productID}');
        break;
      default:
        break;
    }
  }

  /// Concede o entitlement
  Future<void> _grantEntitlement(PurchaseDetails purchase) async {
    try {
      final entitlement = IapEntitlement(
        productId: purchase.productID,
        isPurchased: true,
        purchaseDate: DateTime.now(),
        isVerified: true,
        verificationToken: purchase.purchaseID,
      );

      // Salvar no repositório Isar puro
      await _repository.saveEntitlement(entitlement);

      // Atualizar estado
      switch (purchase.productID) {
        case productIdDarkMode:
          state = state.copyWith(isDarkModeUnlocked: true);
          break;
        case productIdAdFree:
          state = state.copyWith(isAdFreeUnlocked: true);
          break;
        case productIdAdFreeLite:
          final expiration = DateTime.now().add(const Duration(days: 7));
          final adFreeLiteEntitlement = entitlement.copyWith(expirationDate: expiration);
          await _repository.saveEntitlement(adFreeLiteEntitlement);
          state = state.copyWith(adFreeLiteExpiration: expiration);
          break;
        case productIdCustomNotif:
          state = state.copyWith(isCustomNotifUnlocked: true);
          break;
        case productIdMotivationPhrases:
          state = state.copyWith(isMotivationPhrasesUnlocked: true);
          break;
      }

      LoggerService.instance.i('Entitlement concedido: ${purchase.productID}');
    } catch (e) {
      state = state.copyWith(error: 'Erro ao conceder entitlement: $e');
      LoggerService.instance.e('Erro ao conceder entitlement', error: e);
    }
  }

  /// Verifica se o Ad Free Lite está válido
  bool get isAdFreeLiteValid {
    if (state.adFreeLiteExpiration == null) return false;
    return DateTime.now().isBefore(state.adFreeLiteExpiration!);
  }

  /// Verifica se o usuário tem qualquer tipo de Ad Free
  bool get hasAnyAdFree {
    return state.isAdFreeUnlocked || isAdFreeLiteValid;
  }

  /// Compra um produto
  Future<bool> purchaseProduct(String productId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final productDetailsResponse = await _iap.queryProductDetails({productId});
      
      if (productDetailsResponse.productDetails.isEmpty) {
        state = state.copyWith(error: 'Produto não encontrado: $productId');
        return false;
      }

      final purchaseParam = PurchaseParam(
        productDetails: productDetailsResponse.productDetails.first,
      );

      final bool success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (!success) {
        state = state.copyWith(error: 'Falha ao iniciar compra');
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Erro na compra: $e', isLoading: false);
      LoggerService.instance.e('Erro ao comprar produto $productId', error: e);
      return false;
    }
  }

  /// Restaura compras
  Future<void> restorePurchases() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _iap.restorePurchases();
      LoggerService.instance.i('Restauração de compras solicitada');
    } catch (e) {
      state = state.copyWith(error: 'Erro ao restaurar compras: $e');
      LoggerService.instance.e('Erro ao restaurar compras', error: e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Limpa erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Dispose
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
