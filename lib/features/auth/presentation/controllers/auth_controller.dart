import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart' as auth;
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Controller para gerenciar estado de autenticação na UI
/// Implementa ChangeNotifier para integração com Provider
/// Substitui o AuthService legado
class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  final LoggerService _logger;

  // Estado do controller
  auth.User? _currentUser;
  bool _isLoading = false;
  bool _isPasswordRecovery = false;
  String? _errorMessage;
  AuthResult? _lastResult;

  // Stream subscription
  StreamSubscription<auth.User?>? _userChangesSubscription;

  // Getters para UI
  auth.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isPasswordRecovery => _isPasswordRecovery;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get hasError => _errorMessage != null;
  AuthResult? get lastResult => _lastResult;

  AuthController({
    required AuthRepository repository,
    required LoggerService logger,
  })  : _repository = repository,
        _logger = logger {
    _initializeAuthState();
  }

  /// Inicializa o estado de autenticação
  void _initializeAuthState() {
    _logger.i('AuthController: Inicializando estado de autenticação');
    
    // Obter usuário atual
    _loadCurrentUser();
    
    // Escutar mudanças de autenticação
    _userChangesSubscription = _repository.userChanges.listen((user) {
      _currentUser = user;
      _logger.i('AuthController: Usuário mudou: ${user?.email ?? 'null'}');
      notifyListeners();
    });
  }

  /// Carrega o usuário atual
  Future<void> _loadCurrentUser() async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _repository.getCurrentUser();
      _currentUser = user;
      
      _logger.i('AuthController: Usuário carregado: ${user?.email ?? 'null'}');
      notifyListeners();
    } catch (e) {
      _logger.e('AuthController: Erro ao carregar usuário: $e');
      _setError('Erro ao carregar usuário');
    } finally {
      _setLoading(false);
    }
  }

  /// Realiza login com email e senha
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('AuthController: Iniciando signin para: $email');
      
      final credentials = AuthCredentials.forSignin(email: email, password: password);
      final result = await _repository.signIn(credentials);
      
      _lastResult = result;
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _logger.i('AuthController: Login bem-sucedido: ${result.user?.email ?? 'null'}');
        notifyListeners();
        return true;
      } else {
        _setError(result.errorMessage ?? 'Erro desconhecido');
        _logger.e('AuthController: Login falhou: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      _logger.e('AuthController: Erro inesperado no signin: $e');
      _setError('Erro ao fazer login');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Realiza cadastro com email e senha
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('AuthController: Iniciando signup para: $email');
      
      final credentials = AuthCredentials.forSignup(
        email: email,
        password: password,
        name: name,
      );
      final result = await _repository.signUp(credentials);
      
      _lastResult = result;
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _logger.i('AuthController: Cadastro bem-sucedido: ${result.user?.email}');
        notifyListeners();
        return true;
      } else {
        _setError(result.errorMessage ?? 'Erro desconhecido');
        _logger.e('AuthController: Cadastro falhou: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      _logger.e('AuthController: Erro inesperado no signup: $e');
      _setError('Erro ao fazer cadastro');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Realiza login social
  Future<bool> signInWithSocial(AuthType authType) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('AuthController: Iniciando login social: ${authType.name}');
      
      final credentials = AuthCredentials.forSocial(
        email: '', // Social auth não usa email inicialmente
        authType: authType,
      );
      final result = await _repository.signInWithSocial(credentials);
      
      _lastResult = result;
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _logger.i('AuthController: Login social bem-sucedido: ${result.user?.email}');
        notifyListeners();
        return true;
      } else {
        _setError(result.errorMessage ?? 'Erro desconhecido');
        _logger.e('AuthController: Login social falhou: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      _logger.e('AuthController: Erro inesperado no login social: $e');
      _setError('Erro ao fazer login social');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Realiza logout
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('AuthController: Iniciando signout');
      
      await _repository.signOut();
      
      _currentUser = null;
      _logger.i('AuthController: Signout realizado com sucesso');
      notifyListeners();
    } catch (e) {
      _logger.e('AuthController: Erro no signout: $e');
      _setError('Erro ao fazer logout');
    } finally {
      _setLoading(false);
    }
  }

  /// Recupera senha
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('AuthController: Enviando reset de senha para: $email');
      
      await _repository.resetPassword(email);
      
      _logger.i('AuthController: Email de reset enviado com sucesso');
      return true;
    } catch (e) {
      _logger.e('AuthController: Erro ao enviar reset: $e');
      _setError('Erro ao enviar email de recuperação');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza perfil do usuário
  Future<bool> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) {
      _setError('Usuário não logado');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('AuthController: Atualizando perfil do usuário: ${_currentUser!.id}');
      
      final updatedUser = await _repository.updateProfile(
        _currentUser!.id,
        name: name,
        avatarUrl: avatarUrl,
      );
      
      _currentUser = updatedUser;
      _logger.i('AuthController: Perfil atualizado com sucesso');
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('AuthController: Erro ao atualizar perfil: $e');
      _setError('Erro ao atualizar perfil');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reenvia verificação de email
  Future<bool> resendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('AuthController: Reenviando verificação de email');
      
      await _repository.resendEmailVerification();
      
      _logger.i('AuthController: Verificação reenviada com sucesso');
      return true;
    } catch (e) {
      _logger.e('AuthController: Erro ao reenviar verificação: $e');
      _setError('Erro ao reenviar verificação');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Alterna modo de recuperação de senha
  void togglePasswordRecovery() {
    _isPasswordRecovery = !_isPasswordRecovery;
    _clearError();
    _logger.i('AuthController: Toggle password recovery: $_isPasswordRecovery');
    notifyListeners();
  }

  /// Limpa mensagem de erro
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Obtém token de acesso
  Future<String?> getAccessToken() async {
    try {
      return await _repository.getAccessToken();
    } catch (e) {
      _logger.e('AuthController: Erro ao obter access token: $e');
      return null;
    }
  }

  /// Verifica se email está verificado
  Future<bool> isEmailVerified() async {
    if (_currentUser == null) return false;
    
    try {
      return await _repository.isEmailVerified(_currentUser!.id);
    } catch (e) {
      _logger.e('AuthController: Erro ao verificar email: $e');
      return false;
    }
  }

  /// Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Dispose para limpar recursos
  @override
  void dispose() {
    _logger.i('AuthController: Disposing resources');
    _userChangesSubscription?.cancel();
    super.dispose();
  }

  /// Refresh manual do usuário atual
  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  /// Verifica se usuário tem perfil completo
  bool get isProfileComplete {
    if (_currentUser == null) return false;
    
    return _currentUser!.name != null && _currentUser!.name!.isNotEmpty &&
           _currentUser!.email.isNotEmpty;
  }

  /// Obtém nome de exibição do usuário
  String get displayName {
    if (_currentUser?.name != null && _currentUser!.name!.isNotEmpty) {
      return _currentUser!.name!;
    }
    if (_currentUser?.email != null) {
      return _currentUser!.email.split('@').first;
    }
    return 'Usuário';
  }

  /// Exclui conta do usuário
  Future<void> deleteAccount() async {
    if (_currentUser == null) {
      _logger.e('AuthController: Usuário não logado para exclusão');
      throw Exception('Usuário não logado');
    }

    try {
      _logger.i('AuthController: Iniciando exclusão da conta: ${_currentUser!.id}');
      
      await _repository.deleteAccount(_currentUser!.id);
      
      _currentUser = null;
      _logger.i('AuthController: Conta excluída com sucesso');
      notifyListeners();
    } catch (e) {
      _logger.e('AuthController: Erro ao excluir conta: $e');
      rethrow;
    }
  }

  /// Verifica se é primeiro login
  bool get isFirstLogin {
    if (_currentUser == null) return false;
    
    // Considera primeiro login se criado há menos de 5 minutos
    final createdAt = _currentUser!.createdAt;
    if (createdAt == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    return difference.inMinutes < 5;
  }
}
