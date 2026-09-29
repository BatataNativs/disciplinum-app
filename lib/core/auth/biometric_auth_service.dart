import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';

/// Serviço responsável pelo gerenciamento e verificação de autenticação biométrica local
/// (Impressão Digital, Face ID e PIN/Senha do dispositivo).
class BiometricAuthService {
  final LocalAuthentication _localAuth;
  final ObjectBoxPreferencesRepository _prefs;

  static const String _kBiometricEnabledKey = 'biometric_lock_enabled';

  BiometricAuthService({
    LocalAuthentication? localAuth,
    required ObjectBoxPreferencesRepository prefs,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _prefs = prefs;

  /// Verifica se o dispositivo possui hardware biométrico disponível e configurado
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } on PlatformException catch (e) {
      LoggerService.instance.w('Erro ao verificar disponibilidade biométrica: $e');
      return false;
    }
  }

  /// Retorna os tipos de biometria cadastrados no dispositivo
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      LoggerService.instance.w('Erro ao obter biometrias disponíveis: $e');
      return [];
    }
  }

  /// Verifica se o usuário ativou o bloqueio biométrico nas configurações do app
  Future<bool> isBiometricLockEnabled() async {
    return await _prefs.getBool(_kBiometricEnabledKey) ?? false;
  }

  /// Ativa ou desativa o bloqueio biométrico nas configurações do app
  Future<void> setBiometricLockEnabled(bool enabled) async {
    await _prefs.setBool(_kBiometricEnabledKey, enabled);
    LoggerService.instance.i('Bloqueio biométrico ${enabled ? "ativado" : "desativado"}');
  }

  /// Solicita autenticação biométrica ao usuário
  Future<bool> authenticate({
    String localizedReason = 'Confirme sua identidade para acessar o Disciplinum',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        LoggerService.instance.w('Biometria não disponível no dispositivo.');
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
      );

      LoggerService.instance.i('Resultado da autenticação biométrica: $authenticated');
      return authenticated;
    } on PlatformException catch (e) {
      LoggerService.instance.e('Erro durante a autenticação biométrica', error: e);
      return false;
    }
  }
}
