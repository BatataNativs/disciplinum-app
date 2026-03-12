// import 'dart:io'; // Comentado para uso futuro
import 'package:flutter/foundation.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:flutter/material.dart';
// Se você usa shared_preferences para consentimento em outros lugares, mantenha o import.
// Caso contrário, pode remover se não for usar aqui.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:disciplinum/config/app_config.dart';

class AdService with ChangeNotifier {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  // Se você tiver Intersticiais ou Anúncios Premiados globais, eles ficariam aqui.
  // Como movemos o banner de configurações para ser gerenciado localmente pelo widget,
  // não precisamos mais manter variáveis de banner aqui para evitar conflitos de árvore de widgets.

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
    return AppConfig.admobBannerUnitId;
  }

  /// Helper para obter o ID do rewarded ad
  String get rewardedAdUnitId {
    return AppConfig.admobRewardedUnitId;
  }

  // --- Rewarded Ads ---

  /// Pré-carrega um anúncio premiado
  void loadRewardedAd() {
    if (_rewardedAd != null || _isRewardedAdLoading) return;

    _isRewardedAdLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          LoggerService.instance.d('RewardedAd carregado com sucesso.');
          _rewardedAd = ad;
          _isRewardedAdLoading = false;

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd(); // Já pré-carrega o próximo
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              LoggerService.instance.e('Falha ao exibir RewardedAd', error: error);
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          LoggerService.instance.e('Falha ao carregar RewardedAd', error: error);
          _rewardedAd = null;
          _isRewardedAdLoading = false;
        },
      ),
    );
  }

  /// Exibe um anúncio premiado e chama o callback de sucesso
  void showRewardedAd({
    required VoidCallback onUserEarnedReward,
    required VoidCallback onAdDismissed,
  }) {
    if (_rewardedAd == null) {
      LoggerService.instance.w('Tentou exibir, mas o anúncio ainda não carregou.');
      // Opcional: tentar carregar aqui e mostrar um loading na UI
      onAdDismissed();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        LoggerService.instance.d(
            'Usuário ganhou recompensa: ${reward.amount} ${reward.type}');
        onUserEarnedReward();
      },
    );

    // Substitui o callback de fechar só para essa exibição
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed(); // Avisa a UI que fechou
        loadRewardedAd(); // Pré-carrega o próximo
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        LoggerService.instance.e('Falha ao exibir RewardedAd', error: error);
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed();
        loadRewardedAd();
      },
    );
  }

  /// Helper para verificar consentimento (se quiser reutilizar lógica)
  Future<bool> getConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('user_consent_given') ?? false;
  }

  // NENHUM banner sendo segurado aqui como variável global/singleton.
  // Isso previne 100% o erro "AdWidget is already in the Widget tree"
  // para banners de navegação (como Settings).
}
