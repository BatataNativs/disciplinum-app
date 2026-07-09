import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';

/// Serviço de gerenciamento de consentimento de anúncios (UMP SDK)
/// Gerencia o fluxo de consentimento GDPR/CCPA e persiste a escolha do usuário
class ConsentService {
  static const String _consentStatusKey = 'ump_consent_status';
  static const String _personalizedAdsKey = 'personalized_ads_enabled';
  static const String _customDialogShownKey = 'custom_dialog_shown';

  static ConsentService? _instance;
  static ConsentService get instance {
    _instance ??= ConsentService._internal();
    return _instance!;
  }

  late final ObjectBoxPreferencesRepository _prefs;
  ConsentInformation? _consentInformation;
  bool _isInitialized = false;

  ConsentService._internal() {
    _prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
  }

  /// Inicializa o UMP SDK e carrega informações de consentimento
  Future<void> initialize() async {
    if (_isInitialized) {
      LoggerService.instance.d('ConsentService já inicializado');
      return;
    }

    try {
      LoggerService.instance.i('Inicializando UMP SDK...');

      _consentInformation = ConsentInformation.instance;

      // Parâmetros de debug para testes (apenas em debug mode)
      final debugSettings = kDebugMode
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
            )
          : null;

      final params = ConsentRequestParameters(
        consentDebugSettings: debugSettings,
      );

      // Carrega informações de consentimento do servidor
      _consentInformation!.requestConsentInfoUpdate(
        params,
        () async {
          LoggerService.instance
              .i('Informações de consentimento atualizadas com sucesso');
          _isInitialized = true;
        },
        (FormError error) {
          LoggerService.instance.e(
              'Erro ao atualizar informações de consentimento: ${error.message}');
          
          // Handle publisher misconfiguration gracefully (common with test IDs)
          if (error.message.contains('Publisher misconfiguration') || 
              error.message.contains('no form(s) configured')) {
            LoggerService.instance.w('Tratando erro de configuração do editor graciosamente (modo debug/teste)');
            _isInitialized = true; // Permite que o app continue funcionando
          } else {
            _isInitialized = false;
          }
        },
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar UMP SDK', error: e);
      _isInitialized = false;
    }
  }

  /// Verifica se o consentimento é necessário
  Future<bool> isConsentRequired() async {
    if (!_isInitialized || _consentInformation == null) {
      LoggerService.instance.w('ConsentService não inicializado');
      return false;
    }

    try {
      final isRequired = await _consentInformation!.isConsentFormAvailable();
      LoggerService.instance.d('Consent form required: $isRequired');
      return isRequired;
    } catch (e) {
      LoggerService.instance
          .e('Erro ao verificar se consentimento é necessário', error: e);
      return false;
    }
  }

  /// Mostra o formulário de consentimento
  Future<void> showConsentForm() async {
    if (!_isInitialized || _consentInformation == null) {
      LoggerService.instance.w('ConsentService não inicializado');
      return;
    }

    try {
      LoggerService.instance.i('Mostrando formulário de consentimento...');

      ConsentForm.loadConsentForm(
        (ConsentForm consentForm) async {
          final status = await _consentInformation!.getConsentStatus();

          if (status == ConsentStatus.required ||
              status == ConsentStatus.unknown) {
            consentForm.show(
              (FormError? formError) {
                if (formError != null) {
                  LoggerService.instance
                      .e('Erro ao mostrar formulário: ${formError.message}');
                }
                LoggerService.instance.i('Formulário de consentimento fechado');
                _saveConsentStatus();
                _updatePersonalizedAdsSetting();
              },
            );
          } else {
            LoggerService.instance
                .i('Consentimento não é necessário ou já foi obtido');
            _saveConsentStatus();
            _updatePersonalizedAdsSetting();
          }
        },
        (FormError formError) {
          LoggerService.instance
              .e('Erro ao carregar formulário: ${formError.message}');
        },
      );
    } catch (e) {
      LoggerService.instance
          .e('Erro ao mostrar formulário de consentimento', error: e);
    }
  }

