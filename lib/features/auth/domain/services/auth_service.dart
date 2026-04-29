import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/preferences_service.dart';

/// Estado do serviço de autenticação
class AuthState {
  final User? currentUser;
  final Map<String, dynamic>? userProfile;
  final bool isLoading;
  final bool isPasswordRecovery;
  final bool isSocialLoginInProgress;
  final String? errorMessage;

  const AuthState({
    this.currentUser,
    this.userProfile,
    this.isLoading = false,
    this.isPasswordRecovery = false,
    this.isSocialLoginInProgress = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? currentUser,
    Map<String, dynamic>? userProfile,
    bool? isLoading,
    bool? isPasswordRecovery,
    bool? isSocialLoginInProgress,
    String? errorMessage,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      isPasswordRecovery: isPasswordRecovery ?? this.isPasswordRecovery,
      isSocialLoginInProgress: isSocialLoginInProgress ?? this.isSocialLoginInProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Getter para compatibilidade
  bool get isAuthenticated => currentUser != null;
}

/// Serviço de autenticação - VERSÃO RIVERPOD
/// Service puro sem ChangeNotifier - estado gerenciado pelo controller
class AuthService extends StateNotifier<AuthState> {
  final PreferencesService _prefs;
  final supabase = Supabase.instance.client;

  AuthService(this._prefs, _) : super(const AuthState()) {
    _initializeAuth();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      LoggerService.instance.i('🔐 Supabase Auth Event: ${event.name}, userId=${session?.user.id}, currentStateUserId=${state.currentUser?.id}');
      
      if (session?.user != null) {
        if (state.currentUser?.id != session!.user.id) {
          LoggerService.instance.i('🔐 Novo usuário detectado no auth state change, configurando sessão...');
          await _handleUserSession(session.user);
          LoggerService.instance.i('🔐 Sessão configurada com sucesso para: ${session.user.id}');
        } else {
          LoggerService.instance.d('🔐 Usuário já está no estado atual, ignorando evento');
        }
      } else {
        if (state.currentUser != null) {
          LoggerService.instance.i('🔐 Sessão encerrada, limpando estado');
          state = const AuthState();
        }
      }
    });
  }

  // Getters para compatibilidade
  User? get currentUser => state.currentUser;
  Map<String, dynamic>? get userProfile => state.userProfile;
  bool get isLoading => state.isLoading;
  bool get isPasswordRecovery => state.isPasswordRecovery;
  bool get isSocialLoginInProgress => state.isSocialLoginInProgress;
  String? get errorMessage => state.errorMessage;

  // Getters adicionais para compatibilidade
  bool get isEmailUser => currentUser?.appMetadata['provider'] == 'email';

  // Métodos de compatibilidade
  Future<bool> login(String email, String password) => signInWithEmail(email, password);
  Future<bool> signup(String email, String password, String name) => signUpWithEmail(email, password, name);
  Future<bool> loginWithGoogle() => signInWithOAuth(OAuthProvider.google);
  Future<void> logout() => signOut();
  Future<bool> updatePassword(String newPassword) => updateProfile({'password': newPassword});
  Future<bool> deleteAccount() async {
    try {
      await supabase.rpc('delete_user', params: {'user_id': currentUser?.id});
      await signOut();
      return true;
    } catch (e) {
      LoggerService.instance.e('Erro ao deletar conta', error: e);
      return false;
    }
  }

  /// Carrega perfil do usuário (compatibilidade)
  Future<void> loadUserProfile() async {
    if (currentUser != null) {
      await _handleUserSession(currentUser!);
    }
  }

