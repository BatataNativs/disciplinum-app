import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/features/auth/domain/entities/user.dart' as auth;
import 'package:disciplinum/features/auth/domain/entities/auth_credentials.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'auth_controller.dart';

/// Adapter para manter compatibilidade com o AuthService legado
/// Implementa a interface do AuthService usando o novo AuthController
/// Permite migração gradual sem breaking changes
class AuthServiceAdapter extends ChangeNotifier {
  final AuthController _authController;
  final LoggerService _logger;

  AuthServiceAdapter({
    required AuthController authController,
    required LoggerService logger,
  })  : _authController = authController,
        _logger = logger {
    // Escutar mudanças do controller
    _authController.addListener(_onAuthControllerChanged);
  }

  // Propriedades compatíveis com AuthService legado
  User? get currentUser => _convertToSupabaseUser(_authController.currentUser);
  Map<String, dynamic>? get userProfile => _convertToUserProfile(_authController.currentUser);
  bool get isLoading => _authController.isLoading;
  bool get isPasswordRecovery => _authController.isPasswordRecovery;
  bool get isSocialLoginInProgress => false; // Implementado quando necessário
  String? get errorMessage => _authController.errorMessage;

  // Métodos compatíveis com AuthService legado
  Future<void> signInWithEmail(String email, String password) async {
    await _authController.signInWithEmail(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    await _authController.signUpWithEmail(email: email, password: password, name: name);
  }

  Future<void> signInWithGoogle() async {
    await _authController.signInWithSocial(AuthType.google);
  }

  Future<void> signInWithApple() async {
    await _authController.signInWithSocial(AuthType.apple);
  }

  /// Carrega o perfil do usuário (compatibilidade com legado)
  Future<void> loadUserProfile() async {
    await _authController.refreshUser();
  }

  Future<void> signOut() async {
    await _authController.signOut();
  }

  Future<void> logout() async {
    await _authController.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authController.resetPassword(email);
  }

  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    await _authController.updateProfile(name: name, avatarUrl: avatarUrl);
  }

  Future<void> resendEmailVerification() async {
    await _authController.resendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    return await _authController.isEmailVerified();
  }

  Future<String?> getAccessToken() async {
    return await _authController.getAccessToken();
  }

  /// Exclui conta do usuário
  Future<void> deleteAccount() async {
    try {
      final user = _authController.currentUser;
      if (user == null) {
        throw Exception('Usuário não logado');
      }
      
      await _authController.deleteAccount();
    } catch (e) {
      _logger.e('AuthServiceAdapter: Erro ao excluir conta: $e');
      rethrow;
    }
  }

  // Métodos de estado compatíveis
  void setPasswordRecovery(bool value) {
    if (value != _authController.isPasswordRecovery) {
      _authController.togglePasswordRecovery();
    }
  }

  void clearError() {
    _authController.clearError();
  }

  void setLoading(bool loading) {
    // O AuthController gerencia loading internamente
    _logger.d('AuthServiceAdapter: setLoading chamado (gerenciado internamente)');
  }

  // Métodos auxiliares
  void _onAuthControllerChanged() {
    notifyListeners();
  }

  /// Converte User da nova arquitetura para Supabase User (compatibilidade)
  User? _convertToSupabaseUser(auth.User? newUser) {
    if (newUser == null) return null;

    // Criar um User compatível com Supabase
    return User(
      id: newUser.id,
      email: newUser.email,
      phone: null,
      emailConfirmedAt: newUser.isEmailVerified ? DateTime.now().toIso8601String() : null,
      createdAt: newUser.createdAt?.toIso8601String() ?? '',
      lastSignInAt: newUser.lastLoginAt?.toIso8601String() ?? '',
      userMetadata: newUser.metadata ?? {},
      appMetadata: {},
      aud: 'authenticated',
    );
  }

  /// Converte User da nova arquitetura para Map (compatibilidade)
  Map<String, dynamic>? _convertToUserProfile(auth.User? newUser) {
    if (newUser == null) return null;

    return {
      'id': newUser.id,
      'email': newUser.email,
      'name': newUser.name,
      'avatar_url': newUser.avatarUrl,
      'created_at': newUser.createdAt?.toIso8601String(),
      'last_login_at': newUser.lastLoginAt?.toIso8601String(),
      'is_email_verified': newUser.isEmailVerified,
      'metadata': newUser.metadata,
    };
  }

  /// Obtém o AuthController original (para migração gradual)
  AuthController get authController => _authController;

  /// Verifica se usuário está autenticado (compatibilidade)
  bool get isAuthenticated => _authController.isAuthenticated;

  /// Obtém nome de exibição (compatibilidade)
  String get displayName => _authController.displayName;

  /// Verifica se perfil está completo (compatibilidade)
  bool get isProfileComplete => _authController.isProfileComplete;

  /// Verifica se é primeiro login (compatibilidade)
  bool get isFirstLogin => _authController.isFirstLogin;

  /// Refresh do usuário (compatibilidade)
  Future<void> refreshUser() async {
    await _authController.refreshUser();
  }

  /// Dispose para limpar recursos
  @override
  void dispose() {
    _logger.i('AuthServiceAdapter: Disposing resources');
    _authController.removeListener(_onAuthControllerChanged);
    super.dispose();
  }

  /// Método estático para criar instância com dependências
  static AuthServiceAdapter create({
    required AuthController authController,
    required LoggerService logger,
  }) {
    return AuthServiceAdapter(
      authController: authController,
      logger: logger,
    );
  }

  /// Verifica se a migração está completa
  bool get isMigrationComplete {
    return true; // Sempre true quando usando este adapter
  }

  /// Obtém estatísticas da migração
  Map<String, dynamic> getMigrationStats() {
    return {
      'adapter_active': true,
      'auth_controller_active': true,
      'user_authenticated': _authController.isAuthenticated,
      'user_loaded': _authController.currentUser != null,
      'error_count': _authController.hasError ? 1 : 0,
      'loading': _authController.isLoading,
    };
  }
}
