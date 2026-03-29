// import 'dart:io'; // Comentado para uso futuro
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Estado do serviço de anúncios
class AdState {
  final RewardedAd? rewardedAd;
  final bool isRewardedAdLoading;
  final String? errorMessage;

  const AdState({
    this.rewardedAd,
    this.isRewardedAdLoading = false,
    this.errorMessage,
  });

  AdState copyWith({
    RewardedAd? rewardedAd,
    bool? isRewardedAdLoading,
    String? errorMessage,
  }) {
    return AdState(
      rewardedAd: rewardedAd ?? this.rewardedAd,
      isRewardedAdLoading: isRewardedAdLoading ?? this.isRewardedAdLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Serviço de anúncios - VERSÃO RIVERPOD
/// Service puro sem ChangeNotifier - estado gerenciado pelo controller
class AdService extends StateNotifier<AdState> {
  AdService() : super(const AdState());

  // Getters para compatibilidade
  RewardedAd? get rewardedAd => state.rewardedAd;
  bool get isRewardedAdLoading => state.isRewardedAdLoading;
  String? get errorMessage => state.errorMessage;

  /// Inicializa o SDK de anúncios (opcional, se quiser centralizar a inicialização aqui)
  /// Pode ser chamado no main.dart
  /*
  Future<void> init() async {
     await MobileAds.instance.initialize();
  }
  */

  // --- Métodos Utilitários (Opcional) ---

  /// Helper para obter o ID do banner (se quiser centralizar a lógica de ID)
  String get bannerAdUnitId {
    if (kDebugMode) {
      // ID de teste para banners
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    // ID real para banners (hardcoded por enquanto)
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  }

  /// Helper para obter o ID do anúncio premiado
  String get rewardedAdUnitId {
    if (kDebugMode) {
      // ID de teste para anúncios premiados
      return 'ca-app-pub-3940256099942544/5224355225';
    }
    // ID real para anúncios premiados (hardcoded por enquanto)
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  }

  /// Carrega um anúncio premiado
  Future<void> loadRewardedAd() async {
    try {
      state = state.copyWith(isRewardedAdLoading: true, errorMessage: null);

      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            state = state.copyWith(rewardedAd: ad, isRewardedAdLoading: false);
            LoggerService.instance.i('Anúncio premiado carregado com sucesso');
          },
          onAdFailedToLoad: (LoadAdError error) {
            state = state.copyWith(
              isRewardedAdLoading: false,
              errorMessage: 'Falha ao carregar anúncio: ${error.message}',
            );
            LoggerService.instance.e('Falha ao carregar anúncio premiado', error: error);
          },
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isRewardedAdLoading: false,
        errorMessage: 'Erro inesperado ao carregar anúncio',
      );
      LoggerService.instance.e('Erro inesperado ao carregar anúncio premiado', error: e);
    }
  }

  /// Mostra um anúncio premiado
  Future<bool> showRewardedAd({
    required Function() onUserEarnedReward,
    required Function() onAdDismissed,
  }) async {
    try {
      if (state.rewardedAd == null) {
        LoggerService.instance.w('Tentando mostrar anúncio premiado, mas não há anúncio carregado');
        await loadRewardedAd();
        return false;
      }

      state.rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          LoggerService.instance.i('Anúncio premiado mostrado');
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          state = state.copyWith(rewardedAd: null);
          onAdDismissed();
          LoggerService.instance.i('Anúncio premiado fechado');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          state = state.copyWith(rewardedAd: null, errorMessage: 'Falha ao mostrar anúncio');
          LoggerService.instance.e('Falha ao mostrar anúncio premiado', error: error);
        },
      );

      await state.rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onUserEarnedReward();
          LoggerService.instance.i('Recompensa concedida: ${reward.amount} ${reward.type}');
        },
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        rewardedAd: null,
        errorMessage: 'Erro ao mostrar anúncio premiado',
      );
      LoggerService.instance.e('Erro ao mostrar anúncio premiado', error: e);
      return false;
    }
  }

  /// Verifica se há um anúncio premiado disponível
  bool get hasRewardedAd => state.rewardedAd != null;

  /// Limpa erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Descarta recursos
  @override
  void dispose() {
    state.rewardedAd?.dispose();
    super.dispose();
  }
}
