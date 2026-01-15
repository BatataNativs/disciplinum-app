// import 'dart:io'; // Comentado para uso futuro
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Se você usa shared_preferences para consentimento em outros lugares, mantenha o import.
// Caso contrário, pode remover se não for usar aqui.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplinum/config/app_config.dart';

class AdService with ChangeNotifier {
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

  /// Helper para verificar consentimento (se quiser reutilizar lógica)
  Future<bool> getConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('user_consent_given') ?? false;
  }

  // NENHUM banner sendo segurado aqui como variável global/singleton.
  // Isso previne 100% o erro "AdWidget is already in the Widget tree"
  // para banners de navegação (como Settings).
}
