import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/config/app_config.dart';

class SettingsBannerAd extends ConsumerStatefulWidget {
  const SettingsBannerAd({super.key});

  @override
  ConsumerState<SettingsBannerAd> createState() => _SettingsBannerAdState();
}

class _SettingsBannerAdState extends ConsumerState<SettingsBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carrega o anúncio se ainda não estiver carregado e o usuário não for AdFree
    final iap = ref.read(iapServiceProvider);
    if (!iap.isAdFree && _bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    final adUnitId =
        AppConfig.admobBannerUnitId; // Use seu ID de teste ou produção aqui

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          LoggerService.instance.d('Settings Banner loaded locally.');
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          LoggerService.instance.e('Settings Banner failed to load', error: error);
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    // Isso é o mais importante: descarta o anúncio quando o widget sai da tela
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iap = ref.watch(iapServiceProvider);

    if (iap.isAdFree) {
      return const SizedBox.shrink();
    }

    if (_isLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Placeholder enquanto carrega
    return const SizedBox(height: 50);
  }
}
