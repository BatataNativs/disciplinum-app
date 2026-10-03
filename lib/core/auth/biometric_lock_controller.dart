import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/auth/biometric_auth_service.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Estado do bloqueio biométrico
class BiometricLockState {
  final bool isEnabled;
  final bool isLocked;
  final bool isInitialized;
  final bool isAuthenticating;

  const BiometricLockState({
    this.isEnabled = false,
    this.isLocked = false,
    this.isInitialized = false,
    this.isAuthenticating = false,
  });

  BiometricLockState copyWith({
    bool? isEnabled,
    bool? isLocked,
    bool? isInitialized,
    bool? isAuthenticating,
  }) {
    return BiometricLockState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLocked: isLocked ?? this.isLocked,
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }
}

/// Controller responsável pelo ciclo de vida e estado do bloqueio biométrico do aplicativo
class BiometricLockController extends StateNotifier<BiometricLockState>
    with WidgetsBindingObserver {
  final BiometricAuthService _bioService;
  final Ref _ref;

  BiometricLockController(this._bioService, this._ref)
      : super(const BiometricLockState()) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    try {
      final enabled = await _bioService.isBiometricLockEnabled();
      final authState = _ref.read(authServiceProvider);
      final hasUser = authState.currentUser?.id != null;

      // Se estiver habilitado e o usuário tiver sessão ativa,
      // inicia bloqueado para proteger os dados no cold start
      final shouldLock = enabled && hasUser;

      state = state.copyWith(
        isEnabled: enabled,
        isLocked: shouldLock,
        isInitialized: true,
      );

      LoggerService.instance.d(
        '🔐 BiometricLockController inicializado: enabled=$enabled, locked=$shouldLock',
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar BiometricLockController', error: e);
      state = state.copyWith(isInitialized: true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!this.state.isEnabled) return;
    if (this.state.isAuthenticating) return; // Evita loop durante o diálogo do sistema

    final authState = _ref.read(authServiceProvider);
    final hasUser = authState.currentUser?.id != null;
    if (!hasUser) return;

    if (state == AppLifecycleState.paused) {
      LoggerService.instance.d('🔐 App em segundo plano. Bloqueando por biometria...');
      this.state = this.state.copyWith(isLocked: true);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    await _bioService.setBiometricLockEnabled(enabled);
    state = state.copyWith(
      isEnabled: enabled,
      isLocked: false,
    );
  }

  void setAuthenticating(bool authenticating) {
    state = state.copyWith(isAuthenticating: authenticating);
  }

  void unlock() {
    LoggerService.instance.i('🔓 App desbloqueado com sucesso');
    state = state.copyWith(isLocked: false);
  }

  void lock() {
    if (state.isEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