  /// Inicializa a autenticação
  Future<void> _initializeAuth() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        await _handleUserSession(currentUser);
      }
      
      LoggerService.instance.i('AuthService inicializado - Usuário: ${currentUser?.email}');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar AuthService', error: e);
      state = state.copyWith(errorMessage: 'Erro ao inicializar autenticação');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Login com email e senha
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _handleUserSession(response.user!);
        LoggerService.instance.i('Login realizado com sucesso: $email');
        return true;
      }
      
      state = state.copyWith(errorMessage: 'Falha no login');
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      LoggerService.instance.e('Erro no login', error: e);
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado no login');
      LoggerService.instance.e('Erro inesperado no login', error: e);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Registro de novo usuário
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        await _handleUserSession(response.user!);
        LoggerService.instance.i('Registro realizado com sucesso: $email');
        return true;
      }
      
      state = state.copyWith(errorMessage: 'Falha no registro');
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      LoggerService.instance.e('Erro no registro', error: e);
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado no registro');
      LoggerService.instance.e('Erro inesperado no registro', error: e);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Login social (Google, Apple, etc.)
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      LoggerService.instance.i('🔐 OAuth START: provider=${provider.name}');
      state = state.copyWith(isSocialLoginInProgress: true, errorMessage: null);

      final success = await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.disciplinum://callback',
      );

      LoggerService.instance.i('🔐 OAuth signInWithOAuth retornou: success=$success');

      if (success) {
        final user = supabase.auth.currentUser;
        LoggerService.instance.i('🔐 OAuth success=true, currentUser=${user?.id}');
        if (user != null) {
          await _handleUserSession(user);
        } else {
          LoggerService.instance.w('🔐 OAuth success=true mas currentUser=null (aguardando callback...)');
        }
        LoggerService.instance.i('🔐 OAuth retornando true (callback será processado pelo stream)');
        return true;
      }
      
      state = state.copyWith(errorMessage: 'Falha no login social');
      LoggerService.instance.w('🔐 OAuth falhou (success=false)');
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      LoggerService.instance.e('🔐 OAuth AuthException', error: e);
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado no login social');
      LoggerService.instance.e('🔐 OAuth erro inesperado', error: e);
      return false;
    } finally {
      state = state.copyWith(isSocialLoginInProgress: false);
      LoggerService.instance.d('🔐 OAuth finally: isSocialLoginInProgress=false');
    }
  }

  /// Recuperação de senha
  Future<bool> resetPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await supabase.auth.resetPasswordForEmail(email);
      
      LoggerService.instance.i('Email de recuperação enviado: $email');
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      LoggerService.instance.e('Erro na recuperação de senha', error: e);
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado na recuperação');
      LoggerService.instance.e('Erro inesperado na recuperação', error: e);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      
      await supabase.auth.signOut();
      await _prefs.clearAll();
      
      state = const AuthState();
      LoggerService.instance.i('Logout realizado com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro no logout', error: e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Atualiza perfil do usuário
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final response = await supabase.auth.updateUser(
        UserAttributes(data: data),
      );

      if (response.user != null) {
        await _handleUserSession(response.user!);
        LoggerService.instance.i('Perfil atualizado com sucesso');
        return true;
      }
      
      state = state.copyWith(errorMessage: 'Falha ao atualizar perfil');
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      LoggerService.instance.e('Erro ao atualizar perfil', error: e);
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado ao atualizar perfil');
      LoggerService.instance.e('Erro inesperado ao atualizar perfil', error: e);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Manipula sessão do usuário
  Future<void> _handleUserSession(User user) async {
    try {
      // Carrega perfil do usuário antes de atualizar o estado para evitar múltiplos rebuilds
      final profile = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      state = state.copyWith(
        currentUser: user,
        userProfile: profile,
      );

      // Inicializa serviços dependentes
      await _initializeDependentServices();

      LoggerService.instance.i('Sessão do usuário configurada: ${user.email}');
    } catch (e) {
      LoggerService.instance.e('Erro ao configurar sessão do usuário', error: e);
      // Fallback: garante que pelo menos o usuário base seja setado em caso de erro no perfil
      if (state.currentUser == null) {
        state = state.copyWith(currentUser: user);
      }
    }
  }

  /// Inicializa serviços dependentes
  Future<void> _initializeDependentServices() async {
    try {
      // EventBootstrap simplificado (removido por enquanto)
      LoggerService.instance.i('EventBootstrap initialization simplificado');

      // CloudSync initialization (simplificado por enquanto)
      LoggerService.instance.i('CloudSync initialization simplificado');

      LoggerService.instance.i('Serviços dependentes inicializados');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar serviços dependentes', error: e);
    }
  }

  /// Verifica se usuário está autenticado
  bool get isAuthenticated => state.currentUser != null;
}
