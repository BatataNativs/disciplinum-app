import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/config/app_config.dart'; // Importe para pegar o ID do anúncio

class SettingsBannerAd extends StatefulWidget {
  const SettingsBannerAd({super.key});

  @override
  State<SettingsBannerAd> createState() => _SettingsBannerAdState();
}

class _SettingsBannerAdState extends State<SettingsBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carrega o anúncio se ainda não estiver carregado e o usuário não for AdFree
    final iap = Provider.of<IapService>(context, listen: false);
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
          debugPrint('Settings Banner loaded locally.');
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Settings Banner failed to load: $error');
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
    final iap = Provider.of<IapService>(context);

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
