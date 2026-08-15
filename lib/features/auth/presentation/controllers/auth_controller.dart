import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_credentials.dart';
import 'package:disciplinum/features/auth/domain/entities/auth_state.dart';
import 'package:disciplinum/features/auth/domain/entities/user.dart' as auth;
import 'package:disciplinum/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final LoggerService _logger;
  StreamSubscription<auth.User?>? _userChangesSubscription;

  AuthController({
    required AuthRepository repository,
    required LoggerService logger,
  })  : _repository = repository,
        _logger = logger,
        super(const AuthState()) {
    _initializeAuthState();
  }

  auth.User? get currentUser => state.currentUser;
  Map<String, dynamic>? get userProfile => state.userProfile;
  bool get isLoading => state.isLoading;
  bool get isPasswordRecovery => state.isPasswordRecovery;
  bool get isSocialLoginInProgress => state.isSocialLoginInProgress;
  String? get errorMessage => state.errorMessage;
  bool get hasError => state.errorMessage != null;
  bool get isAuthenticated => state.isAuthenticated;

  bool get isProfileComplete {
    final user = currentUser;
    if (user == null) return false;
    return user.name != null && user.name!.isNotEmpty && user.email.isNotEmpty;
  }

  String get displayName {
    final user = currentUser;
    if (user?.name != null && user!.name!.isNotEmpty) {
      return user.name!;
    }
    if (user?.email != null) {
      return user!.email.split('@').first;
    }
    return 'Usuario';
  }

  bool get isFirstLogin {
    final createdAt = currentUser?.createdAt;
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt).inMinutes < 5;
  }

  Future<bool> login(String email, String password) =>
      signInWithEmail(email: email, password: password);

  Future<bool> signup(String email, String password, String name) =>
      signUpWithEmail(email: email, password: password, name: name);

  Future<bool> loginWithGoogle() => signInWithSocial(AuthType.google);

  Future<bool> loginWithApple() => signInWithSocial(AuthType.apple);

  Future<void> logout() => signOut();

  Future<void> loadUserProfile() => refreshUser();

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credentials =
          AuthCredentials.forSignin(email: email, password: password);
      final result = await _repository.signIn(credentials);

      if (result.isSuccess) {
        state = result.user == null
            ? const AuthState()
            : state.copyWith(currentUser: result.user);
        return true;
      }

      _setError(result.errorMessage ?? 'Erro desconhecido');
      return false;
    } catch (e) {
      _logger.e('AuthController: Erro inesperado no login', error: e);
      _setError('Erro ao fazer login');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credentials = AuthCredentials.forSignup(
        email: email,
        password: password,
        name: name,
      );
      final result = await _repository.signUp(credentials);

      if (result.isSuccess) {
        state = result.user == null
            ? const AuthState()
            : state.copyWith(currentUser: result.user);
        return true;
      }

      _setError(result.errorMessage ?? 'Erro desconhecido');
      return false;
    } catch (e) {
      _logger.e('AuthController: Erro inesperado no cadastro', error: e);
      _setError('Erro ao fazer cadastro');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithSocial(AuthType authType) async {
    try {
      _setLoading(true);
      _clearError();
      state = state.copyWith(isSocialLoginInProgress: true);

      final credentials = AuthCredentials.forSocial(
        email: '',
        authType: authType,
      );
      final result = await _repository.signInWithSocial(credentials);

      if (result.isSuccess) {
        state = result.user == null
            ? const AuthState()
            : state.copyWith(currentUser: result.user);
        return true;
      }

      _setError(result.errorMessage ?? 'Erro desconhecido');
      return false;
    } catch (e) {
      _logger.e('AuthController: Erro inesperado no login social', error: e);
      _setError('Erro ao fazer login social');
      return false;
    } finally {
      state = state.copyWith(isSocialLoginInProgress: false);
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      await _repository.signOut();
      state = const AuthState();
    } catch (e) {
      _logger.e('AuthController: Erro no logout', error: e);
      _setError('Erro ao fazer logout');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      await _repository.resetPassword(email);
      return true;
    } catch (e) {
      _logger.e('AuthController: Erro ao enviar reset', error: e);
      _setError('Erro ao enviar email de recuperacao');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _clearError();
      await _repository.updatePassword(newPassword);
      await refreshUser();
      return true;
    } catch (e) {
      _logger.e('AuthController: Erro ao atualizar senha', error: e);
      _setError('Erro ao atualizar senha');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? avatarUrl,
    String? bio,
    bool? showAvatar,
    bool? showEmail,
  }) async {
    final user = currentUser;
    if (user == null) {
      _setError('Usuario nao logado');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final updatedUser = await _repository.updateProfile(
        user.id,
        name: name,
        avatarUrl: avatarUrl,
        bio: bio,
        showAvatar: showAvatar,
        showEmail: showEmail,
      );

      state = state.copyWith(currentUser: updatedUser);
      return true;
    } catch (e) {
      _logger.e('AuthController: Erro ao atualizar perfil', error: e);
      _setError('Erro ao atualizar perfil');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();
      await _repository.resendEmailVerification();
      return true;
    } catch (e) {
      _logger.e('AuthController: Erro ao reenviar verificacao', error: e);
      _setError('Erro ao reenviar verificacao');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void togglePasswordRecovery() {
    state = state.copyWith(isPasswordRecovery: !state.isPasswordRecovery);
    _clearError();
  }

  void clearError() {
    _clearError();
  }

  Future<String?> getAccessToken() async {
    try {
      return await _repository.getAccessToken();
    } catch (e) {
      _logger.e('AuthController: Erro ao obter access token', error: e);
      return null;
    }
  }

  Future<bool> isEmailVerified() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      return await _repository.isEmailVerified(user.id);
    } catch (e) {
      _logger.e('AuthController: Erro ao verificar email', error: e);
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      _setLoading(true);
      _clearError();
      final user = await _repository.getCurrentUser();
      state =
          user == null ? const AuthState() : state.copyWith(currentUser: user);
    } catch (e) {
      _logger.e('AuthController: Erro ao carregar usuario', error: e);
      _setError('Erro ao carregar usuario');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    final user = currentUser;
    if (user == null) {
      _setError('Usuário não logado');
      return false; // ✅ Retorna false se não houver usuário
    }

    try {
      await _repository.deleteAccount(user.id);
      state = const AuthState(); // Limpa o estado do usuário
      return true; // ✅ Retorna true se a exclusão for bem-sucedida
    } catch (e) {
      _logger.e('AuthController: Erro ao excluir conta', error: e);
      _setError(
          'Erro ao excluir conta: ${e.toString()}'); // ✅ Atualiza o estado de erro
      return false; // ✅ Retorna false se falhar
    }
  }

  void _initializeAuthState() {
    _loadCurrentUser();
    _userChangesSubscription = _repository.userChanges.listen((user) {
      state =
          user == null ? const AuthState() : state.copyWith(currentUser: user);
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      _setLoading(true);
      _clearError();
      final user = await _repository.getCurrentUser();
      state =
          user == null ? const AuthState() : state.copyWith(currentUser: user);
    } catch (e) {
      _logger.e('AuthController: Erro ao carregar usuario', error: e);
      _setError('Erro ao carregar usuario');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (state.isLoading != loading) {
      state = state.copyWith(isLoading: loading);
    }
  }

  void _setError(String error) {
    state = state.copyWith(errorMessage: error);
  }

  void _clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  @override
  void dispose() {
    _userChangesSubscription?.cancel();
    super.dispose();
  }
}