  /// Mostra opções de privacidade (para permitir que o usuário altere o consentimento)
  Future<void> showPrivacyOptions() async {
    if (!_isInitialized || _consentInformation == null) {
      LoggerService.instance.w('ConsentService não inicializado');
      return;
    }

    try {
      LoggerService.instance.i('Mostrando opções de privacidade...');

      ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
        if (error != null) {
          LoggerService.instance
              .e('Erro ao mostrar opções de privacidade: ${error.message}');
        } else {
          LoggerService.instance
              .i('Opções de privacidade mostradas com sucesso');
          _saveConsentStatus();
          _updatePersonalizedAdsSetting();
        }
      });
    } catch (e) {
      LoggerService.instance
          .e('Erro ao mostrar opções de privacidade', error: e);
    }
  }

  /// Verifica se anúncios personalizados estão habilitados
  Future<bool> arePersonalizedAdsEnabled() async {
    final enabled =
        await _prefs.getBool(_personalizedAdsKey) ?? true; // Default: true
    LoggerService.instance.d('Anúncios personalizados: $enabled');
    return enabled;
  }

  /// Define se anúncios personalizados estão habilitados
  Future<void> setPersonalizedAdsEnabled(bool enabled) async {
    LoggerService.instance.i('Definindo anúncios personalizados: $enabled');
    await _prefs.setBool(_personalizedAdsKey, enabled);

    // Nota: O UMP SDK não permite alterar o consentimento programaticamente
    // Para alterar o consentimento real, o usuário deve usar as opções de privacidade
    LoggerService.instance.i(
        'Preferência salva. Para alterar consentimento real, use showPrivacyOptions()');
  }

  /// Verifica se o usuário já respondeu ao consentimento
  Future<bool> hasUserRespondedToConsent() async {
    final status = await _prefs.getString(_consentStatusKey);
    final customShown = await _prefs.getBool(_customDialogShownKey);
    return status != null || customShown == true;
  }

  /// Marca que o usuário interagiu com o dialog customizado
  Future<void> markUserRespondedToConsent() async {
    await _prefs.setBool(_customDialogShownKey, true);
  }

  /// Salva o estado do consentimento
  Future<void> _saveConsentStatus() async {
    try {
      final canShowAds = await _canShowAds();
      await _prefs.setBool(_consentStatusKey, canShowAds);
      LoggerService.instance.i('Estado do consentimento salvo: $canShowAds');
    } catch (e) {
      LoggerService.instance
          .e('Erro ao salvar estado do consentimento', error: e);
    }
  }

  /// Atualiza configuração de anúncios personalizados baseado no consentimento
  Future<void> _updatePersonalizedAdsSetting() async {
    try {
      final canShowPersonalizedAds = await _canShowPersonalizedAds();
      await _prefs.setBool(_personalizedAdsKey, canShowPersonalizedAds);
      LoggerService.instance
          .i('Anúncios personalizados atualizados: $canShowPersonalizedAds');
    } catch (e) {
      LoggerService.instance
          .e('Erro ao atualizar anúncios personalizados', error: e);
    }
  }

  /// Verifica se pode mostrar anúncios
  Future<bool> _canShowAds() async {
    if (!_isInitialized || _consentInformation == null) {
      return true; // Default: pode mostrar
    }

    try {
      final canShowAds = await _consentInformation!.canRequestAds();
      LoggerService.instance.d('Pode mostrar anúncios: $canShowAds');
      return canShowAds;
    } catch (e) {
      LoggerService.instance
          .e('Erro ao verificar se pode mostrar anúncios', error: e);
      return true;
    }
  }

  /// Verifica se pode mostrar anúncios personalizados
  Future<bool> _canShowPersonalizedAds() async {
    if (!_isInitialized || _consentInformation == null) {
      return true; // Default: pode mostrar personalizados
    }

    try {
      // Verifica o status de consentimento
      final status = await _consentInformation!.getConsentStatus();

      // Se o usuário consentiu ou não está na região GDPR, pode mostrar personalizados
      final canShowPersonalized = status == ConsentStatus.obtained ||
          status == ConsentStatus.notRequired;

      LoggerService.instance.d(
          'Pode mostrar anúncios personalizados: $canShowPersonalized (status: $status)');
      return canShowPersonalized;
    } catch (e) {
      LoggerService.instance
          .e('Erro ao verificar anúncios personalizados', error: e);
      return true;
    }
  }

  /// Reseta o consentimento (apenas para testes/debug)
  Future<void> resetConsent() async {
    if (!kDebugMode) {
      LoggerService.instance
          .w('resetConsent só deve ser chamado em debug mode');
      return;
    }

    try {
      await _prefs.remove(_consentStatusKey);
      await _prefs.remove(_personalizedAdsKey);
      LoggerService.instance.i('Consentimento resetado (debug mode)');
    } catch (e) {
      LoggerService.instance.e('Erro ao resetar consentimento', error: e);
    }
  }
}
